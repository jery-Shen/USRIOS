//
//  UserViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/9/29.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "UserViewController.h"
#import "ViewUtil.h"
#import "UpdatePwdViewController.h"
@interface UserViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@end

@implementation UserViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}
-(void)initView{
    self.title = [NSString stringWithFormat:@"用户信息"];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:@"user.html" withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
    [self.view addSubview:self.webView];
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
    if([url hasPrefix:@"objc://updatepwd"]){
        UpdatePwdViewController *updatePwdVc = [[UpdatePwdViewController alloc] init];
        [self.navigationController pushViewController:updatePwdVc animated:YES];
    }
    return YES;
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
