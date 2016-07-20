//
//  Utils.m
//  Yoosee
//
//  Created by guojunyi on 14-3-21.
//  Copyright (c) 2014年 guojunyi. All rights reserved.
//

#import "Utils.h"
#import "MD5Manager.h"

@implementation Utils
+(NSString*)getPasswordWithNoHead:(NSString*) password{
    NSString* sHead = PASSWORD_HEAD;
    if ([sHead length] >= [password length]) {
        return nil;
    }
    NSString* sTempHead = [password substringToIndex:[sHead length]];
    if (![sTempHead isEqualToString:sHead]) {
        return nil;
    }
    NSString* ret = [password substringFromIndex:[sHead length]];
    return ret;
}
+(unsigned int)GetTreatedPassword:(NSString*)sPassword{
    if (!sPassword){
        return 294136;
    }
    NSString* ss = [Utils getPasswordWithNoHead:sPassword];
    if (ss) {
        unsigned int ret = [MD5Manager GetTreatedPassword:[ss UTF8String]];
        return ret;
    }
    if ([sPassword characterAtIndex:0] == '0') {
        return sPassword.intValue;
    }
    unsigned int ret = [MD5Manager GetTreatedPassword:[sPassword UTF8String]];
    return ret;
}

@end

