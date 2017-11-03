//
//  OnlineService.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/20.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OnlineService : NSObject
+(instancetype)sharedInstance;
-(void)timerRun;
-(void)timerStop;
-(void)timerRunBack;
@end
