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
#import <ifaddrs.h>
#import <arpa/inet.h>
@interface WifiService()
@property(retain,nonatomic)NSTimer *timer;
@property(retain,nonatomic)NSTimer *syncTimer;
@end


@implementation WifiService

+(instancetype)sharedInstance {
    static WifiService *singleton = nil;
    if (! singleton) {
        singleton = [[self alloc] init];
    }
    return singleton;
}

//获取ip地址
- (NSString *)getIpAddresses{
    NSString *address = @"error";
    struct ifaddrs *interfaces = NULL;
    struct ifaddrs *temp_addr = NULL;
    int success = 0;
    // retrieve the current interfaces - returns 0 on success
    success = getifaddrs(&interfaces);
    if (success == 0)
    {
        // Loop through linked list of interfaces
        temp_addr = interfaces;
        while(temp_addr != NULL)
        {
            if(temp_addr->ifa_addr->sa_family == AF_INET)
            {
                // Check if interface is en0 which is the wifi connection on the iPhone
                if([[NSString stringWithUTF8String:temp_addr->ifa_name] isEqualToString:@"en0"])
                {
                    // Get NSString from C String
                    address = [NSString stringWithUTF8String:inet_ntoa(((struct sockaddr_in *)temp_addr->ifa_addr)->sin_addr)];
                }
            }
            temp_addr = temp_addr->ifa_next;
        }
    }
    // Free memory
    freeifaddrs(interfaces);
    return address;
}

-(void)timerRun{
    
    NSString *ipAddr = [self getIpAddresses];
    NSLog(@"%@",ipAddr);
    if(![ipAddr isEqualToString:@"error"]){
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSMutableArray *hostList = [[NSMutableArray alloc]initWithArray:[defaults arrayForKey:@"hostList"]];
        [[Client sharedInstance] setHostList:hostList];
        [[Client sharedInstance] initUdp:ipAddr];
        [[Client sharedInstance] scanAndConnect];
        
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[Client sharedInstance] selector:@selector(scanServer:) userInfo:nil repeats:YES];
        [self.timer setFireDate:[NSDate distantPast]];
        
        self.syncTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(synDeviceList) userInfo:nil repeats:YES];
        [self.syncTimer setFireDate:[NSDate dateWithTimeIntervalSinceNow:3.0]];
        NSTimeInterval backgroundTimeRemanging = [[UIApplication sharedApplication] backgroundTimeRemaining];
        NSLog(@"backgroundTimeRemanging = %.02f", backgroundTimeRemanging);
    }else{
        NSLog(@"请先连接指定wifi");
    }
}

-(void)synDeviceList{
    NSMutableArray *dsockets = [Client sharedInstance].dsockets;
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.deviceList removeAllObjects];
    @synchronized(dsockets){
        for(int i=0;i<dsockets.count;i++){
            NSDictionary *device = dsockets[i][@"device"];
            if([device[@"temp"] intValue]>50){
                [device setValue:@([device[@"temp"] intValue]/10) forKey:@"temp"];
                [device setValue:@([device[@"tempUpLimit"] intValue]/10) forKey:@"tempUpLimit"];
                [device setValue:@([device[@"tempDownLimit"] intValue]/10) forKey:@"tempDownLimit"];
                [device setValue:@([device[@"hr"] intValue]/10) forKey:@"hr"];
                [device setValue:@([device[@"hrUpLimit"] intValue]/10) forKey:@"hrUpLimit"];
                [device setValue:@([device[@"hrDownLimit"] intValue]/10) forKey:@"hrDownLimit"];
                [device setValue:@([device[@"dp"] intValue]/10) forKey:@"dp"];
                [device setValue:@([device[@"dpUpLimit"] intValue]/10) forKey:@"dpUpLimit"];
                [device setValue:@([device[@"dpDownLimit"] intValue]/10) forKey:@"dpDownLimit"];
            }
            if([device[@"deviceId"] intValue]!=0){
                [appDelegate.deviceList addObject:device];
            }
        }
    }
    //NSLog(@"%lu",(unsigned long)appDelegate.deviceList.count);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncWifiNotification" object:nil];
    
}

-(void)timerStop{
    [self.timer invalidate];
    self.timer = nil;
    [self.syncTimer invalidate];
    self.syncTimer = nil;
    [[Client sharedInstance] shutdown];
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    [appDelegate.deviceList removeAllObjects];
}

-(BOOL)hasDevice{
    return [Client sharedInstance].dsockets.count>0;
}

@end
