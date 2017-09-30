//
//  ViewUtil.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ViewUtil : NSObject
+(UIColor *) colorHex: (NSString *) stringToConvert;
+(void)alertMsg:(NSString *)msg inViewController:(UIViewController *)vc;
+(void)confirmMsg:(NSString *)msg inViewController:(UIViewController *)vc callback:(void(^)(void))callback;
+(NSString *)stringOfInfoBar:(int)infoBar;
@end
