//
//  RongRTCVideoEncoderSettings.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface RongRTCVideoEncoderSettings : NSObject
@property(nonatomic , copy)NSString *name;
@property(nonatomic , assign)unsigned short width;
@property(nonatomic , assign)unsigned short height;
@property(nonatomic, assign) unsigned int startBitrate;
@property(nonatomic, assign) unsigned int maxBitrate;
@property(nonatomic, assign) unsigned int minBitrate;
@property(nonatomic, assign) uint32_t maxFramerate;
@end

NS_ASSUME_NONNULL_END
