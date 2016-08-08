//
//  ViewController.h
//  yooseeMonitorDemo
//
//  Created by apple on 16/6/17.
//  Copyright © 2016年 yuanHongQiang. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>

typedef void(^SeeResultCb)(int);

@interface ViewController : UIViewController{
}
@property(nonatomic,copy) NSString *deviceId;
@property(nonatomic,copy) NSString *devicePwd;
@property(nonatomic , strong) SeeResultCb seeResult;
@end

