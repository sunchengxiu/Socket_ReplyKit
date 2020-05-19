# ios 利用 socket 传输 replykit 屏幕共享数据到主 app


我这里只讲代码，文章知识点什么的，大家自己搜索，网上太多了，比我说的好

## 1. replykit  使用

```
//
//  ViewController.m
//  Socket_Replykit
//
//  Created by 孙承秀 on 2020/5/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
@interface ViewController ()
@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    if (@available(iOS 12.0, *)) {
        self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 80)];
        self.systemBroadcastPickerView.preferredExtension = @"cn.rongcloud.sealrtc.RongRTCRP";
        self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
        self.systemBroadcastPickerView.showsMicrophoneButton = NO;
        [self.view addSubview:self.systemBroadcastPickerView];
        
    }
}


@end


```

打开一个屏幕共享就是这么容易







