

#import "YGFillInProfileViewCtrl.h"
#import "YGFillInProfileCell.h"
#import "YGSystemImagePicker.h"
#import "HZAreaPickerView.h"
#import "CCAlertView.h"
#import "WXApi.h"

static int lockWXAdd = 1;

@interface YGFillInProfileViewCtrl ()<UITableViewDataSource, UITableViewDelegate, UIActionSheetDelegate, UITextFieldDelegate,HZAreaPickerDelegate>
@property (strong, nonatomic) HZAreaPickerView *locatePicker;
@property (nonatomic, strong) NSString *nickNameTemp;
@property (nonatomic) int genderTemp;
@property (nonatomic, strong) NSString *headImageStrTemp;
@property (nonatomic, strong) NSString *locationStringTemp;
@property (weak, nonatomic) IBOutlet UIView *theView;
@property (nonatomic) BOOL isTextField;
@property (nonatomic) BOOL isPicker;
@property (weak, nonatomic) UITextField *textField;

@property (copy, nonatomic) void (^completion)(BOOL canceled);

@end

@implementation YGFillInProfileViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _gender = [LoginManager sharedManager].session.gender;
    _headImageStr = [LoginManager sharedManager].session.headImage;
    _nickName = [LoginManager sharedManager].session.nickName;
    _locationString = [LoginManager sharedManager].session.location;
    
    self.genderTemp = _gender;
    self.headImageStrTemp = _headImageStr;
    self.locationStringTemp = _locationString;
    self.nickNameTemp = _nickName;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenCode:) name:@"AccessTokenCode" object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.theView.transform = CGAffineTransformMakeTranslation(0, 0);
}

- (void)doLeftNavAction
{
    if (_gender != _genderTemp || _headImageStr != _headImageStrTemp || _locationString != _locationStringTemp || _nickName != _nickNameTemp) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"放弃编辑？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *actionCancel = [UIAlertAction actionWithTitle:@"放弃" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
            if (self.completion) {
                self.completion(YES);
            }
            [self leaveTheView];
        }];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"继续" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:actionCancel];
        [alert addAction:action];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        if (self.completion) {
            self.completion(YES);
        }
        [self leaveTheView];
    }
}

- (void)leaveTheView {
    if (self.navigationController.viewControllers.count == 1) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    } else {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [_textField resignFirstResponder];
}

#pragma mark - UITableViewDataSource, UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else
        return 5;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSString *string = nil;
    string = [NSString stringWithFormat:@"cell%ldInImproveUserInformation", (long)indexPath.row + indexPath.section];
    YGFillInProfileCell *cell = [tableView dequeueReusableCellWithIdentifier:string forIndexPath:indexPath];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    __weak YGFillInProfileViewCtrl *weakSelf = self;
    if (indexPath.section == 1) {
        switch (indexPath.row) {
            case 0:{
                if (_headImageStr.length > 0) {
                    [cell.headimageButton setTitle:@"" forState:UIControlStateNormal];
                    [cell.headimageButton setImage:nil forState:UIControlStateNormal];
                    [cell.headimageButton setBackgroundImage:[UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:_headImageStr]]] forState:UIControlStateNormal];
                }
                cell.selectHeadimageBlock = ^ {
                    [weakSelf.locatePicker cancelPicker];
                    YGFillInProfileCell *cell = [weakSelf.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
                    [cell.nicknameTextField resignFirstResponder];
                    
                    [YGSystemImagePicker presentFrom:weakSelf mode:YGImagePickerModePhoto editing:YES completion:^(UIImage *image) {
                        [weakSelf handleCustomSelectImageWithSelectImage:image];
                    }];
                };
                break;}
            case 1:{
                if (_nickName.length > 0) {
                    cell.nicknameTextField.text = _nickName;
                }
                weakSelf.textField = cell.nicknameTextField;
                cell.textFieldBlock = ^(NSString *string){
                    weakSelf.nickName = string;
                    [weakSelf judgeComplete];
                };
                break;}
            case 2:{
                HZLocation *locate = nil;
                if (_locationString.length > 0) {
                    NSArray *array = [_locationString componentsSeparatedByString:@","];
                    if (array&&array.count==2) {
                        locate = [[HZLocation alloc] init];
                        locate.state = [array objectAtIndex:0];
                        locate.city = [array objectAtIndex:1];
                    }
                }
                self.locatePicker = [[HZAreaPickerView alloc] initWithDelegate:self locate:locate isNoDistrict:YES];
                self.locatePicker.toolBar.isCancelBtnHide = NO;
                if (_locationString.length > 0) {
                    cell.locationLabel.textColor = [UIColor colorWithHexString:@"#333333"];
                    cell.locationLabel.text = _locationString;
                }
                break;}
            case 3:{
                cell.selectGenderBlock = ^ (int a) {
                    weakSelf.gender = a;
                    [weakSelf judgeComplete];
                };
                if (_gender != 2) {
                    cell.femaleButton.selected = _gender == 0;
                    cell.maleButton.selected = _gender == 1;
                }
                break;}
            case 4:{
                cell.clickCompleteButtonBlock = ^{
                   [[ServiceManager serviceManagerWithDelegate:weakSelf] UserEditInfo:[[LoginManager sharedManager] getSessionId] memberName:nil nickName:weakSelf.nickName gender:weakSelf.gender headImageData:weakSelf.headImageStr photoImageData:nil birthday:nil signature:nil location:weakSelf.locationString handicap:-100 personalTag:nil academyId:0 seniority:0 introduction:nil careerAchievement:nil teachingAchievement:nil];
                };
                break;}
            default:
                break;
        }
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (void)tableView:(UITableView *)tableView willDisplayHeaderView:(UIView *)view forSection:(NSInteger)section {
    view.tintColor = [UIColor colorWithHexString:@"#F0EFF5"];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            return 120;
        } else if (indexPath.row == 4) {
            return 76;
        }
    }
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(nonnull NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    if (indexPath.section == 1 && indexPath.row == 1) {
        self.isTextField = YES;
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        self.isPicker = YES;
    }
    if (indexPath.section != 1 || indexPath.row != 1) {
        YGFillInProfileCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:1]];
        [cell.nicknameTextField resignFirstResponder];
    }
    if (indexPath.section != 1 || indexPath.row != 2) {
        [_locatePicker cancelPicker];
    }
    switch (indexPath.section + indexPath.row) {
        case 0:
            if ([WXApi isWXAppInstalled] && [WXApi isWXAppSupportApi]) {
                NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
                if (dic) {
                    [self handleWechatInfo:dic];
                }else{
                    //构造SendAuthReq结构体
                    SendAuthReq* req = [[SendAuthReq alloc ] init];
                    req.scope = @"snsapi_userinfo" ;
                    req.state = @"123" ;
                    //第三方向微信终端发送一个SendAuthReq消息结构
                    [WXApi sendReq:req];
                }
            }else{
                [SVProgressHUD showInfoWithStatus:@"该手机未安装微信客户端"];
            }
            break;
        case 2:{
            YGFillInProfileCell *cell = [_tableView cellForRowAtIndexPath:indexPath];
            [cell.nicknameTextField becomeFirstResponder];
            break;}
        case 3:
            [_locatePicker showInView:self.view];
            break;
        case 1:
        case 4:
        case 5:
        default:
            break;
    }
}

#pragma mark - 
- (void)handleCustomSelectImageWithSelectImage:(UIImage*)aImage {
    if (!aImage) {
        return;
    }
    self.headImage = aImage;
    YGFillInProfileCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:1]];
    self.headImageStr = [Utilities imageDataWithImage:_headImage];
    [cell.headimageButton setTitle:@"" forState:UIControlStateNormal];
    [cell.headimageButton setImage:nil forState:UIControlStateNormal];
    [cell.headimageButton setBackgroundImage:_headImage forState:UIControlStateNormal];
    [self judgeComplete];
}

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [_locatePicker cancelPicker];
    int a = 0;
    if (Device_Height > 568) {
        a = 60;
    } else if (Device_Height > 480) {
        a = 158;
    } else if (Device_Height == 480) {
        a = 238;
    }
    self.theView.transform = CGAffineTransformMakeTranslation(0, -a);
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    if (!_isPicker) {
        self.theView.transform = CGAffineTransformMakeTranslation(0, 0);
    } else {
        self.isPicker = NO;
    }

    if (textField.text.length > 0) {
        self.nickName = textField.text;
        [self judgeComplete];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)aTextfield {
    [aTextfield resignFirstResponder];
    return YES;
}
#pragma mark - HZAreaPickerDelegate
- (void)pickerDidChaneStatus:(HZAreaPickerView *)picker{
    YGFillInProfileCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:2 inSection:1]];
    self.locationString = [NSString stringWithFormat:@"%@,%@",picker.locate.state,picker.locate.city];
    if (_locationString.length > 0) {
        cell.locationLabel.textColor = [UIColor colorWithHexString:@"#333333"];
        cell.locationLabel.text = _locationString;
        [self judgeComplete];
    }
//    [[ServiceManager serviceManagerWithDelegate:self] UserEditInfo:[[LoginManager sharedManager] getSessionId] memberName:nil nickName:nil gender:2 headImageData:nil photoImageData:nil birthday:nil signature:nil location:_tempLocationString handicap:-100 personalTag:nil academyId:0 seniority:0 introduction:nil careerAchievement:nil teachingAchievement:nil];
}

-(void)pickerDidCancel:(HZAreaPickerView *)picker{
    if (!_isTextField) {
        self.theView.transform = CGAffineTransformMakeTranslation(0, 0);
    } else {
        self.isTextField = NO;
    }
}

-(void)pickerDidShow:(HZAreaPickerView *)picker{
    int a = 0;
    if (Device_Height > 568) {
        a = 20;
    } else if (Device_Height > 480) {
        a = 118;
    } else if (Device_Height == 480) {
        a = 198;
    }
    self.theView.transform = CGAffineTransformMakeTranslation(0, -a);
}

#pragma mark - WX
- (void)handleWechatInfo:(NSDictionary*)info{
    if (!info) {
        return;
    }
    
    _nickName = info[@"nickname"];
    _headImageStr = info[@"headimgurl"];
    int sex = [info[@"sex"] intValue];
    if (sex == 1) {
        _gender = 1;
    }else if (sex == 2){
        _gender = 0;
    }else{
        _gender = 2;
    }
    _gender = sex;
    
    
    NSString *openId = info[@"openid"];
    NSString *unionId = info[@"unionid"];
    NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
    NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
    
    [[ServiceManager serviceManagerInstance] userBound:@"wechatApp" groupData:groupData sessionId:[[LoginManager sharedManager] getSessionId] phoneNum:nil validateCode:nil isMobile:1 nickName:_nickName gender:_gender headImageUrl:_headImageStr callBack:^(id obj) {
        NSDictionary *dic = (NSDictionary*)obj;
        if (dic) {
            //NSLog(@"*** %@",obj);
            [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
            
            self.nickName = obj[@"nick_name"];
            self.headImageStr = obj[@"head_image"];
            
            [LoginManager sharedManager].session.headImage = _headImageStr;
            [LoginManager sharedManager].session.nickName = _nickName;
            if(_nickName.length > 0) {
                [LoginManager sharedManager].session.displayName = _nickName;
            }
            [LoginManager sharedManager].session.gender = _gender;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
            });
            
            if (self.completion) {
                self.completion(NO);
            }
            
            [self leaveTheView];
        }
    }];
}

- (void)accessTokenCode:(NSNotification*)notification{
    if (lockWXAdd == 1) {
        lockWXAdd = 0;
    } else {
        return;
    }
    id obj = notification.object;
    [[ServiceManager serviceManagerInstance] wechatUserInfo:@"wechatApp" code:obj callBack:^(id obj) {
        lockWXAdd = 1;
        NSDictionary *dictionary = (NSDictionary*)obj;
        NSMutableDictionary *dic = [[NSMutableDictionary alloc] initWithDictionary:dictionary];
        int sex = [dic[@"sex"] intValue];
        if (sex == 2) {
            dic[@"sex"] = @(0);
        }else if (sex == 1){
            dic[@"sex"] = @(1);
        }else{
            dic[@"sex"] = @(2);
        }
        if (dic) {
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"wechat_user_info"];
            [self handleWechatInfo:dic];
        }
    }];
}

#pragma mark - Function
- (BOOL)judgeComplete {
    YGFillInProfileCell *cell = [_tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:4 inSection:1]];
    if (_headImageStr.length > 0 && _nickName.length > 0 && _gender != 2 && _locationString.length > 0) {
        cell.completeButton.enabled = YES;
        return YES;
    } else {
        cell.completeButton.enabled = NO;
        return NO;
    }
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    if (Equal(flag, @"user_edit_info")) {
        if (serviceManager.success) {
            NSArray *array = (NSArray*)data;
            NSDictionary *dic = array[0];
            
            [LoginManager sharedManager].session.headImage = dic[@"head_image"];
            [LoginManager sharedManager].session.nickName = dic[@"nick_name"];
            [LoginManager sharedManager].session.gender = [dic[@"gender"] intValue];
            [LoginManager sharedManager].session.location = _locationString;
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD showSuccessWithStatus:@"修改成功"];
                if (self.completion) {
                    self.completion(NO);
                }
                [self leaveTheView];
            });
        }
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
    NSLog(@"lyf YGFillInProfileViewCtrl dealloc");
}
@end

@implementation YGFillInProfileNaviCtrl

+ (BOOL)presentIfNeed:(UIViewController *)from
             finished:(void (^)(YGFillInProfileNaviCtrl *))finishedBlock
{
    NSString *nickName = [LoginManager sharedManager].session.nickName;
    NSString *headImage = [LoginManager sharedManager].session.headImage;
    
    if (nickName.length == 0 || headImage.length == 0) {
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"提示" message:@"你还没有头像和昵称，完善资料后才能进行操作"];
        [alert addButtonWithTitle:@"取消" block:nil];
        [alert addButtonWithTitle:@"完善资料" block:^{
            
            YGFillInProfileNaviCtrl *navi = [YGFillInProfileNaviCtrl instanceFromStoryboard];
            [from presentViewController:navi animated:YES completion:nil];
            finishedBlock?finishedBlock(navi):nil;
        }];
        [alert show];
        return YES;
    }else{
        finishedBlock?finishedBlock(nil):nil;
        return NO;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    YGFillInProfileViewCtrl *vc = [self.viewControllers firstObject];
    vc.completion = self.completion;
}

- (void)setCompletion:(void (^)(BOOL))completion
{
    _completion = completion;
    YGFillInProfileViewCtrl *vc = [self.viewControllers firstObject];
    vc.completion = completion;
}

@end
