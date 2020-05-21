//
//  RongRTCClientSocket.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RongRTCSocket.h"

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCClientSocket : RongRTCSocket

/// 创建 client socket
- (BOOL)createCliectSocket;

/// client 开始编码发给 server
/// @param sampleBuffer 要编码的 sampleBuffer
- (void)encodeBuffer:(CMSampleBufferRef)sampleBuffer;

@end

NS_ASSUME_NONNULL_END
