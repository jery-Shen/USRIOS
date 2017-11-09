//
//  Client.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
#import "AsyncUdpSocket.h"
@interface Client : NSObject
+ (Client *)sharedInstance;
@property (nonatomic, strong) NSMutableArray *hostList;
@property (nonatomic, strong) NSMutableArray *dsockets;
@property (nonatomic, strong) AsyncUdpSocket *ds;
@property (nonatomic, copy  ) NSString       *wifiIp;   // socket的Host

-(void)shutdown;


-(void)setHostList:(NSMutableArray *)hostList;
-(void)initUdp:(NSString *)ip;
-(void)scanAndConnect;
-(void)scanServer:(int)scanNum;

@end
