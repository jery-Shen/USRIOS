//
//  Hex.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "Hex.h"

@implementation Hex

+(NSData *)convertHexStrToData:(NSString *)str {
    if (!str || [str length] == 0) {
        return nil;
    }
    
    NSMutableData *hexData = [[NSMutableData alloc] initWithCapacity:8];
    NSRange range;
    if ([str length] % 2 == 0) {
        range = NSMakeRange(0, 2);
    } else {
        range = NSMakeRange(0, 1);
    }
    for (NSInteger i = range.location; i < [str length]; i += 2) {
        unsigned int anInt;
        NSString *hexCharStr = [str substringWithRange:range];
        NSScanner *scanner = [[NSScanner alloc] initWithString:hexCharStr];
        
        [scanner scanHexInt:&anInt];
        NSData *entity = [[NSData alloc] initWithBytes:&anInt length:1];
        [hexData appendData:entity];
        
        range.location += range.length;
        range.length = 2;
    }
    return hexData;
}

+ (NSString*)hexStringForData:(NSData*)data

{
    
    if (data == nil) {
        
        return nil;
        
    }
    
    
    NSMutableString* hexString = [NSMutableString string];
    
    
    const unsigned char *p = [data bytes];
    
    
    
    for (int i=0; i < [data length]; i++) {
        
        [hexString appendFormat:@"%02x", *p++];
        
    }
    
    return hexString;
    
}



+(int)parseHex4:(Byte)high : (Byte)low{
    int b0 = high&0xff;
    int b1 = low&0xff;
    return b0*256+b1;
}

+(void)test{
    NSData *data = [Hex convertHexStrToData:@"a1"];
    int deviceId = 18;
    Byte bytes[]={deviceId,0x27,0x01,0x11};
    int  n = [Hex parseHex4:bytes[2] :bytes[3]];
    NSData *data1 = [[NSData alloc] initWithBytes:bytes length:4];
    Byte *b =(Byte *)[data1 bytes];
    //    NSLog(@"%@",data1);
    //    NSLog(@"%d",n);
    //    NSLog(@"%lu",(unsigned long)data.length);
    //    NSLog(@"%@",_input.text);
}

@end
