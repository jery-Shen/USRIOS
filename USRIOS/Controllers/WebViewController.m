//
//  WebViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/9/20.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "WebViewController.h"
#import "ViewUtil.h"

@interface WebViewController ()<UIWebViewDelegate>
@property(nonatomic, retain)  UIWebView *webView;
@property (nonatomic) NSString *url;
@end

@implementation WebViewController

-(id)initWithWidthTitle:(NSString *)title andUrl:(NSString *)url{
    self = [super init] ;
    if ( self ) {
        self.title = title;
        self.url = url;
    }
    return self ;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.webView = [[UIWebView alloc] initWithFrame:CGRectMake(0,0, screenWidth, screenHeight-64)];
    self.webView.scrollView.bounces=NO;
    self.webView.delegate = self;
    
    NSURL *filePath = [[NSBundle mainBundle] URLForResource:self.url withExtension:nil];
    [self.webView loadRequest:[NSURLRequest requestWithURL:filePath]];
    [self.view addSubview:self.webView];
    
    //NSLog(@"%@",self.device);
}
-(void)webViewDidFinishLoad:(UIWebView *)webView{
    
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *url = request.URL.absoluteString;
    if([url hasPrefix:@"http://"]){
        return ![ [ UIApplication sharedApplication ] openURL:request.URL];
    }
    return YES;
}

-(void)back{
    NSLog(@"back");
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
