//
//  YGMoreSettingsViewCtrl.m
//  Golf
//
//  Created by zhengxi on 15/12/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGMoreSettingsViewCtrl.h"
#import "YGMoreSettingsCell.h"
#import "YGRedEnvelpoeViewCtrl.h"
#import "CoachTransitionalPageController.h"
#import "CoachInfoReviewController.h"

@interface YGMoreSettingsViewCtrl ()<UITableViewDataSource, UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *iconArray;
@property (strong, nonatomic) NSArray *titleArray;
@property (strong, nonatomic) NSArray *trailingArray;
@end

@implementation YGMoreSettingsViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializeTableView];
}

- (void)initializeTableView {
    self.iconArray = @[@"hongbao", @"jiaolian"];
    self.titleArray = @[@"发红包", @"申请开通教练"];
    self.trailingArray = @[@"", @""];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (self.coachLevel > -1) {
        return self.iconArray.count - 1;
    }else{
        return self.iconArray.count;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    YGMoreSettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMoreSettingsCell" forIndexPath:indexPath];
    cell.trailingLabel.text = _trailingArray[indexPath.row];
    cell.iconImageView.image = [UIImage imageNamed:_iconArray[indexPath.row]];
    cell.iconLabel.text = _titleArray[indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.row == 0) {
        YGRedEnvelpoeViewCtrl *redPaper = [[YGRedEnvelpoeViewCtrl alloc] init];
        [self pushViewController:redPaper title:_titleArray[indexPath.row] hide:YES];
    }else{
        if (self.coachLevel == -2) {
            ygweakify(self);
            [self pushWithStoryboard:@"Coach" title:@"" identifier:@"CoachTransitionalPageController" completion:^(BaseNavController *controller) {
                CoachTransitionalPageController *vc = (CoachTransitionalPageController*)controller;
                vc.blockReturn = ^(id obj){
                    ygstrongify(self);
                    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
                };
            }];
        }else if (self.coachLevel == -1){
            [self pushWithStoryboard:@"Coach" title:@"正在审核" identifier:@"CoachInfoReviewController" completion:^(BaseNavController *controller){
                CoachInfoReviewController *coachInfoReview = (CoachInfoReviewController*)controller;
                coachInfoReview.isReview = YES;
            }];
        }
    }
}

@end
