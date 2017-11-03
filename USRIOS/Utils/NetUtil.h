//
//  NetUtil.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/18.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NetUtil : NSObject
+(int)online;
+(NSDictionary *)getWifiInfo;
+(NSString *)getWifiSsid;
@end
