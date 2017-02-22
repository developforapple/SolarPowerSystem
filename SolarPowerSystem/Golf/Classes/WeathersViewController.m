//
//  WeathersViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "WeathersViewController.h"
#import "WeathersCell.h"
#import "WeatherModel.h"

@interface WeathersViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;

@end

@implementation WeathersViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.weatherArr count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    WeathersCell *cell = [tableView dequeueReusableCellWithIdentifier:@"WeathersCell" forIndexPath:indexPath];
    if (indexPath.row < _weatherArr.count) {
        cell.index = indexPath.row;
        cell.wm = _weatherArr[indexPath.row];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}

@end
