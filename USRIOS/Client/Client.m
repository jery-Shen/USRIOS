//
//  Client.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "Client.h"
#import "Hex.h"
#import "CRC.h"

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

-(void)initUdp:(NSString *)ip{
    self.wifiIp = ip;
    self.ds =  [[AsyncUdpSocket alloc] initWithDelegate:self];
    [self.ds enableBroadcast:YES error:nil];
    [self.ds receiveWithTimeout:-1 tag:0];
}

-(void)scan{
    NSArray *temp=[self.wifiIp componentsSeparatedByString:@"."];
    NSString *host = [NSString stringWithFormat:@"%@.%@.%@.255",temp[0],temp[1],temp[2]];
    [self.ds sendData:[@"HF-A11ASSISTHREAD" dataUsingEncoding:NSUTF8StringEncoding] toHost:host port:48899 withTimeout:2 tag:0];
}

-(void)connectServers{
    if(!self.dsockets){
        self.dsockets = [[NSMutableArray alloc]init];
    }
    for(int i=0;i<self.hostList.count;i++){
        if(![self isConnected:[self.hostList[i][@"deviceId"] intValue]] && self.hostList[i][@"ip"]){
            //NSLog(@"%@",self.hostList[i]);
            AsyncSocket *socket = [[AsyncSocket alloc] initWithDelegate:self];
            [socket connectToHost:self.hostList[i][@"ip"] onPort:8090 withTimeout:3 error:nil];
            NSMutableDictionary *deviceSocket = [NSMutableDictionary dictionaryWithObjectsAndKeys:socket,@"socket",self.hostList[i][@"deviceId"],@"deviceId",@(1),@"unReceiveTime", nil];
            //NSLog(@"%@",deviceSocket);
            [self.dsockets addObject:deviceSocket];
        }
    }
}

-(BOOL)isConnected:(int)deviceId{
    for(int i=0;i<self.dsockets.count;i++){
        if([self.dsockets[i][@"deviceId"] intValue]==deviceId){
            return YES;
        }
    }
    return NO;
}

-(void)scanAndConnect{
    [self scan];
    [self performSelector:@selector(connectServers) withObject:self afterDelay:1];
}

-(void)setHostList:(NSMutableArray *)hostList{
    if(_hostList==NULL || _hostList.count==0){
        _hostList = hostList;
    }else{
        for(int i=0;i<hostList.count;i++){
            BOOL exist = false;
            for(int j=0;j<_hostList.count;j++){
                if([hostList[i][@"deviceId"] intValue]==[self.hostList[i][@"deviceId"] intValue]){
                    exist = true;
                }
            }
            if(!exist){
                [_hostList addObject:hostList[i]];
            }
        }
    }
}

-(void)scanServer:(int)scanNum{
    @synchronized(self.dsockets){
        if(self.dsockets && self.dsockets.count>0){
            for(int i=0;i<self.dsockets.count;i++){
                NSMutableDictionary *deviceSocket = self.dsockets[i];
                int deviceId = [deviceSocket[@"deviceId"] intValue];
                if(deviceId!=0){
                    AsyncSocket *socket = deviceSocket[@"socket"];
                    Byte buf[] = {(Byte)deviceId,0x03, 0x02, 0x58, 0x00, 0x64};
                    NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
                    [socket writeData:[CRC getCRC:data] withTimeout:2 tag:deviceId];
                }
            }
        }
    }
}

-(void)byteTransfer:(NSData *)data withTag:(long)tag{
    NSLog(@"设备%ld取得数据%@",tag,data);
    NSMutableDictionary *device = [NSMutableDictionary dictionary];
    device[@"online"] = @1;
    Byte *buff = (Byte *)[data bytes];
    int aa = [Hex parseHex4:buff[3] :buff[4]];
    NSLog(@"temp:%d",aa);
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SyncWifiNotification" object:nil];
}

-(NSString *)formatDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:date];
}

#pragma mark  - 连接成功回调
-(void)onSocket:(AsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    
    for(int i=0;i<self.dsockets.count;i++){
        if(self.dsockets[i][@"socket"] == sock){
            NSLog(@"设备%@:连接成功",self.dsockets[i][@"deviceId"]);
            [sock readDataWithTimeout:-1 tag:[self.dsockets[i][@"deviceId"] longValue]];
        }
    }
    
}
-(void)onSocketDidDisconnect:(AsyncSocket *)sock{
    NSLog(@"socket失去连接");
}
-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    [self byteTransfer:data withTag:tag];
    [sock readDataWithTimeout:-1 tag:tag];
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"didWriteDataWithTag");
}

-(void)shutdown{
    NSLog(@"shutdown");
}

-(void)onUdpSocket:(AsyncUdpSocket *)sock didSendDataWithTag:(long)tag{
    NSLog(@"sendudp");
}

-(BOOL)onUdpSocket:(AsyncUdpSocket *)sock didReceiveData:(NSData *)data withTag:(long)tag fromHost:(NSString *)host port:(UInt16)port{
    NSString *msg =[[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *temp = [msg componentsSeparatedByString:@","];
    for(int i=0;i<self.hostList.count;i++){
        NSMutableDictionary *host = [NSMutableDictionary dictionaryWithDictionary:self.hostList[i]];
        if([host[@"mac"] isEqualToString:temp[1]]){
            host[@"ip"] = temp[0];
            [self.hostList replaceObjectAtIndex:i withObject:host];
        }
    }
    [self.ds receiveWithTimeout:-1 tag:0];
    return YES;
}



@end
