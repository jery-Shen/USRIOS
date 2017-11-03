//
//  DeviceSetViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/10/24.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceSetViewController.h"
#import "ViewUtil.h"
#import "HttpUtil.h"
#import "MBProgressHUD.h"

@interface DeviceSetViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@property(nonatomic,retain) MBProgressHUD *hud;
@end

@implementation DeviceSetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
    // Do any additional setup after loading the view.
}

-(void)initView{
    self.title = [NSString stringWithFormat:@"智控%@",self.device[@"deviceId"]];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSave target:self action:@selector(save:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"deviceSet.html" withExtension:nil];
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
    NSString *url = request.URL.absoluteString;
    if([url hasPrefix:@"objc://updateDevice"]){
        self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        self.hud.mode = MBProgressHUDModeText;
        self.hud.labelText = @"请稍后...";
        self.hud.mode = MBProgressHUDModeIndeterminate;
        NSString *params = [url componentsSeparatedByString:@"?"][1];
        NSData *jsonData = [[HttpUtil URLDecodedString:params] dataUsingEncoding:NSUTF8StringEncoding];
        NSError *err;
        NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                                                            options:NSJSONReadingMutableContainers
                                                              error:&err];
        NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
        NSInteger mode = [defaults integerForKey:@"mode"] ;
        if(mode==0){
            [self updateDeviceTask:dic];
        }else{
            [self updateDeviceWifiTask:dic];
        }
    }
    if([url hasPrefix:@"objc://noChange"]){
        NSLog(@"noChange");
        [self.hud setHidden:YES];
    }
    
    return YES;
}

-(void)save:(id)sender{
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"javascript:saveDevice()"];
}

-(void)updateDeviceTask:(NSDictionary *)dic{
    NSLog(@"%@",dic);
    NSLog(@"updateDeviceTask");
}

-(void)updateDeviceWifiTask:(NSDictionary *)dic{
    NSLog(@"updateDeviceWifiTask");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
