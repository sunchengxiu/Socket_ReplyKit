# ios 利用 socket 传输 replykit 屏幕共享数据到主 app

## 先上 [demo](https://github.com/sunchengxiu/Socket_ReplyKit)


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


@end


```

打开一个屏幕共享就是这么容易,

其中，也包括了，创建 server soket 的步骤，我们把主app当做server，然后屏幕共享 extension 当做 client ，通过socket像我们主app发送数据


在extension 里面，我们拿到屏幕共享数据之后


```
//
//  SampleHandler.m
//  SocketReply
//
//  Created by 孙承秀 on 2020/5/19.
//  Copyright © 2020 RongCloud. All rights reserved.
//


#import "SampleHandler.h"
#import "RongRTCClientSocket.h"
@interface SampleHandler()

/**
 client servert
 */
@property(nonatomic , strong)RongRTCClientSocket *clientSocket;
@end
@implementation SampleHandler

- (void)broadcastStartedWithSetupInfo:(NSDictionary<NSString *,NSObject *> *)setupInfo {
    // User has requested to start the broadcast. Setup info from the UI extension can be supplied but optional.
    self.clientSocket = [[RongRTCClientSocket alloc] init];
       [self.clientSocket createCliectSocket];
}

- (void)broadcastPaused {
    // User has requested to pause the broadcast. Samples will stop being delivered.
}

- (void)broadcastResumed {
    // User has requested to resume the broadcast. Samples delivery will resume.
}

- (void)broadcastFinished {
    // User has requested to finish the broadcast.
}

- (void)processSampleBuffer:(CMSampleBufferRef)sampleBuffer withType:(RPSampleBufferType)sampleBufferType {
    
    switch (sampleBufferType) {
        case RPSampleBufferTypeVideo:
            // Handle video sample buffer
            [self sendData:sampleBuffer];
            break;
        case RPSampleBufferTypeAudioApp:
            // Handle audio sample buffer for app audio
            break;
        case RPSampleBufferTypeAudioMic:
            // Handle audio sample buffer for mic audio
            break;
            
        default:
            break;
    }
}
- (void)sendData:(CMSampleBufferRef)sampleBuffer{
     
    [self.clientSocket encodeBuffer:sampleBuffer];
 
}
@end


```


可见 ，这里我们创建了一个 client socket，然后拿到屏幕共享的视频buffer之后，通过socket发给我们的主app，这就是屏幕共享额流程


## 2. local socket 的使用

```
//
//  RongRTCSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import "RongRTCThread.h"
@interface RongRTCSocket()

/**
 rec thread
 */
@property(nonatomic , strong)RongRTCThread *recvThread;
@end
@implementation RongRTCSocket
- (int)createSocket{
    int sock = socket(AF_INET, SOCK_STREAM, 0);
    self.sock = sock;
    if (self.sock == -1) {
        close(self.sock);
        NSLog(@"😁😁😁😁😁socket error : %d",self.sock);
    }
    self.recvThread = [[RongRTCThread alloc] init];
    [self.recvThread run];
    return sock;
}
- (void)setSendBuffer{
    int optVal = 1024 * 1024 * 2;
    int optLen = sizeof(int);
    int res = setsockopt(self.sock, SOL_SOCKET,SO_SNDBUF,(char*)&optVal,optLen );
    NSLog(@"😁😁😁😁😁set send buffer:%d",res);
}
- (void)setRecvBuffer{
    int optVal = 1024 * 1024 * 2;
    int optLen = sizeof(int);
    int res = setsockopt(self.sock, SOL_SOCKET,SO_RCVBUF,(char*)&optVal,optLen );;
    NSLog(@"😁😁😁😁😁set send buffer:%d",res);
}
- (void)setSendingTimeout{
    struct timeval timeout = {10,0};
    int res = setsockopt(self.sock, SOL_SOCKET, SO_SNDTIMEO, (char *)&timeout, sizeof(int));
    NSLog(@"😁😁😁😁😁set send timeout:%d",res);
}
- (void)setRecvTimeout{
    struct timeval timeout = {10,0};
    int  res = setsockopt(self.sock, SOL_SOCKET, SO_RCVTIMEO, (char *)&timeout, sizeof(int));
    NSLog(@"😁😁😁😁😁set send timeout:%d",res);
}
- (BOOL)connect{
    NSString *serverHost = [self ip];
    struct hostent *server = gethostbyname([serverHost UTF8String]);
    if (server == NULL) {
        close(self.sock);
        NSLog(@"😁😁😁😁😁get host error");
        return NO;
    }
    
    struct in_addr *remoteAddr = (struct in_addr *)server->h_addr_list[0];
    struct sockaddr_in addr;
    addr.sin_family = AF_INET;
    addr.sin_addr = *remoteAddr;
    addr.sin_port = htons(CONNECTPORT);
    int res = connect(self.sock, (struct sockaddr *) &addr, sizeof(addr));
    if (res == -1) {
        close(self.sock);
        NSLog(@"😁😁😁😁😁connect error");
        return NO;
    }
    NSLog(@"😁😁😁😁😁socket connect to server success");
    return YES;
}
- (BOOL)bind{
    struct sockaddr_in client;
    client.sin_family = AF_INET;
    NSString *ipStr = [self ip];
    if (ipStr.length <= 0) {
        return NO;
    }
    const char *ip = [ipStr cStringUsingEncoding:NSASCIIStringEncoding];
    client.sin_addr.s_addr = inet_addr(ip);
    client.sin_port = htons(CONNECTPORT);
    int bd = bind(self.sock, (struct sockaddr *) &client, sizeof(client));
    if (bd == -1) {
        close(self.sock);
        NSLog(@"😁😁😁😁😁bind error : %d",bd);
        return NO;
    }
    return YES;
}

- (BOOL)listen{
    int ls = listen(self.sock, 128);
    if (ls == -1) {
        close(self.sock);
        NSLog(@"😁😁😁😁😁listen error : %d",ls);
        return NO;
    }
    return YES;
}
- (void)receive{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        [self recvData];
    });
}
- (NSString *)ip{
    NSString *ip = nil;
    struct ifaddrs *addrs = NULL;
    struct ifaddrs *tmpAddrs = NULL;
    BOOL res = getifaddrs(&addrs);
    if (res == 0) {
        tmpAddrs = addrs;
        while (tmpAddrs != NULL) {
            if(tmpAddrs->ifa_addr->sa_family == AF_INET) {
                // Check if interface is en0 which is the wifi connection on the iPhone
                NSLog(@"%@",[NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tmpAddrs->ifa_addr)->sin_addr)]);
                if([[NSString stringWithUTF8String:tmpAddrs->ifa_name] isEqualToString:@"en0"]) {
                    // Get NSString from C String
                    ip = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)tmpAddrs->ifa_addr)->sin_addr)];
                }
            }
            tmpAddrs = tmpAddrs->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(addrs);
    NSLog(@"😁😁😁😁😁%@",ip);
    return ip;
}
-(void)close{
    int res = close(self.sock);
    NSLog(@"😁😁😁😁😁shut down : %d",res);
}
- (void)recvData{
    
}
-(void)dealloc{
    [self.recvThread stop];
}
@end


```

我创建了一个 socket 的父类，然后 server 和 client 分别继承这个类，来实现，链接绑定等操作，可以看到有很多数据可以设置，有些可以不用，这里不是核心，核心是怎样收发数据


### 发送屏幕贡共享数据


```

//
//  RongRTCClientSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCClientSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import "RongRTCThread.h"
#import "RongRTCSocketHeader.h"
#import "RongRTCVideoEncoder.h"
@interface RongRTCClientSocket()<RongRTCCodecProtocol>{
    pthread_mutex_t lock;
}

/**
 video encoder
 */
@property(nonatomic , strong)RongRTCVideoEncoder *encoder;

/**
 encode queue
 */
@property(nonatomic , strong)dispatch_queue_t encodeQueue;
@end
@implementation RongRTCClientSocket
- (BOOL)createCliectSocket{
    if ([self createSocket] == -1) {
        return NO;
    }
    BOOL isC = [self connect];
    [self setSendBuffer];
    [self setSendingTimeout];
    if (isC) {
        _encodeQueue = dispatch_queue_create("com.rongcloud.encodequeue", NULL);
        [self createVideoEncoder];
        return YES;
    } else {
        return NO;
    }
}
- (void)createVideoEncoder{
    self.encoder = [[RongRTCVideoEncoder alloc] init];
    self.encoder.delegate = self;
    RongRTCVideoEncoderSettings *settings = [[RongRTCVideoEncoderSettings alloc] init];
    settings.width = 720;
    settings.height = 1280;
    settings.startBitrate = 300;
    settings.maxFramerate = 30;
    settings.minBitrate = 1000;
    [self.encoder configWithSettings:settings onQueue:_encodeQueue];
}
-(void)cliectSend:(NSData *)data{
    
    //data length
    NSUInteger dataLength = data.length;
    
    // data header struct
    DataHeader dataH;
    memset((void *)&dataH, 0, sizeof(dataH));
    
    // pre
    PreHeader preH;
    memset((void *)&preH, 0, sizeof(preH));
    preH.pre[0] = '&';
    preH.dataLength = dataLength;
    
    dataH.preH = preH;
    
    // buffer
    int headerlength = sizeof(dataH);
    int totalLength = dataLength + headerlength;
    
    // srcbuffer
    Byte *src = (Byte *)[data bytes];
    
    // send buffer
    char *buffer = (char *)malloc(totalLength * sizeof(char));
    memcpy(buffer, &dataH, headerlength);
    memcpy(buffer + headerlength, src, dataLength);
    
    // tosend
    [self sendBytes:buffer length:totalLength];
    free(buffer);
    
}
- (void)encodeBuffer:(CMSampleBufferRef)sampleBuffer{
    [self.encoder encode:sampleBuffer];
}

- (void)sendBytes:(char *)bytes length:(int )length {
    LOCK(self->lock);
    int hasSendLength = 0;
    while (hasSendLength < length) {
        // connect socket success
        if (self.sock > 0) {
            // send
            int sendRes = send(self.sock, bytes, length - hasSendLength, 0);
            if (sendRes == -1 || sendRes == 0) {
                UNLOCK(self->lock);
                NSLog(@"😁😁😁😁😁send buffer error");
                [self close];
                break;
            }
            hasSendLength += sendRes;
            bytes += sendRes;
            
        } else {
            NSLog(@"😁😁😁😁😁client socket connect error");
            UNLOCK(self->lock);
        }
    }
    UNLOCK(self->lock);
    
}
-(void)spsData:(NSData *)sps ppsData:(NSData *)pps{
    [self cliectSend:sps];
    [self cliectSend:pps];
}
-(void)naluData:(NSData *)naluData{
    [self cliectSend:naluData];
}
-(void)dealloc{
    
    NSLog(@"😁😁😁😁😁dealoc cliect socket");
}
@end

```

这里核心思想是拿到我们屏幕共享的数据之后，要先经过压缩，压缩完成，会通过回调，会给我们当前类，然后通过 `cliectSend `方法，发给主app，我这里是自定义了一个头部，头部添加了一个前缀和一个每次发送字节的长度，然后接收端去解析这个数据就行，核心都在这里 


```
-(void)cliectSend:(NSData *)data{
    
    //data length
    NSUInteger dataLength = data.length;
    
    // data header struct
    DataHeader dataH;
    memset((void *)&dataH, 0, sizeof(dataH));
    
    // pre
    PreHeader preH;
    memset((void *)&preH, 0, sizeof(preH));
    preH.pre[0] = '&';
    preH.dataLength = dataLength;
    
    dataH.preH = preH;
    
    // buffer
    int headerlength = sizeof(dataH);
    int totalLength = dataLength + headerlength;
    
    // srcbuffer
    Byte *src = (Byte *)[data bytes];
    
    // send buffer
    char *buffer = (char *)malloc(totalLength * sizeof(char));
    memcpy(buffer, &dataH, headerlength);
    memcpy(buffer + headerlength, src, dataLength);
    
    // tosend
    [self sendBytes:buffer length:totalLength];
    free(buffer);
    
}

```

大家仔细理解一下。

### 接收屏幕共享数据

```

//
//  RongRTCServerSocket.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/7.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCServerSocket.h"
#import <arpa/inet.h>
#import <netdb.h>
#import <sys/types.h>
#import <sys/socket.h>
#import <ifaddrs.h>
#import <UIKit/UIKit.h>


#import "RongRTCThread.h"
#import "RongRTCSocketHeader.h"
#import "RongRTCVideoDecoder.h"
@interface RongRTCServerSocket()<RongRTCCodecProtocol>
{
    pthread_mutex_t lock;
    int _frameTime;
    CMTime _lastPresentationTime;
    Float64 _currentMediaTime;
    Float64 _currentVideoTime;
    dispatch_queue_t _frameQueue;
}
@property (nonatomic, assign) int acceptSock;

/**
 data length
 */
@property(nonatomic , assign)NSUInteger dataLength;

/**
 timeData
 */
@property(nonatomic , strong)NSData *timeData;

/**
 decoder queue
 */
@property(nonatomic , strong)dispatch_queue_t decoderQueue;

/**
 decoder
 */
@property(nonatomic , strong)RongRTCVideoDecoder *decoder;
@end
@implementation RongRTCServerSocket

- (BOOL)createServerSocket{
    if ([self createSocket] == -1) {
        return NO;
    }
    [self setRecvBuffer];
    [self setRecvTimeout];
    BOOL isB = [self bind];
    BOOL isL = [self listen];
    
    if (isB && isL) {
        _decoderQueue = dispatch_queue_create("com.rongcloud.decoderQueue", NULL);
        _frameTime = 0;
        [self createDecoder];
        [self receive];
        return YES;
    } else {
        return NO;
    }
}
- (void)createDecoder{
    self.decoder = [[RongRTCVideoDecoder alloc] init];
    self.decoder.delegate = self;
    RongRTCVideoEncoderSettings *settings = [[RongRTCVideoEncoderSettings alloc] init];
    settings.width = 720;
    settings.height = 1280;
    settings.startBitrate = 300;
    settings.maxFramerate = 30;
    settings.minBitrate = 1000;
    [self.decoder configWithSettings:settings onQueue:_decoderQueue];
}
-(void)recvData{
    struct sockaddr_in rest;
    socklen_t rest_size = sizeof(struct sockaddr_in);
    self.acceptSock = accept(self.sock, (struct sockaddr *) &rest, &rest_size);
    while (self.acceptSock != -1) {
        DataHeader dataH;
        memset(&dataH, 0, sizeof(dataH));
        
        if (![self receveData:(char *)&dataH length:sizeof(dataH)]) {
            continue;
        }
        PreHeader preH = dataH.preH;
        char pre = preH.pre[0];
        if (pre == '&') {
            // rongcloud socket
            NSUInteger dataLenght = preH.dataLength;
            char *buff = (char *)malloc(sizeof(char) * dataLenght);
            if ([self receveData:(char *)buff length:dataLenght]) {
                NSData *data = [NSData dataWithBytes:buff length:dataLenght];
                [self.decoder decode:data];
                free(buff);
            }
        } else {
            NSLog(@"😁😁😁😁😁pre is not &");
            return;
        }
    }
}
- (BOOL)receveData:(char *)data length:(NSUInteger)length{
    LOCK(lock);
    int recvLength = 0;
    while (recvLength < length) {
        ssize_t res = recv(self.acceptSock, data, length - recvLength, 0);
        if (res == -1 || res == 0) {
            UNLOCK(lock);
            NSLog(@"😁😁😁😁😁recv data error");
            break;
        }
        recvLength += res;
        data += res;
    }
    UNLOCK(lock);
    return YES;
}

-(void)didGetDecodeBuffer:(CVPixelBufferRef)pixelBuffer {
    _frameTime += 1000;
    CMTime pts = CMTimeMake(_frameTime, 1000);
    CMSampleBufferRef sampleBuffer = [RongRTCBufferUtil sampleBufferFromPixbuffer:pixelBuffer time:pts];
    // 查看解码数据是否有问题，如果image能显示，就说明对了。
    // 通过打断点 将鼠标放在 iamge 脑袋上，就可以看到数据了，点击那个小眼睛
    UIImage *image = [RongRTCBufferUtil imageFromBuffer:sampleBuffer];
    [self.delegate didProcessSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

-(void)close{
    int res = close(self.acceptSock);
    self.acceptSock = -1;
    NSLog(@"😁😁😁😁😁shut down server: %d",res);
    [super close];
}
-(void)dealloc{
    NSLog(@"😁😁😁😁😁dealoc server socket");
}
@end


```

这里，通过 socket 收到数据之后，会循环一直收数据，然后进行解码，最后通过 代理  `didGetDecodeBuffer ` 回调数据，然后再抛出代理给app层，通过第三方SDK发送，就可以了


## 3. videotoolbox 硬编码


```

//
//  RongRTCVideoEncoder.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/13.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCVideoEncoder.h"

#import "helpers.h"

@interface RongRTCVideoEncoder(){
    VTCompressionSessionRef _compressionSession;
    int _frameTime;
    
}
/**
 settings
 */
@property(nonatomic , strong )RongRTCVideoEncoderSettings *settings;

/**
 callback queue
 */
@property(nonatomic , strong )dispatch_queue_t callbackQueue;
- (void)sendSpsAndPPSWithSampleBuffer:(CMSampleBufferRef)sampleBuffer;
- (void)sendNaluData:(CMSampleBufferRef)sampleBuffer;
@end

void compressionOutputCallback(void *encoder,
                               void *params,
                               OSStatus status,
                               VTEncodeInfoFlags infoFlags,
                               CMSampleBufferRef sampleBuffer){
    RongRTCVideoEncoder *videoEncoder = (__bridge RongRTCVideoEncoder *)encoder;
    if (status != noErr) {
        return;
    }
    if (infoFlags & kVTEncodeInfo_FrameDropped) {
        return;
    }
    BOOL isKeyFrame = NO;
    CFArrayRef attachments = CMSampleBufferGetSampleAttachmentsArray(sampleBuffer, 0);
    if (attachments != nullptr && CFArrayGetCount(attachments)) {
        CFDictionaryRef attachment = static_cast<CFDictionaryRef>(CFArrayGetValueAtIndex(attachments, 0)) ;
        isKeyFrame = !CFDictionaryContainsKey(attachment, kCMSampleAttachmentKey_NotSync);
    }
    CMBlockBufferRef block_buffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    CMBlockBufferRef contiguous_buffer = nullptr;
    if (!CMBlockBufferIsRangeContiguous(block_buffer, 0, 0)) {
        status = CMBlockBufferCreateContiguous(
                                               nullptr, block_buffer, nullptr, nullptr, 0, 0, 0, &contiguous_buffer);
        if (status != noErr) {
            return;
        }
    } else {
        contiguous_buffer = block_buffer;
        CFRetain(contiguous_buffer);
        block_buffer = nullptr;
    }
    size_t block_buffer_size = CMBlockBufferGetDataLength(contiguous_buffer);
    if (isKeyFrame) {
        [videoEncoder sendSpsAndPPSWithSampleBuffer:sampleBuffer];
    }
    if (contiguous_buffer) {
        CFRelease(contiguous_buffer);
    }
    [videoEncoder sendNaluData:sampleBuffer];
}

@implementation RongRTCVideoEncoder

@synthesize settings = _settings;
@synthesize callbackQueue = _callbackQueue;

- (BOOL)configWithSettings:(RongRTCVideoEncoderSettings *)settings onQueue:(nonnull dispatch_queue_t)queue{
    self.settings = settings;
    if (queue) {
        _callbackQueue = queue;
    } else {
        _callbackQueue = dispatch_get_main_queue();
    }
    if ([self resetCompressionSession:settings]) {
        _frameTime = 0;
        return YES;
    } else {
        return NO;
    }
}
- (BOOL)resetCompressionSession:(RongRTCVideoEncoderSettings *)settings {
    [self destroyCompressionSession];
    OSStatus status = VTCompressionSessionCreate(nullptr, settings.width, settings.height, kCMVideoCodecType_H264, nullptr, nullptr, nullptr, compressionOutputCallback, (__bridge void * _Nullable)(self), &_compressionSession);
    if (status != noErr) {
        return NO;
    }
    [self configureCompressionSession:settings];
    return YES;
}
- (void)configureCompressionSession:(RongRTCVideoEncoderSettings *)settings{
    if (_compressionSession) {
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_RealTime, true);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ProfileLevel, kVTProfileLevel_H264_Baseline_AutoLevel);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AllowFrameReordering, false);
        
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_MaxKeyFrameInterval, 10);
        uint32_t targetBps = settings.startBitrate * 1000;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, targetBps);
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_ExpectedFrameRate, settings.maxFramerate);
        int bitRate = settings.width * settings.height * 3 * 4 * 4;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_AverageBitRate, bitRate);
        int bitRateLimit = settings.width * settings.height * 3 * 4;
        SetVTSessionProperty(_compressionSession, kVTCompressionPropertyKey_DataRateLimits, bitRateLimit);
    }
}
-(void)encode:(CMSampleBufferRef)sampleBuffer{
    //    CFRetain(sampleBuffer);
    //    dispatch_async(_encodeQueue, ^{
    CVImageBufferRef imageBuffer = (CVImageBufferRef)CMSampleBufferGetImageBuffer(sampleBuffer);
    CMTime pts = CMTimeMake(self->_frameTime++, 1000);
    VTEncodeInfoFlags flags;
    OSStatus res = VTCompressionSessionEncodeFrame(self->_compressionSession,
                                                   imageBuffer,
                                                   pts,
                                                   kCMTimeInvalid,
                                                   NULL, NULL, &flags);
    
    //        CFRelease(sampleBuffer);
    if (res != noErr) {
        NSLog(@"encode frame error:%d", (int)res);
        VTCompressionSessionInvalidate(self->_compressionSession);
        CFRelease(self->_compressionSession);
        self->_compressionSession = NULL;
        return;
    }
    //    });
    
}
- (void)sendSpsAndPPSWithSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CMFormatDescriptionRef format = CMSampleBufferGetFormatDescription(sampleBuffer);
    const uint8_t *sps ;
    const uint8_t *pps;
    size_t spsSize ,ppsSize , spsCount,ppsCount;
    OSStatus spsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 0, &sps, &spsSize, &spsCount, NULL);
    OSStatus ppsStatus = CMVideoFormatDescriptionGetH264ParameterSetAtIndex(format, 1, &pps, &ppsSize, &ppsCount, NULL);
    if (spsStatus == noErr && ppsStatus == noErr) {
        const char bytes[] = "\x00\x00\x00\x01";
        size_t length = (sizeof bytes) - 1;
        
        NSMutableData *spsData = [NSMutableData dataWithCapacity:4+ spsSize];
        NSMutableData *ppsData  = [NSMutableData dataWithCapacity:4 + ppsSize];
        [spsData appendBytes:bytes length:length];
        [spsData appendBytes:sps length:spsSize];
        
        [ppsData appendBytes:bytes length:length];
        [ppsData appendBytes:pps length:ppsSize];
        if (self && self.callbackQueue) {
            dispatch_async(self.callbackQueue, ^{
                if (self.delegate && [self.delegate respondsToSelector:@selector(spsData:ppsData:)]) {
                    [self.delegate spsData:spsData ppsData:ppsData];
                }
            });
        }
    } else {
        NSLog(@"😁 sps status:%@,pps status:%@",@(spsStatus),@(ppsStatus));
    }
    
}
- (void)sendNaluData:(CMSampleBufferRef)sampleBuffer{
    size_t totalLength = 0;
    size_t lengthAtOffset=0;
    char *dataPointer;
    CMBlockBufferRef blockBuffer = CMSampleBufferGetDataBuffer(sampleBuffer);
    OSStatus status1 = CMBlockBufferGetDataPointer(blockBuffer, 0, &lengthAtOffset, &totalLength, &dataPointer);
    if (status1 != noErr) {
        NSLog(@"video encoder error, status = %d", (int)status1);
        return;
    }
    static const int h264HeaderLength = 4;
    size_t bufferOffset = 0;
    while (bufferOffset < totalLength - h264HeaderLength) {

        uint32_t naluLength = 0;
        memcpy(&naluLength, dataPointer + bufferOffset, h264HeaderLength);
        naluLength = CFSwapInt32BigToHost(naluLength);

        const char bytes[] = "\x00\x00\x00\x01";
        NSMutableData *naluData = [NSMutableData dataWithCapacity:4 + naluLength];
        [naluData appendBytes:bytes length:4];
        [naluData appendBytes:dataPointer + bufferOffset + h264HeaderLength length:naluLength];
        dispatch_async(self.callbackQueue, ^{
            if (self.delegate && [self.delegate respondsToSelector:@selector(naluData:)]) {
                [self.delegate naluData:naluData];
            }
        });
        bufferOffset += naluLength + h264HeaderLength;
    }
}
- (void)destroyCompressionSession{
    if (_compressionSession) {
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = nullptr;
    }
}
- (void)dealloc
{
    if (_compressionSession) {
        VTCompressionSessionCompleteFrames(_compressionSession, kCMTimeInvalid);
        VTCompressionSessionInvalidate(_compressionSession);
        CFRelease(_compressionSession);
        _compressionSession = NULL;
    }
}
@end


```


## 4. videotoolbox 解码


```

//
//  RongRTCVideoDecoder.m
//  SealRTC
//
//  Created by 孙承秀 on 2020/5/14.
//  Copyright © 2020 RongCloud. All rights reserved.
//

#import "RongRTCVideoDecoder.h"
#import <UIKit/UIKit.h>

#import "helpers.h"
@interface RongRTCVideoDecoder(){
    uint8_t *_sps;
    NSUInteger _spsSize;
    uint8_t *_pps;
    NSUInteger _ppsSize;
    CMVideoFormatDescriptionRef _videoFormatDescription;
    VTDecompressionSessionRef _decompressionSession;
}
/**
 settings
 */
@property(nonatomic , strong )RongRTCVideoEncoderSettings *settings;

/**
 callback queue
 */
@property(nonatomic , strong )dispatch_queue_t callbackQueue;
@end
void DecoderOutputCallback(void * CM_NULLABLE decompressionOutputRefCon,
                           void * CM_NULLABLE sourceFrameRefCon,
                           OSStatus status,
                           VTDecodeInfoFlags infoFlags,
                           CM_NULLABLE CVImageBufferRef imageBuffer,
                           CMTime presentationTimeStamp,
                           CMTime presentationDuration ) {
    if (status != noErr) {
        NSLog(@"😁 decoder callback error :%@", @(status));
        return;
    }
    CVPixelBufferRef *outputPixelBuffer = (CVPixelBufferRef *)sourceFrameRefCon;
    *outputPixelBuffer = CVPixelBufferRetain(imageBuffer);
    RongRTCVideoDecoder *decoder = (__bridge RongRTCVideoDecoder *)(decompressionOutputRefCon);
    dispatch_async(decoder.callbackQueue, ^{
        [decoder.delegate didGetDecodeBuffer:imageBuffer];
        CVPixelBufferRelease(imageBuffer);
    });
}
@implementation RongRTCVideoDecoder

@synthesize settings = _settings;
@synthesize callbackQueue = _callbackQueue;


-(BOOL)configWithSettings:(RongRTCVideoEncoderSettings *)settings onQueue:(dispatch_queue_t)queue{
    self.settings = settings;
    if (queue) {
        _callbackQueue = queue;
    } else {
        _callbackQueue = dispatch_get_main_queue();
    }
    return YES;
}
- (BOOL)createVT{
    if (_decompressionSession) {
        return YES;
    }
    const uint8_t * const parameterSetPointers[2] = {_sps, _pps};
    const size_t parameterSetSizes[2] = {_spsSize, _ppsSize};
    int naluHeaderLen = 4;
    OSStatus status = CMVideoFormatDescriptionCreateFromH264ParameterSets(kCFAllocatorDefault, 2, parameterSetPointers, parameterSetSizes, naluHeaderLen, &_videoFormatDescription );
    if (status != noErr) {
        NSLog(@"😁😁😁😁😁CMVideoFormatDescriptionCreateFromH264ParameterSets error:%@", @(status));
        return false;
    }
    NSDictionary *destinationImageBufferAttributes =
                                        @{
                                            (id)kCVPixelBufferPixelFormatTypeKey: [NSNumber numberWithInt:kCVPixelFormatType_420YpCbCr8BiPlanarFullRange],
                                            (id)kCVPixelBufferWidthKey: [NSNumber numberWithInteger:self.settings.width],
                                            (id)kCVPixelBufferHeightKey: [NSNumber numberWithInteger:self.settings.height],
                                            (id)kCVPixelBufferOpenGLCompatibilityKey: [NSNumber numberWithBool:true]
                                        };
    VTDecompressionOutputCallbackRecord CallBack;
    CallBack.decompressionOutputCallback = DecoderOutputCallback;
    CallBack.decompressionOutputRefCon = (__bridge void * _Nullable)(self);
    status = VTDecompressionSessionCreate(kCFAllocatorDefault, _videoFormatDescription, NULL, (__bridge CFDictionaryRef _Nullable)(destinationImageBufferAttributes), &CallBack, &_decompressionSession);

    if (status != noErr) {
        NSLog(@"😁😁😁😁😁VTDecompressionSessionCreate error:%@", @(status));
        return false;
    }
    status = VTSessionSetProperty(_decompressionSession, kVTDecompressionPropertyKey_RealTime,kCFBooleanTrue);
    
    return YES;
}

- (CVPixelBufferRef)decode:(uint8_t *)frame withSize:(uint32_t)frameSize {
    
    CVPixelBufferRef outputPixelBuffer = NULL;
    CMBlockBufferRef blockBuffer = NULL;
    CMBlockBufferFlags flag0 = 0;
    
    OSStatus status = CMBlockBufferCreateWithMemoryBlock(kCFAllocatorDefault, frame, frameSize, kCFAllocatorNull, NULL, 0, frameSize, flag0, &blockBuffer);
    
    if (status != kCMBlockBufferNoErr) {
        NSLog(@"😁😁😁😁😁VCMBlockBufferCreateWithMemoryBlock code=%d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    CMSampleBufferRef sampleBuffer = NULL;
    const size_t sampleSizeArray[] = {frameSize};
    
    status = CMSampleBufferCreateReady(kCFAllocatorDefault, blockBuffer, _videoFormatDescription, 1, 0, NULL, 1, sampleSizeArray, &sampleBuffer);
    
    if (status != noErr || !sampleBuffer) {
        NSLog(@"😁😁😁😁😁CMSampleBufferCreateReady failed status=%d", (int)status);
        CFRelease(blockBuffer);
        return outputPixelBuffer;
    }
    
    VTDecodeFrameFlags flag1 = kVTDecodeFrame_1xRealTimePlayback;
    VTDecodeInfoFlags  infoFlag = kVTDecodeInfo_Asynchronous;
    
    status = VTDecompressionSessionDecodeFrame(_decompressionSession, sampleBuffer, flag1, &outputPixelBuffer, &infoFlag);
    
    if (status == kVTInvalidSessionErr) {
        NSLog(@"😁😁😁😁😁decode frame error with session err status =%d", (int)status);
        [self resetVT];
    } else  {
        if (status != noErr) {
            NSLog(@"😁😁😁😁😁decode frame error with  status =%d", (int)status);
        }
        
    }

    CFRelease(sampleBuffer);
    CFRelease(blockBuffer);
    
    return outputPixelBuffer;
}
- (void)resetVT{
    [self destorySession];
    [self createVT];
}
-(void)decode:(NSData *)data{
    //    dispatch_async(_callbackQueue, ^{
    uint8_t *frame = (uint8_t*)[data bytes];
    uint32_t length = data.length;
    uint32_t nalSize = (uint32_t)(length - 4);
    uint32_t *pNalSize = (uint32_t *)frame;
    *pNalSize = CFSwapInt32HostToBig(nalSize);
    
    int type = (frame[4] & 0x1F);
    CVPixelBufferRef pixelBuffer = NULL;
    switch (type) {
        case 0x05:
            if ([self createVT]) {
                pixelBuffer= [self decode:frame withSize:length];
            }
            break;
        case 0x07:
            self->_spsSize = length - 4;
            self->_sps = (uint8_t *)malloc(self->_spsSize);
            memcpy(self->_sps, &frame[4], self->_spsSize);
            break;
        case 0x08:
            self->_ppsSize = length - 4;
            self->_pps = (uint8_t *)malloc(self->_ppsSize);
            memcpy(self->_pps, &frame[4], self->_ppsSize);
            break;
        default:
            if ([self createVT]) {
                pixelBuffer = [self decode:frame withSize:length];
            }
            break;
    }
    //    });
}

- (void)dealloc
{
    [self destorySession];
    
}
- (void)destorySession{
    if (_decompressionSession) {
        VTDecompressionSessionInvalidate(_decompressionSession);
        CFRelease(_decompressionSession);
        _decompressionSession = NULL;
    }
}
@end


```


# 总结

糖果的坑：

1. 这里可能都是贴的代码，文字很少，时间紧迫，给大家提供思路和我经历的坑就好了，一开始做这个的时候，没有使用 videotoolbox，使用cpu对bugger进行处理，软编软解，其实也是通过socket发送出去，但是发现，extension 屏幕是有内存限制的，最大50M，在extension 我通过裁剪和压缩的代码，发现经常会崩溃，超过50M，程序被杀死，然后每次压缩的数据其实也很大，效果很不好，后来想到了用苹果的 videotoolbox。
2. videotoolbox 后台解码一直失败，肯定不行的，屏幕共享是必须要在后台可以录制的，经过 google 之后，发现，把videotoolbox 重启一下就可以了，在我的代码里面有体现
3. 解码成功，但是通过融云的库发出去，帧率很低不连贯，图片都是有的，而且要是渲染也是没有问题的，但是通过我们融云的webrtc发送的话，发现帧率为0或者1然后就开始改pts，想过用我们融云的SDK采集的摄像头的pts发现可以，但是，有个问题，开发者不可能一直这么用，最后经过改造之后，终于可以了，这个坑，憋了我好几天，终于在不依赖我们SDK的情况下，实现无缝抽出屏幕共享模块。


上面的代码可能还有bug和问题，写到这里，demo已经能看到效果了，如果有什么bug或者问题，你们给我留言我改下就可以了，但至少我觉得思路是正确没有问题的应该。

上面的代码在github可以下载，要想看到效果，就在 

```
-(void)didGetDecodeBuffer:(CVPixelBufferRef)pixelBuffer {
    _frameTime += 1000;
    CMTime pts = CMTimeMake(_frameTime, 1000);
    CMSampleBufferRef sampleBuffer = [RongRTCBufferUtil sampleBufferFromPixbuffer:pixelBuffer time:pts];
    // 查看解码数据是否有问题，如果image能显示，就说明对了。
    // 通过打断点 将鼠标放在 iamge 脑袋上，就可以看到数据了，点击那个小眼睛
    UIImage *image = [RongRTCBufferUtil imageFromBuffer:sampleBuffer];
    [self.delegate didProcessSampleBuffer:sampleBuffer];
    CFRelease(sampleBuffer);
}

```

这个方法的image下面，打一个断点，鼠标放在 image上面，然后点击小眼睛，就可以看到extension发过来的每一帧图片数据了。







