//
//  OnlineService.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/20.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "OnlineService.h"

int num = 0;
@interface OnlineService()
@property(retain,nonatomic)NSTimer *timer;
@end

@implementation OnlineService

+(instancetype)sharedInstance {
    static OnlineService *singleton = nil;
    if (! singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

-(void)console{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(action) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    NSTimeInterval backgroundTimeRemanging = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"backgroundTimeRemanging = %.02f", backgroundTimeRemanging);
    
}

-(void)action{
    NSLog(@"aa:%d",num);
    num++;
    if(num%10==0){
        [self sendMsg:@"提示"];
    }
    if(num==700){
        //[self sendMsg:@"完成"];
        [self.timer invalidate];
        self.timer = nil;
    }
}

-(void)sendMsg:(NSString *)msg{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    
    
    // 通知内容
    notification.alertBody =  msg;
    notification.applicationIconBadgeNumber = num/10;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}

@end
