//
//  DeviceCell.h
//  BleTest
//
//  Created by ainia on 16/3/17.
//  Copyright © 2016年 ainia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DeviceCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *deviceImageView;
@property (weak, nonatomic) IBOutlet UILabel *deviceLable;
+ (instancetype)cellWithTableView:(UITableView *)tableView;
@property(nonatomic,strong)NSDictionary *deviceDic;
@end
