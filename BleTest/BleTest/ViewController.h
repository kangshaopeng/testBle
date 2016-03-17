//
//  ViewController.h
//  BleTest
//
//  Created by ainia on 16/2/16.
//  Copyright © 2016年 ainia. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreBluetooth/CoreBluetooth.h>
@interface ViewController : UIViewController<CBCentralManagerDelegate,CBPeripheralDelegate>
@property(strong,nonatomic)CBCentralManager *myCentralManager;
@property(strong,nonatomic)NSMutableArray *dicoveryPeripherals;
@property(strong,nonatomic)NSMutableArray *peripheralsRSSI;
@property(strong,nonatomic)CBPeripheral *connectedPeripheral;
@end

