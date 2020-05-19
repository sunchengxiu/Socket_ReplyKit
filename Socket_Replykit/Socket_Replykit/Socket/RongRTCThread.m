//
//  RongRTCThread.m
//  test
//
//  Created by 孙承秀 on 2020/5/12.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCThread.h"
@interface RongRTCNSThread : NSThread

@end
@implementation RongRTCNSThread
-(void)dealloc{
    NSLog(@"rongrtc nsthread dealoc");
}

@end
@interface RongRTCThread()

/**
 thread
 */
@property(nonatomic , strong)RongRTCNSThread *thread;

/**
 stoped
 */
@property(nonatomic , assign)BOOL stoped;

@end
@implementation RongRTCThread
-(instancetype)init{
    if (self = [super init]) {
        self.stoped = NO;
        __weak typeof(self)weakSelf = self;
        self.thread = [[RongRTCNSThread alloc] initWithBlock:^{
            NSLog(@"来了");
            [[NSRunLoop currentRunLoop] addPort:[NSPort port] forMode:NSDefaultRunLoopMode];
            while (weakSelf && !weakSelf.stoped) {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            }
            
        }];
    }
    return self;
}
- (void)excuteTaskWithBlock:(Block)block{
    if (!self.thread || !block) {
        return;
    }
    [self performSelector:@selector(_excuteTask:) onThread:self.thread withObject:block waitUntilDone:NO];
}
- (void)run{
    [self.thread start];
}
- (void)stop{
    if (!self.thread) {
        return;
    }
    [self performSelector:@selector(_stopRunloop) onThread:self.thread withObject:nil waitUntilDone:YES];
}
- (void)_stopRunloop{
    self.stoped = YES;
    CFRunLoopStop(CFRunLoopGetCurrent());
    self.thread = nil;
}
- (void)_excuteTask:(void (^)(void))block{
    block();
}
-(void)dealloc{
    NSLog(@"rongrtc thread dealoc");
    [self stop];
}
@end
