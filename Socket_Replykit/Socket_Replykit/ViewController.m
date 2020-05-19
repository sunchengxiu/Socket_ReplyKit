//
//  ViewController.m
//  Socket_Replykit
//
//  Created by 孙承秀 on 2020/5/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "ViewController.h"
#import <ReplayKit/ReplayKit.h>
#import "RongRTCServerSocket.h"
@interface ViewController ()<RongRTCServerSocketProtocol>
@property (nonatomic, strong) RPSystemBroadcastPickerView *systemBroadcastPickerView;
/**
 server socket
 */
@property(nonatomic , strong)RongRTCServerSocket *serverSocket;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
    [self.serverSocket createServerSocket];
    self.systemBroadcastPickerView = [[RPSystemBroadcastPickerView alloc] initWithFrame:CGRectMake(0, 64, [UIScreen mainScreen].bounds.size.width, 80)];
    self.systemBroadcastPickerView.preferredExtension = @"cn.rongcloud.sealrtc.RongRTCRP";
    self.systemBroadcastPickerView.backgroundColor = [UIColor colorWithRed:53.0/255.0 green:129.0/255.0 blue:242.0/255.0 alpha:1.0];
    self.systemBroadcastPickerView.showsMicrophoneButton = NO;
    [self.view addSubview:self.systemBroadcastPickerView];
}

-(RongRTCServerSocket *)serverSocket{
    if (!_serverSocket) {
        RongRTCServerSocket *socket = [[RongRTCServerSocket alloc] init];
        socket.delegate = self;
        
        _serverSocket = socket;
    }
    return _serverSocket;
}
-(void)didProcessSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    // 这里拿到了最终的数据，比如最后可以使用融云的音视频SDK RTCLib 进行传输就可以了
}
@end
