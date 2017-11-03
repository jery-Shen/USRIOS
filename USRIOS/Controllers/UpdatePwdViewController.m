//
//  UpdatePwdViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/9/29.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "UpdatePwdViewController.h"
#import "ViewUtil.h"
#import "MBProgressHUD.h"
#import "HttpUtil.h"

@interface UpdatePwdViewController ()<UITextFieldDelegate>
@property(nonatomic,retain) MBProgressHUD *hud;
@end

@implementation UpdatePwdViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title = [NSString stringWithFormat:@"修改密码"];
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];

    UITextField *oldpwdfieldName = [[UITextField alloc]init];
    oldpwdfieldName.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 30);
    oldpwdfieldName.center = CGPointMake(self.view.frame.size.width/2,42);
    oldpwdfieldName.placeholder = @"旧密码";
    oldpwdfieldName.keyboardType =  UIKeyboardTypeASCIICapable;
    oldpwdfieldName.secureTextEntry = YES;
    oldpwdfieldName.autocorrectionType = UITextAutocorrectionTypeNo;
    oldpwdfieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    oldpwdfieldName.returnKeyType = UIReturnKeyNext;
    oldpwdfieldName.tag = 10;
    oldpwdfieldName.delegate = self;
    [self.view addSubview:oldpwdfieldName];
    
    UIView *underline = [[UIView alloc] init];
    underline.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 0.5);
    underline.center = CGPointMake(self.view.frame.size.width/2,55);
    underline.backgroundColor = [ViewUtil colorHex:@"aaaaaa"];
    
    
    UITextField *newpwdfieldName = [[UITextField alloc]init];
    newpwdfieldName.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 30);
    newpwdfieldName.center = CGPointMake(self.view.frame.size.width/2,102);
    newpwdfieldName.placeholder = @"新密码";
    newpwdfieldName.keyboardType =  UIKeyboardTypeASCIICapable;
    newpwdfieldName.secureTextEntry = YES;
    newpwdfieldName.autocorrectionType = UITextAutocorrectionTypeNo;
    newpwdfieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    newpwdfieldName.returnKeyType = UIReturnKeyNext;
    newpwdfieldName.tag = 11;
    newpwdfieldName.delegate = self;
    [self.view addSubview:newpwdfieldName];
    
    UIView *underline1 = [[UIView alloc] init];
    underline1.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 0.5);
    underline1.center = CGPointMake(self.view.frame.size.width/2,115);
    underline1.backgroundColor = [ViewUtil colorHex:@"aaaaaa"];
    
    
    UITextField *cpwdfieldName = [[UITextField alloc]init];
    cpwdfieldName.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 30);
    cpwdfieldName.center = CGPointMake(self.view.frame.size.width/2,162);
    cpwdfieldName.placeholder = @"确认密码";
    cpwdfieldName.keyboardType =  UIKeyboardTypeASCIICapable;
    cpwdfieldName.secureTextEntry = YES;
    cpwdfieldName.autocorrectionType = UITextAutocorrectionTypeNo;
    cpwdfieldName.autocapitalizationType = UITextAutocapitalizationTypeNone;
    cpwdfieldName.returnKeyType = UIReturnKeyDone;
    cpwdfieldName.tag = 12;
    cpwdfieldName.delegate = self;
    [self.view addSubview:cpwdfieldName];
    
    UIView *underline2 = [[UIView alloc] init];
    underline2.bounds = CGRectMake(0, 0, self.view.frame.size.width-40, 0.5);
    underline2.center = CGPointMake(self.view.frame.size.width/2,175);
    underline2.backgroundColor = [ViewUtil colorHex:@"aaaaaa"];
    
    [self.view addSubview:underline];
    [self.view addSubview:underline1];
    [self.view addSubview:underline2];

    UIButton *confirmBtn = [[UIButton alloc]initWithFrame:CGRectMake(0,0,self.view.frame.size.width-40,45)];
    confirmBtn.center = CGPointMake(self.view.frame.size.width/2,230);
    confirmBtn.backgroundColor = [ViewUtil colorHex:@"128bed"];
    confirmBtn.layer.cornerRadius = 4.0;
    [confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [confirmBtn addTarget:self action:@selector(confirmClick:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:confirmBtn];
}

-(void)confirmClick:(id)sender{
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    UITextField *oldPwdInput =(UITextField *)[self.view viewWithTag:10];
    UITextField *newPwdInput =(UITextField *)[self.view viewWithTag:11];
    UITextField *cPwdInput =(UITextField *)[self.view viewWithTag:12];
    NSString *oldPwd = oldPwdInput.text;
    NSString *newPwd = newPwdInput.text;
    NSString *cPwd = cPwdInput.text;
    if([oldPwd isEqualToString:@""]){
         [ViewUtil alertMsg:@"旧密码不能为空" inViewController:self];
    }else if([newPwd isEqualToString:@""]){
        [ViewUtil alertMsg:@"新密码不能为空" inViewController:self];
    }else if([cPwd isEqualToString:@""]){
        [ViewUtil alertMsg:@"确认密码不能为空" inViewController:self];
    }else if(![oldPwd isEqualToString:user[@"userPwd"]]){
        [ViewUtil alertMsg:@"旧密码错误" inViewController:self];
    }else if(newPwd.length<6){
        [ViewUtil alertMsg:@"新密码长度必须大于6位" inViewController:self];
    }else if(![newPwd isEqualToString:cPwd]){
        [ViewUtil alertMsg:@"两次密码不一致" inViewController:self];
    }else if([newPwd isEqualToString:oldPwd]){
        [ViewUtil alertMsg:@"新密码不能与旧密码相同" inViewController:self];
    }else{
        [self updatePwd:newPwd];
    }

    [oldPwdInput resignFirstResponder];
    [newPwdInput resignFirstResponder];
    [cPwdInput resignFirstResponder];
}

-(void)updatePwd:(NSString *)newPwd{
    self.hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    self.hud.mode = MBProgressHUDModeText;
    self.hud.labelText = @"请稍后...";
    self.hud.mode = MBProgressHUDModeIndeterminate;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    NSDictionary *map = [HttpUtil getSign:user];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@UpdateUserPwd?token=%@&timestamp=%@@&sign=%@",URL_PRE,map[@"token"],map[@"timestamp"],map[@"sign"]]];
    NSString *postBody = [NSString stringWithFormat:@"userName=%@&userPwd=%@&newPwd=%@",user[@"userName"],user[@"userPwd"],newPwd];
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
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  NSMutableDictionary *mUser = [NSMutableDictionary dictionaryWithDictionary:user];
                                                  mUser[@"userPwd"] = newPwd;
                                                  [defaults setObject:mUser forKey:@"user"];
                                                  [self.navigationController popViewControllerAnimated:YES];
                                                  [ViewUtil alertMsg:@"修改成功" inViewController:self.navigationController];
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

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    if(textField.tag == 10){
        [((UITextField *)[self.view viewWithTag:11]) becomeFirstResponder];
    }else if(textField.tag == 11){
        [((UITextField *)[self.view viewWithTag:12]) becomeFirstResponder];
    }else if(textField.tag == 12){
        [((UITextField *)[self.view viewWithTag:12]) resignFirstResponder];
    }
    return YES;
}

#pragma mark -<UITextFieldDelegate>
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string{
    if (range.location > 15) {
        return NO;
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
