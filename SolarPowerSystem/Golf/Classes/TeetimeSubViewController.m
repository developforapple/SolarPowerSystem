//
//  TeetimeSubViewController.m
//  Golf
//
//  Created by 黄希望 on 15/10/29.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TeetimeSubViewController.h"
#import "ChooseTeetimeCell.h"
#import "OnlyOneLineCell.h"
#import "TwoLabelsCell.h"
#import "FillOrderViewController.h"

@interface TeetimeSubViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,weak) IBOutlet UITableView *tableView;
@property (nonatomic,weak) IBOutlet UITableView *tableView_;
@property (nonatomic,weak) IBOutlet UIView *bgScrollView;

@property (nonatomic,weak) IBOutlet UILabel *dateLabel;
@property (nonatomic,weak) IBOutlet UILabel *weekLabel;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UILabel *courseLabel;
@property (nonatomic,weak) IBOutlet UILabel *bookTypeLabel;
@property (nonatomic,weak) IBOutlet UILabel *pricleLabel;
@property (nonatomic,weak) IBOutlet UILabel *yunbiLabel;
@property (nonatomic,weak) IBOutlet UIButton *backBtn;

@property (nonatomic,weak) IBOutlet UILabel *headListLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_left;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_bottom;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_w;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *lc_h;

@end

@implementation TeetimeSubViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor clearColor];
    _tableView.tableFooterView = [[UIView alloc] init];
    
    self.lc_w.constant = Device_Width*2;
    self.lc_h.constant = Device_Height - 160.f;
    self.lc_left.constant = 0.f;
    self.lc_bottom.constant = -self.lc_h.constant;
    
    [self.view layoutIfNeeded];
}

- (void)setViewData{
    _backBtn.enabled = _canBack ? YES : NO;
    if (_canBack) {
        [_backBtn setTitle:_isSpree ? @"  选择开球时间" : @"  选择Teetime" forState:UIControlStateNormal];
        [_backBtn setImage:[UIImage imageNamed:@"ic_back_blue_small"] forState:UIControlStateNormal];
        [_backBtn setTitleColor:[UIColor colorWithHexString:@"249df3"] forState:UIControlStateNormal];
    }else{
        if (_ttm.agentId>0) {
            [_backBtn setTitle:@"预订信息" forState:UIControlStateNormal];
            [_backBtn setImage:nil forState:UIControlStateNormal];
            [_backBtn setTitleColor:[UIColor colorWithHexString:@"999999"] forState:UIControlStateNormal];
        }
    }
    NSString *dateStr = [Utilities getDateStringFromString:_isSpree?_ttm.date : _cm.date WithFormatter:@"MM月dd日"];
    NSString *weekStr = [Utilities getWeekDayByDate:[Utilities getDateFromString:_isSpree?_ttm.date : _cm.date]];
    [_dateLabel setText:dateStr];
    [_weekLabel setText:weekStr];
    [_timeLabel setText:_ttm.teetime];
    [_courseLabel setText:_ttm.courseName.length>0?_ttm.courseName:@""];
    [_bookTypeLabel setText:PayType[_ttm.payType]];
    [_pricleLabel setText:[NSString stringWithFormat:@"%d",_ttm.price]];
    if (_ttm.yunbi>0) {
        [_yunbiLabel setText:[NSString stringWithFormat:@"返%d",_ttm.yunbi]];
    }else{
        [_yunbiLabel setText:@""];
    }
    if (_isSpree) {
        [_headListLabel setText:@"请选择想要预订的时间"];
    }else{
        [_headListLabel setText:[NSString stringWithFormat:@"%@ 附近的Teetime",_cm.time]];
    }
    [_tableView reloadData];
}

- (IBAction)disappear:(id)sender{
    [self showView:NO];
}

- (IBAction)backView:(id)sender{
    [self nextPage:NO animate:YES];
}

- (void)showView:(BOOL)show{
    if (show) {
        [self setViewData];
    }
    
    [UIView animateWithDuration:0.4 animations:^{
        self.lc_bottom.constant = show?0.f:-self.lc_h.constant;
        [self.view layoutIfNeeded];
    } completion:^(BOOL finished) {
        if (!show) {
            [self nextPage:NO animate:NO];
            if (_blockclick) {
                _blockclick (nil);
            }
        }
    }];
}

- (void)showView:(BOOL)show index:(NSInteger)index{
    [self nextPage:index animate:NO];
    [self showView:show];
}

- (void)nextPage:(BOOL)next animate:(BOOL)animate{
    
    self.lc_left.constant = next?-Device_Width:0.f;
    
    if (next) {
        [_tableView_ reloadData];
    }
    if (animate) {
        [UIView animateWithDuration:.5 delay:0 usingSpringWithDamping:1.8 initialSpringVelocity:1.8 options:(UIViewAnimationOptionCurveEaseInOut) animations:^{
            [self.view layoutIfNeeded];
        } completion:nil];
    }else{
        [_bgScrollView.superview layoutIfNeeded];
    }
}

#pragma mark - UITableView 相关
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if ([tableView isEqual:_tableView]) {
        return [_teetimes count];
    }else{
        return 6;
    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_tableView]) {
        NSString *identifier = _isSpree ? @"ChooseTeetimeCell_spree" : @"ChooseTeetimeCell";
        ChooseTeetimeCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.isSpree = _isSpree;
        cell.ttm = _teetimes[indexPath.row];
        __weak typeof(self) ws = self;
        cell.bookBlock = ^(id data){
            _ttm = (TTModel*)data;
            if (_ttm.payType == PayTypeVip && !_isVip) {
                [[GolfAppDelegate shareAppDelegate] alert:nil message:@"该球场为会员球场，非会员不可预定"];
                return;
            }
            [self setViewData];
            [ws nextPage:YES animate:YES];
        };
        return cell;
    }else{
        NSString *identifier = nil;
        NSString *oneTitle = @"";
        NSString *otherTitle = @"";
        switch (indexPath.row) {
            case 0:
                identifier = @"TwoLabelsCell_price";
                oneTitle = @"价格包含";
                otherTitle = _ttm.priceContent;
                break;
            case 1:
                identifier = @"TwoLabelsCell_note";
                oneTitle = @"预定说明";
                otherTitle = _ttm.description.length+_ttm.bookNote.length>0?[NSString stringWithFormat:@"%@%@",_ttm.description,_ttm.bookNote]:@"暂无预定说明";
                break;
            case 2:
                identifier = (_ttm.yunbi>0 || _ttm.agentId==0)? @"TwoLabelsCell_cancel_line" : @"TwoLabelsCell_cancel";
                oneTitle = @"取消须知";
                otherTitle = _ttm.cancelNote.length>0?_ttm.cancelNote:@"暂无取消说明";
                break;
            case 3:
                identifier = @"TwoLabelsCell_yunbi";
                oneTitle = _ttm.yunbi>0?[NSString stringWithFormat:@" 返%d ",_ttm.yunbi]:@"";
                otherTitle = _ttm.yunbi>0?[NSString stringWithFormat:@"打球后返%d云币，1云币价值1元现金",_ttm.yunbi]:@"";
                break;
            case 4:
                identifier = @"TwoLabelsCell_justnow";
                oneTitle = @" 实时 ";
                otherTitle = @"球会官方实时返回的空闲球位，无需等待人工确认，一步完成预定";
                break;
            case 5: // 空单元格，用于流出与底部的间距
                identifier = @"TwoLabelsCell_price";
                oneTitle = @"";
                otherTitle = @"";
                break;
            default:
                break;
        }
        TwoLabelsCell * cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        cell.oneLabel.text = oneTitle;
        cell.otherLabel.text = otherTitle;
        if (indexPath.row > 2) {
            [Utilities drawView:cell.oneLabel radius:2 bordLineWidth:0.5 borderColor:[UIColor colorWithHexString:@"ff6d00"]];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([tableView isEqual:_tableView]) {
        return 44;
    }else{
        CGFloat height = 0;
        switch (indexPath.row) {
            case 0:
                height = 37;
                break;
            case 1:
                height = [Utilities getSize:_ttm.description.length+_ttm.bookNote.length>0?[NSString stringWithFormat:@"%@%@",_ttm.description,_ttm.bookNote]:@"暂无预定说明" withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-97].height+12;
                break;
            case 2:
                height = [Utilities getSize:_ttm.cancelNote.length>0?_ttm.cancelNote:@"暂无取消说明" withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-97].height+19;
                break;
            case 3:
                height = _ttm.yunbi>0?30:0;
                break;
            case 4:
                if (_ttm.agentId>0) {
                    height = 0;
                }else{
                    if (_ttm.yunbi>0) {
                        height = [Utilities getSize:@"球会官方实时返回的空闲球位，无需等待人工确认，一步完成预定" withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-97].height+18;
                    }else{
                        height = [Utilities getSize:@"球会官方实时返回的空闲球位，无需等待人工确认，一步完成预定" withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-97].height+28;
                    }
                }
                break;
            case 5:
                height = 15;
                break;
            default:
                break;
        }
        return height;
    }
}

- (IBAction)closeAction:(id)sender{
    [self showView:NO];
}

- (IBAction)confirmBookAction:(id)sender{
    if (_ttm.payType == PayTypeVip && !_isVip) {
        [[GolfAppDelegate shareAppDelegate] alert:nil message:@"该球场为会员球场，非会员不可预定"];
        return;
    }
    
    if (self.ttm.canBook == 0) {
        NSString *msg = [NSString stringWithFormat:@"%@%@",_ttm.description,_ttm.bookNote];
        if (msg.length==0) {
            msg = @"当前Teetime不可订";
        }
        [[GolfAppDelegate shareAppDelegate] alert:@"温馨提示" message:msg];
        return;
    }
    
    if (self.ttm.minBuyQuantity>0&&self.ttm.minBuyQuantity>self.ttm.mans) {
        [[GolfAppDelegate shareAppDelegate] alert:@"温馨提示" message:@"起订人数超过剩余可订人数"];
        return;
    }
    
    if (_isSpree == NO) {
        self.ttm.date = _cm.date;
    }
    
    _cm.people = MAX(1, self.ttm.minBuyQuantity);
    _cm.payType = _ttm.payType;
    
    FillOrderViewController *fillOrder = [[FillOrderViewController alloc] initWithNibName:@"FillOrderViewController" bundle:nil];
    fillOrder.myCondition = [_cm copy];
    fillOrder.ttmodel = self.ttm;
    fillOrder.isVip = _isVip;
    fillOrder.isSpree = _isSpree;
    [[GolfAppDelegate shareAppDelegate].currentController pushViewController:fillOrder title:@"填写订单" hide:YES];
    
    [self showView:NO];
}


@end
