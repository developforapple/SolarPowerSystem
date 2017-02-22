//
//  YGProfileEditingViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-9-18.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGProfileEditingViewCtrl.h"
#import "CCActionSheet.h"
#import "YGTagsEditingViewCtrl.h"
#import "SimpleContentTableViewCell.h"
#import "YGTagsTableCell.h"
#import "YGInputViewCtrl.h"
#import "YGSystemImagePicker.h"
#import "YGProfileEditingPicker.h"
#import "YGProfileEditingPickerData.h"
#import "YGProfileEditor.h"

#define kTagButtonLeftMargin 80

typedef NS_ENUM(NSUInteger, _YGRowType) {
    // 0 分隔
    _YGRowTypeAvatar = 1,
    _YGRowTypeName = 2,
    _YGRowTypeGender = 3,
    _YGRowTypeAge = 4,
    _YGRowTypeHandicap = 5,
    _YGRowTypeLocal = 6,
    // 7 分隔
    _YGRowTypeSign = 8,
    _YGRowTypeTags = 9,
    // 10 分隔
    _YGRowTypeLevel = 11,
    // 12 分隔
    
    // 教练
    _YGRowTypeSeniority = 13,
    _YGRowTypeIntro = 14,
    _YGRowTypeAchievement = 15,
    _YGRowTypeHarvest = 16
    // 17 分隔
};

@interface YGProfileEditingViewCtrl ()<UITableViewDelegate,UITableViewDataSource,YGTagsEditingDelegate,YGProfileEditingPickerDelegate>{
    CGFloat widthLabelContent;
    CGFloat height;
}

@property (strong, nonatomic) YGProfileEditingPicker *picker;
@property (nonatomic,strong) NSMutableArray *tags;
@property (nonatomic,weak) IBOutlet UITableView *tableView;

@property (nonatomic, strong) YGTagsTableCell *tagCell;

@property (strong, nonatomic) YGProfileEditor *editor;
@property (strong, nonatomic) YGArea *lastArea;
@end

@implementation YGProfileEditingViewCtrl
#pragma mark - 视图控制

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (IS_3_5_INCH_SCREEN || IS_4_0_INCH_SCREEN) {
        widthLabelContent = 188;
    }else if(IS_4_7_INCH_SCREEN){
        widthLabelContent = 234;
    }else if(IS_5_5_INCH_SCREEN){
        widthLabelContent = 277;
    }
    [self splitTags];
    [self.tableView setContentInset:(UIEdgeInsetsMake(10, 0, 0, 0))];
}

- (void)splitTags{
    NSString *personalTag = [self.userDetail.personalTag stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if (personalTag.length == 0) {
        self.tags = nil;
    }else{
        self.tags = [[personalTag componentsSeparatedByString:@","] mutableCopy];
    }
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    self.personalHomeController.userDetail = self.userDetail;
    [LoginManager sharedManager].session.headImage = self.userDetail.headImage;
    [LoginManager sharedManager].session.displayName = self.userDetail.displayName;
    [LoginManager sharedManager].session.nickName = self.userDetail.nickName;
    [LoginManager sharedManager].session.handicap = self.userDetail.handicap;
    [LoginManager sharedManager].session.gender = self.userDetail.gender;
    [LoginManager sharedManager].session.birthday = self.userDetail.birthday;
    
    if(self.userDetail.nickName.length > 0) {
        self.userDetail.displayName = self.userDetail.nickName;
        [LoginManager sharedManager].session.displayName = self.userDetail.nickName;
    }
    if(self.delegate && [self.delegate respondsToSelector:@selector(refreshUserInfo)]) {
        [self.delegate performSelector:@selector(refreshUserInfo)];
    }
}

- (YGProfileEditingPicker *)picker
{
    if (!_picker){
        YGProfileEditingPicker *picker = [[YGProfileEditingPicker alloc] initWithParentView:self.view];
        picker.delegate = self;
        _picker = picker;
    }
    return _picker;
}

- (YGProfileEditor *)editor
{
    if (!_editor || !_editor.profile || _editor.profile != self.userDetail) {
        _editor = [[YGProfileEditor alloc] initWithProfileModel:self.userDetail];
        
        ygweakify(self);
        [_editor setCompletion:^(BOOL suc, NSString *msg) {
            ygstrongify(self);
            [self handleEditorCompletion:suc msg:msg];
        }];
    }
    return _editor;
}

#pragma mark - getCells

- (SimpleContentTableViewCell *)getCellWithTableView:(UITableView *)tableView indexPath:(NSIndexPath *)indexPath title:(NSString *)title content:(NSString *)content{
    SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ContentCell" forIndexPath:indexPath];
    cell.labelTitle.text = title;
    cell.labelContent.text = content;
    return cell;
}

- (CGFloat)getTextHeight:(NSString *)text{
    CGSize s = [text boundingRectWithSize:CGSizeMake(widthLabelContent, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
    return s.height;
}

// 文本编辑
- (void)editWithDefaultText:(NSString*)defaultText placeHolder:(NSString*)placeHolder isTextField:(BOOL)isTextField length:(int)length title:(NSString*)title complete:(BlockReturn)complete{
    YGInputViewCtrl *vc = [YGInputViewCtrl instanceFromStoryboard];
    vc.title = title;
    vc.blockReturn = complete;
    vc.isTextField = isTextField;
    vc.placeHolderText = placeHolder;
    vc.defaultText = defaultText;
    vc.maxLength = length;
    [self.navigationController pushViewController:vc animated:YES];
}

#pragma mark - TableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [LoginManager sharedManager].myDepositInfo.coachLevel >= 0 ? 18:13;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case _YGRowTypeAvatar:
        {
            SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ImageCell" forIndexPath:indexPath];
            [cell.image sd_setImageWithURL:[NSURL URLWithString:self.userDetail.headImage] placeholderImage:[UIImage imageNamed:@"head_image"] options:(SDWebImageLowPriority) completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                [LoginManager sharedManager].session.imageHead = image;
            }];
            return cell;
        }
            break;
        case _YGRowTypeName:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"昵称" content:(self.userDetail.nickName.length > 0 ? self.userDetail.nickName:@"")];
            break;
        case _YGRowTypeGender:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"性别" content:(self.userDetail.gender == 0 ? @"女":(self.userDetail.gender == 1 ? @"男":@""))];
            break;
        case _YGRowTypeAge:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"年龄" content:(self.userDetail.birthday.length > 0 ? [NSString stringWithFormat:@"%d",[Utilities agewithBirthday:self.userDetail.birthday]]:@"")];
            break;
        case _YGRowTypeHandicap:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"差点" content:(self.userDetail.handicap > -100 ? [NSString stringWithFormat:@"%d",self.userDetail.handicap] : @"")];
            break;
        case _YGRowTypeLocal:
        {
            SimpleContentTableViewCell *cell = [self getCellWithTableView:tableView indexPath:indexPath title:@"所在地" content:(self.userDetail.location.length > 0 ? self.userDetail.location:@"")];
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            return cell;
        }
            break;
        case _YGRowTypeSign:
        {
            SimpleContentTableViewCell *cell = [self getCellWithTableView:tableView indexPath:indexPath title:@"个人签名" content:(self.userDetail.signature.length > 0 ? self.userDetail.signature:@"")];
            return cell;
        }
            break;
        case _YGRowTypeTags:
        {
            [self.tagCell configureWithTags:self.tags];
            self.tagCell.clipsToBounds = YES;
            return self.tagCell;
        }
            break;
        case _YGRowTypeLevel:
        {
            NSString *content = @"";
            switch ([LoginManager sharedManager].session.memberLevel) {
                case 1:
                    content = @"普通用户";
                    break;
                case 2:
                    content = @"VIP用户";
                    break;
                case 3:
                    content = @"大户";
                    break;
                default:
                    break;
            }
            SimpleContentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"VipCell" forIndexPath:indexPath];
            cell.labelContent.text = content;
            UIImage *img = [Utilities imageOfUserType:[LoginManager sharedManager].session.memberLevel];
            if (!img) {
                img = [UIImage imageNamed:@"vip_un.png"];
            }
            cell.image.image = img;
            return cell;
        }
        case _YGRowTypeSeniority:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"教龄" content:(self.userDetail.seniority > 0 ? [NSString stringWithFormat:@"%d",self.userDetail.seniority]:@"")];
            break;
        case _YGRowTypeIntro:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"个人简介" content:(self.userDetail.introduction.length > 0 ? self.userDetail.introduction:@"")];
            break;
        case _YGRowTypeAchievement:
            return [self getCellWithTableView:tableView indexPath:indexPath title:@"所获成就" content:(self.userDetail.achievement.length > 0 ? self.userDetail.achievement:@"")];
            break;
        case _YGRowTypeHarvest:
        {
            SimpleContentTableViewCell *cell = [self getCellWithTableView:tableView indexPath:indexPath title:@"教学成果" content:(self.userDetail.teachHarvest.length > 0 ? self.userDetail.teachHarvest:@"")];
            cell.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
            return cell;
        }
            break;
            
        default:{
            return [tableView dequeueReusableCellWithIdentifier:@"lineCell" forIndexPath:indexPath];
        }   break;
    }
    return [[UITableViewCell alloc] init];
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            return 2;
            break;
        case _YGRowTypeAvatar:
            return 67;
            break;
        case _YGRowTypeName:
        case _YGRowTypeGender:
        case _YGRowTypeAge:
        case _YGRowTypeHandicap:
        case _YGRowTypeLocal:
            return 44;
            break;
        case 7:
            return 10;
            break;
        case _YGRowTypeSign:
        {
            CGSize s = [self.userDetail.signature boundingRectWithSize:CGSizeMake(widthLabelContent, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
            return s.height + 30;
        }
            break;
        case _YGRowTypeTags:
        {
            if (!self.tagCell) {
                self.tagCell = [tableView dequeueReusableCellWithIdentifier:@"YGTagsTableCell"];
            }
            [self.tagCell configureWithTags:self.tags];
            height = [self.tagCell contentHeight];
            [self.tagCell prepareForReuse];
            return MAX(height, 44.f);
        }
            break;
        case 10:
            return 10;
            break;
        case _YGRowTypeLevel:
            return 44;
            break;
        case 12:
            return 10;
            break;
        case _YGRowTypeSeniority:
            return 44;
            break;
        case _YGRowTypeIntro:
            return [self getTextHeight:self.userDetail.introduction] + 30;
            break;
        case _YGRowTypeAchievement:
            return [self getTextHeight:self.userDetail.achievement] + 30;
            break;
        case _YGRowTypeHarvest:
            return [self getTextHeight:self.userDetail.teachHarvest] + 30;
            break;
        case 17:
            return 10;
            break;
    }
    return 0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    ygweakify(self);
    switch (indexPath.row) {
        case _YGRowTypeAvatar:{
            [YGSystemImagePicker presentSheetFrom:self modes:YGSystemImagePickerModes allowEditing:YES completion:^(UIImage *image) {
                [self handleCustomSelectImageWithSelectImage:image];
            }];
        }   break;
        case _YGRowTypeName:{
            [self editWithDefaultText:self.userDetail.nickName.length > 0 ? self.userDetail.nickName : @""
               placeHolder:@"请输入昵称" isTextField:YES length:12 title:@"昵称" complete:^(id callBackString) {
                   ygstrongify(self);
                   [self.editor update:@{YGProfileEditorInfoKeyNickName:callBackString?:@""}];
               }];
        }   break;
        case _YGRowTypeGender:
        case _YGRowTypeAge:
        case _YGRowTypeHandicap:
        case _YGRowTypeLocal:{
            [self.picker update:^(YGProfileEditingPickerConfig *config) {
                ygstrongify(self);
                [self updateEditingPickerConfig:config forRow:indexPath.row];
            }];
            
        }   break;
        case 8:{
            [self editWithDefaultText:self.userDetail.signature.length > 0 ? self.userDetail.signature : @"" placeHolder:@"请输入个性签名" isTextField:NO length:50 title:@"个性签名" complete:^(id callBackString) {
                ygstrongify(self);
                [self.editor update:@{YGProfileEditorInfoKeySignature:callBackString?:@""}];
            }];
        }   break;
        case 9:{
            YGTagsEditingViewCtrl *vc = [YGTagsEditingViewCtrl instanceFromStoryboard];
            vc.delegate = self;
            vc.personalTag = self.userDetail.personalTag;
            [self.navigationController pushViewController:vc animated:YES];
        }   break;
        case 11:
            [[GolfAppDelegate shareAppDelegate] showInstruction:[NSString stringWithFormat:@"https://m.bookingtee.com/vip.html?%d", [LoginManager sharedManager].session.memberLevel] title:@"用户说明" WithController:self];
            break;
        case _YGRowTypeSeniority:{
            [self.picker update:^(YGProfileEditingPickerConfig *config) {
                ygstrongify(self);
                [self updateEditingPickerConfig:config forRow:_YGRowTypeSeniority];
            }];
        }   break;
        case 14:{
            [self editWithDefaultText:self.userDetail.introduction placeHolder:@"请填写个人简介" isTextField:NO length:100 title:@"个人简介" complete:^(id obj) {
                ygstrongify(self);
                [self.editor update:@{YGProfileEditorInfoKeyIntroduction:obj?:@"",
                                      YGProfileEditorInfoKeyAcademyId:@(self.userDetail.academyId)}];
                
            }];
        }   break;
        case 15:{
            [self editWithDefaultText:self.userDetail.achievement placeHolder:@"请填写所获成就" isTextField:NO length:100 title:@"所获成就" complete:^(id obj) {
                ygstrongify(self);
                [self.editor update:@{YGProfileEditorInfoKeyCareerAchievement:obj?:@"",
                                      YGProfileEditorInfoKeyAcademyId:@(self.userDetail.academyId)}];
            }];
        }   break;
        case 16:{
            [self editWithDefaultText:self.userDetail.teachHarvest placeHolder:@"请填写教学成果" isTextField:NO length:100 title:@"教学成果" complete:^(id obj) {
                ygstrongify(self);
                [self.editor update:@{YGProfileEditorInfoKeyTeachAchievement:[obj description]?:@"",
                                      YGProfileEditorInfoKeyAcademyId:@(self.userDetail.academyId)}];
            }];
        }   break;
    }
}
 
- (void)editPersonalTagCallBack:(NSString *)callBackString identifier:(NSString *)identifier{
    if (!callBackString) return;
    [self.editor update:@{YGProfileEditorInfoKeyTag:callBackString}];
}

- (void)handleCustomSelectImageWithSelectImage:(UIImage *)aImage{
    NSData *imageData = UIImageJPEGRepresentation(aImage,0.45);
    [self.editor update:@{YGProfileEditorInfoKeyHeadImage:imageData}];
}

#pragma mark - EditingPicker
- (void)updateEditingPickerConfig:(YGProfileEditingPickerConfig *)config forRow:(_YGRowType)row
{
    switch (row) {
        case _YGRowTypeGender:{
            // 1男 0女
            config.style = YGProfileEditingPickerStyleText;
            config.textOptions = [YGProfileEditingPickerData gender];
            config.text = config.textOptions[(int)(!self.userDetail.gender)];
        }   break;
        case _YGRowTypeAge:{
            config.style = YGProfileEditingPickerStyleDate;
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            
            NSDate *minimumDate = [dateFormatter dateFromString:@"1900-01-01"];
            NSDate *curDate = [dateFormatter dateFromString:self.userDetail.birthday];
            config.minimumDate = minimumDate;
            config.maximumDate = [NSDate date];
            config.date = curDate;
            config.showClear = YES;
        }   break;
        case _YGRowTypeHandicap:{
            config.style = YGProfileEditingPickerStyleNumber;
            config.numberOptions = [YGProfileEditingPickerData handicap];
            config.number = @(self.userDetail.handicap);
            config.showClear = YES;
        }   break;
        case _YGRowTypeLocal:{
            config.style = YGProfileEditingPickerStyleArea;
            config.area = self.lastArea;
            config.showClear = YES;
        }   break;
        case _YGRowTypeSeniority:{
            config.style = YGProfileEditingPickerStyleNumber;
            config.numberOptions = [YGProfileEditingPickerData seniority];
            config.number = @(self.userDetail.seniority);
        }   break;
        default:break;
    }
    config.tag = row;
}

- (void)editingPicker:(YGProfileEditingPicker *)picker didDone:(NSInteger)tag
{
    id value = [picker currentValue];
    if (!value) return;
    
    switch (tag) {
        case _YGRowTypeGender:{
            NSInteger idx = [[YGProfileEditingPickerData gender] indexOfObject:value];
            int gender = (int)(!idx);
            [self.editor update:@{YGProfileEditorInfoKeyGender:@(gender)}];
        }   break;
        case _YGRowTypeAge:{
            NSDateFormatter *dateFormatter = [NSDateFormatter new];
            dateFormatter.dateFormat = @"yyyy-MM-dd";
            NSString *string = [dateFormatter stringFromDate:value];
            [self.editor update:@{YGProfileEditorInfoKeyBirthday:string}];
        }   break;
        case _YGRowTypeHandicap:{
            [self.editor update:@{YGProfileEditorInfoKeyHandicap:value}];
        }   break;
        case _YGRowTypeLocal:{
            self.lastArea = value;
            NSString *location = [NSString stringWithFormat:@"%@,%@",self.lastArea.province.province,self.lastArea.city.city];
            [self.editor update:@{YGProfileEditorInfoKeyLocation:location}];
        }   break;
        case _YGRowTypeSeniority:{
            [self.editor update:@{YGProfileEditorInfoKeySeniority:value}];
        }   break;
    }
}

- (void)editingPicker:(YGProfileEditingPicker *)picker didCleared:(NSInteger)tag
{
    switch (tag) {
        case _YGRowTypeAge:{
            [self.editor update:@{YGProfileEditorInfoKeyBirthday:YGProfileEditorNullValue}];
        }   break;
        case _YGRowTypeHandicap:{
            [self.editor update:@{YGProfileEditorInfoKeyHandicap:YGProfileEditorNullValue}];
        }   break;
        case _YGRowTypeLocal:{
            [self.editor update:@{YGProfileEditorInfoKeyLocation:YGProfileEditorNullValue}];
        }   break;
    }
}

- (void)handleEditorCompletion:(BOOL)suc msg:(NSString *)msg
{
    if (!suc) {
        [SVProgressHUD showErrorWithStatus:msg];
    }else{
        if (self.blockReturn) {
            self.blockReturn(self.userDetail);
        }
        [self splitTags];
        [self.tableView reloadData];
        [SVProgressHUD showSuccessWithStatus:msg?:@"修改完成"];
    }
}
@end
