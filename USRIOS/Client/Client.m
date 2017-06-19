//
//  Client.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "Client.h"
#import "Hex.h"

@implementation Client
+(Client *) sharedInstance
{
    
    static Client *sharedInstace = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        
        sharedInstace = [[self alloc] init];
    });
    
    return sharedInstace;
}

// socket连接
-(void)socketConnectHost{
    
    self.socket    = [[AsyncSocket alloc] initWithDelegate:self];
    
    NSError *error = nil;
    self.socketHost = @"10.10.13.245";
    self.socketPort = 8089;
    [self.socket connectToHost:self.socketHost onPort:self.socketPort withTimeout:3 error:&error];
   
    
}
#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    NSLog(@"socket连接成功");
     [self.socket readDataWithTimeout:-1 tag:0];
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"socket失去连接");
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSLog(@"取得数据%@",data);
     [self.socket readDataWithTimeout:-1 tag:0];
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    NSLog(@"didWriteDataWithTag");
}
-(void)writeData:(NSData *)data{
    [self.socket writeData:data withTimeout:2 tag:1];
}
-(void)shutdown{
    [self.socket disconnect];
}

@end
