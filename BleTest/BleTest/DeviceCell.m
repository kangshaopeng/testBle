//
//  DeviceCell.m
//  BleTest
//
//  Created by ainia on 16/3/17.
//  Copyright © 2016年 ainia. All rights reserved.
//

#import "DeviceCell.h"

@implementation DeviceCell

+ (instancetype)cellWithTableView:(UITableView *)tableView
{
    static NSString *ID = @"DeviceCell";
    DeviceCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (cell == nil) {
        // 从xib中加载cell
        cell = [[[NSBundle mainBundle] loadNibNamed:@"DeviceCell" owner:nil options:nil] lastObject];
    }
    return cell;
}
-(void)setDeviceDic:(NSDictionary *)deviceDic{
    self.deviceImageView.image=[UIImage imageNamed:@"ad_00"];
    if (deviceDic[@"deviceTitle"]) {
        self.deviceLable.text=deviceDic[@"deviceTitle"];
    }else{
        self.deviceLable.text=nil;
    }
    
}
@end