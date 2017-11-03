//
//  WifiService.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface WifiService : NSObject
+(instancetype)sharedInstance;
-(void)timerRun;
-(void)timerStop;
-(BOOL)hasDevice;
@end
