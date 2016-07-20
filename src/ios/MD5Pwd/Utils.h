//
//  Utils.h
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import <Foundation/Foundation.h>

#define  DWORD        unsigned int
#define  BYTE         unsigned char

#define PASSWORD_HEAD @"passwordhead"

enum{
    password_weak,
    password_middle,
    password_strong,
    password_null
};

@interface Utils:NSObject
+(NSString*)getPasswordWithNoHead:(NSString*) password;
+(unsigned int)GetTreatedPassword:(NSString*)sPassword;
@end
