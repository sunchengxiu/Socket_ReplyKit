//
//  RongRTCSocketHeader.h
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

// pre header
typedef struct {
    unsigned char pre[1];// pre
    NSUInteger dataLength; // data length
    CMTime pts;
} PreHeader;

// data header
typedef struct {
    
    PreHeader preH;
    
} DataHeader;


