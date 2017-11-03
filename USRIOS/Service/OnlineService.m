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
#import "HttpUtil.h"
#import "NotificationUtil.h"

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

-(void)timerRun{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    NSTimeInterval backgroundTimeRemanging = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"backgroundTimeRemanging = %.02f", backgroundTimeRemanging);
}

-(void)timerStop{
    [self.timer invalidate];
    self.timer = nil;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.deviceList removeAllObjects];
}

-(void)timerRunBack{
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(loadData) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    NSTimeInterval backgroundTimeRemanging = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"backgroundTimeRemanging = %.02f", backgroundTimeRemanging);
    
}

-(void)loadData{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    NSDictionary *map = [HttpUtil getSign:user];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@GetDeviceListDao?areaId=%d&token=%@&timestamp=%@@&sign=%@",URL_PRE,[user[@"areaId"] intValue],map[@"token"],map[@"timestamp"],map[@"sign"]]];
    //NSLog(@"%@",url);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if(!error){
                                          NSDictionary *res =   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                          if([res[@"status"] intValue] == 200){
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSArray *items = res[@"result"];
                                                  AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
                                                  for(int i = 0; i < [items count]; i++)
                                                  {
                                                      NSDictionary *device = items[i];
                                                      NSDictionary *localDevice = [appDelegate getDevice:[device[@"deviceId"] intValue]];
                                                      if(localDevice==nil){
                                                         [appDelegate.deviceList addObject:items[i]];
                                                      }else{
                                                          [appDelegate.deviceList replaceObjectAtIndex:[appDelegate.deviceList indexOfObject:localDevice] withObject:device];
                                                          [self diffAlarmLocalDevice:localDevice andDevcie:device];
                                                          
                                                      }
                                                      
                                                  }
                                                  [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncLineNotification" object:nil];
                                              });
                                          }
                                      }
                                  }];
    [task resume];
}


-(void)diffAlarmLocalDevice:(NSDictionary *)localDevice andDevcie:(NSDictionary *)device{
    if (device[@"infoBar"] != localDevice[@"infoBar"] && [device[@"infoBar"] intValue] > 1) {
        NSString *alarmMsg = [self stringOfInfoBar:[device[@"infoBar"] intValue]];
        switch ([device[@"infoBar"] intValue]) {
            case 4:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@大于上限%@",device[@"temp"], device[@"tempUpLimit"]];
                break;
            case 5:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@小于下限%@",device[@"temp"], device[@"tempDownLimit"]];
                break;
            case 6:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@大于下限%@",device[@"hr"], device[@"hrUpLimit"]];
                break;
            case 7:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@小于下限%@",device[@"hr"], device[@"hrDownLimit"]];
                break;
            case 8:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@大于下限%@",device[@"dp"], device[@"dpUpLimit"]];
                break;
            case 9:
                alarmMsg = [alarmMsg stringByAppendingFormat:@"，当前%@小于下限%@",device[@"dp"], device[@"dpDownLimit"]];
                break;
            default:
                break;
        }
        NSLog(@"%@",alarmMsg);
        [NotificationUtil sendMsg:alarmMsg andTitle:[NSString stringWithFormat:@"设备%@",device[@"deviceId"]]];
    }
}

-(NSString *)stringOfInfoBar:(int)infoBar{
    NSString *infoBarStr = @"";
    switch (infoBar) {
        case 0:
            infoBarStr = @"待机状态，按开启键启动";
            break;
        case 1:
            infoBarStr = @"工作正常，按关闭键停止";
            break;
        case 2:
            infoBarStr = @"温度过低";
            break;
        case 3:
            infoBarStr = @"断电报警";
            break;
        case 4:
            infoBarStr = @"温度超高";
            break;
        case 5:
            infoBarStr = @"温度过低";
            break;
        case 6:
            infoBarStr = @"湿度超高";
            break;
        case 7:
            infoBarStr = @"湿度过低";
            break;
        case 8:
            infoBarStr = @"压差过高";
            break;
        case 9:
            infoBarStr = @"压差过低";
            break;
        case 10:
            infoBarStr = @"模拟量采集通讯故障";
            break;
        case 11:
            infoBarStr = @"进风自动调节上限";
            break;
        case 12:
            infoBarStr = @"进风自动调节下限";
            break;
        case 13:
            infoBarStr = @"模拟量采集通讯故障";
            break;
            
    }
    return infoBarStr;
}

@end
