//
//  AppDelegate.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/5/31.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "ViewUtil.h"
#import "LoginViewController.h"
#import "DeviceListViewController.h"
#import "DeviceListWifiViewController.h"
#import "HttpUtil.h"


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UINavigationBar appearance].barTintColor=[ViewUtil colorHex:@"128BED"];
    
    self.navigationController = [[NavigationController alloc] init];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationController.navigationBar.translucent = NO;
    
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    NSDictionary *user = [defaults objectForKey:@"user"];
    if(user==nil){
        LoginViewController *loginVc = [[LoginViewController alloc]init];
        [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:loginVc, nil]];
    }else{
        NSInteger  mode = [defaults integerForKey:@"mode"] ;
        if(mode==0){
            DeviceListViewController *deviceListVc = [[DeviceListViewController alloc]init];
            [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:deviceListVc, nil]];
        }else{
            DeviceListWifiViewController *deviceWifiListVc = [[DeviceListWifiViewController alloc]init];
            [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:deviceWifiListVc, nil]];
        }
        
        NSLog(@"%@,%@",user[@"userName"],user[@"userPwd"]);
        [self loginWithName:user[@"userName"] andPwd:user[@"userPwd"]];
        
    }
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

-(void)loginWithName:(NSString *)userName andPwd:(NSString *)userPwd{
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
                                              //NSLog(@"%@",user);
                                          }else{
                                              dispatch_async(dispatch_get_main_queue(), ^{
                                                  
                                                  LoginViewController *loginVc = [[LoginViewController alloc]init];
                                                  [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:loginVc, nil]];
                                                    //[ViewUtil alertMsg:@"密码失效，请重新登录" inViewController:self.navigationController];
                                              });
                                              NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
                                              [defaults removeObjectForKey:@"user"];
                                              [defaults synchronize];
                                          }
                                          
                                      }
                                      
                                  }];
    [task resume];

}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
