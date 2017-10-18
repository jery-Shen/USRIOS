//
//  NetUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/18.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "NetUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>  

@implementation NetUtil
+(NSDictionary *)getWifiInfo{
    return nil;
}
+(NSString *)getWifiSsid{
    NSString *ssid = nil;
    NSArray *ifs = (__bridge_transfer NSArray *)CNCopySupportedInterfaces();
    for (NSString *ifname in ifs) {
        NSDictionary *info = (__bridge id)CNCopyCurrentNetworkInfo((__bridge CFStringRef)ifname);
        if (info[@"SSIDD"])
        {
            ssid = info[@"SSID"];
        }
    }
    return ssid;
}
@end
