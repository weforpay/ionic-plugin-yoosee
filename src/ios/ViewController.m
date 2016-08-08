//
//  ViewController.m
//  yooseeMonitorDemo
//
//  Created by apple on 16/6/17.
//  Copyright © 2016年 yuanHongQiang. All rights reserved.
//


/**
 ----------我是萌萌哒的分割线----------
 
 化繁为简,一如既往!
 
 本demo只演示如何使用p2p库去视频监控,不演示任何跟视频监控无关的操作
 因为视频监控往往是一对一的,所以基本不使用全局消息的通知方式,转而使用协议和代理
 使用p2p去进行视频监控非常简单,也就几步:
 1.调用p2p的呼叫函数,传入设备的id和密码还有呼叫类型即可
 2.实现p2p库的相关代理方法即可,其中比较重要的是P2PClientReady这个代理,在这里面要进行渲染相关的准备工作
 3.在子线程进行渲染,防止阻塞主线程,然后就可以看到画面了
 
 */

/*
 ---看这里---
 本来这个demo对设备的密码是不需要使用加密算法的,是推荐使用纯数字密码的,但奈何设备那边毕竟有字母密码,所以现在加入对字母密码的支持
 很简单,使用Utils.h文件里的 GetTreatedPassword:(NSString*)sPassword 方法就能把带字母的密码加密成数字传给设备,对了,它返回
 的不是NSString类型,记得把它转换成NSString类型呀
 
 */

#import "ViewController.h"
#import "MD5.h"
#import "P2PClient.h"
#import "OpenGLView.h"
#import "Utils.h"

//以下是 用户账号密码 设备id和密码,不保证一直有用,请使用您自己的账号密码和设备
#define UserName @"13420984014"
#define UserPswd @"123456"
//#define DeviceId @"2946367"
//#define DevicePw @"weforpay8"


@interface ViewController ()<P2PClientDelegate>{
    NSString* _p2pcode1;
    NSString* _p2pcode2;
    NSString* _userIDName;//用户的id号
    
    NSString* DeviceId;
    NSString* DevicePw;
    SeeResultCb _seeResult;
    
    BOOL _startingMonitor;
    BOOL _looking ;
    
    BOOL _hadInitDevice;//是否连接设备
    BOOL _hadLogin;//是否成功登录
    BOOL _isReject;//是否挂断了
    
    int _connectTryTimes;
    
    OpenGLView* _remoteView;//监控画面
    
    
    /**
     这个错误提示是来自P2PCInterface.h里的 dwErrorOption枚举,
     写在这里只是为了更好的展示错误信息,实际开发的时候请不要像我这样用这种不好的编程习惯
     */
    NSArray<NSString*>* _errorStrings;
    
    
}

@end



@implementation ViewController

@synthesize deviceId = DeviceId;
@synthesize devicePwd = DevicePw;
@synthesize seeResult=_seeResult;

-(void)createMonitoView{
    CGRect screenRt = [[UIScreen mainScreen] bounds];
    CGFloat w=screenRt.size.width;
    CGFloat h=w*9/16;
    CGRect rect=CGRectMake(0,(screenRt.size.height-h)/2,w, h);
    _remoteView=[[OpenGLView alloc] init];
    _remoteView.frame=rect;
    _remoteView.backgroundColor=[UIColor blackColor];
    [self.view addSubview:_remoteView];
}
- (void)viewDidLoad {
    [super viewDidLoad];
    [self createMonitoView];
    _isReject=YES;
    _looking = NO;
    _connectTryTimes = 0;
    
    _errorStrings=@[
                    @"没有发生错误",
                    @"对方的ID 被禁用",
                    @"对方的ID 过期了",
                    @"对方的ID 尚未激活",
                    @"对方离线",
                    @"对方忙线中",
                    @"对方已关机",
                    @"没有找到协助人",
                    @"对方已经挂断",
                    @"连接超时",
                    @"内部错误",
                    @"无人接听",
                    @"密码错误",
                    @"连接失败",
                    @"连接不支持"
                    ];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)
                                                 name:UIApplicationWillResignActiveNotification object:nil]; //监听是否触发home键挂起程序.
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)
                                                 name:UIApplicationDidBecomeActiveNotification object:nil]; //监听是否重新进入程序程序.
    
    [self setNavigationbar];
    [self startLogin];//开始登录
    [[P2PClient sharedClient] setDelegate:self];
    
}

- (void)applicationWillResignActive:(NSNotification *)notification

{
    _connectTryTimes = 0;
    _startingMonitor = false;
    _looking = false;
    _hadInitDevice = false;
    _hadLogin = false;
    _isReject = false;
    
    [self stopMoni:nil];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    [self startLogin];
}

-(void)viewWillDisappear:(BOOL)animated{
    if(_startingMonitor){
        _seeResult(2);
    }
    if(_looking){
        [self stopMoni:nil];
    }
}
- (void)setNavigationbar
{
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    UINavigationBar *navigationBar = [[UINavigationBar alloc] initWithFrame:CGRectMake(0, 0, screenRect.size.width, 54)];
    
    //创建UINavigationItem
    UINavigationItem * navigationBarTitle = [[UINavigationItem alloc] initWithTitle:self.title];
    [navigationBar pushNavigationItem: navigationBarTitle animated:YES];
    [self.view addSubview: navigationBar];
    //创建UIBarButton 可根据需要选择适合自己的样式
    UIBarButtonItem *item = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemReply target:self action:@selector(back:)];
    //设置barbutton
    navigationBarTitle.leftBarButtonItem = item;
    [navigationBar setItems:[NSArray arrayWithObject: navigationBarTitle]];
    
}

- (IBAction)back:(UIButton *)sender {
    [self dismissViewControllerAnimated:YES completion:^{
        
    }];
}
- (IBAction)reLogin:(UIButton *)sender {
    [self startLogin];
}

- (IBAction)startMoni:(UIButton *)sender {
    if (_isReject&&_hadLogin&&_hadInitDevice) {
        [self addLogs:@"发送呼叫命令"];
        
        _startingMonitor = true;
        
        [[P2PClient sharedClient] setIsBCalled:NO];
        [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_CALLING];
        
        /**设备密码采用了加密算法加密处理,这样密码有字母也不怕了*/
        [[P2PClient sharedClient] p2pCallWithId:DeviceId
                                       password:[NSString stringWithFormat:@"%ud",[Utils GetTreatedPassword:DevicePw]]
                                       callType:P2PCALL_TYPE_MONITOR];
    }
}
- (IBAction)stopMoni:(UIButton *)sender {
    if (!_isReject) {
        [self addLogs:@"发送挂断命令"];
        _isReject=YES;
        [[P2PClient sharedClient] p2pHungUp];
    }
}
- (IBAction)ClearTheLog:(UIButton *)sender {
}


-(void)addLogs:(NSString*)str{
    NSLog(str);
}

-(void)connectDevice{
    if (_hadLogin) {//只有登录了才去连接设备
        if (!_hadInitDevice) {
            [self addLogs:@"正在初始化设备"];
            _hadInitDevice=[[P2PClient sharedClient] p2pConnectWithId:_userIDName codeStr1:_p2pcode1 codeStr2:_p2pcode2];
            NSString* result=[NSString stringWithFormat:@"初始化连接设备 %@",_hadInitDevice?@"成功,你可以操作设备了":@"失败,你将不能操作设备"];
            [self addLogs:result];
            if(_hadInitDevice){
                [self startMoni:nil];
            }
        }
    }
}

-(IBAction)unwindSegueToSelf:(UIStoryboardSegue*)segue{
    
}

#pragma mark - 协议的实现
- (void)P2PClientCalling:(NSDictionary*)info{
    NSString* str=[NSString stringWithFormat:@"正在呼叫,%@,解释:%@",
                   [self stringFromDic:info],
                   [self stringErrorByError:[info[@"ErrorOption"] integerValue]]];
    [self addLogs:str];
}
- (void)P2PClientReject:(NSDictionary*)info{
    _isReject=YES;
    if(_connectTryTimes > 2){
        _seeResult(1);
        return ;
    }
    _connectTryTimes ++;
    
    if(_startingMonitor){
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self startMoni:nil];
        });
    }
    
    NSString* str=[NSString stringWithFormat:@"视频挂断,%@,解释:%@",
                   [self stringFromDic:info],
                   [self stringErrorByError:[info[@"ErrorOption"] integerValue]]];
    [self addLogs:str];
}
- (void)P2PClientAccept:(NSDictionary*)info{
    _startingMonitor = false;
    _looking = YES;
    _seeResult(0);
    NSString* str=[NSString stringWithFormat:@"接收数据,%@,解释:%@",
                   [self stringFromDic:info],
                   [self stringErrorByError:[info[@"ErrorOption"] integerValue]]];
    [self addLogs:str];
}
- (void)P2PClientReady:(NSDictionary*)info{
    _startingMonitor = false;
    NSString* str=[NSString stringWithFormat:@"准备就绪,%@,解释:%@",
                   [self stringFromDic:info],
                   [self stringErrorByError:[info[@"ErrorOption"] integerValue]]];
    [self addLogs:str];
    
    
    
    //开始渲染
    [[P2PClient sharedClient] setP2pCallState:P2PCALL_STATUS_READY_P2P];
    
    if([[P2PClient sharedClient] p2pCallType]==P2PCALL_TYPE_MONITOR){
        //连接就绪之后就开始启动渲染
        [self monitorStartRender];
    }
}
#pragma mark - 准备渲染监控界面
-(void)monitorStartRender{
    [self addLogs:@"渲染>>>你可以看到画面了"];
    _isReject = NO;
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self renderView];
    });
    [[PAIOUnit sharedUnit] setMuteAudio:NO];
    [[PAIOUnit sharedUnit] setSpeckState:YES];
}
#pragma mark - 开始渲染监控画面
- (void)renderView
{
    GAVFrame * m_pAVFrame;
    while (!_isReject)
    {
        if(fgGetVideoFrameToDisplay(&m_pAVFrame))
        {
            [_remoteView render:m_pAVFrame];
            vReleaseVideoFrame();
        }
        usleep(10000);
    }
}

#pragma mark - 登录相关
/**开始登录*/
-(void)startLogin{
    
    /**
     登录的方法不是这个demo的重点,此处不详细介绍,欲知详情,请查看登录的demo
     */
    
    [self addLogs:@"正在登录"];
    /**    可供使用的服务器地址:
     api1.cloudlinks.cn
     api2.cloudlinks.cn
     api3.cloud-links.net
     api4.cloud-links.net
     */
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig delegate:nil delegateQueue:nil];
    NSURL* URL = [NSURL URLWithString:@"http://api1.cloudlinks.cn/Users/LoginCheck.ashx"];
    NSDictionary* URLParams = @{
                                @"AppOS": @"2",
                                @"AppVersion":[NSString stringWithFormat:@"%d",2<<24|7<<16|3<<8|4],
                                @"User":UserName,
                                @"Pwd": [MD5 md5_32bit:UserPswd],
                                @"Opion": @"GetParam",
                                @"VersionFlag": @" ",
                                };
    URL = NSURLByAppendingQueryParameters(URL, URLParams);
    NSMutableURLRequest* request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = @"POST";
    NSURLSessionDataTask* task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!error) {
                NSDictionary* jsonDic=[NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
                //                NSLog(@"返回结果:%@",jsonDic);
                NSString* errCode=jsonDic[@"error_code"];
                if ([errCode isEqualToString:@"0"]) {//返回0即认为是登录成功
                    _hadLogin=YES;
                    [self addLogs:@"登录成功"];
                    //拿到登录成功之后的2个p2p连接码和用户名
                    _userIDName=[NSString stringWithFormat:@"%d",(int)[jsonDic[@"UserID"] integerValue]&0x7fffffff];//用户id就是这样得到的
                    _p2pcode1=jsonDic[@"P2PVerifyCode1"];
                    _p2pcode2=jsonDic[@"P2PVerifyCode2"];
                    [self connectDevice];//开始连接p2p
                    
                }else{
                    _hadLogin=NO;
                    [self addLogs:@"登录失败,对设备的操作将无效,失败原因:"];
                    NSString* theErrStr=jsonDic[@"error"];
                    [self addLogs:theErrStr];
                }
            }
            else {
                _hadLogin=NO;
                NSString* fal=@"登录失败,对设备的操作将无效,失败原因:";
                fal=[fal stringByAppendingString:[error localizedDescription]];
                [self addLogs:fal];
            }
        });
    }];
    [task resume];//发起任务,开始登录
}
/**
 从字典参数拼接地址
 */
static NSString* NSStringFromQueryParameters(NSDictionary* queryParameters)
{
    NSMutableArray* parts = [NSMutableArray array];
    [queryParameters enumerateKeysAndObjectsUsingBlock:^(id key, id value, BOOL *stop) {
        NSString *part = [NSString stringWithFormat: @"%@=%@",
                          [key stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding],
                          [value stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]
                          ];
        [parts addObject:part];
    }];
    return [parts componentsJoinedByString: @"&"];
}

/**
 创建一个带参数的URL地址串
 */
static NSURL* NSURLByAppendingQueryParameters(NSURL* URL, NSDictionary* queryParameters)
{
    NSString* URLString = [NSString stringWithFormat:@"%@?%@",
                           [URL absoluteString],
                           NSStringFromQueryParameters(queryParameters)
                           ];
    NSURL* theUrl=[NSURL URLWithString:URLString];
    return theUrl;
}
-(NSString*)stringFromDic:(NSDictionary*)dic{
    NSString* str=@"";
    if (dic) {
        NSData* data=[NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:nil];
        str=[[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    }
    return str;
}
-(NSString*)stringErrorByError:(NSInteger)error{
    return _errorStrings[error];
}
@end
