//
//  CourseDelayController.m
//  Golf
//
//  Created by 黄希望 on 15/6/3.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseDelayController.h"
#import "CourseDelayMonthCell.h"

@interface CourseDelayController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) IBOutlet UITableView *tableView;
@property (nonatomic,assign) NSInteger monthNum;
@property (nonatomic,strong) NSString *changeDate;

@end

@implementation CourseDelayController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.monthNum = 1;
    self.changeDate = [self delayDateWithDate:self.expiredDate];
}

#pragma mark - UITableView delegate && dataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 8;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQ_TITLE_CELL" forIndexPath:indexPath];
        return cell;
    }else if (indexPath.row == 6){
        CourseDelayMonthCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQ_RESULT_CELL" forIndexPath:indexPath];
        cell.titleLB.text = [NSString stringWithFormat:@"课程延期至: %@",self.changeDate];
        return cell;
    }else if (indexPath.row == 7){
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQ_BUTTON_CELL" forIndexPath:indexPath];
        return cell;
    }else{
        CourseDelayMonthCell *cell = [tableView dequeueReusableCellWithIdentifier:@"YQ_TIME_CELL" forIndexPath:indexPath];
        cell.titleLB.text = [NSString stringWithFormat:@"%tu天",indexPath.row*30];
        cell.accessoryType = self.monthNum == indexPath.row ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryNone;
        
        return cell;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row > 0 && indexPath.row < 7) {
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
        self.monthNum = indexPath.row;
        
        self.changeDate = [self delayDateWithDate:self.expiredDate];
        
        [[GolfAppDelegate shareAppDelegate] performBlock:^{
            [tableView reloadData];
        } afterDelay:0.1];
    }
}

- (NSString*)delayDateWithDate:(NSString*)aDate{
    if (!aDate) {
        return [Utilities stringwithDate:[NSDate date]];
    }
    NSDate *date = [Utilities getDateFromString:aDate];
    NSDate *newDate = [Utilities getTheDay:date withNumberOfDays:self.monthNum * 30];
    return [Utilities stringwithDate:newDate];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 40;
    }else if (indexPath.row == 6){
        return 46;
    }else if (indexPath.row == 7){
        return 64;
    }else{
        return 44;
    }
}

- (IBAction)buttonAction:(id)sender{
    [[ServiceManager serviceManagerWithDelegate:self] teachingMemberClassPostpone:[[LoginManager sharedManager] getSessionId] classId:self.classId dayNum:self.monthNum*30];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (serviceManager.success) {
        if (_blockReturn) {
            _blockReturn(nil);
        }
        [SVProgressHUD showInfoWithStatus:@"已延期成功"];
    }
}

@end
