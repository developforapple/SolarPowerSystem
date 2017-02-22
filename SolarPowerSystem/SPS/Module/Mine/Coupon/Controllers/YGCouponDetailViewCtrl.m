//
//  YGCouponDetailViewCtrl.m
//  Golf
//
//  Created by 廖瀚卿 on 15/4/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "YGCouponDetailViewCtrl.h"
#import "VoucherDetailTableViewCell.h"
#import "YGMallCommodityCell.h"
#import "YG_MallCommodityViewCtrl.h"
#import "ClubMainViewController.h"
#import "VoucherMoreTableViewCell.h"
#import "CoachTableViewCell.h"
#import "CoachDetailsViewController.h"
#import "VoucherCourseTableViewCell.h"
#import "ChooseCoachListController.h"
#import "WXApi.h"
#import "ClubChoseCell.h"
#import "Share.h"

@interface YGCouponDetailViewCtrl ()<UITableViewDataSource,UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (strong,nonatomic) NSMutableArray *datas;
@end

@implementation YGCouponDetailViewCtrl

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        return 246;
    }
    switch (_couponModel.subType) {
        case 2:
        case 3:
        case 4:
            return (_datas.count == indexPath.row) ? 44:107;
            break;
        case 5:
            return 85;
            break;
        case 6:
            return 70;
            break;
        case 7:
            return 93;
            break;
        case 8:
            return 70;
            break;
        default:
            break;
    }
    return 0;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (indexPath.row == 0) {
        return;
    }
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    
    if ([cell isKindOfClass:[CoachTableViewCell class]]) {
        [self pushWithStoryboard:@"Teach" title:@"教练详情" identifier:@"CoachDetailsViewController" completion:^(BaseNavController *controller) {
            CoachDetailsViewController *vc = (CoachDetailsViewController *)controller;
            TeachingCoachModel *m = _datas[indexPath.row];
            vc.coachId = m.coachId;
        }];
    }
    
    if ([cell isKindOfClass:[VoucherCourseTableViewCell class]]) {
        TeachProductDetail *tpd = _datas[indexPath.row];
        if (tpd.productId > 0) {
            [self pushWithStoryboard:@"Jiaoxue" title:@"选择教练" identifier:@"ChooseCoachListController" completion:^(BaseNavController *controller) {
                ChooseCoachListController *vc = (ChooseCoachListController*)controller;
                vc.productId = tpd.productId;
                vc.cityId = [GolfAppDelegate shareAppDelegate].searchCityModel.cityId;
            }];
        }
    }
    
    if ([cell isKindOfClass:[VoucherMoreTableViewCell class]]) {
        [[GolfAppDelegate shareAppDelegate] pushToCommodityWithType:_couponModel.subType dataId:[_couponModel.limitIds intValue] extro:_couponModel.couponName controller:self];
        return;
    }
    
    if ([cell isKindOfClass:[YGMallCommodityCell class]]) {
        CommodityInfoModel *model = [_datas objectAtIndex:indexPath.row];
        YG_MallCommodityViewCtrl *vc = [YG_MallCommodityViewCtrl instanceFromStoryboard];
//        vc.commodityId = (int)model.commodityId;
//        vc.auctionId = model.auctionId;
        vc.cid = model.commodityId;
        [self.navigationController pushViewController:vc animated:YES];
        return;
    }
    
    if ([cell isKindOfClass:[ClubChoseCell class]]) {
        ClubModel *model = [_datas objectAtIndex:indexPath.row];
        ConditionModel *nextCondition = [[ConditionModel alloc] init];

        if([LoginManager sharedManager].currLatitude != 0) {
            nextCondition.latitude = [LoginManager sharedManager].currLatitude;
            nextCondition.longitude = [LoginManager sharedManager].currLongitude;
        }
        
        nextCondition.clubId = model.clubId;
        nextCondition.clubName = model.clubName;
        nextCondition.address = model.address;
        nextCondition.price = model.minPrice;
        nextCondition.payType = model.payType;
        nextCondition.range = @"150";
        nextCondition.time = @"07:30";
        nextCondition.date = [Utilities stringwithDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:1]];
        
        [self pushWithStoryboard:@"BookTeetime" title:@"" identifier:@"ClubMainViewController" completion:^(BaseNavController *controller) {
            ClubMainViewController *vc = (ClubMainViewController*)controller;
            vc.cm = nextCondition;
            vc.agentId = -1;
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    NSInteger count = _datas.count;
    
    switch (_couponModel.subType) {
        case 2:
        case 3:
            if (count > 1) {
                return count+1;
            }
            break;
        default:
            break;
    }
    
    return count;
}

//获取球场的cell
- (ClubChoseCell *)getCellClubChoseTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identifierClub = @"ClubChoseCell";
    ClubChoseCell *cell = (ClubChoseCell *)[tableView dequeueReusableCellWithIdentifier:identifierClub];
    if(!cell){
        cell = [[ClubChoseCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifierClub];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
    }
    
    cell.headImg.hidden = NO;
    cell.vipTag.hidden = YES;
    cell.officialFlag.hidden = YES;
    cell.specialLabel.hidden = YES;
    cell.alockIconImg.hidden = YES;
    cell.clubSpecialOff.hidden = YES;
    
    if([indexPath row] == [_datas count]) {
        cell.lblClubName.text = @"";
        cell.lblLeastDistance.text = @"";
        cell.officialFlag.hidden = YES;
        cell.lblPrice.text = @"";
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.headImg.hidden = YES;
        return cell;
    }
    
    ClubModel *model = [_datas objectAtIndex:[indexPath row]];
    
    [cell.headImg sd_setImageWithURL:[NSURL URLWithString:model.clubImage] placeholderImage:self.defaultImage];
    
    cell.lblClubName.text = [NSString stringWithFormat:@"%@",model.clubName];
    cell.clubKindLabel.text = [NSString stringWithFormat:@"%@ %d洞",model.courseKind,model.clubHoleNum];
    if (model.giveYunbi>0) {
        cell.yunbiLabel.text = [NSString stringWithFormat:@"返%d",model.giveYunbi];
    }else{
        cell.yunbiLabel.text = @"";
    }
    
    cell.lblLeastDistance.text = [NSString stringWithFormat:@"%@km %@",model.remote,model.shortAddress.length>0?model.shortAddress:@""];
    
    CGRect rt;
    CGSize size = [Utilities getSize:cell.clubKindLabel.text withFont:cell.clubKindLabel.font withWidth:cell.clubKindLabel.width];
    
    if (model.isOfficial == 1) {
        cell.officialFlag.hidden = NO;
        rt = cell.officialFlag.frame;
        rt.origin.x = cell.clubKindLabel.frame.origin.x + size.width + 5;
        cell.officialFlag.frame = rt;
    }
    if (model.payType == PayTypeVip) {
        cell.vipTag.hidden = NO;
        rt = cell.vipTag.frame;
        rt.origin.x = model.isOfficial == 1 ? cell.officialFlag.frame.origin.x + cell.officialFlag.frame.size.width + 5 : cell.clubKindLabel.frame.origin.x + size.width + 5;
        cell.vipTag.frame = rt;
    }
    
    if (model.timeMinPrice >= 0&&model.startTime.length>0&&model.endTime.length>0) {
        BOOL isSpecialPrice = NO;//[Utilities compareTimeWithCurrentTime:_myCondition.time beginTime:model.startTime endTime:model.endTime];
        
        if (isSpecialPrice) {
            cell.alockIconImg.hidden = YES;
            cell.specialLabel.hidden = YES;
            cell.clubSpecialOff.hidden = NO;
        }else{
            cell.specialLabel.hidden = NO;
            cell.alockIconImg.hidden = NO;
            cell.clubSpecialOff.hidden = YES;
            cell.specialLabel.text = [NSString stringWithFormat:@"¥%d",model.timeMinPrice];
        }
    }
    
    if (!cell.clubSpecialOff.hidden) {
        rt = cell.clubSpecialOff.frame;
        rt.origin.x = cell.clubKindLabel.frame.origin.x + size.width + 5;
        if (model.isOfficial==1) {
            rt.origin.x += 14 + 5;
        }
        if (!cell.vipTag.hidden) {
            rt.origin.x += 14 + 5;
        }
        cell.clubSpecialOff.frame = rt;
    }
    
    if (model.giveYunbi > 0 || model.closure == 1) { // 返云币或电话预定
        CGRect f = cell.lblPrice.frame;
        f.origin.y = 27;
        cell.lblPrice.frame = f;
    }else{
        CGRect f = cell.lblPrice.frame;
        f.origin.y = 34;
        cell.lblPrice.frame = f;
    }
    
    if (model.closure == 0) {
        cell.phoneBookImg.hidden = YES;
        NSString *price = [NSString stringWithFormat:@"￥%d",model.minPrice];
        if (Device_SysVersion<6.0)
            cell.lblPrice.text = price;
        else
            cell.lblPrice.attributedText = [Utilities attributedStringWithString:price value1:[UIFont systemFontOfSize:10] range1:NSMakeRange(0, 1) value2:[UIFont systemFontOfSize:19] range2:NSMakeRange(1, price.length-1) font:0 otherValue:nil otherRange:NSMakeRange(0, 0)];
    }else if (model.closure == 1){
        cell.phoneBookImg.hidden = NO;
        cell.yunbiLabel.text = @"";
    }else{
        cell.phoneBookImg.hidden = YES;
        cell.yunbiLabel.text = @"";
        CGRect rt = cell.lblPrice.frame;
        rt.size.height = 16;
        rt.origin.y = 35;
        cell.lblPrice.frame = rt;
        cell.lblPrice.font = [UIFont systemFontOfSize:16];
        cell.lblPrice.text = @"已封场";
    }
    
    cell.btnImage.tag = [indexPath row];
    cell.btnClubName.tag = [indexPath row];
    return cell;
}

//获取顶部券详情的cell
- (VoucherDetailTableViewCell *)getCellVoucherDetailTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"VoucherDetailTableViewCell";
    VoucherDetailTableViewCell *cell = (VoucherDetailTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    [cell setCouponModel:_couponModel hideLine:(_datas.count > 1 ? NO:YES)];
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
    }
    return cell;
}

//获取商品cell
- (YGMallCommodityCell *)getCellCommodityTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identifierGoods = @"YGMallCommodityCell";
    YGMallCommodityCell *cell = [tableView dequeueReusableCellWithIdentifier:identifierGoods];
    if (cell == nil) {
        cell = [[[NSBundle mainBundle] loadNibNamed:identifierGoods owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleGray;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    
    cell.textLabel.text = @"";
    cell.hengxianImgView.hidden = NO;
    cell.photoImageView.hidden = NO;
    
    CommodityInfoModel *model = [_datas objectAtIndex:indexPath.row];
    [cell.photoImageView sd_setImageWithURL:[NSURL URLWithString:model.photoImage] placeholderImage:self.defaultImage];
    cell.commodityNameLabel.text = model.commodityName;
    cell.sellingPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.sellingPrice];
    cell.originalPriceLabel.text = [NSString stringWithFormat:@"¥ %d",model.originalPrice];
    cell.soldQuantityLabel.text = [NSString stringWithFormat:@"已售%d件",model.soldQuantity];
    cell.yunbiLabel.text = [NSString stringWithFormat:@"返%d",model.yunbi];
    
    float rebate = ((float)model.sellingPrice/MAX(model.originalPrice, 1)) * 10;
    cell.rebateLabel.text = [NSString stringWithFormat:@"%.01f折",rebate];
    
    if (model.auctionTime.length>0) {
        cell.ruhsingImageView.hidden = NO;
        NSDate *auctionDate = [Utilities getDateFromString:model.auctionTime WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
        NSComparisonResult result = [[NSDate date] compare:auctionDate];
        if (result == NSOrderedAscending) {
            cell.ruhsingImageView.image = [UIImage imageNamed:@"will_rushing.png"];
        }else {
            cell.ruhsingImageView.image = [UIImage imageNamed:@"rushing.png"];
        }
    }else{
        cell.ruhsingImageView.hidden = YES;
    }
    
    if (model.soldQuantity == model.stockQuantity) {
        cell.soldOverLabel.hidden = NO;
        cell.sellingPriceLabel.textColor = [Utilities R:191 G:191 B:191];
    }else{
        cell.soldOverLabel.hidden = YES;
        cell.sellingPriceLabel.textColor = [Utilities R:255 G:109 B:0];
    }
    
    if (cell.soldOverLabel.hidden == YES) {
        cell.yunbiLabel.hidden = model.yunbi>0 ? NO : YES;
        if (model.freight<0) {
            cell.freightLabel.hidden = YES;
        }else if (model.freight==0){
            cell.freightLabel.hidden = NO;
            cell.freightLabel.text = @"免运费";
        }else{
            cell.freightLabel.hidden = NO;
            cell.freightLabel.text = [NSString stringWithFormat:@"运费%d元",model.freight];
        }
    }else{
        cell.freightLabel.hidden = YES;
        cell.yunbiLabel.hidden = YES;
    }
    
    [cell handleCellData];
    return cell;
}

-(UITableViewCell *)getCellProductInfoTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    static NSString *identifierProduct = @"VoucherCourseTableViewCell";
    VoucherCourseTableViewCell *cell = (VoucherCourseTableViewCell *)[tableView dequeueReusableCellWithIdentifier:identifierProduct forIndexPath:indexPath];
    TeachProductDetail *m = [_datas objectAtIndex:indexPath.row];
    cell.labelCourseName.text = m.productName;
    cell.labelPrice.text = [NSString stringWithFormat:@"%d",m.sellingPrice];
    cell.labelOldPrice.text = [NSString stringWithFormat:@"%d",m.originalPrice];
    if (_datas.count - 1 == indexPath.row) {
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        }
    }else{
        if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
            cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
        }
    }
    return cell;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0) {
        return [self getCellVoucherDetailTableView:tableView indexPath:indexPath];
    }
    
    switch (_couponModel.subType) {
        case 2:
        case 3:
        case 4:
            if (_datas.count > 1 && _datas.count == indexPath.row) {
                static NSString *identifier = @"VoucherMoreTableViewCell";
                VoucherMoreTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
                if (cell == nil) {
                    cell = [[VoucherMoreTableViewCell alloc] initWithStyle:(UITableViewCellStyleDefault) reuseIdentifier:identifier];
                }
                return cell;
                break;
            }
            return [self getCellCommodityTableView:tableView indexPath:indexPath];
            break;
        case 5:
            return [self getCellClubChoseTableView:tableView indexPath:indexPath];
            break;
        case 6:
            return [self getCellProductInfoTableView:tableView indexPath:indexPath];
            break;
        case 7:
        {
            TeachingCoachModel *tcm = _datas[indexPath.row];
            CoachTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CoachTableViewCell" forIndexPath:indexPath];
            if (_datas.count - 1 == indexPath.row) {
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }
            }else{
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
                }
            }
            [cell loadData:tcm];
            return cell;

        }
            break;
        case 8:
            return [self getCellProductInfoTableView:tableView indexPath:indexPath];
            break;
        default:
            break;
    }
    
    return nil;
}


#pragma mark - 数据获取

- (void)getClubs{
    ConditionModel *cm = [[ConditionModel alloc] init];
    cm.longitude = [LoginManager sharedManager].currLongitude;
    cm.latitude = [LoginManager sharedManager].currLatitude;
    cm.date = [Utilities stringwithDate:[Utilities getTheDay:[NSDate date] withNumberOfDays:1]];
    cm.clubIds = _couponModel.limitIds;
    
    [[ServiceManager serviceManagerWithDelegate:self] searchClubWithCondition:cm withPage:0 withPageSize:0 withVersion:@"3.0"];
}

- (IBAction)share:(id)sender {
    NSString *hexString = [NSString stringWithFormat:@"%@",[[NSString alloc] initWithFormat:@"%1x",_couponModel.couponId]];
    
    NSString *md5Str = [[NSString stringWithFormat:@"%d%@",_couponModel.couponId,API_KEY] md5String];
    NSInteger toIndex = MIN(md5Str.length, 16);
    md5Str =  [md5Str substringToIndex:toIndex];
    
    NSString *data = [md5Str stringByAppendingString:hexString];
    NSString *title = [NSString stringWithFormat:@"送你一张%d元的%@，赶快领取吧！",_couponModel.couponAmount,_couponModel.couponName];
    NSString *content = _couponModel.subType == 1 ? @"预订球场、购买球具、购买课程，统统都能用。":_couponModel.couponDescription;
    NSString *url =[NSString stringWithFormat:@"%@common/getCoupon.jsp?data=%@",URL_SHARE,data];
    UIImage *img = [UIImage imageNamed:@"daijinquan"];
    Share *share = [[Share alloc] initWithTitle:title content:content image:img url:url scene:WXSceneSession];
    [share sendMsgToWX];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = [NSArray arrayWithArray:data];
    if (arr.count > 0) {
        [_datas addObjectsFromArray:arr];
    }
    
    [_tableView reloadData];
}

#pragma mark - UI相关

-(void)back{
    if (_isModal) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:YES];
    }
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _tableView.contentInset = UIEdgeInsetsMake(0, 0, 44, 0);
    
    if (_couponModel.canSend == YES && [WXApi isWXAppInstalled] == YES) {
        _toolbar.hidden = NO;
    }else{
        _toolbar.hidden = YES;
    }
    
    _datas = [[NSMutableArray alloc] initWithArray:@[@""]];
    
    int longitude = [LoginManager sharedManager].currLongitude;
    int latitude = [LoginManager sharedManager].currLatitude;
    switch (_couponModel.subType) {
        case 1:
            break;
        case 2:
            [[ServiceManager serviceManagerWithDelegate:self] getCommodityInfoList:_couponModel.limitIds
                                                                           brandId:nil
                                                                      commodityIds:nil longitude:longitude latitude:latitude];
            break;
        case 3:
            [[ServiceManager serviceManagerWithDelegate:self] getCommodityInfoList:nil
                                                                           brandId:_couponModel.limitIds
                                                                      commodityIds:nil longitude:longitude latitude:latitude];
            break;
        case 4:
            [[ServiceManager serviceManagerWithDelegate:self] getCommodityInfoList:nil
                                                                           brandId:nil
                                                                      commodityIds:_couponModel.limitIds longitude:longitude latitude:latitude];
            break;
        case 5:
            [self getClubs];
            break;
        case 6:
            [[ServiceManager serviceManagerWithDelegate:self] teachingProductInfoByIds:_couponModel.limitIds classType:nil];
            break;
        case 7:
        {
            NSArray *ids = [_couponModel.limitIds componentsSeparatedByString:@","];
            
            [[ServiceManager serviceManagerWithDelegate:self] getCoachListByPageNo:1
                                                                          pageSize:100
                                                                     withLongitude:[LoginManager sharedManager].currLongitude
                                                                          latitude:[LoginManager sharedManager].currLatitude
                                                                            cityId:0
                                                                           orderBy:0
                                                                              date:nil
                                                                              time:nil
                                                                           keyword:nil
                                                                         academyId:[[ids firstObject] intValue] productId:0];
        }
            break;
        case 8:
            [[ServiceManager serviceManagerWithDelegate:self] teachingProductInfoByIds:nil classType:_couponModel.limitIds];
            break;
        default:
            break;
    }
}

@end
