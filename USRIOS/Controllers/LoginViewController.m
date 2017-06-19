//
//  LoginViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/1.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "LoginViewController.h"
#import "DeviceListViewController.h"
#import "MBProgressHUD.h"
#import "HttpUtil.h"
#import "ViewUtil.h"

@interface LoginViewController()<UITextFieldDelegate>
@property(nonatomic,retain) MBProgressHUD *hud;

@end

@implementation LoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [super viewWillDisappear:animated];
}

- (void)initView{
    self.view.backgroundColor = [UIColor whiteColor];
    
    UITextField *textfieldName = [[UITextField alloc]init];
    textfieldName.bounds = CGRectMake(0, 0, 280, 30);
    textfieldName.center = CGPointMake(self.view.frame.size.width/2,350);
    UIImageView *icon = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    icon.image = [UIImage imageNamed:@"img"];
    textfieldName.leftView =icon;
    textfieldName.leftViewMode = UITextFieldViewModeAlways;
    
    [textfieldName setValue:[NSNumber numberWithInt:12] forKey:@"paddingLeft"];
    textfieldName.placeholder = @"用户名";
    textfieldName.keyboardType =  UIKeyboardTypeAlphabet;
    textfieldName.autocorrectionType = UITextAutocorrectionTypeNo;
    textfieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    textfieldName.returnKeyType = UIReturnKeyNext;
    textfieldName.tag = 11;
    textfieldName.delegate = self;
    [self.view addSubview:textfieldName];
    
    UIView *underline = [[UIView alloc] init];
    underline.bounds = CGRectMake(0, 0, 280, 0.5);
    underline.center = CGPointMake(self.view.frame.size.width/2,375);
    underline.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:underline];
    
    
    
    UITextField *textfieldPassworld = [[UITextField alloc]init];
    textfieldPassworld.bounds = CGRectMake(0, 0, 280, 30);
    textfieldPassworld.center = CGPointMake(self.view.frame.size.width/2,410);
    textfieldPassworld.placeholder = @"密码";
    textfieldPassworld.keyboardType =  UIKeyboardTypeASCIICapable;
    textfieldPassworld.secureTextEntry = YES;
    
    UIImageView *icon2 = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    icon2.image = [UIImage imageNamed:@"img"];
    textfieldPassworld.leftView =icon2;
    textfieldPassworld.leftViewMode = UITextFieldViewModeAlways;
    
    [textfieldPassworld setValue:[NSNumber numberWithInt:12] forKey:@"paddingLeft"];
    textfieldPassworld.delegate = self;
    textfieldPassworld.tag = 10;
    [self.view addSubview:textfieldPassworld];

    UIView *underline2 = [[UIView alloc] init];
    underline2.bounds = CGRectMake(0, 0, 280, 0.5);
    underline2.center = CGPointMake(self.view.frame.size.width/2,435);
    underline2.backgroundColor = [UIColor lightGrayColor];
    [self.view addSubview:underline2];
    
    UIButton *gobutton = [UIButton buttonWithType:UIButtonTypeSystem];
    gobutton.tag = 9;
    gobutton.bounds = CGRectMake(0, 0, 280, 30);
    gobutton.center = CGPointMake(self.view.frame.size.width/2, 480);
    [gobutton setTitle:@"登陆" forState:UIControlStateNormal];
    [gobutton addTarget:self action:@selector(goButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:gobutton];
    
    
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    //增加监听，当键退出时收出消息
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    
}


- (void)goButtonPressed:(UIButton *)sender{
    UITextField *name = (UITextField *)[self.view viewWithTag:11];
    UITextField *passworld = (UITextField *)[self.view viewWithTag:10];
    if([name.text isEqualToString:@""] || [passworld.text isEqualToString:@""]){
        [ViewUtil alertMsg:@"用户名密码不能为空" inViewController:self];
    }else{
        
        [self loginWithName:name.text andPwd:passworld.text];
    }
    //关闭键盘
    [name resignFirstResponder];
    [passworld resignFirstResponder];
}

-(void)loginWithName:(NSString *)userName andPwd:(NSString *)userPwd{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = @"登录中...";
    self.hud.mode = MBProgressHUDModeIndeterminate;

    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@Login",URL_PRE]];
    NSString *postBody = [NSString stringWithFormat:@"userName=%@&userPwd=%@",userName,userPwd];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [postBody dataUsingEncoding:NSUTF8StringEncoding];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:
                                  ^(NSData *data, NSURLResponse *response, NSError *error) {
                                      if(!error){
                                          NSDictionary *res =   [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                                          if([res[@"status"] intValue] == 200){
                                              NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                                              [defaults setObject:res[@"result"][@"user"] forKey:@"user"];
                                              [defaults setObject:res[@"result"][@"hostList"] forKey:@"hostList"];
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  DeviceListViewController *devcieListVc = [[DeviceListViewController alloc] init];
                                                  [self.navigationController setNavigationBarHidden:NO animated:NO];
                                                  [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:devcieListVc, nil]];
                                              });
                                          }else{
                                              [ViewUtil alertMsg:res[@"error"] inViewController:self];
                                          }

                                      }else{
                                          [ViewUtil alertMsg:[NSString stringWithFormat:@"%@",error] inViewController:self];
                                                                                }
                                      dispatch_async(dispatch_get_main_queue(), ^{
                                          [self.hud setHidden:YES];
                                      });

                                  }];
    [task resume];

}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark -<UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    UITextField *name = (UITextField *)[self.view viewWithTag:11];
    if (textField == name) {
        if (range.location > 9) {
            return NO;
        }
    }else {
        if (range.location > 5) {
            return NO;
        }
    }
    
    return YES;
}

- (void)keyboardWillShow:(NSNotification *)aNotification
{
    
    NSDictionary *userInfo = [aNotification userInfo];
    NSValue *aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    int height = keyboardRect.size.height;
    CGRect frame = [self.view viewWithTag:9].frame;
    int offset = frame.origin.y+frame.size.height- (self.view.frame.size.height - height-30);//求出键盘顶部与textfield底部大小的距离
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyBoard"context:nil];
    [UIView setAnimationDuration:animationDuration];
    if(offset > -64)
        
    {
        CGRect rect = CGRectMake(0.0f, -offset,self.view.frame.size.width,self.view.frame.size.height); //上推键盘操作,view大小始终没变
        self.view.frame = rect;
    }
    
    [UIView commitAnimations];
    
    
}

//当键退出时调用
- (void)keyboardWillHide:(NSNotification *)aNotification
{
    NSTimeInterval animationDuration = 0.30f;
    [UIView beginAnimations:@"ResizeForKeyboard"context:nil];
    [UIView setAnimationDuration:animationDuration];
    CGRect rect = CGRectMake(0.0f, 0.0f, self.view.frame.size.width, self.view.frame.size.height);      //还原上一步view上提效
    self.view.frame = rect;
    [UIView commitAnimations];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    UITextField *textfieldPassworld = (UITextField *)[self.view viewWithTag:10];
    if(textField.tag == 11){
        [textfieldPassworld becomeFirstResponder];
    }else if(textField.tag == 10){
        NSLog(@"111");
        [textfieldPassworld resignFirstResponder];
    }
    return YES;
}
-(void)viewDidUnload{
    NSLog(@"viewDidUnload");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    NSLog(@"didReceiveMemoryWarning");
}

-(void)dealloc{
    NSLog(@"logindealloc");
}
@end
