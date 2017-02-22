//
//  CourseSchoolDetailsViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/15.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseSchoolDetailsViewController.h"
#import "TitleValueTableViewCell.h"
#import "AlbumTableViewCell.h"
#import "HeaderTableViewCell.h"
#import "TextTableViewCell.h"
#import "CCAlertView.h"
#import "CoachTableViewController.h"
#import "PublicCourseCell.h"
#import "PublicCourseDetailController.h"
#import "YGMapViewCtrl.h"
#import "YGTeachBookingViewCtrl.h"
#import "JZNavigationExtension.h"

@interface CourseSchoolDetailsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *imageHead;
@property (weak, nonatomic) IBOutlet UILabel *labelSchoolName;
@property (weak, nonatomic) IBOutlet UILabel *labelSignature;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingView;

@end

@implementation CourseSchoolDetailsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    YGPostBuriedPoint(YGTeachPointSchooldDetail);
    self.navigationItem.title = nil;
    [self loadData];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
         [[ServiceManager serviceManagerWithDelegate:self] getTeachingAcademyDetail:_academyId];
    });
}


- (void)loadData{
    if (_academyModel) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:_academyModel.photoImage] placeholderImage:self.defaultImage];
        [self.imageHead sd_setImageWithURL:[NSURL URLWithString:_academyModel.headImage] placeholderImage:self.defaultImage];
        [self.labelSchoolName setText:_academyModel.academyName];
        [self.labelSignature setText:_academyModel.signature];
    }
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)data flag:(NSString*)flag{
    NSArray *arr = (NSArray *)data;
    if (Equal(flag, @"teaching_academy_detail")) {
        _academyModel = [arr firstObject];
        [self loadData];
    }
    [_loadingView stopAnimating];
    self.tableView.hidden = NO;
    self.imageView.hidden = NO;
    [self.tableView reloadData];
}

- (void)beginTeachBooking
{
    if (![[LoginManager sharedManager] getLoginState]) {
        [[LoginManager sharedManager] loginWithDelegate:nil controller:self animate:YES blockRetrun:^(id data) {
            YGTeachBookingViewCtrl *vc = [YGTeachBookingViewCtrl instanceFromStoryboard];
            vc.courseId = @(self.academyId);
            [self.navigationController pushViewController:vc animated:YES];
        } cancelReturn:^(id data) {
        }];
    }else{
        YGTeachBookingViewCtrl *vc = [YGTeachBookingViewCtrl instanceFromStoryboard];
        vc.courseId = @(self.academyId);
        [self.navigationController pushViewController:vc animated:YES];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2 + (_academyModel.publicClassList.count > 0 ? 1:0) + (_academyModel.albumList.count > 0 ? 1:0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0 || section == 1) {
        return 2;
    }
    if (section == 2) {
        if (_academyModel.albumList.count > 0) {
            return 2;
        }else{
            return [self publicClassListCount];
        }
    }
    if (section == 3) {
        return [self publicClassListCount];
    }
    return 0;
}

- (NSInteger)publicClassListCount{
    if (_academyModel.publicClassList.count > 0) {
        return _academyModel.publicClassList.count + 1;
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    TextTableViewCell *cell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell" forIndexPath:indexPath];
                    cell.labelTextValue.text = [NSString stringWithFormat:@"%.2fkm %@",_academyModel.distance,_academyModel.address == nil ? @"":_academyModel.address];
                    return cell;
                }
                    break;
                case 1:
                {
                    ygweakify(self);
                    TextTableViewCell *cell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"PhoneTableViewCell" forIndexPath:indexPath];
                    cell.labelTextValue.text = _academyModel.linkPhone;
                    cell.rightButton.hidden = !_academyModel.virtualCourseFlag;
                    [cell setRightBtnAction:^{
                        ygstrongify(self);
                        [self beginTeachBooking];
                    }];
                    return cell;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (_academyModel.albumList.count > 0) {
                switch (indexPath.row) {
                    case 0:
                    {
                        TitleValueTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"TitleValueTableViewCell" forIndexPath:indexPath];
                        cell.labelTitle.text = @"学院教练";
                        cell.labelValue.text = [NSString stringWithFormat:@"%d名",_academyModel.coachCount];
                        return cell;
                    }
                        break;
                    case 1:
                    {
                        AlbumTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AlbumTableViewCell" forIndexPath:indexPath];
                        [cell loadAlbum:_academyModel.albumList];
                        return cell;
                    }
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                        return [self cellForHeaderTitle:@"学院介绍" tableView:tableView indexPath:indexPath];
                        break;
                    case 1:
                        return [self cellForIntroduction:tableView indexPath:indexPath];;
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 2:
        {
            if (_academyModel.albumList.count > 0) {
                switch (indexPath.row) {
                    case 0:
                        return [self cellForHeaderTitle:@"学院介绍" tableView:tableView indexPath:indexPath];
                        break;
                    case 1:
                        return [self cellForIntroduction:tableView indexPath:indexPath];
                        break;
                    default:
                        break;
                }
            }else{
                if (indexPath.row == 0) {
                    UITableViewCell *cell = [self cellForHeaderTitle:@"公开课" tableView:tableView indexPath:indexPath];
                    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                        cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                    }
                    return cell;
                }
                return [self cellForPublicCourse:tableView indexPath:indexPath];
            }
        }
            break;
        case 3:
        {
            if (indexPath.row == 0) {
                UITableViewCell *cell = [self cellForHeaderTitle:@"公开课" tableView:tableView indexPath:indexPath];
                if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
                    cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
                }
                return cell;
            }
            return [self cellForPublicCourse:tableView indexPath:indexPath];
        }
            break;
        default:
            break;
    }
    
    return [[UITableViewCell alloc] init];
}

- (UITableViewCell *)cellForIntroduction:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    TextTableViewCell *cell = (TextTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"TextTableViewCell2" forIndexPath:indexPath];
    cell.labelTextValue.text = _academyModel.introduction;
    return cell;
}

- (UITableViewCell *)cellForPublicCourse:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    PublicCourseCell *cell = (PublicCourseCell *)[tableView dequeueReusableCellWithIdentifier:@"PublicCourseCell" forIndexPath:indexPath];
    cell.publicCourse = _academyModel.publicClassList[indexPath.row - 1];
    return cell;
}

- (UITableViewCell *)cellForHeaderTitle:(NSString *)title tableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath{
    HeaderTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"HeaderTableViewCell" forIndexPath:indexPath];
    cell.labelHeaderTitle.text = title;
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 15, 0, 0)];
    }
    return cell;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    CGFloat offsetY = scrollView.contentOffset.y;
    CGFloat h = CGRectGetHeight(self.tableView.tableHeaderView.frame);
    CGFloat alpha = MAX(0,  offsetY/(h-64.f));
    self.jz_navigationBarBackgroundAlpha = alpha;
    
    if (alpha < .5f) {
        self.navigationItem.title = nil;
    }else{
        self.navigationItem.title = _academyModel.academyName;
    }
}

#pragma mark - UITableViewDelegate


-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    if (section == 0) {
        return 0;
    }
    return 10;
}


-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *v = [[UIView alloc] init];
    v.backgroundColor = [UIColor colorWithHexString:@"#f1f0f6"];
    return v;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    ClubModel *club = [[ClubModel alloc] init];
                    club.clubName = _academyModel.academyName;
                    club.address = _academyModel.address;
                    club.latitude = _academyModel.latitude;
                    club.longitude = _academyModel.longitude;
                    club.trafficGuide = _academyModel.address;
                    
                    YGMapViewCtrl *vc = [YGMapViewCtrl instanceFromStoryboard];
                    vc.clubList = @[club];
                    [self.navigationController pushViewController:vc animated:YES];
                }
                    break;
                case 1:
                {
                    CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"呼叫 %@",_academyModel.linkPhone]];
                    
                    [alert addButtonWithTitle:@"取消" block:nil];
                    [alert addButtonWithTitle:@"呼叫" block:^{
                        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_academyModel.linkPhone]]];
                    }];
                    [alert show];
                    return;
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (_academyModel.albumList.count > 0) {
                switch (indexPath.row) {
                    case 0:
                        break;
                    case 1:
                    {
                        [self pushWithStoryboard:@"Teach" title:@"学院教练" identifier:@"CoachTableViewController" completion:^(BaseNavController *controller) {
                            CoachTableViewController *vc = (CoachTableViewController*)controller;
                            vc.academyId = _academyModel.academyId;
                            SearchCityModel *scm = [[SearchCityModel alloc] init];
                            scm.longitude = [LoginManager sharedManager].currLongitude;
                            scm.latitude = [LoginManager sharedManager].currLatitude;
                            scm.cityId = _cityId;
                            vc.hasSearchButton = NO;
                            vc.useControls = NO;
                            vc.isSearchViewController = NO;
                            vc.selectedCityModel = scm;
                        }];
                    }
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 2:
        {
            if (_academyModel.albumList.count > 0) {
                return;
            }else{
                if (indexPath.row > 0) {
                    [self showPublicCourseDetailController:indexPath];
                }
            }
        }
            break;
        case 3:
        {
            if (indexPath.row > 0) {
                [self showPublicCourseDetailController:indexPath];
            }
        }
            break;
        default:
            break;
    }
}

- (void)showPublicCourseDetailController:(NSIndexPath *)indexPath{
    // 数据上报采集点
    [[BaiduMobStat defaultStat] logEvent:@"btnAcademyPublicClass" eventLabel:@"学院公开课点击"];
    [MobClick event:@"btnAcademyPublicClass" label:@"学院公开课点击"];
    [self pushWithStoryboard:@"Jiaoxue" title:@"公开课详情" identifier:@"PublicCourseDetailController" completion:^(BaseNavController *controller) {
        PublicCourseModel *model = _academyModel.publicClassList[indexPath.row -1];
        PublicCourseDetailController *publicCourseDetail = (PublicCourseDetailController*)controller;
        publicCourseDetail.blockRefresh = ^(id data){
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [[ServiceManager serviceManagerWithDelegate:self] getTeachingAcademyDetail:_academyId];
            });
        };
        publicCourseDetail.publicClassId = model.publicClassId;
    }];
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.section) {
        case 0:
        {
            switch (indexPath.row) {
                case 0:
                {
                    NSString *text = [NSString stringWithFormat:@"%.2fkm %@",_academyModel.distance,_academyModel.address];
                    CGSize size = [text boundingRectWithSize:CGSizeMake(Device_Width - 60, 40) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
                    
                    return size.height + 30;
                }
                    break;
                case 1:
                    return 44;
                    break;
                default:
                    break;
            }
        }
            break;
        case 1:
        {
            if (_academyModel.albumList.count > 0) {
                switch (indexPath.row) {
                    case 0:
                        return 40;
                        break;
                    case 1:
                        return 74;
                        break;
                    default:
                        break;
                }
            }else{
                switch (indexPath.row) {
                    case 0:
                        return 40;
                        break;
                    case 1:
                        return [self heightForIntroduction];
                        break;
                    default:
                        break;
                }
            }
        }
            break;
        case 2:
        {
            if (_academyModel.albumList.count > 0) {
                switch (indexPath.row) {
                    case 0:
                        return 40;
                        break;
                    case 1:
                        return [self heightForIntroduction];
                        break;
                    default:
                        break;
                }
            }else{
                if (indexPath.row == 0) {
                    return 40;
                }
                return 232;
            }
        }
            break;
        case 3:
        {
            if (indexPath.row == 0) {
                return 40;
            }
            return 232;
        }
            break;
        default:
            break;
    }
    
     return 0;
}

- (CGFloat)heightForIntroduction{
    CGSize size = [_academyModel.introduction boundingRectWithSize:CGSizeMake(Device_Width - 26, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14.0]} context:nil].size;
    
    return size.height + 30;
}

@end
