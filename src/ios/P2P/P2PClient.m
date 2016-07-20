//
//  P2PClientNew.m
//  YooseeP2P
//
//  Created by apple on 16/6/14.
//  Copyright © 2016年 yhq. All rights reserved.
//

#import "P2PClient.h"


static P2PClient *manager = nil;
@implementation P2PClient
#pragma mark - 获取单例
+(_Nonnull instancetype)sharedClient{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[P2PClient alloc] init];
    });
    return manager;
}
#pragma mark - 初始化连接p2p库
-(BOOL)p2pConnectWithId:(NSString *)contactId codeStr1:(NSString *)codeStr1 codeStr2:(NSString *)codeStr2{
    
    vP2PExit();
    
    sP2PInitPrm mP2Pprm;
    mP2Pprm.dw3CID = contactId.intValue;
    mP2Pprm.dw3CID |= 0x80000000 ;
    mP2Pprm.dwCode1 = codeStr1.intValue;
    mP2Pprm.dwCode2 = codeStr2.intValue;
    
    mP2Pprm.pHostName = "|p2p1.cloudlinks.cn|p2p2.cloudlinks.cn|p2p3.cloud-links.net|p2p4.cloud-links.net|p2p5.cloudlinks.cn|p2p6.cloudlinks.cn|p2p7.cloudlinks.cn|p2p8.cloudlinks.cn|p2p9.cloudlinks.cn|p2p10.cloudlinks.cn";
    mP2Pprm.dwChNs         = 1;
    mP2Pprm.dwChBufSize[0] = 1024*512;
    mP2Pprm.dwChBufSize[1] = 1024*512;
    mP2Pprm.dwChBufSize[2] = 1024*512;
    mP2Pprm.dwChBufSize[3] = 1024*512;
    mP2Pprm.dwPassword     = 1792802871;
    mP2Pprm.dwCustomerID[0] = 0;
    mP2Pprm.dwCustomerID[1] = 0;
    mP2Pprm.dwCustomerID[2] = 0;
    mP2Pprm.dwCustomerID[3] = 0;
    mP2Pprm.dwCustomerID[4] = 0;
    mP2Pprm.dwCustomerID[5] = 0;
    mP2Pprm.dwCustomerID[6] = 0;
    mP2Pprm.dwCustomerID[7] = 0;
    mP2Pprm.dwCustomerID[8] = 0;
    mP2Pprm.dwCustomerID[9] = 0;
    mP2Pprm.vCallingSignal = vCallingSignal;
    mP2Pprm.vRejectSignal  = vRejectSignal;
    mP2Pprm.vAcceptSignal  = vAcceptSignal;
    mP2Pprm.vP2PConnReady  = vP2PConnReady;
    mP2Pprm.vRecvRemoteMessage = vRecvRemoteMessage;
    mP2Pprm.vSendMessageAck=    vSendMessageAck;
    mP2Pprm.vFriendsStatusUpdate = vFriendsStatusUpdate;
    mP2Pprm.vFlagUpdate = NULL;//没用到则 = NULL
    BOOL result=fgP2PInit(&mP2Pprm);
    return result;
    
}
#pragma mark - 准备连接呼叫设备
-(void)p2pCallWithId:(NSString *)userId password:(NSString*)password callType:(P2PCallType)type{
    if(!password){
        password = @"";
    }
    if (userId)
    {
        UINT64 iCallId = [userId intValue];
        if ([userId hasPrefix:@"0"]){
            iCallId |= 0x80000000;
        }
        
        NSString *callMsg = @"test callMsg";
        DWORD dwCallPrm[4];
        
        if (type==P2PCALL_TYPE_MONITOR) {
            dwCallPrm[0] = CONN_TYPE_MONITOR;
            dwCallPrm[1] = LOCAL_VIDEO_ABILITY;
            dwCallPrm[2] = FLAG_VIDEO_TRANS_VGA;
            dwCallPrm[3] = 0 ;
            if(fgP2PCall(iCallId, 1, password.intValue, dwCallPrm, (char *)[callMsg UTF8String])){
//                NSLog(@"呼叫成功");
            }else{
                NSLog(@"呼叫失败");
            }
        }
        if (type==P2PCALL_TYPE_VIDEO) {
            dwCallPrm[0] = CONN_TYPE_VIDEO_CALL;
            dwCallPrm[1] = LOCAL_VIDEO_ABILITY ;
            dwCallPrm[2] = 0 ;
            dwCallPrm[3] = 0 ;
            fgP2PCall(iCallId, 0, 0, dwCallPrm, (char *)[callMsg UTF8String]);
        }
    }
}

#pragma mark - 挂断视频
-(void)p2pHungUp{
    vStopRecvAndDec();//停止接收并且解码
    vStopAVEncAndSend();//停止编码且发送
    vP2PHungup(FALSE);//挂断视频通话或者监控...
}
#pragma mark - 开始呼叫
- (void)startCall
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [NSThread sleepForTimeInterval:0.1];
        
        _srecAndDecPrm.dwConnectType = _p2pCallType;
        _srecAndDecPrm.vRecvAVData = NULL;
        _srecAndDecPrm.vRecvAVHeader = NULL;
        _srecAndDecPrm.vRecvUserDataCallBack = commandSettingInAction;
        if(fgStartRecvAndDec(&(_srecAndDecPrm))){//接收并解码
            //                NSLog(@"接收并解码成功");
        }else{
            NSLog(@"接收并解码失败");
        }
        if (self.p2pCallType == P2PCALL_TYPE_VIDEO || self.p2pCallType == P2PCALL_TYPE_MONITOR) {
            fgStartAVEncAndSend(VIDEO_FRAME_RATE);//编码并发送
        }
    });
}
#pragma mark - 发送全局消息
- (void)receivePlayingCommand:(NSDictionary *)dictionary
{
    [[NSNotificationCenter defaultCenter] postNotificationName:RECEIVE_PLAYING_CMD
                                                        object:self
                                                      userInfo:dictionary];
}


#pragma mark - p2p库回调函数
void commandSettingInAction(DWORD dwCmd, DWORD  dwOption , DWORD * pdwData,  DWORD  dwDataLen)
{
//    NSLog(@"commandSettingInAction");
    if (dwCmd == USR_CMD_AUDIO_ONLY) {
        NSNumber *mesgType = [NSNumber numberWithInt:RECEIVE_PLAYING_CMD_CHANGE_VIDEO_STATE];
        NSNumber *option  = [NSNumber numberWithBool:dwOption];
        NSDictionary *parameter = @{@"mesgType": mesgType,
                                    @"option" : option};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
    }
    if (dwCmd == USR_CMD_CURRENT_USERS_NS) {
        NSNumber *value  = [NSNumber numberWithInt:dwOption];
        NSDictionary *parameter = @{@"option" : value};
        [[P2PClient sharedClient] receivePlayingCommand:parameter];
    }
    if (dwCmd == USR_CMD_PLAY_CTL) {}
    return;
}
void (vCallingSignal)(sCallingPrmType *sCallPrm){
//    NSLog(@"======vCallingSignal========");
    unsigned int fgBCalled;
    unsigned int dwHisID;
    unsigned int dwDevType;
    unsigned int fgInSameDomain;
    unsigned int fgMonitorOnly;
    unsigned int dwRemoteChNs;
    
    fgBCalled = sCallPrm->fgBCalled;
    dwHisID = sCallPrm->dwHisID;
    dwDevType = sCallPrm->dwHisDevType;
    fgInSameDomain = sCallPrm->fgInSameDomain;
    fgMonitorOnly = sCallPrm->fgSuperCall;
    dwRemoteChNs = sCallPrm->dwRemoteChNs;
    
    NSMutableDictionary * info = [NSMutableDictionary dictionary];
    if(fgBCalled==1){
        [info setObject:[NSString stringWithFormat:@"%i",dwHisID&0x7fffffff] forKey:@"callId"];
        [info setObject:@"YES" forKey:@"isBCalled"];
    }else{
        [info setObject:@"NO" forKey:@"isBCalled"];
    }
    [[P2PClient sharedClient] delegateCalling:info];
}
void (vRejectSignal)(KBOOL fgBCalled,  DWORD dwErrorOption){
//    NSLog(@"======vRejectSignal========");
    NSNumber* errorFlag=[NSNumber numberWithInt:dwErrorOption];
    NSDictionary* dic=@{@"ErrorOption":errorFlag};
    [[P2PClient sharedClient] delegateReject:dic];
}

#define VIDEO_ABILITY_16_9  (1<<7)
void (vAcceptSignal)(KBOOL fgBCalled, DWORD *pdwPrm){
//    NSLog(@"======vAcceptSignal========");
    if (pdwPrm[1]==0) {
        [[P2PClient sharedClient] setIs960P:YES];
    }else{
        [[P2PClient sharedClient] setIs960P:NO];
    }
    BOOL is16b9 = NO;
    if(pdwPrm[0]==CONN_TYPE_MONITOR||pdwPrm[0]==CONN_TYPE_FILE_TRANS||pdwPrm[0]==CONN_TYPE_VIDEO_CALL){
        if(((pdwPrm[1] >> 24)& VIDEO_ABILITY_16_9 )||((pdwPrm[1] >> 16)& VIDEO_ABILITY_16_9 ))
        {
            is16b9 = YES;
        }
    }
    NSDictionary* dic=@{@"is16b9":[NSNumber numberWithInt:is16b9]};
    [[P2PClient sharedClient] delegateAccept:dic];
}
void (vP2PConnReady)(void){
//    NSLog(@"======vP2PConnReady========");
    [[P2PClient sharedClient] delegateReady:nil];
}
void (vRecvRemoteMessage)(DWORD dwSrcID, KBOOL fgHasCheckdPassword,  void *pMesg, DWORD dwMesgSize){
//    NSLog(@"======vRecvRemoteMessage========");

}

void (vSendMessageAck)(DWORD dwDesID, DWORD dwMesgID, DWORD  dwError){
//    NSLog(@"======vSendMessageAck========");

}
void (vFriendsStatusUpdate)(sFriendsType * pFriends ){
//    NSLog(@"======vFriendsStatusUpdate========");
}
#pragma mark - 协议方法
- (void)delegateCalling:(NSDictionary*)info {
    NSString *isBCalled = [info objectForKey:@"isBCalled"];
    if([isBCalled isEqualToString:@"YES"]){
        NSString *callId = [info objectForKey:@"callId"];
        _callId = callId;
        _isBCalled = YES;
    }else{
        _isBCalled = NO;
    }
    _p2pCallState = P2PCALL_STATUS_CALLING;
    if(_isBCalled){
        _p2pCallType = P2PCALL_TYPE_VIDEO;
    }
    if(_p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if ([_delegate respondsToSelector:@selector(P2PClientCalling:)]) {
            [_delegate P2PClientCalling:info];
        }
    }
}
- (void)delegateReject:(NSDictionary*)info {
    
    if (_p2pCallState == P2PCALL_STATUS_READY_P2P) {
        [[PAIOUnit sharedUnit] stopAudio];
        [self p2pHungUp];
    }
    _p2pCallState = P2PCALL_STATUS_NONE;
    if(_p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if ([_delegate respondsToSelector:@selector(P2PClientReject:)]) {
            [_delegate P2PClientReject:info];
        }
    }
}
- (void)delegateAccept:(NSDictionary*)info {
    _is16B9 = [[info valueForKey:@"is16b9"] intValue];
    if(_p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if ([_delegate respondsToSelector:@selector(P2PClientAccept:)]) {
            [_delegate P2PClientAccept:info];
        }
    }
}

- (void)delegateReady:(NSDictionary*)info {
    self.p2pCallState = P2PCALL_STATUS_READY_P2P;
    [[PAIOUnit sharedUnit] startAudioWithCallType:self.p2pCallType];
    [self startCall];
    if(self.p2pCallType!=P2PCALL_TYPE_PLAYBACK){
        if ([_delegate respondsToSelector:@selector(P2PClientReady:)]) {
            [_delegate P2PClientReady:info];
        }
    }
}
@end
