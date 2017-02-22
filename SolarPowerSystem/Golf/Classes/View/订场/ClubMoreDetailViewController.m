//
//  ClubMoreDetailViewController.m
//  Golf
//
//  Created by user on 13-5-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "ClubMoreDetailViewController.h"
//#import "UILabel+Hxw.h"
#import <QuartzCore/QuartzCore.h>
#import "ClubFairwayModel.h"
#import "UIImageView+WebCache.h"
#import "ImageBrowser.h"
#import "UIButton+WebCache.h"
#import "YGMapViewCtrl.h"
#import "YGCapabilityHelper.h"

NSString *clubInfoTitleItem[8] = {@"球场模式",@"建立时间",@"球场面积",@"果岭草种",@"球场数据",@"设计师",@"球道长度",@"球道草种"};

@interface ClubMoreDetailViewController ()<UITableViewDelegate,UITableViewDataSource>{
    UITableView *_tableView;
    UIScrollView *_scrollview;
    NSMutableArray *_images;
    NSArray *_pictureInfoList;
    CGFloat ory;
    CGFloat yy;
}

@property (nonatomic,strong) NSMutableArray *dataArray;

@end

@implementation ClubMoreDetailViewController
@synthesize clubId = _clubId;
@synthesize clubInfo = _clubInfo;
@synthesize dataArray = _dataArray;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    YGPostBuriedPoint(YGCoursePointCourseInfo);
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    _scrollview = [[UIScrollView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    _scrollview.showsHorizontalScrollIndicator = NO;
    _scrollview.showsVerticalScrollIndicator = NO;
    [self.view addSubview:_scrollview];
    
    _tableView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.scrollEnabled = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [_scrollview addSubview:_tableView];
    
    [self loadClubInfo];
    [self loadPictureList];
}

- (void)loadClubInfo{
    if (!self.clubInfo) {
        [[ServiceManager serviceManagerWithDelegate:self] getClubInfo:_clubId needPackage:0];
    }else{
        [self setClubItemData:self.clubInfo];
        CGRect rt = _tableView.frame;
        rt.size.height = _tableView.contentSize.height;
        _tableView.frame = rt;
        [_tableView reloadData];
        
        [_scrollview setContentSize:CGSizeMake(Device_Width, _tableView.frame.size.height + 20)];
    }
}

- (void)loadPictureList{
    _images = [[NSMutableArray alloc] init];
    [[ServiceManager serviceManagerWithDelegate:self] getClubFairwayList:_clubId];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *resultArray = (NSArray*)data;
    if (resultArray&&resultArray.count>0) {
        if (Equal(flag, @"club_info")) {
            self.clubInfo = (ClubModel*)[resultArray objectAtIndex:0];
            if (_clubInfo) {
                [self setClubItemData:self.clubInfo];
                [_tableView reloadData];
            }
        }
        if (Equal(flag, @"club_fairway_list")) {
            if (_pictureInfoList) {
                _pictureInfoList = nil;
            }
            _pictureInfoList = [[NSArray alloc] initWithArray:resultArray];
            
            if (_pictureInfoList.count>0) {
                
                [_tableView reloadData];
            }
        }
    }
    CGRect rt = _tableView.frame;
    rt.size.height = _tableView.contentSize.height;
    _tableView.frame = rt;
    [_scrollview setContentSize:CGSizeMake(Device_Width, _tableView.frame.size.height + 20)];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSInteger aSection = 1;
    if (self.clubInfo.address.length>0) {
        aSection ++;
    }
    if (self.clubInfo.phone.length>0) {
        aSection ++;
    }
    if (_pictureInfoList && _pictureInfoList.count>0) {
        aSection ++;
    }
    if (self.clubInfo.introduction.length>0) {
        aSection ++;
    }
    if (self.clubInfo.clubFacility.length>0) {
        aSection ++;
    }
    return aSection;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIndentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIndentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIndentifier];
        cell.backgroundColor = [Utilities R:253 G:253 B:253];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
        cell.textLabel.font = [UIFont systemFontOfSize:14];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.backgroundColor = [UIColor clearColor];
    }
    cell.textLabel.text = @"";
    [cell.contentView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    if (Device_SysVersion<7.0&&indexPath.row == 0) {
        [Utilities lineviewWithFrame:CGRectMake(0, 0, Device_Width, 1) forView:cell.contentView];
    }
    
    if (indexPath.section == 0) {
        CGFloat y = 15;
        for (int i=0; i<8; i++) {
            y = [self doubleLabelWithTitle:clubInfoTitleItem[i] content:self.dataArray[i] ory:y forView:cell.contentView];
        }
    }
    
    NSInteger aSection = 1;
    if (self.clubInfo.address.length>0) {
        if (indexPath.section == aSection) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            
            CGSize sz = [Utilities getSize:self.clubInfo.address withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-99-78];
            CGFloat height = 14;
            if (sz.height>18) {
                height = 34;
            }
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 15, 59, 14)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            titleLabel.text = @"地址";
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:titleLabel];
            
            UILabel *rightLabel = [[UILabel alloc] initWithFrame:CGRectMake(Device_Width-65, sz.height>18?24:15, 59, 14)];
            rightLabel.backgroundColor = [UIColor clearColor];
            rightLabel.text = @"导航";
            rightLabel.font = [UIFont systemFontOfSize:14];
            rightLabel.textColor = [UIColor colorWithHexString:@"249df3"];
            [cell.contentView addSubview:rightLabel];
            
            UILabel *addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 15, Device_Width-99-78, height)];
            addressLabel.backgroundColor = [UIColor clearColor];
            addressLabel.text = self.clubInfo.address;
            addressLabel.textColor = [UIColor colorWithHexString:@"333333"];
            addressLabel.numberOfLines = 0;
            addressLabel.lineBreakMode = NSLineBreakByWordWrapping;
            addressLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:addressLabel];
        }
        aSection ++;
    }
    if (self.clubInfo.phone.length>0) {
        if (indexPath.section == aSection) {
            cell.selectionStyle = UITableViewCellSelectionStyleGray;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;

            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 15, 59, 14)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            titleLabel.text = @"球场电话";
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:titleLabel];
            
            UILabel *phoneLabel = [[UILabel alloc] initWithFrame:CGRectMake(99, 15, 200, 14)];
            phoneLabel.backgroundColor = [UIColor clearColor];
            phoneLabel.text = self.clubInfo.phone;
            phoneLabel.textColor = [UIColor colorWithHexString:@"249df3"];
            phoneLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:phoneLabel];
        }
        aSection ++;
    }
    if (_pictureInfoList && _pictureInfoList.count>0) {
        if (indexPath.section == aSection) {
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 15, 59, 14)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            titleLabel.text = @"球道详情";
            titleLabel.font = [UIFont systemFontOfSize:14];
            titleLabel.textAlignment = NSTextAlignmentRight;
            [cell.contentView addSubview:titleLabel];
            
            NSInteger count = MIN(_pictureInfoList.count, 3);
            for (int i=0; i<count; i++) {
                NSString *imgUrl = [_pictureInfoList objectAtIndex:i];
                UIButton *buttonImg = [UIButton buttonWithType:UIButtonTypeCustom];
                buttonImg.frame = CGRectMake(99+i*63, 15, 55, 55);
                [buttonImg sd_setBackgroundImageWithURL:[NSURL URLWithString:imgUrl] forState:UIControlStateNormal placeholderImage:self.defaultImage];
                [buttonImg addTarget:self action:@selector(buttonImageClick:) forControlEvents:UIControlEventTouchUpInside];
                buttonImg.tag = 1000 + i;
                [cell.contentView addSubview:buttonImg];
            }
        }
        aSection ++;
    }
    if (self.clubInfo.introduction.length>0) {
        if (indexPath.section == aSection) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style} ;
            NSAttributedString *att = [[NSAttributedString alloc] initWithString:self.clubInfo.introduction attributes:attributes];
            CGSize sz = [Utilities getSize:self.clubInfo.introduction attributes:attributes withWidth:Device_Width-26];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 14, 100, 17)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            titleLabel.text = @"球场简介";
            titleLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 38, Device_Width-26, sz.height)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.numberOfLines = 0;
            contentLabel.textColor = [UIColor colorWithHexString:@"333333"];
            contentLabel.attributedText = att;
            contentLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:contentLabel];
        }
        aSection ++;
    }
    if (self.clubInfo.clubFacility.length>0) {
        if (indexPath.section == aSection) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style} ;
            NSAttributedString *att = [[NSAttributedString alloc] initWithString:self.clubInfo.clubFacility attributes:attributes];
            CGSize sz = [Utilities getSize:self.clubInfo.clubFacility attributes:attributes withWidth:Device_Width-26];
            
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 14, 100, 17)];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = [UIColor colorWithHexString:@"999999"];
            titleLabel.text = @"球场设施";
            titleLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:titleLabel];
            
            UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(13, 38, Device_Width-26, sz.height)];
            contentLabel.backgroundColor = [UIColor clearColor];
            contentLabel.numberOfLines = 0;
            contentLabel.textColor = [UIColor colorWithHexString:@"333333"];
            contentLabel.attributedText = att;
            contentLabel.font = [UIFont systemFontOfSize:14];
            [cell.contentView addSubview:contentLabel];
        }
        aSection ++;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat rowHeight = 0;
    NSInteger aSection = 1;
    if (indexPath.section == 0) {
        rowHeight = 215;
    }
    if (self.clubInfo.address.length>0) {
        if (indexPath.section == aSection) {
            CGSize sz = [Utilities getSize:self.clubInfo.address withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-99-78];
            if (sz.height<18)
                rowHeight = 44;
            else
                rowHeight = 62;
        }
        aSection ++;
    }
    if (self.clubInfo.phone.length>0) {
        if (indexPath.section == aSection) {
            rowHeight = 44;
        }
        aSection ++;
    }
    if (_pictureInfoList && _pictureInfoList.count>0) {
        if (indexPath.section == aSection) {
            rowHeight = 85;
        }
        aSection ++;
    }
    if (self.clubInfo.introduction.length>0) {
        if (indexPath.section == aSection) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            CGSize sz = [Utilities getSize:self.clubInfo.introduction attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style} withWidth:Device_Width-26];
            rowHeight = sz.height + 53;
        }
        aSection ++;
    }
    if (self.clubInfo.clubFacility.length>0) {
        if (indexPath.section == aSection) {
            NSMutableParagraphStyle *style = [[NSMutableParagraphStyle alloc] init];
            style.lineSpacing = 6;
            CGSize sz = [Utilities getSize:self.clubInfo.clubFacility attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],NSParagraphStyleAttributeName:style} withWidth:Device_Width-26];
            rowHeight = sz.height + 53;
        }
        aSection ++;
    }
    return rowHeight;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 15;
}


- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (Device_SysVersion<7.0) {
        return 0;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger aSection = 1;
    if (self.clubInfo.address.length>0) {
        if (indexPath.section == aSection) {
            [self pressedMap];
        }
        aSection ++;
    }
    if (self.clubInfo.phone.length>0) {
        if (indexPath.section == aSection) {
            [YGCapabilityHelper call:self.clubInfo.phone needConfirm:YES];
        }
        aSection ++;
    }
    
    if (_pictureInfoList && _pictureInfoList.count>0) {
        if (indexPath.section == aSection) {
            UIButton *button = (UIButton *)[self.view viewWithTag:1000 ];
            CGRect rt = [button.superview convertRect:button.frame toView:[GolfAppDelegate shareAppDelegate].window];
            [ImageBrowser IBWithImages:_pictureInfoList isCollection:NO currentIndex:0 initRt:rt isEdit:NO highQuality:YES vc:self backRtBlock:nil completion:nil];
        }
        aSection ++;
    }
}

- (CGFloat) doubleLabelWithTitle:(NSString*)title content:(NSString*)content ory:(CGFloat)y forView:(UIView*)view{
    UILabel *leftLabel = [[UILabel alloc] initWithFrame: CGRectMake(13, y, 60, 14)];
    leftLabel.text = title;
    leftLabel.textColor = [UIColor colorWithHexString:@"999999"];
    leftLabel.font = [UIFont systemFontOfSize:14];
    leftLabel.textAlignment = NSTextAlignmentRight;
    leftLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:leftLabel];
    
    UILabel *rightLabel = [[UILabel alloc] initWithFrame: CGRectMake(99, y, 190, 14)];
    rightLabel.text = content;
    rightLabel.font = [UIFont systemFontOfSize:14];
    rightLabel.textColor = [UIColor colorWithHexString:@"333333"];
    rightLabel.backgroundColor = [UIColor clearColor];
    [view addSubview:rightLabel];
    
    return y+24;
}

- (void)setClubItemData:(ClubModel*)model{
    if (!self.dataArray) {
        self.dataArray = [NSMutableArray array];
        [self.dataArray addObject:model.courseKind?model.courseKind:@""];
        [self.dataArray addObject:model.buildDate?model.buildDate:@""];
        [self.dataArray addObject:model.courseArea?model.courseArea:@""];
        [self.dataArray addObject:model.greenGrass?model.greenGrass:@""];
        [self.dataArray addObject:model.courseData?model.courseData:@""];
        [self.dataArray addObject:model.designer?model.designer:@""];
        [self.dataArray addObject:model.fairwayLength?model.fairwayLength:@""];
        [self.dataArray addObject:model.fairwayGrass?model.fairwayGrass:@""];
    }
}

- (void)checkImageLists{
    
    [ImageBrowser IBWithImages:_pictureInfoList isCollection:NO currentIndex:0 initRt:CGRectZero isEdit:NO highQuality:YES vc:self backRtBlock:nil completion:nil];
    
}

- (void)buttonImageClick:(UIButton*)button{
    NSInteger tag = button.tag - 1000;
    CGRect rt = [button.superview convertRect:button.frame toView:[GolfAppDelegate shareAppDelegate].window];
    [ImageBrowser IBWithImages:_pictureInfoList isCollection:NO currentIndex:tag initRt:rt isEdit:NO highQuality:YES vc:self backRtBlock:nil completion:nil];
}

-(void)pressedMap
{
    ClubModel *club = [[ClubModel alloc] init];
    club.clubName = _clubInfo.clubName;
    club.address = _clubInfo.address;
    club.latitude = _clubInfo.latitude;
    club.longitude = _clubInfo.longitude;
    club.trafficGuide = _clubInfo.trafficGuide;
    
    YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
    vc.clubList = @[club];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
