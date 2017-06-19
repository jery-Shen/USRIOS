//
//  HttpUtil.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/19.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpUtil : NSObject
extern NSString * const URL_PRE;
+(NSDictionary *)getSign:(NSDictionary *)user;
@end
