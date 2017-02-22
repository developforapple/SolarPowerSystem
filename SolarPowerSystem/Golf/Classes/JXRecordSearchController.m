//
//  JXRecordSearchController.m
//  Golf
//
//  Created by 黄希望 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXRecordSearchController.h"
#import "JXSearchRecordCell.h"


@interface JXRecordSearchController ()
@end

@implementation JXRecordSearchController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.recordList = [NSMutableArray array];
    [self.recordList addObjectsFromArray:[[NSUserDefaults standardUserDefaults] objectForKey:self.cacheName]];

        
    [self.tableView registerNib:[UINib nibWithNibName:@"JXSearchRecordCell" bundle:nil] forCellReuseIdentifier:@"JXSearchRecordCell"];
    self.tableView.tableFooterView = [[UIView alloc] init];
    [self.tableView setContentInset:UIEdgeInsetsMake(64, 0, 0, 0)];
    self.tableView.separatorColor = [UIColor colorWithHexString:@"#e6e6e6"];
}


#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.recordList.count>0 ? [self.recordList count]+1 : 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    JXSearchRecordCell *cell = [tableView dequeueReusableCellWithIdentifier:@"JXSearchRecordCell" forIndexPath:indexPath];
    if (indexPath.row == self.recordList.count && self.recordList.count > 0) {
        cell.textLabel.text = @"清除历史记录";
    }else{
        cell.textLabel.text = self.recordList[indexPath.row];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.completion) {
        if (indexPath.row < self.recordList.count) {
            self.completion (self.recordList[indexPath.row]);
        }else{
            [self.recordList removeAllObjects];
            [[NSUserDefaults standardUserDefaults] setObject:self.recordList forKey:self.cacheName];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self.tableView reloadData];
            if (self.clearCompletion) {
                self.clearCompletion ();
            }
        }
        [UIView animateWithDuration:0.2 animations:^{
            self.view.alpha = 0;
        } completion:^(BOOL finished) {
            if (self.hide) {
                self.hide(self);
            }
        }];
    }
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    if (self.disappearKeyboard) {
        self.disappearKeyboard ();
    }
}

@end
