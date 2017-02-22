//
//  SpecialOfferListViewController.m
//  Golf
//
//  Created by user on 13-1-10.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import "SpecialOfferListViewController.h"
#import "ClubMainViewController.h"
#import "SimpleCityModel.h"
#import "SpecialOfferTableViewCell.h"

@interface SpecialOfferListViewController ()

@end

@implementation SpecialOfferListViewController


-(void)setExtraCellLineHidden: (UITableView *)tableView
{
    UIView *view = [UIView new];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}

- (void)weekChooseViewDelegateWithIndex:(NSInteger)index{
    _weekDay = index;
    _myCondition.weekDay = [@(_weekDay) intValue];
    [self performSelector:@selector(getSpecialOfferList) withObject:nil afterDelay:0.05];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.clipsToBounds = YES;
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.separatorColor = [UIColor colorWithHexString:@"eeeeee"];
    _tableView.contentInset = UIEdgeInsetsMake(60.f, 0, 0, 0);
    [self.view addSubview:_tableView];
    [self setExtraCellLineHidden:_tableView];
    _tableView.hidden = YES;
    
    _weekChooseView = [[[NSBundle mainBundle] loadNibNamed:@"WeekChooseView" owner:self options:nil] lastObject];
    _weekChooseView.delegate = self;
    [_weekChooseView setFrame:CGRectMake(0, 63, Device_Width, 60)];
    [self.view addSubview:_weekChooseView];
    
    CGFloat x = Device_Width/2 - 200/2;
    
    _noneLabel = [[UILabel alloc] initWithFrame:CGRectMake(x, 110 + 64.f, Device_Width-2*x, 60)];
    _noneLabel.backgroundColor = [UIColor clearColor];
    _noneLabel.font = [UIFont systemFontOfSize:14];
    _noneLabel.textColor = [Utilities R:72 G:71 B:71];
    _noneLabel.text = @"暂未搜索到特价的teetime，请更换城市或日期重新搜索";
    _noneLabel.textAlignment = NSTextAlignmentCenter;
    _noneLabel.hidden = YES;
    _noneLabel.numberOfLines = 0;
    [self.view addSubview:_noneLabel];
    
    
    _myCondition = [[ConditionModel alloc] init];
    
    _refreshing = NO;
    _isSpecialOffer = YES;
    
    lastTime = [NSDate timeIntervalSinceReferenceDate];
    
    _myCondition.cityId = 0;
    _myCondition.provinceId = 0;
    _myCondition.cityName = @"当前位置";
    
    if([LoginManager sharedManager].currLatitude != 0) {
        _myCondition.longitude = [LoginManager sharedManager].currLongitude;
        _myCondition.latitude = [LoginManager sharedManager].currLatitude;
        [self getSpecialOfferList];
    }     
    _myCondition.date = [Utilities stringwithDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:1]];
    
    _weekDay = [Utilities weekDayByDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:1]];
    _myCondition.weekDay = [@(_weekDay) intValue];
    [_weekChooseView setWeekWithIndex:_weekDay];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [self rightButtonAction:_myCondition.cityName];
}

- (void)getSpecialOfferList{
    _tableView.hidden = YES;
    [[ServiceManager serviceManagerWithDelegate:self] getSpecialOfferList:_myCondition.cityId provinceId:_myCondition.provinceId longitude:[LoginManager sharedManager].currLongitude latitude:[LoginManager sharedManager].currLatitude weekDay:_weekDay];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    _specialOfferList = [[NSArray alloc] initWithArray:data];
    
    if (_specialOfferList.count <= 0){
        _noneLabel.hidden = NO;
    }else{
        _noneLabel.hidden = YES;
    }

    _tableView.hidden = NO;
    [_tableView reloadData];
}

- (void)doRightNavAction{
    [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"SelectedCitysController" completion:^(BaseNavController *controller) {
        SelectedCitysController *vc = (SelectedCitysController*)controller;
        vc.cm = _myCondition;
        vc.chooseBlock = ^(id data){
            SimpleCityModel *cityModel = (SimpleCityModel *)data;
            _myCondition.cityId = cityModel.cityId;
            _myCondition.provinceId = cityModel.provinceId;
            _myCondition.cityName = cityModel.name;
            
            [self performSelector:@selector(getSpecialOfferList) withObject:nil afterDelay:0.05];
        };
    }];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [_specialOfferList count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"SpecialOfferCell";
    SpecialOfferTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"SpecialOfferTableViewCell" owner:self options:nil] lastObject];
    }
    
    if (indexPath.row+1 > [_specialOfferList count]) return cell;
    
    SpecialOfferModel *model = [_specialOfferList objectAtIndex:indexPath.row];
    
    cell.clubNameLabel.text = model.shortName;
    cell.originalPriceLabel.text = [NSString stringWithFormat:@"原价￥%d",model.originalPrice];
    CGSize sz = [[NSString stringWithFormat:@"原价￥%d",model.originalPrice] boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, 14) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11]} context:nil].size;
    cell.imgLineWidth.constant = sz.width + 6;
    cell.currentPriceLabel.text = [NSString stringWithFormat:@"￥%d",model.currentPrice];
    
    CGRect rt;
    if ([model.beginTime isEqualToString:@""] || [model.endTime isEqualToString:@""]) {
        cell.timeAreaLabel.text = @"全天特惠";
        rt = cell.timeAreaLabel.frame;
        cell.timeAreaLabel.frame = rt;
    }else{
        cell.timeAreaLabel.text = [NSString stringWithFormat:@"%@~%@",model.beginTime,model.endTime];
        rt = cell.timeAreaLabel.frame;
        cell.timeAreaLabel.frame = rt;
    }
    
    if (model.currentPrice <= 0) {
        cell.currentPriceLabel.hidden = YES;
    }
    else{
        cell.currentPriceLabel.hidden = NO;
    }
    
    CGSize size = [Utilities getSize:[NSString stringWithFormat:@"￥%d",model.originalPrice] withFont:[UIFont systemFontOfSize:13] withWidth:Device_Width];
    rt = cell.lineImg.frame;
    rt.size.width = size.width;
    rt.origin.x = 300 - size.width;
    cell.lineImg.frame = rt;
 
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 68;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{

    SpecialOfferModel *model = [_specialOfferList objectAtIndex:indexPath.row];
    _myCondition.clubId = model.clubId;
    _myCondition.clubName = model.clubName;
    _myCondition.weekDay = model.weekDay;
    
    if (model.weekDay > 0) {
        NSDate *endDate = [Utilities getDateFromString:model.endDate];
        NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
        NSInteger currentIndex = [Utilities weekDayByDate:[NSDate date]];
        NSDate *date = nil;
        if([endDate timeIntervalSinceDate:today] == 0) {
            _myCondition.date = [Utilities stringwithDate:endDate];
        }
        else if (model.weekDay == 1) {
            if (currentIndex == 1) {
                date = [Utilities getTheDay:[NSDate date] withNumberOfDays:7];
            }
            else{
                date = [Utilities getTheDay:[NSDate date] withNumberOfDays:(8-currentIndex)];
            }
        }
        else{
            if (model.weekDay > currentIndex) {
                if (currentIndex == 1) {
                    date = [Utilities getTheDay:[NSDate date] withNumberOfDays:(7-model.weekDay)];
                }
                else{
                    date=[Utilities getTheDay:[NSDate date] withNumberOfDays:(model.weekDay-currentIndex)];
                }
            }else{
                date=[Utilities getTheDay:[NSDate date] withNumberOfDays:(model.weekDay-currentIndex+7)];
            }
        }
        _myCondition.date = [Utilities stringwithDate:date];
    }else{
        _myCondition.date = model.beginDate;
    }
    
    if (model.beginTime.length <= 0 || model.endTime.length <= 0) {
        _myCondition.time = @"07:30";
    }
    else{
        _myCondition.time = [self setMidValue:model];
    }
    
    _myCondition.time = [Utilities minTimeWithDate:_myCondition.date time:_myCondition.time];
    
    [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
        ClubMainViewController *vc = (ClubMainViewController*)controller;
        vc.cm = [_myCondition copy];
        vc.agentId = -1;
    }];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (int)setValueLength:(NSString *)value{
    NSArray *array = [value componentsSeparatedByString:@":"];
    int timeInterval = [[array objectAtIndex:0] intValue]*60 + [[array objectAtIndex:1] intValue];
    return timeInterval;
}

- (NSString *)setMidValue:(SpecialOfferModel *)model{
    int timeInterval1 = [self setValueLength:model.beginTime];
    int timeInterval2 = [self setValueLength:model.endTime];
    int timeHour = (timeInterval1 + timeInterval2)/120;
    int timeMin = ((timeInterval1 + timeInterval2) / 2) % 60;
    if (timeMin < 15 || timeMin > 45) {
        timeMin = 0;
        return [NSString stringWithFormat:@"%02d:%02d",timeHour,timeMin];
    }
    else{
        timeMin = 30;
        return [NSString stringWithFormat:@"%02d:%02d",timeHour,timeMin];
    }
    return nil;
}

@end
