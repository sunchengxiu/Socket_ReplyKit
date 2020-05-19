//
//  RTCSocket.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <pthread.h>


#import "RongRTCBufferUtil.h"
NS_ASSUME_NONNULL_BEGIN
#define CONNECTPORT 8888
#define LOCK(lock) pthread_mutex_lock(&(lock));

#define UNLOCK(lock) pthread_mutex_lock(&(lock));;
@interface RongRTCSocket : NSObject
- (int)createSocket;
- (NSString *)ip;
@property (nonatomic, assign) int sock;
- (BOOL)connect;
- (BOOL)bind;
- (BOOL)listen;
- (void)receive;
- (void)recvData;
- (void)close;
- (void)setSendBuffer;
- (void)setRecvBuffer;
- (void)setSendingTimeout;
- (void)setRecvTimeout;
@end

NS_ASSUME_NONNULL_END
