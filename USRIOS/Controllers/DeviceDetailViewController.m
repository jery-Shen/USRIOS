//
//  DeviceDetailViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceDetailViewController.h"
#import "ViewUtil.h"
#import "DeviceSetViewController.h"
#import "AppDelegate.h"

@interface DeviceDetailViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@property(retain,nonatomic)NSTimer *timer;
@end

@implementation DeviceDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    
}

-(void)initView{
    self.title = [NSString stringWithFormat:@"智控%@",self.device[@"deviceId"]];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(edit:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;

    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;

    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"deviceDetail.html" withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
    [self.view addSubview:self.webView];
    if (@available(iOS 11.0, *)) {
        self.webView.scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    //NSLog(@"%@",self.device);
    
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.device options:0 error:nil];
    NSString *deviceStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *deviceStrZy = [deviceStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:onData('%@')",deviceStrZy]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
        return YES;
}

-(void)syncData{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    self.device = [appDelegate getDevice:[self.device[@"deviceId"] intValue]];
    if(self.device){
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:self.device options:0 error:nil];
        NSString *deviceStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        NSString *deviceStrZy = [deviceStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
        [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:onData('%@')",deviceStrZy]];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)edit:(id)sender{
    DeviceSetViewController *deviceSetVc = [[DeviceSetViewController alloc]init];
    deviceSetVc.device = self.device;
    [self.navigationController pushViewController:deviceSetVc animated:YES];
}


- (void)viewWillAppear:(BOOL)animated{
    [self.navigationController.navigationBar setBarTintColor:[ViewUtil colorHex:@"128bed"]];
    self.navigationController.navigationBar.shadowImage = [UIImage new];
    [self.navigationController.navigationBar setBackgroundImage:[UIImage new] forBarMetrics:UIBarMetricsDefault];
    [super viewWillDisappear:animated];
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(syncData) userInfo:nil repeats:YES];
    
}


- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController.navigationBar setBarTintColor:[ViewUtil colorHex:@"128bed"]];
    [super viewWillDisappear:animated];
    [self.timer invalidate];
    self.timer = nil;
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
