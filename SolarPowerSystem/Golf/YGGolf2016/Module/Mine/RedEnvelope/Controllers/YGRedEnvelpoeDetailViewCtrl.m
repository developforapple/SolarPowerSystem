//
//  YGRedEnvelpoeDetailViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-8-26.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGRedEnvelpoeDetailViewCtrl.h"
#import "YGRedEnvelpoeDetailCell.h"
#import "SharePackage.h"

@interface YGRedEnvelpoeDetailViewCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    SharePackage *share;
}

@property (nonatomic,strong) RedPaperModel *redPaperDetailInfo;

@end

@implementation YGRedEnvelpoeDetailViewCtrl
@synthesize redPaperId;
@synthesize redPaperDetailInfo;


- (void)viewDidLoad
{
    [super viewDidLoad];
    shareBtn.hidden = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 0) style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    [self.view addSubview:_tableView];
    
    [_tableView registerNib:[UINib nibWithNibName:@"YGRedEnvelpoeDetailCell" bundle:nil] forCellReuseIdentifier:@"YGRedEnvelpoeDetailCell"];
    
    [[ServiceManager serviceManagerWithDelegate:self] redPaperDetail:[[LoginManager sharedManager] getSessionId] Id:self.redPaperId];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array && array.count > 0) {
        self.redPaperDetailInfo = [array objectAtIndex:0];
        NSString *date = [Utilities getDateStringFromString:self.redPaperDetailInfo.beginDate WithFormatter:@"MM月dd日"];
        oneLabel.text = [NSString stringWithFormat:@"%@消费奖励的红包",date];
        if (self.redPaperDetailInfo.totalQuantity == self.redPaperDetailInfo.usedQuantity) {
            twoLabel.text = [NSString stringWithFormat:@"%d个红包全部领完",self.redPaperDetailInfo.usedQuantity];
            twoLabel.textColor = [Utilities R:205 G:60 B:50];
            _tableView.frame = CGRectMake(0, twoLabel.frame.origin.y + twoLabel.frame.size.height + 25, Device_Width, 44*(self.redPaperDetailInfo.usedQuantity+1));
        }else{
            NSInteger num = [self willExpireDate:self.redPaperDetailInfo.expireDate];
            //NSLog(@"*** %d",num);
            NSString *getStatus = nil;
            if (num >= 0) {
                shareBtn.hidden = NO;
                getStatus = num > 0 ? [NSString stringWithFormat:@"%d天后过期",(int)num] : @"今天过期";
                twoLabel.text = [NSString stringWithFormat:@"还剩%d个红包  %@",self.redPaperDetailInfo.totalQuantity-self.redPaperDetailInfo.usedQuantity,getStatus];
            }else{
                shareBtn.hidden = YES;
                getStatus =  @"已过期";
                twoLabel.text = [NSString stringWithFormat:@"已领%d个/共%d个  %@",self.redPaperDetailInfo.usedQuantity,self.redPaperDetailInfo.totalQuantity,getStatus];
            }
            
            if (self.redPaperDetailInfo.usedList.count == 0) {
                _tableView.frame = CGRectMake(0, shareBtn.frame.origin.y + shareBtn.frame.size.height + 20, Device_Width, 44*2);
            }else{
                if (num < 0) {
                    _tableView.frame = CGRectMake(0, twoLabel.frame.origin.y + twoLabel.frame.size.height + 25, Device_Width, 44*(self.redPaperDetailInfo.usedQuantity+1));
                }else{
                    _tableView.frame = CGRectMake(0, shareBtn.frame.origin.y + shareBtn.frame.size.height + 20, Device_Width, 44*(self.redPaperDetailInfo.usedQuantity+1));
                }
            }
        }
        [_tableView reloadData];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.redPaperDetailInfo.usedList.count > 0 ? self.redPaperDetailInfo.usedList.count : 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"YGRedEnvelpoeDetailCell";
    YGRedEnvelpoeDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    if (self.redPaperDetailInfo.usedList.count == 0) {
        cell.textLabel.text = @"无记录";
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [Utilities R:138 G:138 B:138];
        return cell;
    }
    
    RedPaperSubModel *model = [self.redPaperDetailInfo.usedList objectAtIndex:indexPath.row];
    NSString *date = [Utilities getDateStringFromString:model.createTime WithAllFormatter:@"MM-dd HH:mm"];
    cell.phoneLabel.text = model.phoneNum;
    cell.dateLabel.text = date;
    cell.moneyLabel.text = [NSString stringWithFormat:@"¥%d",model.couponAmount];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (UIView*)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 44)];
    view.backgroundColor = [Utilities R:241 G:240 B:246];
    
    UILabel *leftLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 20, 200, 14)];
    leftLabel.backgroundColor = [UIColor clearColor];
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textColor = [Utilities R:138 G:138 B:138];
    leftLabel.text = @"朋友们的手气";
    [view addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-105, 20, 90, 14)];
    rightLabel.backgroundColor = [UIColor clearColor];
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.textColor = [Utilities R:255 G:109 B:0];
    rightLabel.textAlignment = NSTextAlignmentRight;
    rightLabel.text = [NSString stringWithFormat:@"¥%d",self.redPaperDetailInfo.usedAmount];
    [view addSubview:rightLabel];
    
    return view;
}

- (NSInteger)willExpireDate:(NSString*)expireDate{
    NSInteger dayNum = 0;
    if (expireDate&&expireDate.length>0) {
        NSDate *date = [Utilities getDateFromString:expireDate];
        NSString *currentDate = [Utilities stringwithDate:[NSDate date]];
        NSDate *cDate = [Utilities getDateFromString:currentDate];
        dayNum = [Utilities numDayWithBeginDate:cDate endDate:date];
    }
    return dayNum;
}

- (IBAction)shareAction:(id)sender{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    if (!share) {
        share = [[SharePackage alloc] initWithTitle:self.redPaperDetailInfo.shareTitle content:self.redPaperDetailInfo.shareContent img:[UIImage imageNamed:@"award.png"] url:self.redPaperDetailInfo.shareUrl];
    }
    [share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}

@end
