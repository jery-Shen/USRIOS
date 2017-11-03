//
//  NotificationUtil.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NotificationUtil : NSObject
+(void)sendMsg:(NSString *)msg andTitle:(NSString *)title;
+(void)sendMsgNew:(NSString *)msg andTitle:(NSString *)title;
@end
