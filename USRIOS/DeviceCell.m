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
    title =[[UILabel alloc] init];
    [title setTextColor:[ViewUtil colorHex:@"989898"]];
    [title setText:@"content"];
    title.frame = CGRectMake(10,10, 200, 25);
    [self.contentView addSubview:title];
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
