//
//  NetUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/18.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "NetUtil.h"
#import "HttpUtil.h"
#import <SystemConfiguration/CaptiveNetwork.h>  

@implementation NetUtil
+(int)online{
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@OnLine",URL_PRE]];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      NSDictionary *res =   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                      NSLog(@"初始化：%@",res);
                                  }];
    [task resume];
    return 0;
}
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
