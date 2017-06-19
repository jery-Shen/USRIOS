//
//  DeviceListWifiViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/19.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceListWifiViewController.h"
#import "DeviceListViewController.h"
#import "ViewUtil.h"
#import "DeviceCell.h"
#import "DeviceDetailViewController.h"
#import "NirKxMenu.h"


@interface DeviceListWifiViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UIActivityIndicatorView *loading;
@property(nonatomic,retain) NSMutableArray *data;
@end

@implementation DeviceListWifiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title = @"智控列表";
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    UIBarButtonItem *rightButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"menu_btn"] style:UIBarButtonItemStyleDone target:self action:@selector(menu:)];
    self.navigationItem.rightBarButtonItem = rightButtonItem;
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.loading =  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 30, 30)];
    self.loading.center = CGPointMake(self.view.center.x, self.view.center.y-50);
    [self.loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.loading.hidden = NO;
    // [self.loading startAnimating];
    
    self.loading.hidden = YES;
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loading];
    
}



-(void)menu:(id)sender{
    NSArray *menuItems =
    @[[KxMenuItem menuItem:@"切换联网"
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
        .intervalSpacing= 25,  //MenuItemImage与MenuItemTitle的间距
        .menuCornerRadius= 6.5,  //菜单圆角半径
        .maskToBackground= true,  //是否添加覆盖在原View上的半透明遮罩
        .shadowOfMenu= false,  //是否添加菜单阴影
        .hasSeperatorLine= true,  //是否设置分割线
        .seperatorLineHasInsets= false,//是否在分割线两侧留下Insets
        .textColor= {0.2f,0.2f,0.2f}, //Color(R: 0, G: 0, B: 0),  //menuItem字体颜色
        .menuBackgroundColor= {1,1,1}  //菜单的底色
        
    };
    
    [KxMenu showMenuInView:self.navigationController.view fromRect:CGRectMake([sender view].frame.origin.x, [sender view].frame.origin.y+25, [sender view].frame.size.width, [sender view].frame.size.height) menuItems:menuItems withOptions:opt];
    
    
}

-(void)line{
    DeviceListViewController *devcieListVc = [[DeviceListViewController alloc] init];
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    [self.navigationController setViewControllers:[[NSArray alloc]initWithObjects:devcieListVc, nil]];
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    [defaults setInteger:0 forKey:@"mode"];
}

-(void)refresh{
    
}

-(void)instructe{
    
}

-(void)set{
    
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
    return 5;
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
    
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 133;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceDetailViewController *deviceDetailVc = [[DeviceDetailViewController alloc] init];
    [self.navigationController pushViewController:deviceDetailVc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)dealloc{
    NSLog(@"listwifidealloc");
}

@end
