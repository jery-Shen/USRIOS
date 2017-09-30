//
//  MyDeviceViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/9/29.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "MyDeviceViewController.h"
#import "ViewUtil.h"
#import "MBProgressHUD.h"
#import "HttpUtil.h"

@interface MyDeviceViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@property(nonatomic,retain) MBProgressHUD *hud;
@end

@implementation MyDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title = [NSString stringWithFormat:@"我的设备"];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"wv_refresh_white"] style:UIBarButtonItemStyleDone target:self action:@selector(updateDevice)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"myDevice.html" withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
    [self.view addSubview:self.webView];
    
    
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *hostList = [defaults objectForKey:@"hostList"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:hostList options:0 error:nil];
    NSString *hostListStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *hostListZy = [hostListStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:onData('%@')",hostListZy]];
}

-(void)updateDevice{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = @"更新中...";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    [self.hud hide:YES afterDelay:2];
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    NSDictionary *map = [HttpUtil getSign:user];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@GetHostList?areaId=%d&token=%@&timestamp=%@@&sign=%@",URL_PRE,[user[@"areaId"] intValue],map[@"token"],map[@"timestamp"],map[@"sign"]]];
    //NSLog(@"%@",url);
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:
          ^(NSData *data, NSURLResponse *response, NSError *error) {
              if(!error){
                  NSDictionary *res =   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                  if([res[@"status"] intValue] == 200){
                      NSDictionary *hostList = res[@"result"];
                      NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                      [defaults setObject:hostList forKey:@"hostList"];
                      NSData *jsonData = [NSJSONSerialization dataWithJSONObject:hostList options:0 error:nil];
                      NSString *hostListStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                      NSString *hostListZy = [hostListStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
                      dispatch_time_t timer = dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC);
                      dispatch_after(timer, dispatch_get_main_queue(), ^{
                          self.hud.labelText = @"更新成功";
                          self.hud.mode = MBProgressHUDModeText;
                          [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:onData('%@')",hostListZy]];
                      });
                      
                  }else{
                      [ViewUtil alertMsg:res[@"error"] inViewController:self];
                  }
              }else{
                  [ViewUtil alertMsg:[NSString stringWithFormat:@"%@",error] inViewController:self];
              }
          }];
    [task resume];
    

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
