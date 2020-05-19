//
//  RongRTCServerSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCServerSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <UIKit/UIKit.h>


#import "RongRTCThread.h"
#import "RongRTCSocketHeader.h"
#import "RongRTCVideoDecoder.h"
@interface RongRTCServerSocket()<RongRTCCodecProtocol>
{
    pthread_mutex_t lock;
    int _frameTime;
    CMTime _lastPresentationTime;
    Float64 _currentMediaTime;
    Float64 _currentVideoTime;
    dispatch_queue_t _frameQueue;
}
@property (nonatomic, assign) int acceptSock;

/**
 data length
 */
@property(nonatomic , assign)NSUInteger dataLength;

/**
 timeData
 */
@property(nonatomic , strong)NSData *timeData;

/**
 decoder queue
 */
@property(nonatomic , strong)dispatch_queue_t decoderQueue;

/**
 decoder
 */
@property(nonatomic , strong)RongRTCVideoDecoder *decoder;
@end
@implementation RongRTCServerSocket

- (BOOL)createServerSocket{
    if ([self createSocket] == -1) {
        return NO;
    }
    [self setRecvBuffer];
    [self setRecvTimeout];
    BOOL isB = [self bind];
    BOOL isL = [self listen];
    
    if (isB && isL) {
        _decoderQueue = dispatch_queue_create("com.rongcloud.decoderQueue", NULL);
        _frameTime = 0;
        [self createDecoder];
        [self receive];
        return YES;
    } else {
        return NO;
    }
}
- (void)createDecoder{
    self.decoder = [[RongRTCVideoDecoder alloc] init];
    self.decoder.delegate = self;
    RongRTCVideoEncoderSettings *settings = [[RongRTCVideoEncoderSettings alloc] init];
    settings.width = 720;
    settings.height = 1280;
    settings.startBitrate = 300;
    settings.maxFramerate = 30;
    settings.minBitrate = 1000;
    [self.decoder configWithSettings:settings onQueue:_decoderQueue];
}
-(void)recvData{
    struct sockaddr_in rest;
    socklen_t rest_size = sizeof(struct sockaddr_in);
    self.acceptSock = accept(self.sock, (struct sockaddr *) &rest, &rest_size);
    while (self.acceptSock != -1) {
        DataHeader dataH;
        memset(&dataH, 0, sizeof(dataH));
        
        if (![self receveData:(char *)&dataH length:sizeof(dataH)]) {
            continue;
        }
        PreHeader preH = dataH.preH;
        char pre = preH.pre[0];
        if (pre == '&') {
            // rongcloud socket
            NSUInteger dataLenght = preH.dataLength;
            char *buff = (char *)malloc(sizeof(char) * dataLenght);
            if ([self receveData:(char *)buff length:dataLenght]) {
                NSData *data = [NSData dataWithBytes:buff length:dataLenght];
                [self.decoder decode:data];
                free(buff);
            }
        } else {
            NSLog(@"😁😁😁😁😁pre is not &");
            return;
        }
    }
}
- (BOOL)receveData:(char *)data length:(NSUInteger)length{
    LOCK(lock);
    int recvLength = 0;
    while (recvLength < length) {
        ssize_t res = recv(self.acceptSock, data, length - recvLength, 0);
        if (res == -1 || res == 0) {
            UNLOCK(lock);
            NSLog(@"😁😁😁😁😁recv data error");
            break;
        }
        recvLength += res;
        data += res;
    }
    UNLOCK(lock);
    return YES;
}

-(void)didGetDecodeBuffer:(CVPixelBufferRef)pixelBuffer {
    _frameTime += 1000;
    CMTime pts = CMTimeMake(_frameTime, 1000);
    CMSampleBufferRef sampleBuffer = [RongRTCBufferUtil sampleBufferFromPixbuffer:pixelBuffer time:pts];
    // 查看解码数据是否有问题，如果image能显示，就说明对了。
    // 通过打断点 将鼠标放在 iamge 脑袋上，就可以看到数据了，点击那个小眼睛
    UIImage *image = [RongRTCBufferUtil imageFromBuffer:sampleBuffer];
    [self.delegate didProcessSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

-(void)close{
    int res = close(self.acceptSock);
    self.acceptSock = -1;
    NSLog(@"😁😁😁😁😁shut down server: %d",res);
    [super close];
}
-(void)dealloc{
    NSLog(@"😁😁😁😁😁dealoc server socket");
}
@end
