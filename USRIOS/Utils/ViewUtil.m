//
//  ViewUtil.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "ViewUtil.h"

@implementation ViewUtil
+(UIColor *) colorHex: (NSString *) stringToConvert
{
    NSString *cString = [[stringToConvert stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];//字符串处理
    //例子，stringToConvert #ffffff
    if ([cString length] < 6)
        return [UIColor whiteColor];//如果非十六进制，返回白色
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];//去掉头
    if ([cString length] != 6)//去头非十六进制，返回白色
        return [UIColor whiteColor];
    //分别取RGB的值
    NSRange range;
    range.location = 0;
    range.length = 2;
    NSString *rString = [cString substringWithRange:range];
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    unsigned int r, g, b;
    //NSScanner把扫描出的制定的字符串转换成Int类型
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    //转换为UIColor
    return [UIColor colorWithRed:((float) r / 255.0f)
                           green:((float) g / 255.0f)
                            blue:((float) b / 255.0f)
                           alpha:1.0f];
}

+(void)alertMsg:(NSString *)msg inViewController:(UIViewController *)vc{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:cancelAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}
+(void)confirmMsg:(NSString *)msg inViewController:(UIViewController *)vc callback:(void(^)(void))callback{
    UIAlertController *alertController = [UIAlertController alertControllerWithTitle:msg message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *okAction = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        callback();
    }];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    [alertController addAction:okAction];
    [alertController addAction:cancelAction];
    [vc presentViewController:alertController animated:YES completion:nil];
}
+(NSString *)stringOfInfoBar:(int)infoBar{
    NSString *infoBarStr = @"";
    switch (infoBar) {
        case 0:
            infoBarStr = @"待机状态，按开启键启动";
            break;
        case 1:
            infoBarStr = @"工作正常，按关闭键停止";
            break;
        case 2:
            infoBarStr = @"温度过低";
            break;
        case 3:
            infoBarStr = @"断电报警";
            break;
        case 4:
            infoBarStr = @"温度超高";
            break;
        case 5:
            infoBarStr = @"温度过低";
            break;
        case 6:
            infoBarStr = @"湿度超高";
            break;
        case 7:
            infoBarStr = @"湿度过低";
            break;
        case 8:
            infoBarStr = @"压差过高";
            break;
        case 9:
            infoBarStr = @"压差过低";
            break;
        case 10:
            infoBarStr = @"模拟量采集通讯故障";
            break;
        case 11:
            infoBarStr = @"进风自动调节上限";
            break;
        case 12:
            infoBarStr = @"进风自动调节下限";
            break;
        case 13:
            infoBarStr = @"模拟量采集通讯故障";
            break;
            
    }
    return infoBarStr;
}
@end
