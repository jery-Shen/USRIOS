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
#import "OnlineService.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [UINavigationBar appearance].barTintColor=[ViewUtil colorHex:@"128BED"];
    
    if ([[UIApplication sharedApplication] respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationType type =  UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound;
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:type
                                                                                 categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
    }
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    self.deviceList = [NSMutableArray arrayWithCapacity:50];
    
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
//    __block UIBackgroundTaskIdentifier bgTask;// 后台任务标识
//    
//    bgTask = [application beginBackgroundTaskWithExpirationHandler:^{
//        [application endBackgroundTask:bgTask];
//        bgTask = UIBackgroundTaskInvalid;
//    }];
    
    //[[OnlineService sharedInstance] console];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    //[UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    NSLog(@"*********notification:%@******************",notification.alertBody);
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    
    //    [[NSNotificationCenter defaultCenter] postNotificationName:@"pushWebView" object:nil];
    
}



@end
