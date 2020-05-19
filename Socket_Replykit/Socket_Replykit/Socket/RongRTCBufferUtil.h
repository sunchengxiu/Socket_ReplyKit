//
//  RongRTCBufferUtil.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <VideoToolbox/VideoToolbox.h>
#import <UIKit/UIKit.h>
NS_ASSUME_NONNULL_BEGIN

@interface RongRTCBufferUtil : NSObject
+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth;
+ (size_t)getCMTimeSize;
+(CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img;
+ (CMSampleBufferRef)sampleBufferFromPixbuffer:(CVPixelBufferRef)pixbuffer timeData:(NSData *)data;
+ (CMSampleBufferRef)sampleBufferFromPixbuffer:(CVPixelBufferRef)pixbuffer time:(CMTime)time;
+ (UIImage *)imageFromBuffer:(CMSampleBufferRef)buffer;
@end

NS_ASSUME_NONNULL_END
