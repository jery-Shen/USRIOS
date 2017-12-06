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
#import "Client.h"

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
            //[self updateDeviceWifiTask:dic];
            [NSThread detachNewThreadSelector:@selector(updateDeviceWifiTask:) toTarget:self withObject:dic];
        }
    }
    if([url hasPrefix:@"objc://noChange"]){
        NSLog(@"noChange");
        [self.hud setHidden:YES];
        [self.navigationController popViewControllerAnimated:YES];
    }
    return YES;
}

-(void)save:(id)sender{
    
    [self.webView stringByEvaluatingJavaScriptFromString:@"javascript:saveDevice()"];
}

-(void)updateDeviceTask:(NSDictionary *)dic{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    NSDictionary *map = [HttpUtil getSign:user];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@UpdateDevice?token=%@&timestamp=%@@&sign=%@",URL_PRE,map[@"token"],map[@"timestamp"],map[@"sign"]]];
    NSMutableString *postBody = [NSMutableString stringWithFormat:@""];
    NSArray *keys = [dic allKeys];
    for (int i = 0; i < keys.count; i ++){
        [postBody appendString:[NSString stringWithFormat:@"%@=%@&", keys[i], dic[keys[i]]]];
    }
    [postBody appendString:[NSString stringWithFormat:@"t=1"]];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      
                                      if(!error){
                                          NSDictionary *res =   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                          //NSLog(@"%@",res);
                                          if([res[@"status"] intValue] == 200){
                                              dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 2 * NSEC_PER_SEC);
                                              dispatch_after(timer, dispatch_get_main_queue(), ^{
                                                  self.hud.labelText = @"更新成功";
                                                  self.hud.mode = MBProgressHUDModeText;
                                                  [self.navigationController popViewControllerAnimated:YES];
                                              });
                                          }else{
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  [ViewUtil alertMsg:res[@"error"] inViewController:self];
                                                  [self.hud setHidden:YES];
                                              });
                                          }
                                      }else{
                                          dispatch_async(dispatch_get_main_queue(), ^{
                                              [ViewUtil alertMsg:[NSString stringWithFormat:@"%@",error] inViewController:self];
                                              [self.hud setHidden:YES];
                                          });
                                      }
                                  }];
    [task resume];
}

-(void)updateDeviceWifiTask:(NSDictionary *)dic{
    NSLog(@"updateDeviceWifiTask");
    if([[Client sharedInstance] updateDevice:dic]){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.hud setHidden:YES];
            [self.navigationController popViewControllerAnimated:YES];
        });
    }else{
        NSLog(@"设备正在被其他终端操控，请关闭其他终端后再修改");//联网显示：系统检测到设备在联网模式下传输数据，请切换联网模式后再修改设备参数
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
