//
//  DeviceListViewController.m
//  USRIOS
//
//  Created by 沈耀杰 on 2017/6/13.
//  Copyright © 2017年 沈耀杰. All rights reserved.
//

#import "DeviceListViewController.h"
#import "ViewUtil.h"
#import "DeviceCell.h"
#import "DeviceDetailViewController.h"

@interface DeviceListViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(nonatomic,retain) UITableView *tableView;
@property(nonatomic,retain) UIActivityIndicatorView *loading;
@property(nonatomic,retain) NSMutableArray *data;
@end


@implementation DeviceListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initView];
}

-(void)initView{
    self.title = @"智控列表";
    self.view.backgroundColor = [ViewUtil colorHex:@"f8f8f8"];
    
    CGRect rx = [ UIScreen mainScreen ].bounds;
    CGFloat screenWidth = rx.size.width;
    CGFloat screenHeight = rx.size.height;
    
    self.loading =  [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0,0, 30, 30)];
    self.loading.center = CGPointMake(self.view.center.x, self.view.center.y-50);
    [self.loading setActivityIndicatorViewStyle:UIActivityIndicatorViewStyleGray];
    self.loading.hidden = NO;
    [self.loading startAnimating];
    
    
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, screenWidth, screenHeight-64) style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.view addSubview:self.tableView];
    [self.view addSubview:self.loading];

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
    return 2;
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
    cell.textLabel.text = @"111";
    return cell;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 160;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    DeviceDetailViewController *deviceDetailVc = [[DeviceDetailViewController alloc] init];
    [self.navigationController pushViewController:deviceDetailVc animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"返回" style:UIBarButtonItemStylePlain target:nil action:nil];
}

-(void)dealloc{
    NSLog(@"listdealloc");
}


@end
