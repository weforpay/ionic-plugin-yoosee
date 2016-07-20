//
//  PAIOUnit.m
//  cuNewVersion
//
//  Created by Jie on 13-11-15.
//  Copyright (c) 2013年 Passol. All rights reserved.
//

#import "PAIOUnit.h"
#import <AudioUnit/AudioUnit.h>


//什么含义
#define kOutputBus 0
#define kInputBus 1

#define pi 3.14159


@interface PAIOUnit ()
{
    AudioUnit                   _audioUnit;
    AudioBufferList             *_m_inBufferList;
    Float64                     recordSampleRate;
    AudioStreamBasicDescription audioFormat;
}

@property (readonly) AudioUnit audioUnit;
@property (readonly) AudioBufferList * m_inBufferList;


@end

@implementation PAIOUnit
@synthesize audioUnit = _audioUnit;
@synthesize m_inBufferList = _m_inBufferList;

#define checkstatus(x) checkStatusWithLineNumber(__LINE__, x)
void checkStatusWithLineNumber(int lineNumber, OSStatus status) {
	if (status != 0) NSLog(@"An error occurred on line %d: %d", lineNumber, (int)status);
}

#pragma mark - IO CallBack

void interruptionListenerCallback (void *inUserData, UInt32 interruptionState)
{
    //其实作用不大
    if ([[PAIOUnit sharedUnit] isRunning]) {
        
        if (interruptionState == kAudioSessionBeginInterruption) {
            //hungup
        }
    }
}

void audioRouteChangeCallback(void*inClientData, AudioSessionPropertyID inID, UInt32 inDataSize, const void*inData) {
    CFDictionaryRef routeChangeDictionary = inData;
    CFNumberRef routeChangeReasonRef = CFDictionaryGetValue(routeChangeDictionary, CFSTR(kAudioSession_AudioRouteChangeKey_Reason));
    SInt32 routeChangeReason;
    CFNumberGetValue(routeChangeReasonRef, kCFNumberSInt32Type, &routeChangeReason);
    switch (routeChangeReason) {
        case kAudioSessionRouteChangeReason_OldDeviceUnavailable:
            NSLog(@"AudioSessionRouteChange : Old Audio Device Unavailable");
            break;
        case kAudioSessionRouteChangeReason_NewDeviceAvailable:
            NSLog(@"AudioSessionRouteChange : New Audio Device Available");
            break;
        case kAudioSessionRouteChangeReason_Override:
            NSLog(@"AudioSessionRouteChange : Audio Device Route Change Override");
            break;
        default:
            if (routeChangeReason == kAudioSessionRouteChangeReason_NoSuitableRouteForCategory) {
                NSLog(@"AudioSessionRouteChange : No Suitable Route For Category");
            }
            break;
    }

    [[PAIOUnit sharedUnit] checkSpeaker];
}

static OSStatus recordingCallback(void *inRefCon,
                                  AudioUnitRenderActionFlags *ioActionFlags,
                                  const AudioTimeStamp *inTimeStamp,
                                  UInt32 inBusNumber,
                                  UInt32 inNumberFrames,
                                  AudioBufferList *ioData) {
        
    
    if ([[PAIOUnit sharedUnit] isRunning]) {
        @autoreleasepool {
            
            [PAIOUnit sharedUnit].m_inBufferList->mBuffers[0].mDataByteSize = inNumberFrames*sizeof(UInt16);
            
            OSStatus status;
            status = AudioUnitRender([PAIOUnit sharedUnit].audioUnit,
                                     ioActionFlags,
                                     inTimeStamp,
                                     inBusNumber,
                                     inNumberFrames,
                                     [PAIOUnit sharedUnit].m_inBufferList);
//            if (noErr != status) {
//                NSLog(@"AudioUnitRender error: %d", status);
//                return status;
//            }
            checkstatus(status);
            if (status != noErr) {
                NSLog(@"AudioUnitRender error: %d", (int)status);
                return status;
            }
            
            [[PAIOUnit sharedUnit] processAudio:[[PAIOUnit sharedUnit] m_inBufferList]];
        }
    }
    return noErr;
}

static OSStatus playbackCallback(void *inRefCon,
								 AudioUnitRenderActionFlags *ioActionFlags,
								 const AudioTimeStamp *inTimeStamp,
								 UInt32 inBusNumber,
								 UInt32 inNumberFrames,
								 AudioBufferList *ioData)
{
    BOOL isGetAudioOk = NO;
    if ([[P2PClient sharedClient]p2pCallState] == P2PCALL_STATUS_READY_P2P)
    {
        isGetAudioOk = fgGetAudioDataToPlay(ioData->mBuffers[0].mData, ioData->mBuffers[0].mDataByteSize );
    }
    if ([[PAIOUnit sharedUnit] muteAudio] || !isGetAudioOk /*|| (NO == [[PAIOUnit sharedUnit] silentAudio])*/)
    {
        memset(ioData->mBuffers[0].mData, 0,ioData->mBuffers[0].mDataByteSize );
    }

    return noErr;
}

#pragma mark init method

- (BOOL)intialiseAudio
{
    
    
    AudioComponentDescription audioDesc;
    audioDesc.componentType = kAudioUnitType_Output;
    audioDesc.componentSubType = kAudioUnitSubType_VoiceProcessingIO;
    audioDesc.componentFlags = 0;
    audioDesc.componentFlagsMask = 0;
    audioDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    OSStatus status = noErr;
    AudioComponent inputComponent = AudioComponentFindNext(NULL, &audioDesc);
    status = AudioComponentInstanceNew(inputComponent, &_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    
    UInt32 flag = 1;
    // Enable IO for recording
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Input,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);
    
    // Enable IO for playback
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_EnableIO,
                                  kAudioUnitScope_Output,
                                  kOutputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);
	
	// Describe format
	audioFormat.mSampleRate			= 8000;
	audioFormat.mFormatID			= kAudioFormatLinearPCM;
	audioFormat.mFormatFlags		= kAudioFormatFlagIsSignedInteger | kAudioFormatFlagIsPacked;
	audioFormat.mFramesPerPacket	= 1;
	audioFormat.mChannelsPerFrame	= 1;
	audioFormat.mBitsPerChannel		= 16;//short
	audioFormat.mBytesPerPacket		= 2;
	audioFormat.mBytesPerFrame		= 2;
	
    // Apply format
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkstatus(status);
    
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_StreamFormat,
                                  kAudioUnitScope_Input,
                                  kOutputBus,
                                  &audioFormat,
                                  sizeof(audioFormat));
    checkstatus(status);
    
    
    // Set input callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = recordingCallback;
    callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioOutputUnitProperty_SetInputCallback,
                                  kAudioUnitScope_Global,
                                  kInputBus,
                                  &callbackStruct,
                                  sizeof(callbackStruct));
    
	// Set output callback
    callbackStruct.inputProc = playbackCallback;
	callbackStruct.inputProcRefCon = (__bridge void *)(self);
    status = AudioUnitSetProperty(_audioUnit,
								  kAudioUnitProperty_SetRenderCallback,
								  kAudioUnitScope_Global,
								  kOutputBus,
								  &callbackStruct,
								  sizeof(callbackStruct));
    checkstatus(status);
	
	// Disable buffer allocation for the recorder (optional - do this if we want to pass in our own)
    flag = 0;
    status = AudioUnitSetProperty(_audioUnit,
                                  kAudioUnitProperty_ShouldAllocateBuffer,
                                  kAudioUnitScope_Output,
                                  kInputBus,
                                  &flag,
                                  sizeof(flag));
    checkstatus(status);

    AudioUnitSetProperty(_audioUnit,
                         kAUVoiceIOProperty_VoiceProcessingEnableAGC,
                         kAudioUnitScope_Global,
                         0,
                         &flag,
                         sizeof(flag));

    if (status) {
        return NO;
    }
    
    _m_inBufferList = (AudioBufferList *)malloc(sizeof(AudioBufferList) + sizeof(AudioBuffer));
    _m_inBufferList->mNumberBuffers = 1;
    _m_inBufferList->mBuffers[0].mNumberChannels = 1;
    _m_inBufferList->mBuffers[0].mDataByteSize = 320 * 2;
    _m_inBufferList->mBuffers[0].mData = malloc( 320 * 2 );
    
    return YES;
}


#pragma mark AUDIOUNIT METHOD

+ (PAIOUnit *)sharedUnit
{
    static PAIOUnit *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[PAIOUnit alloc] initWithAudioUnit];
        sharedInstance.isRunning = NO;
        sharedInstance.silentAudio = YES;
    });
    return sharedInstance;
}

- (id)initWithAudioUnit
{
    if (self = [super init]) {
        return self;
    }
    return nil;
}


- (BOOL)startAudioWithCallType:(P2PCallType )type
{
    
    BOOL isOK = [self initAudioSession];
    if (!isOK) {
        return NO;
    }
    
    isOK = [self intialiseAudio];
    if (!isOK) {
        return NO;
    }
    
    OSStatus status;
    self.isRunning = YES;
    self.callType = type;
    
    status = AudioUnitInitialize(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    status = AudioOutputUnitStart(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    
    
    return YES;
    
}

- (BOOL)stopAudio
{
    OSStatus status = AudioOutputUnitStop(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
	status = AudioUnitUninitialize(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    
    [self uninitWithAutioUnit];
    self.isRunning = NO;
	return YES;
}


- (BOOL)uninitWithAutioUnit
{
    OSStatus status;
    free(_m_inBufferList->mBuffers[0].mData);
    free(_m_inBufferList);
    status = AudioComponentInstanceDispose(_audioUnit);
    checkstatus(status);
    if (status) {
        return NO;
    }
    [self exitAudioSession];
    return YES;
}

#pragma mark Audiodata transit
- (void)processAudio:(AudioBufferList*)bufferList
{
    if (self.isRunning)
    {
        if (self.silentAudio) {
            short *myData = bufferList->mBuffers[0].mData;
            for (int i = 0; i < (bufferList->mBuffers[0].mDataByteSize)/2 ; i++) {
                myData[i] = 0;
            }
            
        }
        else
        {
            if ([[P2PClient sharedClient]p2pCallState] == P2PCALL_STATUS_READY_P2P)
            {
                vFillAudioRawData(bufferList->mBuffers[0].mData,  bufferList->mBuffers[0].mDataByteSize);
            }
        }
    }
}

#pragma mark AudioSession Control

- (BOOL)initAudioSession
{
    OSStatus error = AudioSessionInitialize(NULL, NULL, interruptionListenerCallback, NULL); // 初始化音频会话
    if (error)
        printf("ERROR INITIALIZING AUDIO SESSION! %d\n", (int)error);
    
//    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    UInt32 audioCategory = kAudioSessionCategory_PlayAndRecord;
    AudioSessionSetProperty(kAudioSessionProperty_AudioCategory, sizeof(audioCategory), &audioCategory);
    
    // 侦听耳机插拔事件
    AudioSessionAddPropertyListener(kAudioSessionProperty_AudioRouteChange, audioRouteChangeCallback, (__bridge void *)(self));
    
//    UInt32 routeSpeaker = kAudioSessionOverrideAudioRoute_Speaker;
//    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(routeSpeaker), &routeSpeaker);

    UInt32 doSetProperty = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryMixWithOthers, sizeof(doSetProperty), &doSetProperty);
    
    Float32 duration = (float)320.0/8000.0;
    double version = [[UIDevice currentDevice].systemVersion doubleValue];
    if (version >= 7.0) {
        if ([UIScreen mainScreen].bounds.size.height == 568.0) {
            duration = (float)160.0/8000.0;
        }
    }
    
    //Float32 duration = (float)kAudioBufferNumFrames / kDefaultSoundRate;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareIOBufferDuration, sizeof(duration), &duration);
    Float64 hwSampleRate = 8000.0;
    AudioSessionSetProperty(kAudioSessionProperty_PreferredHardwareSampleRate, sizeof(hwSampleRate), &hwSampleRate);
    
    OSStatus status = AudioSessionSetActive(true); // 激活会话
    if (status) {
        NSLog(@"error when open AudioSession!");
        return NO;
    }
    return YES;
}

- (BOOL)exitAudioSession
{
    AudioSessionRemovePropertyListenerWithUserData(kAudioSessionProperty_AudioRouteChange, audioRouteChangeCallback, (__bridge void *)(self));
    OSStatus status = AudioSessionSetActive(false); // 反激活会话
    if (status) {
        NSLog(@"error when close AudioSession!");
        return NO;
    }
    return YES;
}

#pragma mark - check AudioChange

- (BOOL)isHeadphone {
    CFStringRef route;
    UInt32 propertySize = sizeof(CFStringRef);
    AudioSessionGetProperty(kAudioSessionProperty_AudioRoute, &propertySize, &route);
    if((route == NULL) || (CFStringGetLength(route) == 0)){
        // Silent Mode
        NSLog(@"AudioRoute: SILENT, do nothing!");
    } else {
        NSString* routeStr = (__bridge NSString *)route;
        NSLog(@"AudioRoute: %@", routeStr);
        /* Known values of route:
         * "Headset"
         * "Headphone"
         * "Speaker"
         * "SpeakerAndMicrophone"
         * "HeadphonesAndMicrophone"
         * "HeadsetInOut"
         * "ReceiverAndMicrophone"
         * "Lineout"
         */
        NSRange headphoneRange = [routeStr rangeOfString : @"Headphone"];
        NSRange headsetRange = [routeStr rangeOfString : @"Headset"];
        if (headphoneRange.location != NSNotFound) {
            return YES;
        } else if(headsetRange.location != NSNotFound) {
            return YES;
        }
    }
    return NO;
}

- (void)checkSpeaker
{
    UInt32 audioRoute;
    if (self.isHeadphone) {
        audioRoute = kAudioSessionOverrideAudioRoute_None; // 默认输出
    } else {
        audioRoute = kAudioSessionOverrideAudioRoute_Speaker; // 扬声器输出
    }
    AudioSessionSetProperty(kAudioSessionProperty_OverrideAudioRoute, sizeof(UInt32), &audioRoute);
}

-(void)setSpeckState:(BOOL)state{
    
    if ([[P2PClient sharedClient]p2pCallState] == P2PCALL_STATUS_READY_P2P) {
        self.silentAudio = state;
        if(self.callType==P2PCALL_TYPE_MONITOR){
            if(self.silentAudio){
                fgSendUserData(5, 0, NULL, 0);
            }else{
                fgSendUserData(5, 1, NULL, 0);
            }
        }
    }
}



@end
