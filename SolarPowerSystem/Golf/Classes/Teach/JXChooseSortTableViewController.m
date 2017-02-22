//
//  JXChooseSortTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXChooseSortTableViewController.h"

@interface JXChooseSortTableViewController ()

@end

@implementation JXChooseSortTableViewController{
    NSArray *datas;
    UITableViewCell *_tempCell;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    datas = @[@"推荐排序",@"教学最多",@"距离最近",@"级别最高",@"评分最高",@"价格最低"];
    self.tableView.backgroundColor = [UIColor clearColor];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.text = datas[indexPath.row];
    if (_sort == indexPath.row) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        if ([cell respondsToSelector:@selector(tintColor)]) {
            [cell.textLabel setTextColor:cell.tintColor];
        }else{
            [cell.textLabel setTextColor:[UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0]];
        }
        _tempCell = cell;
    }else{
        cell.accessoryType = UITableViewCellAccessoryNone;
        [cell.textLabel setTextColor:[UIColor blackColor]];
    }
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (_blockReturn) {
        if (_tempCell) {
            _tempCell.accessoryType = UITableViewCellAccessoryNone;
            _tempCell.textLabel.textColor = [UIColor blackColor];
        }
        UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
        _tempCell = cell;
        if ([cell respondsToSelector:@selector(tintColor)]) {
            [cell.textLabel setTextColor:cell.tintColor];
        }else{
            [cell.textLabel setTextColor:[UIColor colorWithRed:85/255.0 green:192/255.0 blue:234/255.0 alpha:1.0]];
        }
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        _blockReturn(@{@"title":datas[indexPath.row],@"value":@(indexPath.row)});
    }
}

@end
