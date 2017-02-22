//
//  PackageDetailViewController.m
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "PackageDetailViewController.h"
#import "LoginManager.h"
#import "UIImageView+WebCache.h"
#import "UILabel+Hxw.h"
#import "ClubMoreDetailViewController.h"
#import "SharePackage.h"
#import "ImageBrowser.h"
#import "YGCapabilityHelper.h"
#import "SearchService.h"

@implementation PackageDetailViewController
@synthesize packageId = _packageId;
@synthesize clubId = _clubId;
@synthesize agentId = _agentId;
@synthesize packageDetail = _packageDetail;

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"套餐详情";
    [self rightButtonAction:@"分享"];
    
    _listArray = [[NSMutableArray alloc] initWithCapacity:0];
    _specArray = [[NSMutableArray alloc] initWithCapacity:0];
    _specNameArray = [[NSMutableArray alloc] initWithCapacity:0];
    _specPriceArray = [[NSMutableArray alloc] initWithCapacity:0];
    _myCondition = [[ConditionModel alloc] init];
    _packageCondition = [[PackageConditionModel alloc] init];
    
    [_carryView setFrame:[UIScreen mainScreen].bounds];
    _carryView.delegate = self;
    _carryView.showsHorizontalScrollIndicator = NO;
    _carryView.showsVerticalScrollIndicator = NO;
    _carryView.scrollEnabled = YES;
    
    UIControl *touch = [[UIControl alloc] initWithFrame:_packageImgView.frame];
    touch.backgroundColor = [UIColor clearColor];
    [touch addTarget:self action:@selector(browseImage) forControlEvents:UIControlEventTouchUpInside];
    [_carryView addSubview:touch];
    
    _clubTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 0) style:UITableViewStyleGrouped];
    _clubTableView.delegate = self;
    _clubTableView.dataSource = self;
    _clubTableView.scrollEnabled = NO;
    [_carryView addSubview:_clubTableView];
    
    _floatView.backgroundColor = [UIColor whiteColor];
    
    if (!self.packageDetail) {
        [[ServiceManager serviceManagerWithDelegate:self] getPackageDetail:self.packageId];
    }else{
        [self handlePackageDetailInfo];
    }
}

- (void)doRightNavAction{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    if (!_share) {
        NSString *title = [NSString stringWithFormat:@"高球之旅-%@",_packageDetail.packageName];
        NSString *content = @"";
        if (_specArray.count>0) {
            PriceSpecModel *model = _specArray[0];
            content = [NSString stringWithFormat:@"%d元起",model.currentPrice];
        }
        
        NSString *url = [NSString stringWithFormat:@"%@club/packageDetail.jsp?packageId=%d",URL_SHARE,_packageDetail.packageId];
        
        _share = [[SharePackage alloc] initWithTitle:title content:content img:_packageImgView.image url:url];
    }
    [_share shareInfoForView:self.view];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    [GolfAppDelegate shareAppDelegate].currentController = self;
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray *)data;
    if (array && array.count>0) {
        if (Equal(flag, @"package_detail")) {
            self.packageDetail = [array objectAtIndex:0];
            [self handlePackageDetailInfo];
        }
    }
}

- (void)handlePackageDetailInfo{
    if (_packageDetail.specList.count > 0) {
        for (NSDictionary *dic in _packageDetail.specList){
            int specId = [[dic objectForKey:@"spec_id"] intValue];
            int currentPrice = [[dic objectForKey:@"current_price"] intValue]/100;
            NSString *specName = [dic objectForKey:@"spec_name"];
            PriceSpecModel *model = [[PriceSpecModel alloc] init];
            model.specId = specId;
            model.specName = specName;
            model.currentPrice = currentPrice;
            [_specNameArray addObject:specName];
            [_specPriceArray addObject:[NSString stringWithFormat:@"¥%d",currentPrice]];
            [_specArray addObject:model];
        }
    }
    if (_packageDetail.clubList.count > 0) {
        for (NSDictionary *dic in _packageDetail.clubList) {
            NSString *name = [dic objectForKey:@"club_name"];
            int clubId = [[dic objectForKey:@"club_id"] intValue];
            ListModel *model = [[ListModel alloc] init];
            model.clubName = name;
            model.clubId = clubId;
            [_listArray addObject:model];
        }
        [_clubTableView reloadData];
        [self performSelectorOnMainThread:@selector(setPackageDetailInfo:) withObject:_packageDetail waitUntilDone:NO];
    }
}

- (void)setPackageDetailInfo:(PackageDetailModel *)detailModel{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *startDate = [formatter dateFromString:detailModel.beginDate];
    NSDate *endDate = [formatter dateFromString:detailModel.endDate];
    [formatter setDateFormat:@"yyyy年MM月dd日"];
    NSString *start = [formatter stringFromDate:startDate];
    NSString *end = [formatter stringFromDate:endDate];
   
    NSDate *date = [Utilities getTheDay:[NSDate date] withNumberOfDays:1];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    _myCondition.date = dateStr;
    _myCondition.time = @"07:30";
    _myCondition.clubId = detailModel.clubId;
    _myCondition.clubName = ((ListModel *)[_listArray objectAtIndex:0]).clubName;
    
    NSString *imageUrl = [Utilities formatImageUrlWithStr:detailModel.packagePicture withFormatStr:@"l"];
    [_packageImgView sd_setImageWithURL:[NSURL URLWithString:imageUrl] placeholderImage:self.defaultImage];
    
    [_lblPackageName setText:detailModel.packageName];
    [_lblDate setText:[NSString stringWithFormat:@"%@-%@",start,end]];
    
    if (detailModel.agentId > 0) {
        [_lblSupplier setText:detailModel.agentName];
    }
    else{
        [_lblSupplier setText:@"球会官方直销"];
    }
    
    float weith = 0;
    float info_y = 78;
    CGRect rt;

    if (_specNameArray && _specNameArray.count > 0) {
        for (NSString *specName in _specNameArray){
            CGSize size = [Utilities getSize:specName withFont:[UIFont systemFontOfSize:16] withWidth:Device_Width];
            weith = MAX(size.width, weith);
        }
    }
    
    if (weith > 90) {
        rt = [UILabel labelColumnWithFrame:CGRectMake(13, info_y, Device_Width-26, 20) titleArray:_specNameArray textArray:_specPriceArray font:16 lineBreak:NO forView:infoView contentColor:[Utilities R:254 G:132 B:26]];
    }else{
        rt = [UILabel labelDoubleColumnWithFrame:CGRectMake(13, info_y, Device_Width-26, 20) titleArray:_specNameArray textArray:_specPriceArray font:16 lineBreak:NO forView:infoView contentColor:[Utilities R:254 G:132 B:26]];
    }
    
    info_y += rt.size.height +10;
    rt = infoView.frame;
    rt.size.height = info_y;
    infoView.frame = rt;
    [self addGiveYunbiLabel:infoView];//lyf 加

    info_y = infoView.frame.origin.y + infoView.frame.size.height;
    
    rt = _floatView.frame;
    rt.origin.y = info_y;
    rt.size.width = [UIScreen mainScreen].bounds.size.width;//lyf 加
    _floatView.frame = rt;
    
    rt = _shadowImg.frame;
    rt.origin.y = _floatView.frame.origin.y + _floatView.frame.size.height;
    _shadowImg.frame = rt;
    
    info_y += _floatView.frame.size.height+5;
    
    rt = _clubTableView.frame;
    rt.origin.y = info_y+10;
    rt.size.height = _tableHeight;
    _clubTableView.frame = rt;
        
    if (_listArray && _listArray.count > 3) {
        [self showLabels:(info_y + 40 + 20)];
    }
    else{
        [self showLabels:(info_y + 40*_listArray.count + 25)];
    }
    floatView_y = _floatView.frame.origin.y;
}

- (void)addGiveYunbiLabel:(UIView *)theView { //lyf 加
    int giveYunbi = _packageDetail.giveYunbi;
    if (giveYunbi > 0) {
        for (UIView *view in theView.subviews) {
            if ([view isKindOfClass:[UILabel class]]) {
                UILabel *label = (UILabel *)view;
                NSRange range = [label.text rangeOfString:@"¥"];
                if (range.location != NSNotFound && range.length != 0) {
                    UILabel *giveYunbiLabel = [[UILabel alloc] init];
                    giveYunbiLabel.text = [NSString stringWithFormat:@"返%d", giveYunbi];
                    CGRect rect = label.frame;
                    CGSize size1 = [giveYunbiLabel.text sizeWithAttributes:@{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:11]}];
                    giveYunbiLabel.textColor = [UIColor colorWithHexString:@"#ff6d00"];
                    giveYunbiLabel.textAlignment = NSTextAlignmentCenter;
                    giveYunbiLabel.font = [UIFont systemFontOfSize:9];
                    giveYunbiLabel.layer.cornerRadius = 1.5;
                    giveYunbiLabel.layer.borderColor = [UIColor colorWithHexString:@"#ff6d00"].CGColor;
                    giveYunbiLabel.layer.borderWidth = 0.5;
                    giveYunbiLabel.frame = CGRectMake(rect.origin.x + rect.size.width + 5, rect.origin.y + 4, size1.width, size1.height);
                    [theView addSubview:giveYunbiLabel];
                }
            }
        }
    }
}

- (void)showLabels:(int)org_y{
    int y = org_y;
    if (_packageDetail.tourNote.length > 0) {
        y += [self createLabels:y title:@"行程安排: " content:_packageDetail.tourNote];
    }
    if (_packageDetail.priceInclude.length > 0) {
        y += [self createLabels:y title:@"价格包含: " content:_packageDetail.priceInclude];
    }
    if (_packageDetail.priceExclude.length > 0) {
        y += [self createLabels:y title:@"价格不含: " content:_packageDetail.priceExclude];
    }
    if (_packageDetail.description.length > 0) {
        y += [self createLabels:y title:@"备注信息: " content:_packageDetail.description];
    }
    _carryView.contentSize = CGSizeMake(Device_Width, y + 20);
}

- (int)createLabels:(int)origin_y title:(NSString *)title content:(NSString *)content{    
    int hight = 0;
    UIButton *titleLabel = [[UIButton alloc] initWithFrame:CGRectMake(0, origin_y, 90, 25)];
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    [titleLabel setTitle:title forState:UIControlStateNormal];
    [titleLabel setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [titleLabel setBackgroundImage:[UIImage imageNamed:@"package_title.png"] forState:UIControlStateNormal];
    titleLabel.userInteractionEnabled = NO;
    [_carryView addSubview:titleLabel];
    
    UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    contentLabel.backgroundColor = [UIColor clearColor];
    contentLabel.font = [UIFont systemFontOfSize:14];
    contentLabel.text = content;
    contentLabel.numberOfLines = 0;
    contentLabel.textColor = [Utilities R:51 G:51 B:51];
    [_carryView addSubview:contentLabel];
    
    CGSize size = [Utilities getSize:content withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width-20];
    [contentLabel setFrame:CGRectMake(10, origin_y + 30, Device_Width-20, size.height)];
    hight = size.height + 30 + 10;
    
    return hight;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    if (_listArray.count > 3) {
        return 1;
    }
    return _listArray.count;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.backgroundColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:14];
    }
    if (_listArray.count > 3) {
        cell.textLabel.text = @"查看球会详情";
    }
    else{
        ListModel *model = [_listArray objectAtIndex:indexPath.row];
        cell.textLabel.text = model.clubName;
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    _tableHeight += 40;
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (Device_SysVersion<7.0) {
        return 0;
    }
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (Device_SysVersion<7.0) {
        return 0;
    }
    return 0.1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (_listArray.count > 3) {
        UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:nil];
        actionSheet.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
        for(ListModel *model in _listArray){
            [actionSheet addButtonWithTitle:model.clubName];
        }
        [actionSheet addButtonWithTitle:@"取消"];
        actionSheet.cancelButtonIndex = actionSheet.numberOfButtons-1;  
        [actionSheet showInView:self.view];
    }
    else{
        [self pushViewControllerWithIndex:indexPath.row];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex == actionSheet.numberOfButtons - 1) {
        return;
    }
    [self pushViewControllerWithIndex:buttonIndex];
}

- (void)pushViewControllerWithIndex:(NSInteger)index{
    ListModel *model = [_listArray objectAtIndex:index];
    ClubMoreDetailViewController *clubMore = [[ClubMoreDetailViewController alloc] init];
    clubMore.clubId = model.clubId;
    [self pushViewController:clubMore title:@"球场信息" hide:YES];
}

- (IBAction)bookButtonPressed:(id)sender{

    [self enterPackageFillVC];
}

- (void)login{
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"GolfSessionID"]) {
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GolfSessionID"];
    }
    [[LoginManager sharedManager] loginWithDelegate:self controller:self animate:YES];
}

- (void)enterPackageFillVC{
    _packageCondition.packageId = _packageDetail.packageId;
    _packageCondition.packageName = _packageDetail.packageName;
    _packageCondition.clubId = _packageDetail.clubId;
    _packageCondition.agentId = _packageDetail.agentId;
    _packageCondition.agentName = _packageDetail.agentName;
    _packageCondition.bookConfirm = _packageDetail.bookConfirm;
    _packageCondition.clubName = _myCondition.clubName;
    _packageCondition.startDate = _packageDetail.beginDate;
    _packageCondition.endDate = _packageDetail.endDate;
    _packageCondition.payType = _packageDetail.payType;
    _packageCondition.prepayAmount = _packageDetail.prepayAmount;
    _packageCondition.giveYunbi = _packageDetail.giveYunbi;

    PackageFillViewController *packageFill = [[PackageFillViewController alloc] init];
    packageFill.title = _packageDetail.packageName;
    packageFill.specList = _specArray;
    packageFill.myCondition = _packageCondition;
    [self pushViewController:packageFill title:_packageDetail.packageName hide:YES];
}

- (void)loginButtonPressed:(id)sender{
    [self enterPackageFillVC];
}

- (void)browseImage{
    [SearchService getImageListWityId:_packageId type:PackageTypeImage success:^(NSArray *list) {
        if (list.count > 0) {
            NSMutableArray *imageArray = [NSMutableArray arrayWithObject:_packageDetail.packagePicture];
            [imageArray addObjectsFromArray:list];
            
            CGRect initRt = [_packageImgView.superview convertRect:_packageImgView.frame toView:[GolfAppDelegate shareAppDelegate].window];
            
            [ImageBrowser IBWithImages:imageArray isCollection:NO currentIndex:0 initRt:initRt isEdit:NO highQuality:YES vc:self backRtBlock:^CGRect(NSInteger index) {
                return initRt;
            } completion:nil];
        }
        
    } failure:^(id error) {
        
    }];
}

- (IBAction)phoneBook:(id)sender
{
    [YGCapabilityHelper call:self.packageDetail.linkPhone needConfirm:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    [_carryView bringSubviewToFront:_floatView];
    CGRect f = _floatView.frame;
    if (_carryView.contentOffset.y >= floatView_y) {
        float s = _carryView.contentOffset.y - floatView_y;
        f.origin.y = floatView_y + s;
        _floatView.frame = f;
        
        f = _shadowImg.frame;
        f.origin.y = _floatView.frame.origin.y + _floatView.frame.size.height;
        _shadowImg.frame = f;
    }else{
        f.origin.y = floatView_y;
        _floatView.frame = f;
        
        f = _shadowImg.frame;
        f.origin.y = _floatView.frame.origin.y + _floatView.frame.size.height;
        _shadowImg.frame = f;
    }
}

@end
