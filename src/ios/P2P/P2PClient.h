//
//  P2PclientNew.h
//  YooseeP2P
//
//  Created by apple on 16/6/14.
//  Copyright © 2016年 yhq. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "P2PCInterface.h"
#import "Constants.h"
#import "PAIOUnit.h"
#import "config.h"

//以下是全局消息的名字定义
#define RECEIVE_PLAYING_CMD @"RECEIVE_PLAYING_CMD"
#define RECEIVE_PLAYING_CMD_CHANGE_VIDEO_STATE 0x11

//视频监控的几个定义
#define  FLAG_VIDEO_TRANS_QVGA 	 (0)  //
#define  FLAG_VIDEO_TRANS_HD     (1)  //
#define  FLAG_VIDEO_TRANS_VGA    (2)  //

@protocol P2PClientDelegate <NSObject>

@optional
- (void)P2PClientCalling:(nullable NSDictionary*)info;
- (void)P2PClientReject:(nullable NSDictionary*)info;
- (void)P2PClientAccept:(nullable NSDictionary*)info;
- (void)P2PClientReady:(nullable NSDictionary*)info;
@end

@interface P2PClient : NSObject

@property (nonatomic) sRecAndDecPrm srecAndDecPrm;
@property (nonatomic) P2PCallState p2pCallState;
@property (nonatomic) P2PCallType p2pCallType;


@property (nullable,nonatomic,copy) NSString *callId;
@property (nullable,nonatomic,copy) NSString *callPassword;
@property (nonatomic) BOOL isBCalled;
@property (nonatomic) BOOL is16B9;
@property (nonatomic) BOOL is960P;
@property (nullable,nonatomic, weak) id<P2PClientDelegate> delegate;


+(_Nonnull instancetype)sharedClient;


-(BOOL)p2pConnectWithId:(nullable NSString*)contactId codeStr1:(nullable NSString*)codeStr1 codeStr2:(nullable NSString*)codeStr2;
-(void)p2pCallWithId:(NSString *)userId password:(NSString*)password callType:(P2PCallType)type;
-(void)p2pHungUp;
@end
