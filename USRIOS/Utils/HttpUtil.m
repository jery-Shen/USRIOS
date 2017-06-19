//
//  HttpUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/19.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "HttpUtil.h"

@implementation HttpUtil

NSString * const URL_PRE = @"http://ivc.lightxx.cn/";

+(NSDictionary *)getSign:(NSDictionary *)user{
    NSDictionary *map = [NSDictionary dictionaryWithObjectsAndKeys:@"123",@"token",@"123",@"timestamp",@"123",@"sign", nil];
    return map;
}

@end
