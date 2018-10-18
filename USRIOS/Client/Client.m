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
            NSMutableDictionary *deviceSocket = [NSMutableDictionary dictionaryWithObjectsAndKeys:socket,@"socket",self.hostList[i][@"deviceId"],@"deviceId",[NSMutableDictionary dictionary],@"device",[NSMutableData data],@"buffer",@(1),@"unReceiveTime",@(false),@"isSending", nil];
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
                    deviceSocket[@"unReceiveTime"] = @([deviceSocket[@"unReceiveTime"] intValue]-1);
                    //NSLog(@"%@",deviceSocket);
                    if([deviceSocket[@"unReceiveTime"] intValue]<0 && ![deviceSocket[@"isSending"] boolValue]){
                        //NSLog(@"设备%d,%d",deviceId,[deviceSocket[@"isSending"] boolValue]);
                        AsyncSocket *socket = deviceSocket[@"socket"];
                        Byte buf[] = {(Byte)deviceId,0x03, 0x02, 0x58, 0x00, 0x64};
                        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
                        [socket writeData:[CRC getCRC:data] withTimeout:2 tag:deviceId];
                    }
                }
            }
        }
    }
}

-(void)byteTransfer:(NSData *)data withTag:(long)tag{
    //NSLog(@"设备%ld取得数据%@",tag,data);
    Byte *buff = (Byte *)[data bytes];
    if(buff[0]==0){
        return;
    }
    NSMutableDictionary *deviceSocket = [self getDeviceSocket:(int)tag];
    NSMutableDictionary *device = deviceSocket[@"device"];
    device[@"deviceId"] = @(tag);
    AsyncSocket *socket = deviceSocket[@"socket"];
    device[@"deviceIp"] = socket.connectedHost;
    device[@"online"] = @1;
    device[@"temp"] = @([Hex parseHex4:buff[3]:buff[4]]);
    device[@"tempUpLimit"] = @([Hex parseHex4:buff[5]:buff[6]]);
    device[@"tempDownLimit"] = @([Hex parseHex4:buff[7]:buff[8]]);
    device[@"tempOff"] = @([Hex parseHex4:buff[9]:buff[10]]);
    device[@"tempReally"] = @([Hex parseHex4:buff[11]:buff[12]]);
    
    device[@"workMode"] = @([Hex parseHex4:buff[15]:buff[16]]);
    device[@"airCount"] = @([Hex parseHex4:buff[17]:buff[18]]);
    device[@"inWindSpeed"] = @([Hex parseHex4:buff[19]:buff[20]]);
    device[@"outWindSpeed"] = @([Hex parseHex4:buff[21]:buff[22]]);
    
    device[@"hr"] = @([Hex parseHex4:buff[23]:buff[24]]);
    device[@"hrUpLimit"] = @([Hex parseHex4:buff[25]:buff[26]]);
    device[@"hrDownLimit"] = @([Hex parseHex4:buff[27]:buff[28]]);
    device[@"hrOff"] = @([Hex parseHex4:buff[29]:buff[30]]);
    device[@"hrReally"] = @([Hex parseHex4:buff[31]:buff[32]]);
    
    device[@"dp"] = @([Hex parseHex4:buff[43]:buff[44]]);
    device[@"dpUpLimit"] = @([Hex parseHex4:buff[45]:buff[46]]);
    device[@"dpDownLimit"] = @([Hex parseHex4:buff[47]:buff[48]]);
    device[@"dpOff"] = @([Hex parseHex4:buff[49]:buff[50]]);
    device[@"dpReally"] = @([Hex parseHex4:buff[51]:buff[52]]);
    device[@"dpTarget"] = @([Hex parseHex4:buff[53]:buff[54]]);
    device[@"akpMode"] = @([Hex parseHex4:buff[55]:buff[56]]);
    
    device[@"communicateFalse"] = @([Hex parseHex4:buff[35]:buff[36]]);
    device[@"communicateTrue"] = @([Hex parseHex4:buff[37]:buff[38]]);
    device[@"infoBar"] = @([Hex parseHex4:buff[39]:buff[40]]);
    device[@"stateSwitch"] = @([Hex parseHex4:buff[41]:buff[42]]);
    
    device[@"workHour"] = @([Hex parseHex4:buff[63]:buff[64]]);
    device[@"workSecond"] = @([Hex parseHex4:buff[65]:buff[66]]);
    device[@"converterMax"] = @([Hex parseHex4:buff[67]:buff[68]]);
    device[@"converterMin"] = @([Hex parseHex4:buff[69]:buff[70]]);
    device[@"converterModel"] = @([Hex parseHex4:buff[71]:buff[72]]);
    device[@"cycleError"] = @([Hex parseHex4:buff[73]:buff[74]]);
    device[@"alarmCycle"] = @([Hex parseHex4:buff[75]:buff[76]]);
    
    device[@"tempAlarmClose"] = @([Hex parseHex4:buff[83]:buff[84]]);
    device[@"hrAlarmClose"] = @([Hex parseHex4:buff[85]:buff[86]]);
    device[@"dpAlarmClose"] = @([Hex parseHex4:buff[87]:buff[88]]);
    device[@"inWindAlarmClose"] = @([Hex parseHex4:buff[89]:buff[90]]);
    
    device[@"airSpeed10"] = @([Hex parseHex4:buff[103]:buff[104]]);
    device[@"airSpeed12"] = @([Hex parseHex4:buff[105]:buff[106]]);
    device[@"airSpeed14"] = @([Hex parseHex4:buff[107]:buff[108]]);
    device[@"airSpeed16"] = @([Hex parseHex4:buff[109]:buff[110]]);
    device[@"airSpeed18"] = @([Hex parseHex4:buff[111]:buff[112]]);
    device[@"airSpeed20"] = @([Hex parseHex4:buff[113]:buff[114]]);
    device[@"airSpeed22"] = @([Hex parseHex4:buff[115]:buff[116]]);
    device[@"airSpeed24"] = @([Hex parseHex4:buff[117]:buff[118]]);
    device[@"airSpeed26"] = @([Hex parseHex4:buff[119]:buff[120]]);
    device[@"airSpeed28"] = @([Hex parseHex4:buff[121]:buff[122]]);
    device[@"airSpeed30"] = @([Hex parseHex4:buff[123]:buff[124]]);
    device[@"airSpeed35"] = @([Hex parseHex4:buff[125]:buff[126]]);
    device[@"airSpeed40"] = @([Hex parseHex4:buff[127]:buff[128]]);
    device[@"airSpeed45"] = @([Hex parseHex4:buff[129]:buff[130]]);
    device[@"airSpeed50"] = @([Hex parseHex4:buff[131]:buff[132]]);
    deviceSocket[@"unReceiveTime"] = @1;
    deviceSocket[@"receiveCount"] = @([deviceSocket[@"receiveCount"] intValue]+1);
}

-(NSMutableDictionary *)getDeviceSocket:(int)devcieId{
    @synchronized(self.dsockets){
        for(int i=0;i<self.dsockets.count;i++){
            if([self.dsockets[i][@"deviceId"] intValue]==devcieId){
                return self.dsockets[i];
            }
        }
    }
    return NULL;
}

-(NSString *)formatDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"YYYY-MM-dd hh:mm:ss"];
    return [formatter stringFromDate:date];
}

-(BOOL)updateDevice:(NSDictionary *)paramMap{
    NSMutableArray *sendQueue = [NSMutableArray array];
    int deviceId = [paramMap[@"deviceId"] intValue];
    if(paramMap[@"tempUpLimit"]){
        int tempUpLimit = [paramMap[@"tempUpLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x79,0x00,(Byte)tempUpLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
    }
    if(paramMap[@"tempDownLimit"]){
        int tempDownLimit = [paramMap[@"tempDownLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7a,0x00,(Byte)tempDownLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"hrUpLimit"]){
        int hrUpLimit = [paramMap[@"hrUpLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7b,0x00,(Byte)hrUpLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"hrDownLimit"]){
        int hrDownLimit = [paramMap[@"hrDownLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7c,0x00,(Byte)hrDownLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"dpUpLimit"]){
        int dpUpLimit = [paramMap[@"dpUpLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7d,0x00,(Byte)dpUpLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"dpDownLimit"]){
        int dpDownLimit = [paramMap[@"dpDownLimit"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7e,0x00,(Byte)dpDownLimit};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"tempAlarmClose"]){
        int tempAlarmClose = [paramMap[@"tempAlarmClose"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,0x7f,0x00,(Byte)tempAlarmClose};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"hrAlarmClose"]){
        int hrAlarmClose = [paramMap[@"hrAlarmClose"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,(Byte)0x80,0x00,(Byte)hrAlarmClose};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"dpAlarmClose"]){
        int dpAlarmClose = [paramMap[@"dpAlarmClose"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,(Byte)0x81,0x00,(Byte)dpAlarmClose};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    if(paramMap[@"inWindAlarmClose"]){
        int inWindAlarmClose = [paramMap[@"inWindAlarmClose"] intValue];
        Byte buf[] = {(Byte)deviceId,0x06,0x03,(Byte)0x82,0x00,(Byte)inWindAlarmClose};
        NSData *data = [NSData dataWithBytes:buf length:sizeof(buf)];
        [sendQueue addObject:data];
        
    }
    return [self sendUpdate:deviceId withSendQueue:sendQueue];
}

-(BOOL)sendUpdate:(int)deviceId withSendQueue:(NSArray *)sendQueue{
    NSMutableDictionary *deviceSocket = [self getDeviceSocket:(int)deviceId];
    if(deviceSocket!=nil){
        deviceSocket[@"isSending"] = @(true);
        [NSThread sleepForTimeInterval:3.5f];
        if([deviceSocket[@"unReceiveTime"] intValue]<0){
            for(int i=0;i<sendQueue.count;i++){
                dispatch_async(dispatch_get_main_queue(), ^{
                    AsyncSocket *socket = deviceSocket[@"socket"];
                    NSData *data = sendQueue[i];
                    [socket writeData:[CRC getCRC:data] withTimeout:-1 tag:deviceId];
                    NSLog(@"%@",data);
                });
                [NSThread sleepForTimeInterval:0.5f];
                
            }
            [NSThread sleepForTimeInterval:0.5f];
            deviceSocket[@"isSending"] = @(false);
            //NSLog(@"%@",deviceSocket);
            return YES;
        }else{
            deviceSocket[@"isSending"] = @(false);
            return NO;
        }
    }
    return YES;
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
    NSMutableDictionary *deviceSocket;
    @synchronized(self.dsockets){
        for(int i=0;i<self.dsockets.count;i++){
            if(self.dsockets[i][@"socket"] == sock){
                deviceSocket = self.dsockets[i];
                break;
            }
        }
        if(deviceSocket!=NULL){
            [self.dsockets removeObject:deviceSocket];
            NSLog(@"设备%@失去连接",deviceSocket[@"deviceId"]);
        }
    }
}


-(void)onSocket:(AsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag{
    NSMutableDictionary *deviceSocket = [self getDeviceSocket:(int)tag];
    NSMutableData *buffer = deviceSocket[@"buffer"];
    [buffer appendData:data];
    if(buffer.length>=205){
        if([[Hex hexStringForData:[buffer subdataWithRange:NSMakeRange(buffer.length-4,2)]] isEqual:@"aa55"]){
            NSData *crcData = [buffer subdataWithRange:NSMakeRange(0, buffer.length - 2)];
            if([[[CRC getCRC:crcData] subdataWithRange:NSMakeRange(buffer.length - 2, 2)] isEqualToData:[buffer subdataWithRange:NSMakeRange(buffer.length - 2, 2)]]){
                [self byteTransfer:buffer withTag:tag];
            }
        }
        [buffer resetBytesInRange:NSMakeRange(0, [data length])];
        [buffer setLength:0];
        
    }
    [sock readDataWithTimeout:-1 tag:tag];
}
-(void)onSocket:(AsyncSocket *)sock didWriteDataWithTag:(long)tag{
    //NSLog(@"didWriteDataWithTag");
}

-(void)shutdown{
    [self.ds close];
    self.ds = nil;
    NSMutableArray *sockets = [NSMutableArray array];
    @synchronized(self.dsockets){
        for(int i=0;i<self.dsockets.count;i++){
            [sockets addObject:self.dsockets[i][@"socket"]];
        }
    }
    for(int i=0;i<sockets.count;i++){
        AsyncSocket *socket = sockets[i];
        if([socket isConnected]){
            [socket disconnect];
        }
    }
    [self.hostList removeAllObjects];
    [self.dsockets removeAllObjects];
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
            //host[@"ip"] = @"10.10.12.36";
            [self.hostList replaceObjectAtIndex:i withObject:host];
        }
    }
    [self.ds receiveWithTimeout:-1 tag:0];
    return YES;
}



@end
