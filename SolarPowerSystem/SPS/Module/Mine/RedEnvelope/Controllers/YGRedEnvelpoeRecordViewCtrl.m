//
//  YGRedEnvelpoeRecordViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-8-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGRedEnvelpoeRecordViewCtrl.h"
#import "UIButton+Custom.h"
#import "YGRedEnvelpoeDetailViewCtrl.h"
#import "YGRefreshComponent.h"

@interface YGRedEnvelpoeRecordViewCtrl ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    
    BOOL isLoad;
    int pageNo;
    int pageSize;
}

@property (nonatomic,strong) NSMutableArray *redPaperList;

@end

@implementation YGRedEnvelpoeRecordViewCtrl

@synthesize redPaperList;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    pageNo = 0;
    pageSize = 20;
    self.redPaperList = [NSMutableArray array];
    
    _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height) style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    [_tableView setRefreshHeaderEnable:YES];
    ygweakify(self);
    [_tableView setRefreshCallback:^(YGRefreshType type) {
        ygstrongify(self);
        [self getRedPaperListFromServer];
    }];
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
    
    [self getRedPaperListFromServer];
}

- (void)getRedPaperListFromServer{
    pageNo ++;
    [[ServiceManager serviceManagerWithDelegate:self] getRedPackeList:[[LoginManager sharedManager] getSessionId] type:0 pageNo:pageNo pageSize:pageSize];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array && array.count > 0) {
        isLoad = YES;
        NSDictionary *dic = [array objectAtIndex:0];
        if ([dic objectForKey:@"redpacket_list"]) {
            NSArray *aa = [dic objectForKey:@"redpacket_list"];
            if (aa&&aa.count>0) {
                if (pageNo == 1) {
                    [self.redPaperList removeAllObjects];
                }
                for (id obj in aa) {
                    RedPaperModel *model = [[RedPaperModel alloc] initWithDic:obj];
                    [self.redPaperList addObject:model];
                }
                [_tableView.mj_header endRefreshing];
            }else{
                [_tableView.mj_header endRefreshing];
            }
        }
        [_tableView reloadData];
    }
}

#pragma mark - Scroll
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return MAX(self.redPaperList.count, 1);
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.redPaperList.count == 0) {
        UITableViewCell *noCell = [[UITableViewCell alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 60)];
        noCell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        noCell.textLabel.textColor = [Utilities R:138 G:138 B:138];
        noCell.textLabel.text = isLoad == YES ? @"暂无红包记录" : @"";
        noCell.textLabel.textAlignment = NSTextAlignmentCenter;
        return noCell;
    }
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
        cell.textLabel.font = [UIFont systemFontOfSize:16];
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
        cell.detailTextLabel.textColor = [Utilities R:138 G:138 B:138];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    RedPaperModel *model = [self.redPaperList objectAtIndex:indexPath.row];
    NSString *date = [Utilities getDateStringFromString:model.beginDate WithFormatter:@"MM月dd日"];
    cell.textLabel.text = [NSString stringWithFormat:@"%@消费奖励的红包",date];
    if (model.totalQuantity == model.usedQuantity) {
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%d个红包全部领完",model.usedQuantity];
    }else{
        NSInteger num = [self willExpireDate:model.expireDate];
        NSString *getStatus = nil;
        if (num < 0) {
            getStatus = @"已过期";
        }else if (num == 0){
            getStatus = @"今天过期";
        }else{
            getStatus = [NSString stringWithFormat:@"%d天后过期",(int)num];
        }
        cell.detailTextLabel.text = [NSString stringWithFormat:@"已领%d个/%d个  %@",model.usedQuantity,model.totalQuantity,getStatus];
        
        if (num >= 0) {
            UIButton *button = [UIButton myButton:self Frame:CGRectMake(Device_Width-73, 15, 50, 30) NormalImage:nil SelectImage:nil Title:@"发红包" TitleColor:[Utilities R:6 G:156 B:216] Font:14 Action:@selector(redPaperDetail:)];
            button.tag = indexPath.row + 1;
            [cell.contentView addSubview:button];
        }
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    if (self.redPaperList.count == 0) {
        return;
    }
    RedPaperModel *model = [self.redPaperList objectAtIndex:indexPath.row];
    YGRedEnvelpoeDetailViewCtrl *redPaperDetail = [[YGRedEnvelpoeDetailViewCtrl alloc] init];
    redPaperDetail.redPaperId = model.redPacketId;
    [self pushViewController:redPaperDetail title:@"红包详情" hide:YES];
}

- (void)redPaperDetail:(UIButton*)button{
    NSInteger index = button.tag-1;
    RedPaperModel *model = [self.redPaperList objectAtIndex:index];
    YGRedEnvelpoeDetailViewCtrl *redPaperDetail = [[YGRedEnvelpoeDetailViewCtrl alloc] init];
    redPaperDetail.redPaperId = model.redPacketId;
    [self pushViewController:redPaperDetail title:@"红包详情" hide:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.redPaperList.count == 0) {
        return 120;
    }
    return 60;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
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

@end
