//
//  RongRTCVideoEncoder.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCVideoEncoder.h"

#import "helpers.h"

@interface RongRTCVideoEncoder(){
    VTCompressionSessionRef _compressionSession;
    int _frameTime;
    dispatch_queue_t _encodeQueue;
}
/**
 settings
 */
@property(nonatomic , strong )RongRTCVideoEncoderSettings *settings;

/**
 callback queue
 */
@property(nonatomic , strong )dispatch_queue_t callbackQueue;

- (void)sendSpsAndPPSWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)sendNaluData:(CMSampleBufferRef)sampleBuffer;
@end

void compressionOutputCallback(void *encoder,
                               void *params,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CMSampleBufferRef sampleBuffer){
    RongRTCVideoEncoder *videoEncoder = (__bridge RongRTCVideoEncoder *)encoder;
    if (status != noErr) {
        return;
    }
    if (infoFlags & kVTEncodeInfo_FrameDropped) {
        return;
    }
    BOOL isKeyFrame = NO;
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, 0);
    if (attachments != nullptr && CFArrayGetCount(attachments)) {
        CFDictionaryRef attachment = static_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(attachments, 0)) ;
        isKeyFrame = !CFDictionaryContainsKey(attachment, kCMSampleAttachmentKey_NotSync);
    }
    CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CMBlockBufferRef contiguous_buffer = nullptr;
    if (!CMBlockBufferIsRangeContiguous(block_buffer, 0, 0)) {
        status = CMBlockBufferCreateContiguous(
                                               nullptr, block_buffer, nullptr, nullptr, 0, 0, 0, &contiguous_buffer);
        if (status != noErr) {
            return;
        }
    } else {
        contiguous_buffer = block_buffer;
        CFRetain(contiguous_buffer);
        block_buffer = nullptr;
    }
    if (isKeyFrame) {
        [videoEncoder sendSpsAndPPSWithSampleBuffer:sampleBuffer];
    }
    if (contiguous_buffer) {
        CFRelease(contiguous_buffer);
    }
    [videoEncoder sendNaluData:sampleBuffer];
}

@implementation RongRTCVideoEncoder

@synthesize settings = _settings;
@synthesize callbackQueue = _callbackQueue;

- (BOOL)configWithSettings:(RongRTCVideoEncoderSettings *)settings onQueue:(nonnull dispatch_queue_t)queue{
    self.settings = settings;
    if (queue) {
        _callbackQueue = queue;
    } else {
        _callbackQueue = dispatch_get_main_queue();
    }
    _encodeQueue = dispatch_queue_create("com.rongcloud.encodeQueue", NULL);
    if ([self resetCompressionSession:settings]) {
        _frameTime = 0;
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)resetCompressionSession:(RongRTCVideoEncoderSettings *)settings {
    [self destroyCompressionSession];
    OSStatus status = VTCompressionSessionCreate(nullptr, settings.width, settings.height, kCMVideoCodecType_H264, nullptr, nullptr, nullptr, compressionOutputCallback, (__bridge void * _Nullable)(self), &_compressionSession);
    if (status != noErr) {
        return NO;
    }
    [self configureCompressionSession:settings];
    return YES;
}
- (void)configureCompressionSession:(RongRTCVideoEncoderSettings *)settings{
    if (_compressionSession) {
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, true);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, false);
        
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, 10);
        uint32_t targetBps = settings.startBitrate * 1000;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, targetBps);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, settings.maxFramerate);
        int bitRate = settings.width * settings.height * 3 * 4 * 4;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitRate);
        int bitRateLimit = settings.width * settings.height * 3 * 4;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimit);
    }
}
-(void)encode:(CMSampleBufferRef)sampleBuffer{
    CFRetain(sampleBuffer);
    dispatch_async(_encodeQueue, ^{
        CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
        CMTime pts = CMTimeMake(self->_frameTime++, 1000);
        VTEncodeInfoFlags flags;
        OSStatus res = VTCompressionSessionEncodeFrame(self->_compressionSession,
                                                       imageBuffer,
                                                       pts,
                                                       kCMTimeInvalid,
                                                       NULL, NULL, &flags);
        
        CFRelease(sampleBuffer);
        if (res != noErr) {
            NSLog(@"encode frame error:%d", (int)res);
            VTCompressionSessionInvalidate(self->_compressionSession);
            CFRelease(self->_compressionSession);
            self->_compressionSession = NULL;
            return;
        }
    });
    
}
- (void)sendSpsAndPPSWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
    const uint8_t *sps ;
    const uint8_t *pps;
    size_t spsSize ,ppsSize , spsCount,ppsCount;
    OSStatus spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sps, &spsSize, &spsCount, NULL);
    OSStatus ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pps, &ppsSize, &ppsCount, NULL);
    if (spsStatus == noErr && ppsStatus == noErr) {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1;
        
        NSMutableData *spsData = [NSMutableData dataWithCapacity:4+ spsSize];
        NSMutableData *ppsData  = [NSMutableData dataWithCapacity:4 + ppsSize];
        [spsData appendBytes:bytes length:length];
        [spsData appendBytes:sps length:spsSize];
        
        [ppsData appendBytes:bytes length:length];
        [ppsData appendBytes:pps length:ppsSize];
        if (self && self.callbackQueue) {
            dispatch_async(self.callbackQueue, ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(spsData:ppsData:)]) {
                    [self.delegate spsData:spsData ppsData:ppsData];
                }
            });
        }
    } else {
        NSLog(@"😁 sps status:%@,pps status:%@",@(spsStatus),@(ppsStatus));
    }
    
}
- (void)sendNaluData:(CMSampleBufferRef)sampleBuffer{
    size_t totalLength = 0;
    size_t lengthAtOffset=0;
    char *dataPointer;
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus status1 = CMBlockBufferGetDataPointer(blockBuffer, 0, &lengthAtOffset, &totalLength, &dataPointer);
    if (status1 != noErr) {
        NSLog(@"video encoder error, status = %d", (int)status1);
        return;
    }
    static const int h264HeaderLength = 4;
    size_t bufferOffset = 0;
    while (bufferOffset < totalLength - h264HeaderLength) {

        uint32_t naluLength = 0;
        memcpy(&naluLength, dataPointer + bufferOffset, h264HeaderLength);
        naluLength = CFSwapInt32BigToHost(naluLength);

        const char bytes[] = "\x00\x00\x00\x01";
        NSMutableData *naluData = [NSMutableData dataWithCapacity:4 + naluLength];
        [naluData appendBytes:bytes length:4];
        [naluData appendBytes:dataPointer + bufferOffset + h264HeaderLength length:naluLength];
        if (self.callbackQueue) {
            dispatch_async(self.callbackQueue, ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(naluData:)]) {
                    [self.delegate naluData:naluData];
                }
            });
        }
        bufferOffset += naluLength + h264HeaderLength;
    }
}
- (void)destroyCompressionSession{
    if (_compressionSession) {
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = nullptr;
    }
}
- (void)dealloc
{
    if (_compressionSession) {
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
}
@end
