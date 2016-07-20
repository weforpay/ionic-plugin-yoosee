#ifndef _P2PC_INTERFACE_H_
#define _P2PC_INTERFACE_H_

#ifdef WIN32
#define PACKED
#else
#define PACKED  __attribute__((packed))
#endif

#define  MAX_P2PCH_NS   4  //最大通道数，目前是4 请不要做更改

#define UPDATE_FLAG_SUPPORT



#define  KTRUE      1
#define  KFALSE    0
#define  DWORD        unsigned int               //32bits
#define  WORD          unsigned short           //16bits
#define  BYTE            unsigned char            //8bits
#define  KBOOL            unsigned int               //32bits
#define  UINT64        unsigned long long      //64bits


#import <Foundation/Foundation.h>

enum{
    DEV_TYPE_NULL,
    DEV_TYPE_SERVER,
    DEV_TYPE_NPC,
    DEV_TYPE_MOBILE,
    DEV_TYPE_PC,
    
    DEV_TYPE_DOORBELL,
    DEV_TYPE_ALERTOR,
    DEV_TYPE_IPC
};

#define CONN_TYPE_VIDEO_CALL  0x00
#define CONN_TYPE_MONITOR     0x01
#define CONN_TYPE_FILE_TRANS  0x02

#define VIDEO_ABILITY_320x240   (1<<0)
#define VIDEO_ABILITY_640x480   (1<<1)
#define VIDEO_ABILITY_1280x720  (1<<2)
#define VIDEO_ABILITY_1920x1080 (1<<3)

//sP2PInitPrm.vRejectSignal() 中参数dwErrorOption 的枚举定义，表示p2p连接失败的原因
enum
{
    CALL_ERROR_NONE=0,            //成功
    CALL_ERROR_DESID_NOT_ENABLE,  //对方的ID 被禁用
    CALL_ERROR_DESID_OVERDATE,    //对方的ID 过期了
    CALL_ERROR_DESID_NOT_ACTIVE,  //对方的ID 尚未激活
    CALL_ERROR_DESID_OFFLINE,     //对方离线
    CALL_ERROR_DESID_BUSY,        //对方忙线中
    CALL_ERROR_DESID_POWERDOWN,   //对方已关机
    CALL_ERROR_NO_HELPER,         //没有找到协助人
    CALL_ERROR_HANGUP,            //对方已经挂断
    CALL_ERROR_TIMEOUT,           //连接超时
    CALL_ERROR_INTER_ERROR,       //内部错误
    CALL_ERROR_RING_TIMEOUT,      //无人接听
    CALL_ERROR_PW_WRONG,          //密码错误( 在远程监控时用到密码，在视频通话是不需要)
    CALL_ERROR_CONN_FAIL,         //连接失败
    CALL_ERROR_NOT_SUPPORT,       //连接不支持
};

enum
{
    MESG_TYPE_GET_SETTING,  // 0
    MESG_TYPE_SET_SETTING,  // 1
    MESG_TYPE_RET_SETTING,
    MESG_TYPE_GET_REC_LIST,
    MESG_TYPE_RET_REC_LIST,
    MESG_TYPE_MESSAGE,
    MESG_TYPE_DEBUG_LOG_ON,
    MESG_TYPE_DEBUG_LOG_OFF,
    MESG_TYPE_DEBUG_LOG_SUBMIT,
    MESG_TYPE_ALARM_CALL,
    
    MESG_TYPE_GET_DATETIME,
    MESG_TYPE_SET_DATETIME, // 11
    MESG_TYPE_RET_DATETIME,  // 12
    
    MESG_TYPE_GET_EMIAL,  // 13
    MESG_TYPE_SET_EMIAL,  // 14
    MESG_TYPE_RET_EMIAL,  // 15
    
    MESG_TYPE_GET_WIFILIST,  // 16
    MESG_TYPE_SET_WIFILIST,  // 17
    MESG_TYPE_RET_WIFILIST,  // 18
    
    MESG_TYPE_GET_ALARMCODE_STATUS,  // 19
    MESG_TYPE_SET_ALARMCODE_STATUS,  // 20
    MESG_TYPE_RET_ALARMCODE_STATUS,  // 21
    
    MESG_TYPE_GET_APPID,  // 22
    MESG_TYPE_SET_APPID,  // 23
    MESG_TYPE_RET_APPID,  // 24
    
    MESG_TYPE_SET_INIT_PASSWD,  // 25
    MESG_TYPE_RET_INIT_PASSWD,  // 26
    
    MESG_TYPE_USER_CMD,       // 27
	MESG_TYPE_USER_CMD_RET,   // 28
    
    
	MESG_TYPE_UPG_CHEK_VERSION,     // 29
	MESG_TYPE_UPG_CHEK_VERSION_RET,         // 30
	MESG_TYPE_UPG_FILE_TO_DOWNLOAD,        // 31
	MESG_TYPE_UPG_FILE_TO_DOWNLOAD_RET,     // 32
	MESG_TYPE_UPG_FILE_CANCEL_DOWNLOAD,	    // 33
	MESG_TYPE_UPG_FILE_CANCEL_DOWNLOAD_RET,  //34
	
	MESG_TYPE_UPG_CHEK_CUR_VERSION,          // 35
	MESG_TYPE_UPG_CHEK_CUR_VERSION_RET,		//36
    
    MESG_TYPE_UPG_CREATE_WHOLEFLASH_TO_FILE,          // 37
	MESG_TYPE_UPG_CREATE_WHOLEFLASH_TO_FILE_RET,      // 38
	MESG_TYPE_GET_SYS_VERSION,               // 39
	MESG_TYPE_GET_SYS_VERSION_RET,          // 40
	MESG_TYPE_DRBL_ACK_GET = 58,
    MESG_TYPE_DRBL_ACK_RET,           // 59
	MESG_TYPE_DRBLCALL,                  //60
    MESG_TYPE_DRBL_HOSTSTA_RET,        // 61
    
	MESG_TYPE_DEV_CHKCODE_SEND,     // 62
	MESG_TYPE_DRBL_CHKCODE_SEND,   // 63
	MESG_TYPE_DEV_UNLOCK_DRBL,       // 64
	MESG_TYPE_UNLOCK_DRBL_RET,      // 65
    
    MESG_TYPE_GET_SDCARD_INFO = 80,
    MESG_TYPE_SET_FORMAT_SDCARD = 81,
    
    MESG_TYPE_GET_DEFENCE_SWITCH_STATE,  //82   获取防区开关
    MESG_TYPE_SET_DEFENCE_SWITCH_STATE,  //83   设置防区开关
    MESG_TYPE_RET_DEFENCE_SWITCH_STATE,  //84   设置返回值
    
    MESG_TYPE_SET_GPIO_CTL = 95,
    MESG_TYPE_RET_GPIO_CTL, //值：96
    
    MESG_TYPE_WORKMODE_SETTING =149,
    
    MESG_TYPE_QRCODE_LEARN_CODE =216,
    
    MESG_TYPE_CUSTOM_CMD_NO_VERRIFY_SET = 127,
    MESG_TYPE_CUSTOM_CMD_NO_VERRIFY_RET,   //128
    
    MESG_TYPE_GET_DEVICE_LANGUAGE = 211,
    MESG_TYPE_SET_DEVICE_LANGUAGE,       //212
    MESG_TYPE_RET_DEVICE_LANGUAGE,       //213
    
    MESG_TYPE_SETORGET_LENS_FOCUS_PARAMS = 224,   // 自动变焦  获取和设置变焦镜头马达当前位置的命令是一样滴  消息头命令
	
	MESG_TYPE_DEVICE_NOT_SUPPORT_RET = 0XFF,

};

enum{
    MESG_SUBTYPE_SETTING_WORKMODE_DEFAULT,//0
    
    MESG_SUBTYPE_SETTING_IPC_WORKMODE,  //1
    MESG_SUBTYPE_SETTING_IPC_WORKMODE_RET,//2
    
    MESG_SUBTYPE_SETTING_SENSOR_WORKMODE,//3
    MESG_SUBTYPE_SETTING_SENSOR_WORKMODE_RET,//4
    
    MESG_SUBTYPE_SETTING_SCHEDULE_WORKMODE,//5
    MESG_SUBTYPE_SETTING_SCHEDULE_WORKMODE_RET,//6
    
    MESG_SUBTYPE_DELETE_SCHEDULE,//7
    MESG_SUBTYPE_DELETE_SCHEDULE_RET,//8
    
    MESG_SUBTYPE_GET_CURRENTWORKMODE,//9
    MESG_SUBTYPE_GET_CURRENTWORKMODE_RET,//10
    
    MESG_SUBTYPE_GET_SENSORWORKMODE,//11
    MESG_SUBTYPE_GET_SENSORWORKMODE_RET,//12
    
    MESG_SUBTYPE_GET_WORKMODE_SCHEDULE, //13
    MESG_SUBTYPE_GET_WORKMODE_SCHEDULE_RET,//14
    
    MESG_SUBTYPE_SETTING_ALL_SENSOR_SWITCH,//15
    MESG_SUBTYPE_SETTING_ALL_SENSOR_SWITCH_RET,//16
    
    MESG_SUBTYPE_GET_ALL_SENSOR_SWITCH,//17
    MESG_SUBTYPE_GET_ALL_SENSOR_SWITCH_RET,//18
    
    MESG_SUBTYPE_SET_LOW_VOL_TIMEINTERVAL,//19
    MESG_SUBTYPE_SET_LOW_VOL_TIMEINTERVAL_RET,//20
    
    MESG_SUBTYPE_GET_LOW_VOL_TIMEINTERVAL,//21
    MESG_SUBTYPE_GET_LOW_VOL_TIMEINTERVAL_RET,//22
    
    MESG_SUBTYPE_DELETE_ONE_CONTROLER,//23
    MESG_SUBTYPE_DELETE_ONE_CONTROLER_RET,//24
    
    MESG_SUBTYPE_DELETE_ONE_SENSOR,//25
    MESG_SUBTYPE_DELETE_ONE_SENSOR_RET,//26
    
    MESG_SUBTYPE_CHANGE_CONTROLER_NAME,//27
    MESG_SUBTYPE_CHANGE_CONTROLER_NAME_RET,//28
    
    MESG_SUBTYPE_CHANGE_SENSOR_NAME,//29
    MESG_SUBTYPE_CHANGE_SENSOR_NAME_RET,//30
    
    MESG_SUBTYPE_INTO_LEARN_STATE,//31
    MESG_SUBTYPE_INTO_LEARN_STATE_RET,//32
    
    MESG_SUBTYPE_TURN_SENSOR,//33
    MESG_SUBTYPE_TURN_SENSOR_RET,//34
    
    MESG_SUBTYPE_SHARE_TO_MEMBER,//35
    MESG_SUBTYPE_SHARE_TO_MEMBER_RET,//36
    MESG_SUBTYPE_GOT_SHARE_MESG,//37
    
    MESG_SUBTYPE_GOT_SHARE_MESG_RET,//38
    MESG_SUBTYPE_DEV_RECV_MEMBER_FEEDBACK,//39
    
    MESG_SUBTYPE_ADMIN_DELETE_ONE_MEMBER,//40
    MESG_SUBTYPE_ADMIN_DELETE_ONE_MEMBER_RET,//41
    
    MESG_SUBTYPE_DELETE_DEV,//42
    MESG_SUBTYPE_DELETE_DEV_RET,//43
    
    MESG_SUBTYPE_SET_ONE_SPECIAL_ALARM=46, //46
    MESG_SUBTYPE_SET_ONE_SPECIAL_ALARM_RET, //47
    
    MESG_SUBTYPE_GET_ALL_SPECIAL_ALARM, //48
    MESG_SUBTYPE_GET_ALL_SPECIAL_ALARM_RET, //49
    
    MESG_SUBTYPE_DEAL_LAMP, //50
    MESG_SUBTYPE_DEAL_LAMP_RET, //51
    
    MESG_SUBTYPE_KEEPCLIENT, //52
    MESG_SUBTYPE_KEEPCLIENT_RET,  //53
    
    MESG_SUBTYPE_MAX
};

enum
{
    OS_ARM_LINUX,
    OS_ANDROID,
    OS_IOS,
    OS_MAC,
    OS_WINDOWS,
    OS_X86_LINUX,
    
    OS_NONE = 0xFF,
    
};



enum  {
    PUSH_MESG_SYSTEM,
    PUSH_MESG_VERIFY,
    PUSH_MESG_FRIEND,
    PUSH_MESG_ALARM,
    PUSH_MESG_CALL,
    PUSH_MESG_DOORBELL
    };

enum
{
  ID_STATUS_OFFLINE,
  ID_STATUS_ONLINE,
  ID_STATUS_INACTIVE,
};

#define MAX_FRIENDS_NS 256

typedef struct  sFriendsType
{
    DWORD dwFriendsCount;
    DWORD dwFriends[MAX_FRIENDS_NS];
    BYTE  bStatus[MAX_FRIENDS_NS];
    BYTE  bType[MAX_FRIENDS_NS];
	
}PACKED  sFriendsType;

typedef struct sCallingPrmType
{
    KBOOL       fgBCalled;
    DWORD   dwHisID;
    DWORD   dwHisDevType;
    KBOOL       fgInSameDomain;
    KBOOL       fgSuperCall;
    DWORD   dwRemoteChNs;
    DWORD   dwCallPrm[4];
    
}sCallingPrmType;

//网络库的初始化参数
typedef struct sP2PInitPrm
{
    DWORD   dw3CID;           // 本机ID   ;  调试时可以使用: dw3CID=2000,  dwR1=0x5a8d47b0, dwR2=0x4fd73aa3
    DWORD   dwCode1;         // 检验码1
    DWORD   dwCode2;          // 检验码2
    char *      pHostName;     // 服务器表,请传入:  "|www.cloudlinks.cn|www.cloud-links.net|www.gwelltimes.com"
    DWORD   dwChNs;           // 本机通道数目，请设为1
    DWORD   dwChBufSize[MAX_P2PCH_NS]; // 每个通道的缓存大小，请统一设置为(1024*512)
    DWORD   dwPassword;   //密码，请设为十进制数: 123456
    DWORD   dwCustomerID[10];  // 添加这一行，客户编号。设为0表示全部设备都能接入
    // 被呼叫 时，当有人拨打进来，通过此函数 告知上层。
    // 主叫时，拨打已经通了。对方正在响铃，也回调此函数。
    // fgBCalled : KTRUE 表示 被呼叫, KFALSE 表示主叫。 
    // dwHisID  :  对方ID 号。
    // fgInSameDomain :对方跟本机在  同一个局域网里。
    // fgMonitorOnly :  暂时没有用。
    // dwRemoteChNs : 暂时没有用。
    void (* vCallingSignal )(sCallingPrmType *sCallPrm); 
    
    
	//呼叫被拒绝或者连接断开的回调函数
	// fgBCalled : TRUE 表示 被呼叫, FALSE 表示主叫。
	// dwErrorOption:  断开的原因，请参见前述枚举。
    void (* vRejectSignal )(KBOOL fgBCalled,  DWORD dwErrorOption);
    
    //接听回调函数, 当对方接通了或本机接听了来电，通过此函数告知上层。
    // fgBCalled : TRUE 表示 被呼叫, FALSE 表示主叫。 
   void (* vAcceptSignal )(KBOOL fgBCalled, DWORD *pdwPrm);

    // 连接OK 回调函数，当连接通道一切就绪，告诉上层开始传输音视频。
   void (* vP2PConnReady)(void);
   void (* vRecvRemoteMessage)(DWORD dwSrcID, KBOOL fgHasCheckdPassword,  void *pMesg, DWORD dwMesgSize);

   void (* vSendMessageAck)(DWORD dwDesID, DWORD dwMesgID, DWORD  dwError);

   void (* vFriendsStatusUpdate)(sFriendsType * pFriends );
#ifdef UPDATE_FLAG_SUPPORT
void (* vFlagUpdate)(DWORD *pdwFlags );
#endif
   

}sP2PInitPrm;

#ifdef UPDATE_FLAG_SUPPORT
void vP2PSetUpdateFlag(DWORD *pdwFlag);//得到新的系统消息后，调此函数映射回，停止回调
#endif
enum
{
   MESG_ERROR_NONE,
   MESG_ERROR_PASSWORD_FAIL ,
   MESG_ERROR_TIMEOUT,
   MESG_IOS_PUSH_ERROR,
   MESG_ERROR_NO_RIGHT,
};

KBOOL     fgP2PInit(sP2PInitPrm * pPrm);  // 网络库初始化
void       vP2PExit(void);                // 网络库退出并释放资源


KBOOL      fgP2PLinkOK(void);   // 查看网络库状态.(类似与QQ 是否在线)

//呼叫一个ID
// dwId: 对方ID 号。
// fgSuperCall:   KTRUE:监控,  KFALSE : 视频电话。
// dwPassword :  如果视频监控，此为对方的监控密码。

// 16-code 48 手机号
KBOOL   fgP2PCall(UINT64 u64Id,  KBOOL  fgSuperCall, DWORD dwPassword,  DWORD *pdwPrm,  char *strPushMesg);
void   vP2PHungup(KBOOL fgWaitFinish); // 挂断连接
void   vP2PAccept(DWORD *pdwPrm);   // 接受呼叫
KBOOL   fgP2PSendRemoteMessage(DWORD  dwDesID, DWORD dwRemotePW, DWORD dwMesgID,  void * pMesg,  DWORD  dwMesgSize, char * pPushMesg,  DWORD  dwPushMesgLen, DWORD dwType);
KBOOL   fgP2PGetFriendsStatus(DWORD  *pFriendsTable, DWORD dwCount);



///////////////////////////////////////////////////////////////




//////////////////////////
enum
{
    PACKET_TYPE_AV_DATA = 0,  
    PACKET_TYPE_HEADER_ONLY ,
    PACKET_TYPE_USR_DATA,
    
};

//AV 数据分组头结构
typedef struct  sAVBlockHeaderType
{
    BYTE        bHeaderFlag[4]; //  分组头标记 0xFF 0xFF 0xFF 0x88
    BYTE        bVersion;      //  版本号
    BYTE        bPacketType;  //  此分组的类型，
    
    WORD      wAudioPackCnt;  //当前分组中音频帧的数量
    DWORD    dwVideoDataLen;  //当前分组中视频数据的长度
    UINT64     u64VPTS;        //当前分组中视频帧时间戳，uS为单位
    UINT64     u64APTS;       //当前分组中音频帧时间戳，uS为单位
    
}PACKED  sAVBlockHeaderType;

//AV 信息头
typedef struct sAVInfoType
{
   	//{
    WORD    AudioType:                3;   //音频编码格式
    WORD    AudioCodecOption:    4;        //音频编码的参数
    WORD    AudioMode:                1;  // 音频模式： 单声道/双声道
    WORD    AudioBitWidth:           2;    // 音频位宽，目前只支持16bit
    WORD    AudioSampleRate :      3;      // 音频采样率
    WORD    SampleNumPerFrame : 3;        //每帧数据里的采样数
    //}
    
	//{
    DWORD  VideoType:           4;  /// 视频类型，目前只支持H264
    DWORD  VideoWidth:         12;  // 视频像素宽度
    DWORD  VideoHeight:        10;   //视频像素高度
    DWORD  videoFrameRate: 6;        // 视频帧率
    //} 
    
}PACKED sAVInfoType;


//AV 信息分组数据结构
typedef struct  sAVBlockHeader2Type
{
    BYTE        bHeaderFlag[4]; //  分组头标记 0xFF 0xFF 0xFF 0x88
    BYTE        bVersion;  //  版本号
    BYTE        bPacketType;  //  此分组的类型
    
    sAVInfoType     sAvInfo;  //音视频格式信息
    UINT64     u64VPTS;  //当前分组中视频帧时间戳，uS为单位
    UINT64     u64APTS;  //当前分组中音频帧时间戳，uS为单位
    
}PACKED  sAVBlockHeader2Type;


/////音频类型
enum
{
    AUDIO_TYPE_NONE = 0,
    AUDIO_TYPE_G711A ,
    AUDIO_TYPE_G711U ,
	AUDIO_TYPE_PT_G726 ,
	AUDIO_TYPE_PT_AAC,
	AUDIO_TYPE_PT_AMR,
	AUDIO_TYPE_PT_ADPCMA,
	AUDIO_TYPE_MAX,
};

///AMR音频编码选项
enum 
{
    AMR_FORMAT_MMS,   
    AMR_FORMAT_IF1,     
    AMR_FORMAT_IF2,   
    AMR_FORMAT_NONE,
};

//音频模式 单声道/立体声
enum 
{
    AUDIO_SOUND_MODE_MOMO   =0,/*mono*/
    AUDIO_SOUND_MODE_STEREO =1,/*stereo*/
    AUDIO_SOUND_MODE_NONE  ,  
};

// 音频采样位宽
enum 
{
    AUDIO_BIT_WIDTH_8   = 0,   /* 8bit width */
    AUDIO_BIT_WIDTH_16  = 1,   /* 16bit width*/
    AUDIO_BIT_WIDTH_32  = 2,   /* 32bit width*/
    AUDIO_BIT_WIDTH_NONE,
};

////音频采样率
enum  
{ 
    AUDIO_SAMPLE_RATE_8K   = 0,    /* 8K samplerate*/
    AUDIO_SAMPLE_RATE_11K ,   /* 11.025K samplerate*/
    AUDIO_SAMPLE_RATE_16K ,   /* 16K samplerate*/
    AUDIO_SAMPLE_RATE_22K	,   /* 22.050K samplerate*/
    AUDIO_SAMPLE_RATE_24K ,   /* 24K samplerate*/
    AUDIO_SAMPLE_RATE_32K ,   /* 32K samplerate*/
    AUDIO_SAMPLE_RATE_44K ,   /* 44.1K samplerate*/
    AUDIO_SAMPLE_RATE_48K ,   /* 48K samplerate*/
    
}; 

////音频每帧采样数
enum
{
    SAMPLE_NUM_80 = 0,
    SAMPLE_NUM_160 ,
    SAMPLE_NUM_320 ,
    SAMPLE_NUM_480 ,
    SAMPLE_NUM_1024 ,
    SAMPLE_NUM_2048 ,
    
};


///视频类型
enum
{
    VIDEO_TYPE_NONE = 0 ,
    VIDEO_TYPE_H264 ,
    VIDEO_TYPE_MPEG4 ,
    VIDEO_TYPE_JPEG,
    VIDEO_TYPE_MJPEG,
    
};

//user data bCommandType
enum
{
    USR_CMD_PTZ_CTL,  //云台控制
    USR_CMD_VIDEO_CTL,  // 视频控制
    USR_CMD_REMOTLY_DEFENCE_CTL, //
    USR_CMD_PLAY_CTL,
    USR_CMD_AUDIO_ONLY,
    USR_CMD_FM1188_CTL,
    USR_CMD_CURRENT_USERS_NS,
    USR_CMD_MAX_NS,
};



//bCommandOption
enum
{
    USR_CMD_OPTION_PTZ_TURN_LEFT,
    USR_CMD_OPTION_PTZ_TURN_RIGHT,
    USR_CMD_OPTION_PTZ_TURN_UP,
    USR_CMD_OPTION_PTZ_TURN_DOWN,
};

enum
{
    USR_CMD_OPTION_VIDEO_PAUSE, //暂停
    USR_CMD_OPTION_VIDEO_RESUME, //  继续
    USR_CMD_OPTION_VIDEO_FAST_FORWARD, // 快进
    USR_CMD_OPTION_VIDEO_SLOW_FORWARD, //慢进
    USR_CMD_OPTION_VIDEO_STEP,   // 单步
};

//bCommandOption
enum
{
    USR_CMD_OPTION_START_DEFENCE,
    USR_CMD_OPTION_STOP_DEFENCE,
    USR_CMD_OPTION_READ_DEFENCE_STATUS,
    USR_CMD_OPTION_WRITE_DEFENCE_STATUS,
};

//bCommandOption
enum
{
   USR_CMD_OPTION_NONE,
   USR_CMD_OPTION_FILE_INFO, //begin PTS = (((UINT64)(pUserData->dwCmdData[0])<<32) |pUserData->dwCmdData[1]);//End PTS = (((UINT64)(pUserData->dwCmdData[2])<<32) |pUserData->dwCmdData[3]);
   USR_CMD_OPTION_FILE_END, //
   	
   USR_CMD_OPTION_PAUSE,
   USR_CMD_OPTION_PAUSE_RET,
     
   USR_CMD_OPTION_RESUME,
   USR_CMD_OPTION_RESUME_RET,
   
   USR_CMD_OPTION_JUMP,//memcpy(&u64JumpTargetPTS , pUsrCmd->dwCmdData, sizeof(UINT64) );
   USR_CMD_OPTION_JUMP_RET, //pUserData->dwCmdData[0] : true , false
    
   USR_CMD_OPTION_NEXT_FILE, //memcpy(&sTargetNextFile, pUsrCmd->dwCmdData, sizeof(sRecFilenameType) );
   USR_CMD_OPTION_NEXT_FILE_RET, ////pUserData->dwCmdData[0] : true , false

   USR_CMD_OPTION_STOP,
   USR_CMD_OPTION_STOP_RET,//pUserData->dwCmdData[0] : true , false

   USR_CMD_OPTION_PLAY,
   USR_CMD_OPTION_PLAY_RET,//pUserData->dwCmdData[0] : true , false


};

////用户数据分组结构
typedef struct  sUsrDataBlockHeaderType
{
    BYTE        bHeaderFlag[4];
    BYTE        bVersion;
    BYTE        bPacketType; ////PACKET_TYPE_USR_DATA
    
    BYTE        bCommandType; //
    BYTE        bCommandOption;
    
    DWORD    dwCmdData[5]; //保留
    
}PACKED  sUsrDataBlockHeaderType;

////////////////////////////////////////////////////////////////



#define SUPPORT_REC_TO_FILE

#define  GBOOL         unsigned int



/////////////////////av encode interface///////////////////////////
GBOOL    fgStartAVEncAndSend(DWORD dwVideoFrameRate);
void     vStopAVEncAndSend(void);
GBOOL    fgFillVideoRawFrame(BYTE *pbData, DWORD dwSize, DWORD dwWidth, DWORD dwHeight, GBOOL fgX2Reflection);
void     vFillAudioRawData(BYTE *pbData, DWORD dwSize);
GBOOL    fgSendUserData(DWORD dwCmd,   DWORD  dwOption , BYTE * pData,  DWORD  dwDataLen) ;

///////////////////////end of av encode interface///////////////////////////////////

typedef struct GAVFrame
{
    BYTE *data[3];
    int  linesize[3];
    int  width;
    int  height;
    uint64_t pts;
}GAVFrame;


#define CONN_TYPE_VIDEO_CALL  0x00
#define CONN_TYPE_MONITOR     0x01
#define CONN_TYPE_FILE_TRANS  0x02
#define CONN_TYPE_PLAY_REC_FILE 0x02

typedef struct sRecAndDecPrm
{
    DWORD  dwConnectType;//以前是传的1或者0 现在需要改一改
    void (* vRecvUserDataCallBack )(DWORD dwCmd, DWORD  dwOption , DWORD * pdwData,  DWORD  dwDataLen);
    void    (*vRecvAVHeader)(sAVInfoType * pAVInfo) ;
    void    (*vRecvAVData)(BYTE *pAudioData, DWORD dwAudioDataLen, DWORD dwFrames, UINT64 u64APTS, BYTE *pVideoData, DWORD dwVideoLen,  UINT64 u64VPTS) ;
    
}sRecAndDecPrm;
////////////////////////av decode interface //////////////////////////////////
GBOOL       fgStartRecvAndDec(sRecAndDecPrm *psInitPrm);
void        vStopRecvAndDec(void);
GBOOL       fgGetAudioDataToPlay(BYTE * pDesBuf,  DWORD dwSize) ;
GBOOL       fgGetVideoFrameToDisplay(GAVFrame ** pFrame);
void        vReleaseVideoFrame(void) ;
void        vSetSupperDrop(KBOOL fgDrop);
//////////////////////end of av decode interface////////////////////////////////
//暂停两者不播放
#ifdef SUPPORT_REC_TO_FILE
GBOOL    fgStartRecordToFile(char *pFileName);
void    vStopRecord(void);
#endif

#endif //_P2PC_INTERFACE_H
