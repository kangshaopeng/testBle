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
    //4.查询服务
    [peripheral discoverServices:nil];
    //获取查找结果 代理
    peripheral.delegate = self;
    
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverServices:(NSError *)error{
    NSLog(@"%@",peripheral.services);
    //5.匹配需求服务
    for (CBService *service in peripheral.services) {
        NSLog(@"%@",service.UUID.UUIDString);
        if ([service.UUID.UUIDString isEqualToString:@"FE00"]) {
            //6.查询特征
            [peripheral discoverCharacteristics:nil forService:service];
            
        }
    }
}
-(void)peripheral:(CBPeripheral *)peripheral didDiscoverCharacteristicsForService:(CBService *)service error:(NSError *)error{
    NSLog(@"%@",service.characteristics);
    //7.匹配特征
    for (CBCharacteristic *characteristic in service.characteristics) {
        if ([characteristic.UUID.UUIDString isEqualToString:@"FE01"]) {
            //8.进行数据读写
            NSData *data = [self stringToHex:@"7F10"];
            [peripheral setNotifyValue:YES forCharacteristic:characteristic];
            //写入数据
            [peripheral writeValue:data forCharacteristic:characteristic type:CBCharacteristicWriteWithoutResponse];
            //读取数据
            [peripheral readValueForCharacteristic:characteristic];
        }
    }

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
    return 44;
}

- (NSData *)stringToHex:(NSString *)string
{
    NSMutableData *data = [[NSMutableData alloc] initWithCapacity:0];
    string = [string stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (string.length%2 != 0) //长度不是偶数的倍数
    {
        return nil;
    }
    NSUInteger len = string.length/2;
    Byte byte;
    for (NSUInteger i=0; i<len; i++)
    {
        byte = ([self toByte:[string characterAtIndex:2*i]]<<4) + [self toByte:[string characterAtIndex:2*i+1]];
        [data appendBytes:&byte length:1];
    }
    
    return data;
}
//将字符转换为对应的asci值
-(Byte)toByte:(unichar)ch;
{
    if (ch>='a' && ch<='f')
    {
        return ch-'a'+10;
    }
    else if (ch>='A' && ch<='F')
    {
        return ch-'A'+10;
    }
    else if (ch>='0' && ch<='9')
    {
        return ch-'0';
    }
    else
    {
        return 0;
    }
}
//  当已经更新特征的数据后调用
///
///  @param peripheral     外设
///  @param characteristic 特征
///  @param error          错误
- (void)peripheral:(CBPeripheral *)peripheral didUpdateValueForCharacteristic:(CBCharacteristic *)characteristic error:(NSError *)error{
    NSData *data = characteristic.value;
    NSLog(@"--------%@",data);
}

@end
