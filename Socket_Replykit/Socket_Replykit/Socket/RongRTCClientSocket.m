//
//  RongRTCClientSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCClientSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import "RongRTCThread.h"
#import "RongRTCSocketHeader.h"
#import "RongRTCVideoEncoder.h"
@interface RongRTCClientSocket()<RongRTCCodecProtocol>{
    pthread_mutex_t lock;
}

/**
 video encoder
 */
@property(nonatomic , strong)RongRTCVideoEncoder *encoder;

/**
 encode queue
 */
@property(nonatomic , strong)dispatch_queue_t encodeQueue;
@end
@implementation RongRTCClientSocket
- (BOOL)createCliectSocket{
    if ([self createSocket] == -1) {
        return NO;
    }
    BOOL isC = [self connect];
    [self setSendBuffer];
    [self setSendingTimeout];
    if (isC) {
        _encodeQueue = dispatch_queue_create("com.rongcloud.encodequeue", NULL);
        [self createVideoEncoder];
        return YES;
    } else {
        return NO;
    }
}
- (void)createVideoEncoder{
    self.encoder = [[RongRTCVideoEncoder alloc] init];
    self.encoder.delegate = self;
    RongRTCVideoEncoderSettings *settings = [[RongRTCVideoEncoderSettings alloc] init];
    settings.width = 720;
    settings.height = 1280;
    settings.startBitrate = 300;
    settings.maxFramerate = 30;
    settings.minBitrate = 1000;
    [self.encoder configWithSettings:settings onQueue:_encodeQueue];
}
-(void)cliectSend:(NSData *)data{
    
    //data length
    NSUInteger dataLength = data.length;
    
    // data header struct
    DataHeader dataH;
    memset((void *)&dataH, 0, sizeof(dataH));
    
    // pre
    PreHeader preH;
    memset((void *)&preH, 0, sizeof(preH));
    preH.pre[0] = '&';
    preH.dataLength = dataLength;
    
    dataH.preH = preH;
    
    // buffer
    int headerlength = sizeof(dataH);
    int totalLength = dataLength + headerlength;
    
    // srcbuffer
    Byte *src = (Byte *)[data bytes];
    
    // send buffer
    char *buffer = (char *)malloc(totalLength * sizeof(char));
    memcpy(buffer, &dataH, headerlength);
    memcpy(buffer + headerlength, src, dataLength);
    
    // tosend
    [self sendBytes:buffer length:totalLength];
    free(buffer);
    
}
- (void)encodeBuffer:(CMSampleBufferRef)sampleBuffer{
    [self.encoder encode:sampleBuffer];
}

- (void)sendBytes:(char *)bytes length:(int )length {
    LOCK(self->lock);
    int hasSendLength = 0;
    while (hasSendLength < length) {
        // connect socket success
        if (self.sock > 0) {
            // send
            int sendRes = send(self.sock, bytes, length - hasSendLength, 0);
            if (sendRes == -1 || sendRes == 0) {
                UNLOCK(self->lock);
                NSLog(@"😁😁😁😁😁send buffer error");
                [self close];
                break;
            }
            hasSendLength += sendRes;
            bytes += sendRes;
            
        } else {
            NSLog(@"😁😁😁😁😁client socket connect error");
            UNLOCK(self->lock);
        }
    }
    UNLOCK(self->lock);
    
}
-(void)spsData:(NSData *)sps ppsData:(NSData *)pps{
    [self cliectSend:sps];
    [self cliectSend:pps];
}
-(void)naluData:(NSData *)naluData{
    [self cliectSend:naluData];
}
-(void)dealloc{
    
    NSLog(@"😁😁😁😁😁dealoc cliect socket");
}
@end
