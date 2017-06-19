//
//  Client.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AsyncSocket.h"
@interface Client : NSObject
+ (Client *)sharedInstance;
@property (nonatomic, strong) AsyncSocket    *socket;       // socket
@property (nonatomic, copy  ) NSString       *socketHost;   // socket的Host
@property (nonatomic, assign) UInt16         socketPort;    // socket的prot

-(void)socketConnectHost;// socket连接
-(void)writeData:(NSData *)data;
-(void)shutdown;
@end
