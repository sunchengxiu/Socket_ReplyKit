//
//  RongRTCCodec.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>

#import "RongRTCVideoEncoderSettings.h"
#import "RongRTCCodecProtocol.h"

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCCodec : NSObject

/// 编解码配置
@property(nonatomic , strong , readonly)RongRTCVideoEncoderSettings *settings;

/// 回调队列
@property(nonatomic , strong , readonly)dispatch_queue_t callbackQueue;

/// 代理
@property(nonatomic , weak)id <RongRTCCodecProtocol> delegate;

/// 使用编解码器之前的配置
/// @param settings 配置
/// @param queue 是否在指定队列里面回调代理方法，如果不传，默认在主线程回调代理方法
- (BOOL)configWithSettings:(RongRTCVideoEncoderSettings *)settings onQueue:(dispatch_queue_t)queue;

/// 编码
/// @param sampleBuffer 编码 buffer
- (void)encode:(CMSampleBufferRef)sampleBuffer ;

/// 解码
/// @param data 需要解码的数据
-(void)decode:(NSData *)data;

@end

NS_ASSUME_NONNULL_END
