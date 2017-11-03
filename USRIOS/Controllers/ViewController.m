//
//  ViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "ViewController.h"
#import "Hex.h"
#import "AsyncSocket.h"
#import "Client.h"
#import "LoginViewController.h"
#import "DeviceListViewController.h"
#import "LoginViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //[[Client sharedInstance] socketConnectHost];
    //[self goLoginView];
    self.title = @"aa";
    self.view.backgroundColor = [UIColor yellowColor];
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 200, 40)];
    [btn setTitle:@"haha" forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(myclick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:btn];
    
    

}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
}

-(void)myclick:(id)sender{
    
   
    NSLog(@"1111");
    DeviceListViewController *devcieListVc = [[DeviceListViewController alloc] init];

    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:devcieListVc, nil]];
}
- (void)goLoginView{
    LoginViewController *login = [[LoginViewController alloc]init];
    [self presentViewController:login animated:NO completion:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)dealloc{
    NSLog(@"viewdealloc");
}



@end
