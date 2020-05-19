//
//  RongRTCServerSocket.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCSocket.h"

NS_ASSUME_NONNULL_BEGIN

@protocol RongRTCServerSocketProtocol;

@interface RongRTCServerSocket : RongRTCSocket

/**
 delegate
 */
@property(nonatomic , weak)id <RongRTCServerSocketProtocol> delegate;

/// 创建 server socket
- (BOOL)createServerSocket;

@end


@protocol RongRTCServerSocketProtocol <NSObject>

/// 解码数据回调
/// @param sampleBuffer 解码数据
- (void)didProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer;

@end
NS_ASSUME_NONNULL_END
