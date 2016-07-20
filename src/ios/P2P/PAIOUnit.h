//
//  PAIOUnit.h
//  cuNewVersion
//
//  Created by Jie on 13-11-15.
//  Copyright (c) 2013年 Passol. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <MediaPlayer/MediaPlayer.h>
#import "P2PClient.h"

@interface PAIOUnit : NSObject

@property (nonatomic, assign) BOOL isRunning;
@property (nonatomic, assign) P2PCallType callType;
@property (nonatomic, assign) BOOL muteAudio;
@property (nonatomic, assign) BOOL silentAudio;

+ (PAIOUnit *)sharedUnit;

- (id)initWithAudioUnit;
- (BOOL)startAudioWithCallType:(P2PCallType)type;
- (BOOL)stopAudio;
- (BOOL)uninitWithAutioUnit;


-(void)setSpeckState:(BOOL)state;
@end
