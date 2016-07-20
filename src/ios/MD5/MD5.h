//
//  MD5.h
//  SDDemo
//
//  Created by MAC on 16/5/18.
//  Copyright © 2016年 yhq. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MD5 : NSObject
/**取得字符串的32位的md5加密值*/
+ (NSString *)md5_32bit:(NSString *)str;

@end
