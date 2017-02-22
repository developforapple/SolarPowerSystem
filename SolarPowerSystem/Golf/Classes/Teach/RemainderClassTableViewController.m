//
//  RemainderClassTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "RemainderClassTableViewController.h"
#import "RemainderClassTableViewCell.h"
#import "MemberClassModel.h"
#import "JXChooseTimeController.h"
#import "TeachingOrderDetailViewController.h"
#import "YGTeachingArchiveCourseDetailViewCtrl.h"

@interface RemainderClassTableViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;
@end

@implementation RemainderClassTableViewController{
    NSMutableArray *datas;
    NoResultView *noResultView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    datas = [[NSMutableArray alloc] init];
    
    [self loadData];
    
    __weak RemainderClassTableViewController *weakSelf = self;
    
    noResultView = [NoResultView text:@"暂无剩余课时" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    self.tableView.contentInset = UIEdgeInsetsMake(64.f, 0, 0, 0);
}

- (void)loadData{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[ServiceManager serviceManagerWithDelegate:self] getTeachingMemberClassList:_sessionId coachId:_coachId];
    });
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    
    NSArray *arr = (NSArray*)data;
    if (Equal(flag, @"teaching_member_class_list")) {
        [datas removeAllObjects];
        [datas addObjectsFromArray:arr];
        
        [noResultView show:arr == nil || arr.count == 0];
    }
    if (_loadingView) {
        [_loadingView removeFromSuperview];
    }
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return datas.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    RemainderClassTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RemainderClassTableViewCell" forIndexPath:indexPath];
    MemberClassModel *modal = datas[indexPath.row];
    [cell loadData:modal];
    if (cell.blockReturn == nil) {
        cell.blockReturn = ^(id data){
            MemberClassModel *m = (MemberClassModel *)data;
            if (m.remainHour > 0) {
                [self chooseTime:m];
            }else{
                [SVProgressHUD showInfoWithStatus:@"剩余课时已用完，不可预约"];
            }
        };
    }
    return cell;
}

- (void)chooseTime:(MemberClassModel *)m{
    TeachingCoachModel *tc = [[TeachingCoachModel alloc] init];
    tc.coachId = m.coachId;
    tc.nickName = m.nickName;
    tc.headImage = m.headImage;
    tc.teachingSite = m.teachingSite;
    
    [self pushWithStoryboard:@"Jiaoxue" title:@"选择预约时间" identifier:@"JXChooseTimeController" completion:^(BaseNavController *controller) {
        JXChooseTimeController *chooseTime = (JXChooseTimeController*)controller;
        chooseTime.teachingCoach = tc;
        chooseTime.productId = m.productId;
        chooseTime.productName = m.productName;
        chooseTime.classHour = m.classHour;
        chooseTime.remainHour = m.remainHour;
        chooseTime.classNo = m.classHour-m.remainHour+1;
        chooseTime.classId = m.classId;
        chooseTime.classType = m.classType;
        chooseTime.blockReturn = ^(id data){
            [self loadData];
            if (_blockReturn) {
                _blockReturn(nil);
            }
            [self.navigationController popToViewController:self animated:YES];
        };
    }];
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 86;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    MemberClassModel *m = datas[indexPath.row];
    
    // 跳转到课时详情
    [self _gotoYGTeachingArchiveCourseDetailViewCtrl:m];
}

/**
 跳转到课时详情

 @param m
 */
-(void)_gotoYGTeachingArchiveCourseDetailViewCtrl:(MemberClassModel *) m
{
//    [self pushWithStoryboard:@"Teach" title:@"订单详情" identifier:@"TeachingOrderDetailViewController" completion:^(BaseNavController *controller) {
//        TeachingOrderDetailViewController *vc = (TeachingOrderDetailViewController *)controller;
//        vc.classId = m.classId;
//        vc.title = @"订单详情";
//        vc.blockRefresh = ^(id data){
//            [self loadData];
//        };
//    }];
    
    YGTeachingArchiveCourseDetailViewCtrl *vc = [YGTeachingArchiveCourseDetailViewCtrl instanceFromStoryboard];
    vc.classId = m.classId;
    ygweakify(self)
    vc.taCourseDetailBlock = ^() {
        ygstrongify(self)
        [self loadData];
    };
    [self.navigationController pushViewController:vc animated:YES];
}


@end
