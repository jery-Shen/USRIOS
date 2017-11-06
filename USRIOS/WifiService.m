//
//  WifiService.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//
#import "AppDelegate.h"
#import "WifiService.h"
#import "Client.h"
#import "Hex.h"
#import "CRC.h"
@interface WifiService()
@property(retain,nonatomic)NSTimer *timer;
@end


@implementation WifiService

+(instancetype)sharedInstance {
    static WifiService *singleton = nil;
    if (! singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

-(void)timerRun{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSMutableArray *hostList = [[NSMutableArray alloc]initWithArray:[defaults arrayForKey:@"hostList"]];
    [[Client sharedInstance] setHostList:hostList];
    [[Client sharedInstance] initUdp:@"10.10.13.245"];
    [[Client sharedInstance] scanAndConnect];

    self.timer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:[Client sharedInstance] selector:@selector(scanServer:) userInfo:nil repeats:YES];
    [self.timer setFireDate:[NSDate distantPast]];
    NSTimeInterval backgroundTimeRemanging = [[UIApplication sharedApplication] backgroundTimeRemaining];
    NSLog(@"backgroundTimeRemanging = %.02f", backgroundTimeRemanging);
}

-(void)timerStop{
    [self.timer invalidate];
    self.timer = nil;
    [[Client sharedInstance] shutdown];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.deviceList removeAllObjects];
}

-(BOOL)hasDevice{
    return [Client sharedInstance].dsockets.count>0;
}

@end
