//
//  ViewController.m
//  BleTest
//
//  Created by ainia on 16/2/16.
//  Copyright © 2016年 ainia. All rights reserved.
//

#import "ViewController.h"
#import "DeviceCell.h"
@interface ViewController ()<UITableViewDataSource,UITableViewDelegate>
@property(strong,nonatomic)UITableView *tableView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView=[[UITableView alloc]initWithFrame:CGRectMake(10, 64, self.view.bounds.size.width-20, self.view.bounds.size.height-64) style:UITableViewStyleGrouped];
    self.tableView.delegate=self;
    self.tableView.dataSource=self;
    [self.view addSubview:self.tableView];
    [self setupRightButton];
    self.myCentralManager=[[CBCentralManager alloc]initWithDelegate:self queue:nil];
    self.dicoveryPeripherals=[NSMutableArray array];
    self.peripheralsRSSI=[NSMutableArray array];
}
-(void)setupRightButton{
    UIButton *rightButton=[[UIButton alloc]initWithFrame:CGRectMake(self.view.frame.size.width-50, 30, 40, 40)];
    [rightButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [rightButton setTitle:@"扫描" forState:UIControlStateNormal];
    [rightButton addTarget:self action:@selector(scan) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:rightButton];
//    UIBarButtonItem *item=[[UIBarButtonItem alloc]initWithTitle:@"扫描" style:UIBarButtonItemStylePlain target:self action:@selector(scan)];
//    self.navigationItem.rightBarButtonItem=item;
}
-(void)scan{
    [self.myCentralManager stopScan];
    if (self.dicoveryPeripherals.count) {
        [self.dicoveryPeripherals removeAllObjects];
    }
    NSDictionary *dic=[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:NO] forKey:CBCentralManagerScanOptionAllowDuplicatesKey];
    [self.myCentralManager scanForPeripheralsWithServices:nil options:dic];
}
/**
 CBCentralManagerStateUnknown = 0,
	CBCentralManagerStateResetting,
	CBCentralManagerStateUnsupported,
	CBCentralManagerStateUnauthorized,
	CBCentralManagerStatePoweredOff,
	CBCentralManagerStatePoweredOn,
 **/
-(void)centralManagerDidUpdateState:(CBCentralManager *)central{
    switch (central.state) {
        case CBCentralManagerStatePoweredOn:
            NSLog(@"蓝牙已经打开");
            [self.myCentralManager scanForPeripheralsWithServices:nil options:nil];
            break;
        case CBCentralManagerStatePoweredOff:
            NSLog(@"蓝牙已经关闭");
            break;
        case CBCentralManagerStateUnsupported:
            NSLog(@"CBCentralManagerStateUnsupported");
            break;
        case CBCentralManagerStateUnknown:
            NSLog(@"CBCentralManagerStateUnknown");
        case CBCentralManagerStateUnauthorized:
            NSLog(@"CBCentralManagerStateUnauthorized");
        case CBCentralManagerStateResetting:
            NSLog(@"CBCentralManagerStateResetting");
            break;
        default:
            break;
    }
}
-(void)centralManager:(CBCentralManager *)central didDiscoverPeripheral:(CBPeripheral *)peripheral advertisementData:(NSDictionary<NSString *,id> *)advertisementData RSSI:(NSNumber *)RSSI{
//    NSLog(@"%@----------%@--------%@----------%@",central,peripheral.name,advertisementData,RSSI);
    if (![self.dicoveryPeripherals containsObject:peripheral]) {
        [self.dicoveryPeripherals addObject:peripheral];
        [self.peripheralsRSSI addObject:RSSI];
        [self.tableView reloadData];
    }
    NSLog(@"%@--------------------%@",peripheral.name,RSSI);
}
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (section==0) {
        return 1;
    }else{
        return self.dicoveryPeripherals.count;
    }
    
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID=@"cell";
    UITableViewCell *cell=[tableView dequeueReusableCellWithIdentifier:ID];
    if (cell==nil) {
        cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:ID];
    }
    if (indexPath.section==0) {
        cell.textLabel.text=self.connectedPeripheral.name;
    }else{
        cell.textLabel.text=[self.dicoveryPeripherals[indexPath.row] name];
        cell.detailTextLabel.text=[NSString stringWithFormat:@"%@",self.peripheralsRSSI[indexPath.row]];
    }
    
    return cell;
//   DeviceCell *cell=[DeviceCell cellWithTableView:tableView];
//    if (indexPath.section==0) {
//        if (self.connectedPeripheral) {
//            cell.deviceDic=[NSDictionary dictionaryWithObject:[self.connectedPeripheral name] forKey:@"deviceTitle"];
//        }
//        
//    }else{
//        cell.deviceDic=[NSDictionary dictionaryWithObject:[self.dicoveryPeripherals[indexPath.row] name] forKey:@"deviceTitle"];
//    }
//    
//    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (indexPath.section==0) {
        [self.myCentralManager cancelPeripheralConnection:self.connectedPeripheral];
    }else{
        [self.myCentralManager connectPeripheral:self.dicoveryPeripherals[indexPath.row] options:nil];
        
    }
}
-(void)centralManager:(CBCentralManager *)central didConnectPeripheral:(CBPeripheral *)peripheral{
    self.connectedPeripheral=peripheral;
    [self.tableView reloadData];
    NSLog(@"连接上了------%@",peripheral.name);
}
-(void)centralManager:(CBCentralManager *)central didDisconnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    self.connectedPeripheral=nil;
    [self.tableView reloadData];
    NSLog(@"断开了蓝牙连接！！！");
}
-(void)centralManager:(CBCentralManager *)central didFailToConnectPeripheral:(CBPeripheral *)peripheral error:(NSError *)error{
    NSLog(@"蓝牙连接失败！！！");
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section==0) {
        return @"连接的设备";
    }else{
        return @"发现的设备";
    }
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}
@end
