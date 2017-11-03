//
//  SetViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/9/20.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "SetViewController.h"
#import "ViewUtil.h"
#import "LoginViewController.h"
#import "WebViewController.h"
#import "UserViewController.h";
#import "MyDeviceViewController.h"

@interface SetViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@end

@implementation SetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title = [NSString stringWithFormat:@"设置"];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"set.html" withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
    [self.view addSubview:self.webView];
    
    //NSLog(@"%@",self.device);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:user options:0 error:nil];
    NSString *userStr = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    NSString *userStrZy = [userStr stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"];
    [self.webView stringByEvaluatingJavaScriptFromString:[NSString stringWithFormat:@"javascript:onData('%@')",userStrZy]];
}



- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if([url hasPrefix:@"objc://userinfo"]){
        UserViewController *userVc = [[UserViewController alloc] init];
        [self.navigationController pushViewController:userVc animated:YES];
    }
    if([url hasPrefix:@"objc://host"]){
        MyDeviceViewController *myDeviceVc = [[MyDeviceViewController alloc] init];
        [self.navigationController pushViewController:myDeviceVc animated:YES];
    }
    if([url hasPrefix:@"objc://about"]){
        WebViewController *webVc = [[WebViewController alloc] initWithWidthTitle:@"关于我们" andUrl:@"about.html"];
        [self.navigationController pushViewController:webVc animated:YES];
    }
    if([url hasPrefix:@"objc://help"]){
        WebViewController *webVc = [[WebViewController alloc] initWithWidthTitle:@"帮助系统" andUrl:@"help.html"];
        [self.navigationController pushViewController:webVc animated:YES];
    }
    if([url hasPrefix:@"objc://logout"]){
        [self logout];
    }
    return YES;
}
-(void)logout{
    LoginViewController *loginVc = [[LoginViewController alloc] init];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:loginVc, nil]];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults removeObjectForKey:@"user"];
    [defaults synchronize];
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
