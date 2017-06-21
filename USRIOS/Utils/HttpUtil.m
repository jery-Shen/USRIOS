//
//  HttpUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/19.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//
#import<CommonCrypto/CommonDigest.h>
#import "HttpUtil.h"

@implementation HttpUtil

NSString * const URL_PRE = @"http://ivc.lightxx.cn/";

+(NSDictionary *)getSign:(NSDictionary *)user{
    NSString *token = user[@"userName"];
    NSString *timestamp = [NSString stringWithFormat:@"%ld",(long)[[NSDate date] timeIntervalSince1970]];
    NSString *sign = [HttpUtil md5:[NSString stringWithFormat:@"%@IVC%@",token,timestamp]];
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:token,@"token",timestamp,@"timestamp",sign,@"sign", nil];
    return map;
}

+ (NSString *) md5:(NSString *) input {
    const char *cStr = [input UTF8String];
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

@end
