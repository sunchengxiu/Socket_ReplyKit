


// 软编


////
////  OtherTest.m
////  SealRTC
////
////  Created by 孙承秀 on 2020/5/7.
////  Copyright © 2020 RongCloud. All rights reserved.
////
//
//#import "OtherTest.h"
//#import <arpa/inet.h>
//#import <netdb.h>
//#import <sys/types.h>
//#import <sys/socket.h>
//#import <ifaddrs.h>
//#import "RongRTCThread.h"
//#import "RongRTCSocketHeader.h"
//#import "RongRTCVideoEncoder.h"
//@interface OtherTest(){
//    pthread_mutex_t lock;
//}
//
///**
// thread
// */
//@property(nonatomic , strong)RongRTCThread *thread;
//
///**
// video encoder
// */
//@property(nonatomic , strong)RongRTCVideoEncoder *encoder;
//@end
//@implementation OtherTest
//- (BOOL)createCliectSocket{
//    if ([self createSocket] == -1) {
//        return NO;
//    }
//    BOOL isC = [self connect];
//    [self setSendBuffer];
//    [self setSendingTimeout];
//    if (isC) {
//        self.thread = [[RongRTCThread alloc] init];
//        [self.thread run];
//        return YES;
//    } else {
//        return NO;
//    }
//}
//
//-(void)cliectSend:(CMSampleBufferRef)sampleBuffer length:(size_t)length{
//    // 发送字符串测试
//    //    char sendData[32] = "hello service";
//    //    ssize_t size_t = send(self.sock, sendData, strlen(sendData), 0);
//
//    if (@available(iOS 9.0, *)) {
//        @autoreleasepool {
//
//            // time
//            CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
//
//            // compress
//            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//            CGImageRef image = NULL;
//            // data
//            OSStatus createdImage = VTCreateCGImageFromCVPixelBuffer(imageBuffer, NULL, &image);
//            UIImage * image1 = nil;
//            if (createdImage == noErr) {
//                image1 = [UIImage imageWithCGImage:image];
//            }
//            image1 = [RongRTCBufferUtil compressImage:image1 newWidth:480];
//            NSData *data= UIImageJPEGRepresentation(image1, 0.1);
//            CFRelease(image);
//            //data length
//            NSUInteger dataLength = data.length;
//
//            // data header struct
//            DataHeader dataH;
//            memset((void *)&dataH, 0, sizeof(dataH));
//
//            // pre
//            PreHeader preH;
//            memset((void *)&preH, 0, sizeof(preH));
//            preH.pre[0] = '&';
//            preH.dataLength = dataLength;
//            preH.time = currentTime;
//
//            dataH.preH = preH;
//
//            // buffer
//            int headerlength = sizeof(dataH);
//            int totalLength = dataLength + headerlength;
//
//            // srcbuffer
//            Byte *src = (Byte *)[data bytes];
//
//            // send buffer
//            char *buffer = (char *)malloc(totalLength * sizeof(char));
//            memcpy(buffer, &dataH, headerlength);
//            memcpy(buffer + headerlength, src, dataLength);
//
//            // tosend
//            [self sendBytes:buffer length:totalLength];
//
//        }
//    }
//}
////-(void)cliectSend:(CMSampleBufferRef)sampleBuffer length:(size_t)length{
////    // 发送字符串测试
////    //    char sendData[32] = "hello service";
////    //    ssize_t size_t = send(self.sock, sendData, strlen(sendData), 0);
////
////    if (@available(iOS 9.0, *)) {
////        @autoreleasepool {
////
////            // time
////            CMTime currentTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
////
////            // compress
////            CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
////            CGImageRef image = NULL;
////            // data
////            OSStatus createdImage = VTCreateCGImageFromCVPixelBuffer(imageBuffer, NULL, &image);
////            UIImage * image1 = nil;
////            if (createdImage == noErr) {
////                image1 = [UIImage imageWithCGImage:image];
////            }
////            image1 = [RongRTCBufferUtil compressImage:image1 newWidth:480];
////            NSData *data= UIImageJPEGRepresentation(image1, 0.1);
////            CFRelease(image);
////            //data length
////            NSUInteger dataLength = data.length;
////
////            // data header struct
////            DataHeader dataH;
////            memset((void *)&dataH, 0, sizeof(dataH));
////
////            // pre
////            PreHeader preH;
////            memset((void *)&preH, 0, sizeof(preH));
////            preH.pre[0] = '&';
////            preH.dataLength = dataLength;
////            preH.time = currentTime;
////
////            dataH.preH = preH;
////
////            // buffer
////            int headerlength = sizeof(dataH);
////            int totalLength = dataLength + headerlength;
////
////            // srcbuffer
////            Byte *src = (Byte *)[data bytes];
////
////            // send buffer
////            char *buffer = (char *)malloc(totalLength * sizeof(char));
////            memcpy(buffer, &dataH, headerlength);
////            memcpy(buffer + headerlength, src, dataLength);
////
////            // tosend
////            [self sendBytes:buffer length:totalLength];
////
////        }
////    }
////}
//- (void)sendBytes:(char *)bytes length:(int )length {
//    __block char *datas = bytes;
//    __weak typeof(self)weakSelf = self;
//    [self.thread excuteTaskWithBlock:^{
//        __strong typeof(self)strongSelf = weakSelf;
//        LOCK(strongSelf->lock);
//        int hasSendLength = 0;
//        while (hasSendLength < length) {
//            // connect socket success
//            if (self.sock > 0) {
//                // send
//                int sendRes = send(strongSelf.sock, datas, length - hasSendLength, 0);
//                if (sendRes == -1 || sendRes == 0) {
//                    UNLOCK(strongSelf->lock);
//                    NSLog(@"😁😁😁😁😁send buffer error");
//                    [self close];
//                    return ;
//                }
//                hasSendLength += sendRes;
//                datas += sendRes;
//
//            } else {
//                NSLog(@"😁😁😁😁😁client socket connect error");
//                UNLOCK(strongSelf->lock);
//            }
//        }
//        UNLOCK(strongSelf->lock);
//    }];
//
//}
//
//- (NSData *)compressBuffer:(CMSampleBufferRef)sampleBuffer{
//    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
//    CGImageRef image = NULL;
//    // data
//    OSStatus createdImage = VTCreateCGImageFromCVPixelBuffer(imageBuffer, NULL, &image);
//    UIImage * image1 = nil;
//    if (createdImage == noErr) {
//        image1 = [UIImage imageWithCGImage:image];
//    }
//    image1 = [RongRTCBufferUtil compressImage:image1 newWidth:480];
//    NSData *data= UIImageJPEGRepresentation(image1, 0.1);
//    CFRelease(image);
//    return data;
//}
//
//-(void)dealloc{
//    [self.thread stop];
//    NSLog(@"😁😁😁😁😁dealoc cliect socket");
//}
//@end



// 软解

//
//  RongRTCServerSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

//#import "RongRTCServerSocket.h"
//#import <arpa/inet.h>
//#import <netdb.h>
//#import <sys/types.h>
//#import <sys/socket.h>
//#import <ifaddrs.h>
//#import <UIKit/UIKit.h>
//#import "RongRTCThread.h"
//#import "RongRTCSocketHeader.h"
//
//@interface RongRTCServerSocket()
//{
//    pthread_mutex_t lock;
//}
//@property (nonatomic, assign) int acceptSock;
//
///**
// data length
// */
//@property(nonatomic , assign)NSUInteger dataLength;
//
///**
// timeData
// */
//@property(nonatomic , strong)NSData *timeData;
///**
// thread
// */
//@property(nonatomic , strong)RongRTCThread *thread;
//@end
//@implementation RongRTCServerSocket
//
//- (BOOL)createServerSocket{
//    if ([self createSocket] == -1) {
//        return NO;
//    }
//    [self setRecvBuffer];
//    [self setRecvTimeout];
//    BOOL isB = [self bind];
//    BOOL isL = [self listen];
//    
//    if (isB && isL) {
//        self.thread = [[RongRTCThread alloc] init];
//        [self.thread run];
//        [self receive];
//        return YES;
//    } else {
//        return NO;
//    }
//}
//-(void)recvData{
//    struct sockaddr_in rest;
//    socklen_t rest_size = sizeof(struct sockaddr_in);
//    self.acceptSock = accept(self.sock, (struct sockaddr *) &rest, &rest_size);
//    while (self.acceptSock != -1) {
//        DataHeader dataH;
//        memset(&dataH, 0, sizeof(dataH));
//        
//        if (![self receveData:(char *)&dataH length:sizeof(dataH)]) {
//            continue;
//        }
//        PreHeader preH = dataH.preH;
//        char pre = preH.pre[0];
//        if (pre == '&') {
//            // rongcloud socket
//            NSUInteger dataLenght = preH.dataLength;
//            CMTime time = preH.time;
//            char *buff = (char *)malloc(sizeof(char) * dataLenght);
//            if ([self receveData:(char *)buff length:dataLenght]) {
//                NSData *data = [NSData dataWithBytes:buff length:dataLenght];
//                // recv data success
//                UIImage *image = [UIImage imageWithData:data];
//                if (image) {
//                    CVPixelBufferRef pix = [RongRTCBufferUtil CVPixelBufferRefFromUiImage:image];
//                    CMSampleBufferRef sam = [RongRTCBufferUtil sampleBufferFromPixbuffer:pix time:time];
//                    if (self.delegate && [self.delegate respondsToSelector:@selector(didProcessSampleBuffer:)]) {
//                        [self.delegate didProcessSampleBuffer:sam];
//                    }
//                } else {
//                    self.dataLength = 50000;
//                }
//            }
//        } else {
//            NSLog(@"😁😁😁😁😁pre is not &");
//            return;
//        }
//    }
//}
//- (BOOL)receveData:(char *)data length:(NSUInteger)length{
//    LOCK(lock);
//    int recvLength = 0;
//    while (recvLength < length) {
//        ssize_t res = recv(self.acceptSock, data, length - recvLength, 0);
//        if (res == -1 || res == 0) {
//            UNLOCK(lock);
//            NSLog(@"😁😁😁😁😁recv data error");
//            return NO;
//        }
//        recvLength += res;
//        data += res;
//    }
//    UNLOCK(lock);
//    return YES;
//}
//- (size_t)getCMTimeSize{
//    size_t size = sizeof(CMTime);
//    return size;
//}
//
//-(void)close{
//    int res = close(self.acceptSock);
//    NSLog(@"😁😁😁😁😁shut down server: %d",res);
//    [super close];
//}
//-(void)dealloc{
//    [self.thread stop];
//    NSLog(@"😁😁😁😁😁dealoc server socket");
//}
//@end

