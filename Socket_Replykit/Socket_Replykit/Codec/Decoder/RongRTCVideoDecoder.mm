//
//  RongRTCVideoDecoder.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/14.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCVideoDecoder.h"
#import <UIKit/UIKit.h>

#import "helpers.h"
@interface RongRTCVideoDecoder(){
    uint8_t *_sps;
    NSUInteger _spsSize;
    uint8_t *_pps;
    NSUInteger _ppsSize;
    CMVideoFormatDescriptionRef _videoFormatDescription;
    VTDecompressionSessionRef _decompressionSession;
    dispatch_queue_t _decodeQueue;
}
/**
 settings
 */
@property(nonatomic , strong )RongRTCVideoEncoderSettings *settings;

/**
 callback queue
 */
@property(nonatomic , strong )dispatch_queue_t callbackQueue;


@end
void DecoderOutputCallback(void * CM_NULLABLE decompressionOutputRefCon,
                           void * CM_NULLABLE sourceFrameRefCon,
                           OSStatus status,
                           VTDecodeInfoFlags infoFlags,
                           CM_NULLABLE CVImageBufferRef imageBuffer,
                           CMTime presentationTimeStamp,
                           CMTime presentationDuration ) {
    if (status != noErr) {
        NSLog(@"😁 decoder callback error :%@", @(status));
        return;
    }
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
    RongRTCVideoDecoder *decoder = (__bridge RongRTCVideoDecoder *)(decompressionOutputRefCon);
    if (decoder && decoder.callbackQueue) {
        dispatch_async(decoder.callbackQueue, ^{
            if (decoder.delegate && [decoder.delegate respondsToSelector:@selector(didGetDecodeBuffer:)]) {
                [decoder.delegate didGetDecodeBuffer:imageBuffer];
            }
            CVPixelBufferRelease(imageBuffer);
        });
    }
}
@implementation RongRTCVideoDecoder

@synthesize settings = _settings;
@synthesize callbackQueue = _callbackQueue;


-(BOOL)configWithSettings:(RongRTCVideoEncoderSettings *)settings onQueue:(dispatch_queue_t)queue{
    self.settings = settings;
    if (queue) {
        _callbackQueue = queue;
    } else {
        _callbackQueue = dispatch_get_main_queue();
    }
     _decodeQueue = dispatch_queue_create("com.rongcloud.encodeQueue", NULL);
    return YES;
}
- (BOOL)createVT{
    if (_decompressionSession) {
        return YES;
    }
    const uint8_t * const parameterSetPointers[2] = {_sps, _pps};
    const size_t parameterSetSizes[2] = {_spsSize, _ppsSize};
    int naluHeaderLen = 4;
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, naluHeaderLen, &_videoFormatDescription );
    if (status != noErr) {
        NSLog(@"😁😁😁😁😁CMVideoFormatDescriptionCreateFromH264ParameterSets error:%@", @(status));
        return false;
    }
    NSDictionary *destinationImageBufferAttributes =
                                        @{
                                            (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
                                            (id)kCVPixelBufferWidthKey: [NSNumber numberWithInteger:self.settings.width],
                                            (id)kCVPixelBufferHeightKey: [NSNumber numberWithInteger:self.settings.height],
                                            (id)kCVPixelBufferOpenGLCompatibilityKey: [NSNumber numberWithBool:true]
                                        };
    VTDecompressionOutputCallbackRecord CallBack;
    CallBack.decompressionOutputCallback = DecoderOutputCallback;
    CallBack.decompressionOutputRefCon = (__bridge void * _Nullable)(self);
    status = VTDecompressionSessionCreate(kCFAllocatorDefault, _videoFormatDescription, NULL, (__bridge CFDictionaryRef _Nullable)(destinationImageBufferAttributes), &CallBack, &_decompressionSession);

    if (status != noErr) {
        NSLog(@"😁😁😁😁😁VTDecompressionSessionCreate error:%@", @(status));
        return false;
    }
    status = VTSessionSetProperty(_decompressionSession, kVTDecompressionPropertyKey_RealTime,kCFBooleanTrue);
    
    return YES;
}

- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMBlockBufferFlags flag0 = 0;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, frame, frameSize, kCFAllocatorNull, NULL, 0, frameSize, flag0, &blockBuffer);
    
    if (status != kCMBlockBufferNoErr) {
        NSLog(@"😁😁😁😁😁VCMBlockBufferCreateWithMemoryBlock code=%d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    const size_t sampleSizeArray[] = {frameSize};
    
    status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _videoFormatDescription, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
    
    if (status != noErr || !sampleBuffer) {
        NSLog(@"😁😁😁😁😁CMSampleBufferCreateReady failed status=%d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    VTDecodeFrameFlags flag1 = kVTDecodeFrame_1xRealTimePlayback;
    VTDecodeInfoFlags  infoFlag = kVTDecodeInfo_Asynchronous;
    
    status = VTDecompressionSessionDecodeFrame(_decompressionSession, sampleBuffer, flag1, &outputPixelBuffer, &infoFlag);
    
    if (status == kVTInvalidSessionErr) {
        NSLog(@"😁😁😁😁😁decode frame error with session err status =%d", (int)status);
        [self resetVT];
    } else  {
        if (status != noErr) {
            NSLog(@"😁😁😁😁😁decode frame error with  status =%d", (int)status);
        }
        
    }

    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);
    
    return outputPixelBuffer;
}
- (void)resetVT{
    [self destorySession];
    [self createVT];
}
-(void)decode:(NSData *)data{
    dispatch_async(_decodeQueue, ^{
        uint8_t *frame = (uint8_t*)[data bytes];
        uint32_t length = (uint32_t)data.length;
        uint32_t nalSize = (uint32_t)(length - 4);
        uint32_t *pNalSize = (uint32_t *)frame;
        *pNalSize = CFSwapInt32HostToBig(nalSize);
        
        int type = (frame[4] & 0x1F);
        CVPixelBufferRef pixelBuffer = NULL;
        switch (type) {
            case 0x05:
                if ([self createVT]) {
                    pixelBuffer= [self decode:frame withSize:length];
                }
                break;
            case 0x07:
                self->_spsSize = length - 4;
                self->_sps = (uint8_t *)malloc(self->_spsSize);
                memcpy(self->_sps, &frame[4], self->_spsSize);
                break;
            case 0x08:
                self->_ppsSize = length - 4;
                self->_pps = (uint8_t *)malloc(self->_ppsSize);
                memcpy(self->_pps, &frame[4], self->_ppsSize);
                break;
            default:
                if ([self createVT]) {
                    pixelBuffer = [self decode:frame withSize:length];
                }
                break;
        }
    });
}

- (void)dealloc
{
    [self destorySession];
    
}
- (void)destorySession{
    if (_decompressionSession) {
        VTDecompressionSessionInvalidate(_decompressionSession);
        CFRelease(_decompressionSession);
        _decompressionSession = NULL;
    }
}
@end
