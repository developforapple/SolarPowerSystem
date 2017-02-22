//
//  YGPopoverItemsViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPopoverItemsViewCtrl.h"

@interface YGPopoverItemsViewCtrl ()<UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *popoverView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *popoverHeightConstraint;
@property (strong, nonatomic) NSArray *items;
@property (copy, nonatomic) void (^callback)(YGPopoverItem *item);
@end

@implementation YGPopoverItemsViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self adjustUI];
}

- (void)show
{
    self.popoverView.alpha = 0.f;
    [super show];
}

- (void)didShowAnimation
{
    [UIView animateWithDuration:.3f animations:^{
        self.popoverView.alpha = 1.f;
    } completion:^(BOOL finished) {
    }];
}

- (void)dismiss
{
    [UIView animateWithDuration:0.3f animations:^{
        self.popoverView.alpha = 0.f;
    } completion:^(BOOL finished) {
        [super dismiss];
    }];
}

- (void)setupItems:(NSArray *)items
          callback:(void (^)(YGPopoverItem *item))callback
{
    self.items = items;
    self.callback = callback;
    [self adjustUI];
    [self.tableView reloadData];
}

- (void)adjustUI
{
    self.popoverHeightConstraint.constant = self.tableView.rowHeight * self.items.count + 5.f;
    [self.popoverView.superview layoutIfNeeded];
}

- (IBAction)backAction:(id)sender
{
    [self dismiss];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.items.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YGMallPopoverCell" forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:10086];
    UILabel *label = [cell viewWithTag:10010];
    YGPopoverItem *item = self.items[indexPath.row];
    label.text = item.title;
    imageView.image = [UIImage imageNamed:item.iconName];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.callback) {
        YGPopoverItem *item = self.items[indexPath.row];
        self.callback(item);
    }
    [self dismiss];
}
@end

#import "YGMallViewCtrl.h"
#import "YGMallCommodityListContainer.h"
#import "YGMallCartViewCtrl.h"
#import "ClubHomeController.h"
#import "TeachHomeTableViewController.h"

@implementation YGPopoverItem

+ (instancetype)itemWithType:(YGPopoverItemType)type
{
    YGPopoverItem *item = [YGPopoverItem new];
    switch (type) {
        case YGPopoverItemTypeHome:{
            item.title = @"首页";
            item.iconName = @"icon_mall_index_more_home";
        }   break;
        case YGPopoverItemTypeMall:{
            item.title = @"商城";
            item.iconName = @"icon_mall_index_more_mall";
        }   break;
        case YGPopoverItemTypeMallList:{
            item.title = @"精选";
            item.iconName = @"icon_mall_index_more_list";
        }   break;
        case YGPopoverItemTypeMallCart:{
            item.title = @"购物车";
            item.iconName = @"icon_mall_index_more_cart";
        }   break;
        case YGPopoverItemTypeCourseHome:{
            item.title = @"球场";
            item.iconName = @"icon_course_more_home";
        }   break;
        case YGPopoverItemTypeTeachingHome:{
            item.title = @"教学";
            item.iconName = @"icon_teaching_more_home";
        }   break;
        case YGPopoverItemTypeTeachBookingHome:{
            item.title = @"练习场";
            item.iconName = @"icon_teaching_more_home";
        }   break;
    }
    item.type = type;
    return item;
}

+ (void)performDefaultOpeaterOfItem:(YGPopoverItem *)item fromNavi:(UINavigationController *)navi
{
    if (!navi) return;
    
    __kindof UIViewController *(^CleckViewCtrl)(Class cls) = ^ __kindof UIViewController *(Class cls){
        for (UIViewController *vc in navi.viewControllers) {
            if ([vc isKindOfClass:cls]) {
                return vc;
            }
        }
        return nil;
    };
    
    switch (item.type) {
        case YGPopoverItemTypeHome:{
            [navi popToRootViewControllerAnimated:YES];
        }   break;
        case YGPopoverItemTypeMall:{
            __kindof UIViewController *vc = CleckViewCtrl([YGMallViewCtrl class]);
            if (vc) {
                [navi popToViewController:vc animated:YES];
            }else{
                vc = [YGMallViewCtrl instanceFromStoryboard];
                [navi pushViewController:vc animated:YES];
            }
        }   break;
        case YGPopoverItemTypeMallList:{
            YGMallCommodityListContainer *vc = CleckViewCtrl([YGMallCommodityListContainer class]);
            if (vc) {
                [navi popToViewController:vc animated:YES];
            }else{
                [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:2 dataId:-1 extro:@"" controller:navi.topViewController];
            }
        }   break;
        case YGPopoverItemTypeMallCart:{
            YGMallCartViewCtrl *vc = CleckViewCtrl([YGMallCartViewCtrl class]);
            if (vc) {
                [navi popToViewController:vc animated:YES];
            }else{
                [[LoginManager sharedManager] loginIfNeed:navi.topViewController doSomething:^(id data) {
                    YGMallCartViewCtrl *cartVC = [YGMallCartViewCtrl instanceFromStoryboard];
                    [navi pushViewController:cartVC animated:YES];
                }];
            }
        }   break;
        case YGPopoverItemTypeCourseHome:{
            ClubHomeController *vc = CleckViewCtrl([ClubHomeController class]);
            if (vc) {
                [navi popToViewController:vc animated:YES];
            }else{
                vc = [ClubHomeController instanceFromStoryboard];
                [navi pushViewController:vc animated:YES];
            }
        }   break;
        case YGPopoverItemTypeTeachingHome:
        case YGPopoverItemTypeTeachBookingHome:{
            TeachHomeTableViewController *vc = CleckViewCtrl([TeachHomeTableViewController class]);
            if (vc) {
                [navi popToViewController:vc animated:YES];
            }else{
                vc = [TeachHomeTableViewController instanceFromStoryboard];
                [navi pushViewController:vc animated:YES];
            }
        }   break;
    }
}

@end
