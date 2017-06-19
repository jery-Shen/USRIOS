//
//  DeviceCell.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceCell.h"
#import "ViewUtil.h"

@implementation DeviceCell
@synthesize title,content,time,info,des;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier];
    if (self) {
        [self initLayuot];
    }
    return self;
}

-(void)initLayuot{
    [self setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    
    title =[[UILabel alloc] init];
    title.text = @"智控1";
    title.textColor = [ViewUtil colorHex:@"333333"];
    title.font = [UIFont systemFontOfSize:16];
    title.frame = CGRectMake(60,15, 50, 30);
    [self.contentView addSubview:title];
    
    
    info =[[UILabel alloc] init];
    info.text = @"工作正常";
    info.textColor = [ViewUtil colorHex:@"128bed"];
    info.font = [UIFont systemFontOfSize:13];
    info.layer.borderWidth = 2;
    info.layer.borderColor = [[ViewUtil colorHex:@"128bed"] CGColor];
    info.layer.cornerRadius = 12;
    info.textAlignment = NSTextAlignmentCenter;
    CGSize maximumLabelSize = CGSizeMake(60, 260);
    CGSize expectSize = [info sizeThatFits:maximumLabelSize];
    info.frame = CGRectMake(113,13, expectSize.width+15, expectSize.height+8);
    [self.contentView addSubview:info];
    
    content =[[UILabel alloc] init];
    content.text = @"温度:15，湿度:25，压差:125";
    content.textColor = [ViewUtil colorHex:@"666666"];
    content.font = [UIFont systemFontOfSize:14];
    content.frame = CGRectMake(15,65, screenWidth-30, 30);
    [self.contentView addSubview:content];
    
    des =[[UILabel alloc] init];
    des.text = @"换气期数:20.00，进风速度:19.20，目标压差:20";
    des.textColor = [ViewUtil colorHex:@"666666"];
    des.font = [UIFont systemFontOfSize:14];
    des.frame = CGRectMake(15,95, screenWidth-30, 30);
    [self.contentView addSubview:des];

    UIImageView *logo = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img.png"]];
    logo.frame = CGRectMake(15, 15, 40, 40);
    [self.contentView addSubview:logo];
    
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [UIColor clearColor].CGColor);
    CGContextFillRect(context, rect);
    
    if(self.tag == 0){
        //上分割线，
        CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f].CGColor);
        CGContextFillRect(context, CGRectMake(0, 0, rect.size.width , 0.5));
    }
    
    //下分割线
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:0.8f green:0.8f blue:0.8f alpha:1.0f].CGColor);
    CGContextFillRect(context, CGRectMake(0, rect.size.height-0.5, rect.size.width, 0.5));
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}



- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
