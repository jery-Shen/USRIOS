//
//  DeviceDetailViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "ViewUtil.h"

@interface DeviceDetailViewController ()

@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
}

-(void)initView{
    self.title = @"智控1";
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
   
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitle:@"haha" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(myclick:) forControlEvents:UIControlEventTouchUpInside];
    [btn setTitleColor:[ViewUtil colorHex:@"128bed"] forState:UIControlStateNormal];
    
    [self.view addSubview:btn];
    
    
}

-(void)myclick:(id)sender{
    
    NSLog(@"1111");
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
