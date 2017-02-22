//
//  ChooseStudentTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ChooseStudentTableViewController.h"
#import "MemberClassModel.h"
#import "NoResultView.h"
#import "StudentInfoTableViewCell.h"
#import "YGTAStudentTimeAlertView.h"
#import "JCAlertView.h"

@interface ChooseStudentTableViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation ChooseStudentTableViewController{
    NSMutableArray *datas;
    NSArray *filterData;
    NoResultView *noResultView;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    datas = [[NSMutableArray alloc] init];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    [self loadData];
    
    __weak ChooseStudentTableViewController *weakSelf = self;
    noResultView =  [NoResultView text:@"暂无剩余课时的学员" type:NoResultTypeList superView:self.view show:^{
        weakSelf.tableView.hidden = YES;
    } hide:^{
        weakSelf.tableView.hidden = NO;
    }];
    
    UIButton *navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navLeftButton.frame = CGRectMake(0, 0, 50, 30);
    UIImage *img = [UIImage imageNamed:@"back_icon.png"];
    [navLeftButton setBackgroundImage:img forState:UIControlStateNormal];
    [navLeftButton setBackgroundImage:img forState:UIControlStateHighlighted];
    [navLeftButton addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
}

- (void)doLeftNavAction{
    [self.navigationController popViewControllerAnimated:YES];
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
        [noResultView show:datas.count == 0];
    }
    
    [self.tableView reloadData];
}

#pragma mark - Table view data source

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        // 谓词搜索
        NSString *str = self.searchDisplayController.searchBar.text;
        NSPredicate *predicate = [NSPredicate predicateWithFormat:@"nickName contains [cd] %@",str];
        filterData =  [[NSArray alloc] initWithArray:[datas filteredArrayUsingPredicate:predicate]];
        return filterData.count;
    }else{
        return datas.count;
    }
}
#pragma clang diagnostic pop

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 100;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    StudentInfoTableViewCell *cell = nil;
    
    MemberClassModel *m = nil;
    
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        m = filterData[indexPath.row];
        cell = [self.tableView dequeueReusableCellWithIdentifier:@"StudentInfoTableViewCell"];
    }else{
        m = datas[indexPath.row];
        cell = [tableView dequeueReusableCellWithIdentifier:@"StudentInfoTableViewCell" forIndexPath:indexPath];
    }
#pragma clang diagnostic pop

    [cell loadData:m];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    MemberClassModel *m = nil;
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        [self.searchDisplayController.searchBar resignFirstResponder];
        m = filterData[indexPath.row];
    }else{
        m = datas[indexPath.row];
    }
#pragma clang diagnostic pop
    
    m.orderTime = [NSString stringWithFormat:@"%@ %@%@",_date,_time,_nextTime];
    // 弹窗预约
    [self _showYGTAStudentTimeAlertView:m];
}

/**
 * 弹窗确认预约
 */
-(void) _showYGTAStudentTimeAlertView:(MemberClassModel *) m
{
    YGTAStudentTimeAlertView *alerView = [YGTAStudentTimeAlertView instance];
    alerView.width = Device_Width - 50.f;
    [alerView configureWithEntity:m date:self.date time:self.time];
    
    JCAlertView *alert = [[JCAlertView alloc] initWithCustomView:alerView dismissWhenTouchedBackground:NO];
    [alert show];
    
    ygweakify(self)
    alerView.studentTimeOptBlock = ^(MemberClassModel *memberClassModel,YGTAStudentTimeAlertOptType optType){
        ygstrongify(self)
        switch (optType) {
            case YGTAStudentTimeAlertOptTypeCancel:
            case YGTAStudentTimeAlertOptTypeConfirm:
                [alert dismissWithCompletion:NULL];
                break;
            case YGTAStudentTimeAlertOptTypeAppointmented:
                if (self.blockReturn) {
                    self.blockReturn(nil);
                }
                break;
            default:
                break;
        }
    };
}

@end
