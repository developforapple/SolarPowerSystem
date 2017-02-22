//
//  DDAssetsGroupListViewController.m
//  QuizUp
//
//  Created by Normal on 15/12/8.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsGroupViewController.h"
#import "DDAssetsManager.h"

#define kDDAssetsGroupCell @"DDAssetsGroupCell"

@interface DDAssetsGroupViewController ()<UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UIView *backBlurView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewHeightConstraint;

@property (strong, nonatomic) NSArray *dataSource;

@end

@implementation DDAssetsGroupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.backBlurView.backgroundColor = [UIColor clearColor];
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.tableView.tableFooterView = [UIView new];
    
    [self _loadDataSource];
    
    [self.backBlurView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(_dismiss)]];
}

- (void)_loadDataSource
{
    ddweakify(self);
    [DDAssetsManager loadAssetsGroupsWithCompletion:^(NSArray *groups, NSError *error) {
        ddstrongify(self);
        
        self.dataSource = groups;
        [self.tableView reloadData];
    }];
}

- (void)setDisplay:(BOOL)display
{
    if (display) {
        [self _loadDataSource];
        [self _show];
    }else{
        [self _dismiss];
    }
    _display = display;
}

- (void)_show
{
    _display = YES;
    [UIView animateWithDuration:.1f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backBlurView.backgroundColor = [UIColor colorWithWhite:.1f alpha:.6f];
    } completion:^(BOOL finished) {
    }];
    
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.tableViewHeightConstraint.constant = kDefaultGroupListFullHeight;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (self.didDisplayedBlock) {
            self.didDisplayedBlock();
        }
        
    }];
}

- (void)_dismiss
{
    _display = NO;
    [UIView animateWithDuration:.2f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        self.backBlurView.backgroundColor = [UIColor clearColor];
    } completion:^(BOOL finished) {
    }];
    [UIView animateWithDuration:.4f delay:0.f options:UIViewAnimationOptionCurveEaseInOut animations:^{
        
        self.tableViewHeightConstraint.constant = 0.f;
        [self.view layoutIfNeeded];
        
    } completion:^(BOOL finished) {
        
        if (self.didEndDisplayedBlock) {
            self.didEndDisplayedBlock();
        }
    }];
}

#pragma mark - UITableView delegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    id<DDGroupProtocol> group = self.dataSource[indexPath.row];
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kDDAssetsGroupCell forIndexPath:indexPath];
    cell.textLabel.text = [group groupTitle];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld张图片",(long)[group numberOfAssets]];
    [group posterImage:^(CGImageRef ref) {
        cell.imageView.image = [UIImage imageWithCGImage:ref];
    }];
    cell.imageView.bounds = CGRectMake(0, 0, 50.f, 50.f);
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.separatorInset = UIEdgeInsetsZero;
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.f) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self _dismiss];
    id<DDGroupProtocol> group = self.dataSource[indexPath.row];
    if (self.didSelectedGroupBlock) {
        self.didSelectedGroupBlock(group);
    }
}

@end
