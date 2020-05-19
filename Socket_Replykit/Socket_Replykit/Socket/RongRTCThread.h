//
//  RongRTCThread.h
//  test
//
//  Created by 孙承秀 on 2020/5/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^Block)(void);
@interface RongRTCThread : NSObject
- (void)excuteTaskWithBlock:(Block)block;
- (void)run;
- (void)stop;
@end

NS_ASSUME_NONNULL_END
