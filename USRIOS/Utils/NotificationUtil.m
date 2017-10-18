//
//  NotificationUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "NotificationUtil.h"
#import <UIKit/UIKit.h>
#import <UserNotifications/UserNotifications.h>

@implementation NotificationUtil

+(void)sendMsg:(NSString *)msg andTitle:(NSString *)title{
    UILocalNotification *notification = [[UILocalNotification alloc] init];
    // 设置触发通知的时间
    NSDate *fireDate = [NSDate dateWithTimeIntervalSinceNow:1];
    
    notification.fireDate = fireDate;
    // 时区
    notification.timeZone = [NSTimeZone defaultTimeZone];
    // 通知内容
    notification.alertTitle = title;
    notification.alertBody =  msg;
    notification.applicationIconBadgeNumber = [UIApplication sharedApplication].applicationIconBadgeNumber+1;
    // 通知被触发时播放的声音
    notification.soundName = UILocalNotificationDefaultSoundName;
    [[UIApplication sharedApplication] scheduleLocalNotification:notification];
}
+(void)sendMsgNew:(NSString *)msg andTitle:(NSString *)title{
    UNMutableNotificationContent *content = [UNMutableNotificationContent new];
    //设置应用程序的数字图标
    content.badge =  [NSNumber numberWithInteger:[UIApplication sharedApplication].applicationIconBadgeNumber+1];
    //设置声音
    content.sound = [UNNotificationSound defaultSound];
    //设置文字
    content.title = title;
    content.body = msg;
    
    //设置触发时间和重复,用UNNotificationTrigger的子类UNTimeIntervalNotificationTrigger实现
    //NSTimeInterval发送通知时间
    //repeats是否重复
    UNTimeIntervalNotificationTrigger *trigger = [UNTimeIntervalNotificationTrigger triggerWithTimeInterval:1 repeats:NO];
    
    UNNotificationRequest *request = [UNNotificationRequest requestWithIdentifier:@"identifer" content:content trigger:trigger];
    
    //通过用户通知中心来添加一个本地通知的请求
    [[UNUserNotificationCenter currentNotificationCenter] addNotificationRequest:request withCompletionHandler:^(NSError * _Nullable error) {
        
    }];
}
@end
