//
//  Hex.h
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Hex : NSObject
+(NSString *)ToHex:(long int)tmpid;
+(NSString *)ToHex2:(long int)tmpid;
+(NSString *)ToHex4:(long int)tmpid;
+(NSData *)convertHexStrToData:(NSString *)str;
+(NSString*)hexStringForData:(NSData*)data;
+(int)parseHex4:(Byte)high : (Byte)low;
@end
