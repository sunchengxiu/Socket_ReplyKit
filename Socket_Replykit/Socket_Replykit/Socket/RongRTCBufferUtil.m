//
//  RongRTCBufferUtil.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/8.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCBufferUtil.h"

/// 下面的这些方法，一定要记得release，有的没有在方法里面release，但是在外面release了，要不然会内存泄漏
@implementation RongRTCBufferUtil
+ (UIImage *)imageFromBuffer:(CMSampleBufferRef)buffer {
    
    CVPixelBufferRef pixelBuffer = (CVPixelBufferRef)CMSampleBufferGetImageBuffer(buffer);
    
    CIImage *ciImage = [CIImage imageWithCVPixelBuffer:pixelBuffer];
    
    CIContext *temporaryContext = [CIContext contextWithOptions:nil];
    CGImageRef videoImage = [temporaryContext createCGImage:ciImage fromRect:CGRectMake(0, 0, CVPixelBufferGetWidth(pixelBuffer), CVPixelBufferGetHeight(pixelBuffer))];
    
    UIImage *image = [UIImage imageWithCGImage:videoImage];
    CGImageRelease(videoImage);
    
    return image;
}

+ (UIImage *)compressImage:(UIImage *)image newWidth:(CGFloat)newImageWidth
{
    if (!image) return nil;
    float imageWidth = image.size.width;
    float imageHeight = image.size.height;
    float width = newImageWidth;
    float height = image.size.height/(image.size.width/width);
    float widthScale = imageWidth /width;
    float heightScale = imageHeight /height;
    UIGraphicsBeginImageContext(CGSizeMake(width, height));
    if (widthScale > heightScale) {
        [image drawInRect:CGRectMake(0, 0, imageWidth /heightScale , height)];
    }
    else {
        [image drawInRect:CGRectMake(0, 0, width , imageHeight /widthScale)];
    }
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
    
}
+(CVPixelBufferRef)CVPixelBufferRefFromUiImage:(UIImage *)img {
    
    CGSize size = img.size;
    CGImageRef image = [img CGImage];
    
    NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGImageCompatibilityKey,
                             [NSNumber numberWithBool:YES], kCVPixelBufferCGBitmapContextCompatibilityKey, nil];
    CVPixelBufferRef pxbuffer = NULL;
    CVReturn status = CVPixelBufferCreate(kCFAllocatorDefault, size.width, size.height, kCVPixelFormatType_32ARGB, (__bridge CFDictionaryRef) options, &pxbuffer);
    
    NSParameterAssert(status == kCVReturnSuccess && pxbuffer != NULL);
    
    CVPixelBufferLockBaseAddress(pxbuffer, 0);
    void *pxdata = CVPixelBufferGetBaseAddress(pxbuffer);
    NSParameterAssert(pxdata != NULL);
    
    CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef context = CGBitmapContextCreate(pxdata, size.width, size.height, 8, 4*size.width, rgbColorSpace, kCGImageAlphaPremultipliedFirst);
    NSParameterAssert(context);
    
    CGContextDrawImage(context, CGRectMake(0, 0, CGImageGetWidth(image), CGImageGetHeight(image)), image);
    
    CGColorSpaceRelease(rgbColorSpace);
    CGContextRelease(context);
    
    CVPixelBufferUnlockBaseAddress(pxbuffer, 0);
    
    return pxbuffer;
}
+ (CMSampleBufferRef)sampleBufferFromPixbuffer:(CVPixelBufferRef)pixbuffer time:(CMTime)time{
    
    CMSampleBufferRef sampleBuffer = NULL;
    
    //    //获取视频信息
    CMVideoFormatDescriptionRef videoInfo = NULL;
    OSStatus result = CMVideoFormatDescriptionCreateForImageBuffer(NULL, pixbuffer, &videoInfo);
    CMTime currentTime = time;
  
    //    CMSampleTimingInfo timing = {currentTime, currentTime, kCMTimeInvalid};
    CMSampleTimingInfo timing = {currentTime, currentTime, kCMTimeInvalid};
    result = CMSampleBufferCreateForImageBuffer(kCFAllocatorDefault,pixbuffer, true, NULL, NULL, videoInfo, &timing, &sampleBuffer);
    CFRelease(videoInfo);
    return sampleBuffer;
}

+ (size_t)getCMTimeSize{
    size_t size = sizeof(CMTime);
    return size;
}

@end
