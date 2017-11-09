//
//  DeviceListViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceListViewController.h"
#import "DeviceListWifiViewController.h"
#import "ViewUtil.h"
#import "DeviceCell.h"
#import "DeviceDetailViewController.h"
#import "NirKxMenu.h"
#import "LoginViewController.h"
#import "HttpUtil.h"
#import "AppDelegate.h"
#import "OnlineService.h"
#import "SetViewController.h"
#import "WebViewController.h"

@interface DeviceListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UIActivityIndicatorView *loading;
@property(nonatomic,retain) NSMutableArray *data;
@end


@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
   
    self.loading.hidden = NO;
    [self.loading startAnimating];
    [[OnlineService sharedInstance] timerRun];
    //[[OnlineService sharedInstance] performSelector:@selector(timerRun) withObject:nil afterDelay:0.5];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(syncData:) name:@"SyncLineNotification" object:nil];

    NSLog(@"viewDidLoad");
}



-(void)initView{
    self.title = @"智控列表";
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(menu:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    //self.navigationController.navigationBar.prefersLargeTitles = true;
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    if (@available(iOS 11.0, *)) {
        self.tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    self.loading =  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 30, 30)];
    self.loading.center = CGPointMake(self.view.center.x, self.view.center.y-50);
    [self.loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    [self.view addSubview:self.loading];
    self.data = [NSMutableArray arrayWithCapacity:20];
}

-(void)syncData:(id)sender{
    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
   // NSLog(@"%lu",(unsigned long)[appDelegate.deviceList count]);
    [self.data removeAllObjects];
    for(int i = 0; i < [appDelegate.deviceList count]; i++)
    {
        [self.data addObject:appDelegate.deviceList[i]];
    }
    [self.tableView reloadData];
    if(self.data.count>0 && ![self.loading isHidden]){
        self.loading.hidden = YES;
        [self.loading stopAnimating];
    }
}


-(void)menu:(id)sender{
    NSArray *menuItems =
    @[[KxMenuItem menuItem:@"切换单机 "
                     image:[UIImage imageNamed:@"wv_change_black"]
                    target:self
                    action:@selector(line)],
      [KxMenuItem menuItem:@"刷新"
                     image:[UIImage imageNamed:@"wv_refresh_black"]
                    target:self
                    action:@selector(refresh)],
      [KxMenuItem menuItem:@"使用说明"
                     image:[UIImage imageNamed:@"wv_des_black"]
                    target:self
                    action:@selector(instructe)],
      [KxMenuItem menuItem:@"设置"
                     image:[UIImage imageNamed:@"wv_set_black"]
                    target:self
                    action:@selector(set)]
      ];
    OptionalConfiguration opt = {
        .arrowSize =  9,     //指示箭头大小
        .marginXSpacing= 7,  //MenuItem左右边距
        .marginYSpacing= 9,  //MenuItem上下边距
        .intervalSpacing= 28,  //MenuItemImage与MenuItemTitle的间距
        .menuCornerRadius= 6.5,  //菜单圆角半径
        .maskToBackground= true,  //是否添加覆盖在原View上的半透明遮罩
        .shadowOfMenu= false,  //是否添加菜单阴影
        .hasSeperatorLine= true,  //是否设置分割线
        .seperatorLineHasInsets= false,//是否在分割线两侧留下Insets
        .textColor= {0.2f,0.2f,0.2f}, //Color(R: 0, G: 0, B: 0),  //menuItem字体颜色
        .menuBackgroundColor= {1,1,1}  //菜单的底色

    };
    [KxMenu showMenuInView:self.navigationController.view fromRect:CGRectMake(self.view.frame.size.width-55, self.view.frame.origin.y-50, [sender view].frame.size.width, [sender view].frame.size.height) menuItems:menuItems withOptions:opt];
}

-(void)line{
    DeviceListWifiViewController *devcieListWifiVc = [[DeviceListWifiViewController alloc] init];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:devcieListWifiVc, nil]];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setInteger:1 forKey:@"mode"];
}

-(void)refresh{
    self.loading.hidden = NO;
    [self.loading startAnimating];
}

-(void)instructe{
    WebViewController *webVc = [[WebViewController alloc] initWithWidthTitle:@"使用说明" andUrl:@"instructe.html"];
    [self.navigationController pushViewController:webVc animated:YES];
}

-(void)set{
    SetViewController *setVc = [[SetViewController alloc] init];
    [self.navigationController pushViewController:setVc animated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellID = @"CELL";
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil){
        cell = [[DeviceCell alloc]initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellID];
        cell.tag = indexPath.item;
    }
    
    NSDictionary *item = self.data[indexPath.item];
    cell.tag = indexPath.item;
    cell.title.text = [NSString stringWithFormat:@"智控%d",[item[@"deviceId"] intValue]];
    
    int infoBar = [item[@"infoBar"] intValue];
    cell.info.text = [ViewUtil stringOfInfoBar:infoBar];
    if(infoBar==0){
        cell.info.textColor = [ViewUtil colorHex:@"cccccc"];
        cell.info.layer.borderColor = [[ViewUtil colorHex:@"cccccc"] CGColor];
    }else if(infoBar==1){
        cell.info.textColor = [ViewUtil colorHex:@"1aad19"];
        cell.info.layer.borderColor = [[ViewUtil colorHex:@"1aad19"] CGColor];
    }else{
        cell.info.textColor = [ViewUtil colorHex:@"e64340"];
        cell.info.layer.borderColor = [[ViewUtil colorHex:@"e64340"] CGColor];
    }
    if([item[@"online"] intValue] == 0){
        cell.info.textColor = [ViewUtil colorHex:@"cccccc"];
        cell.info.layer.borderColor = [[ViewUtil colorHex:@"cccccc"] CGColor];
        cell.info.text = @"失去连接";
    }
    CGSize maximumLabelSize = CGSizeMake(60, 260);
    CGSize expectSize = [cell.info sizeThatFits:maximumLabelSize];
    cell.info.frame = CGRectMake(113,20, expectSize.width+15, expectSize.height+8);
    cell.content.text = [NSString stringWithFormat:@"温度:%@，湿度:%@，压差:%@",item[@"temp"],item[@"hr"],item[@"dp"]];
    cell.des.text = [NSString stringWithFormat:@"换气期数:%@，进风速度:%.2lf，目标压差:%@",item[@"airCount"],[item[@"inWindSpeed"] floatValue]/100,item[@"dpTarget"]];
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 133;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceDetailViewController *deviceDetailVc = [[DeviceDetailViewController alloc] init];
    deviceDetailVc.device = self.data[indexPath.item];
    [self.navigationController pushViewController:deviceDetailVc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)dealloc{
    NSLog(@"listdealloc");
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [[OnlineService sharedInstance] timerStop];
}


@end
