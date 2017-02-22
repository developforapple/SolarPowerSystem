

#import "YGWeChatLoginLogic.h"
#import "OpenUDID.h"
#import "WXApi.h"
#import <PINCache/PINCache.h>

@interface YGWeChatLoginLogic()<ServiceManagerDelegate>
@property (nonatomic,assign) int wXTryToLogin;
@property (nonatomic,strong) UIViewController *viewCtr;
@end

@implementation YGWeChatLoginLogic
- (void)weChatLoginWithController:(UIViewController *)viewController{
    self.viewCtr = viewController;
    
    if (![WXApi isWXAppInstalled]){
        [SVProgressHUD showInfoWithStatus:@"您未安装微信"];
        return;
    }else if (![WXApi isWXAppSupportApi]){
        [SVProgressHUD showInfoWithStatus:@"您的微信无法登录APP"];
    }
    
//    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
//    
//    NSString *groupData = [userDefault objectForKey:KGroupData];
//    if (groupData && groupData.length > 0) {
//        _wXTryToLogin = 1;
//        
//        NSString *osName = [[UIDevice currentDevice] systemName];
//        NSString *osVersion = [[UIDevice currentDevice] systemVersion];
//        NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
//        
//        LoginParamsModel *model = [[LoginParamsModel alloc] init];
//        model.phoneNum = [userDefault objectForKey:KGolfSessionPhone];
//        model.password = @"";
//        model.deviceName = [[UIDevice currentDevice] name];
//        model.osName = osName;
//        model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
//        model.imeiNum = [OpenUDID value];
//        model.latitude = [LoginManager sharedManager].currLatitude;
//        model.longitude = [LoginManager sharedManager].currLongitude;
//        model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
//        model.groupFlag = @"wechatApp";
//        model.groupData = groupData;
//        
//        [self login:model];
//        
//    }else{
//    }
    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenCode:) name:@"AccessTokenCode" object:nil];
}

- (void)accessTokenCode:(NSNotification*)notification{
    _wXTryToLogin = 2;
    id obj = notification.object;
    [SVProgressHUD show];
    ygweakify(self);
    [[ServiceManager serviceManagerInstance] wechatUserInfo:@"wechatApp" code:obj callBack:^(id obj) {
        ygstrongify(self);
        NSDictionary *dic = (NSDictionary*)obj;
        if (dic){
            NSString *openId = dic[@"openid"];
            NSString *unionId = dic[@"unionid"];
            NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
            NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"wechat_user_info"];
            
            NSString *osName = [[UIDevice currentDevice] systemName];
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            LoginParamsModel *model = [[LoginParamsModel alloc] init];
            model.phoneNum = @"";
            model.password = @"";
            model.deviceName = [[UIDevice currentDevice] name];
            model.osName = osName;
            model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
            model.imeiNum = [OpenUDID value];
            model.latitude = [LoginManager sharedManager].currLatitude;
            model.longitude = [LoginManager sharedManager].currLongitude;
            model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
            model.groupFlag = @"wechatApp";
            model.groupData = groupData;
            
            [self login:model];
        }
    }];

}

- (void)login:(LoginParamsModel*)model{
    [LoginService publicLogin:model needLoading:YES success:^(UserSessionModel *session) {
        
        if(session && ![session.sessionId isEqualToString:@""]){
            [LoginManager sharedManager].session = session;
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
            if (dic) {
                NSString *openId = dic[@"openid"];
                NSString *unionId = dic[@"unionid"];
                NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
                
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
            }
            [self performSelectorOnMainThread:@selector(finishThread:) withObject:session waitUntilDone:YES];
        }
        
    } failure:^(id error) {
        
        if (_wXTryToLogin == 1) { // 尝试登录不成功时
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"wechat_user_info"];
            [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGroupData];
            //构造SendAuthReq结构体
            SendAuthReq* req = [[SendAuthReq alloc ] init];
            req.scope = @"snsapi_userinfo" ;
            req.state = @"123" ;
            //第三方向微信终端发送一个SendAuthReq消息结构
            [WXApi sendReq:req];
        }else if (_wXTryToLogin == 2){
            NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
            if (dic) {
                NSString *openId = dic[@"openid"];
                NSString *unionId = dic[@"unionid"];
                NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
                NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,
                                       unionId,[apendStr md5String]];
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                [[NSUserDefaults standardUserDefaults] synchronize];
                
                NSString *osName = [[UIDevice currentDevice] systemName];
                NSString *deviceName = [[UIDevice currentDevice] name];
                NSString *osVersion = [[UIDevice currentDevice] systemVersion];
                NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
                int gender;
                if ([dic[@"sex"] intValue]== 1) {
                    gender = 1;
                }else if ([dic[@"sex"] intValue] == 0){
                    gender = 0;
                }else{
                    gender = 2;
                }
                ygweakify(self);
                [LoginService userRegist:@"" withPassword:@"" withLongitude:[LoginManager sharedManager].currLongitude withLatitude:[LoginManager sharedManager].currLatitude withValidateCode:@"" withDeviceToken:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] withOsName:osName withDeviceName:deviceName withOsVersion:[osVersion stringByAppendingFormat:@",%@",appVersion] withActivationCode:@"" withGroupData:groupData withCountryCode:@"" success:^(UserSessionModel *userSession) {
                    
                    [[ServiceManager serviceManagerInstance] userBound:@"wechatApp" groupData:groupData sessionId:userSession.sessionId phoneNum:nil validateCode:nil isMobile:1 nickName:dic[@"nickname"] gender:gender headImageUrl:dic[@"headimgurl"] callBack:^(id obj) {
                        ygstrongify(self);
                        if (obj) {
                            NSString *backNickName = obj[@"nick_name"];
                            NSString *backHeadImg = obj[@"head_image"];
                            int gender = [obj[@"gender"] intValue];
                            [LoginManager sharedManager].session.nickName = backNickName;
                            [LoginManager sharedManager].session.headImage = backHeadImg;
                            [LoginManager sharedManager].session.gender = gender;
                            [self.viewCtr.navigationController dismissViewControllerAnimated:YES completion:^{
                                [SVProgressHUD dismiss];
                                [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatLoginSuccess" object:nil];
                            }];
                        }
                    }];
                    
                } failure:^(id error) {
                    [SVProgressHUD dismiss];
                }];
            }
        }
    }];
}

- (void)finishThread:(id)sender{
    
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage]
                                                    options:SDWebImageLowPriority
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      if (image != nil) {
                                                          [LoginManager sharedManager].session.imageHead = image;
                                                      }
                                                  }];
    
    [LoginManager sharedManager].loginState = YES;
    
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
    [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.mobilePhone forKey:KGolfSessionPhone];
    [[NSUserDefaults standardUserDefaults] setObject:@([LoginManager sharedManager].session.memberId)  forKey:@"GolfUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshFootprintList" object:@"refresh"];
    
    if (_wXTryToLogin == 2) {
        if ([LoginManager sharedManager].session.nickName.length==0
            || [LoginManager sharedManager].session.headImage.length==0) {
            [self userBind];
        }
    }
    
    if (![LoginManager sharedManager].isloadedUserRemarks) {
        _wXTryToLogin = 0;
        [[ServiceManager serviceManagerWithDelegate:self] userFollowRemark:[[LoginManager sharedManager] getSessionId]];
    }
    
    [self.viewCtr dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"WeChatLoginSuccess" object:nil];
    }];
}

- (void)userBind{
    NSDictionary *dic = [[NSUserDefaults standardUserDefaults] objectForKey:@"wechat_user_info"];
    if (dic) {
        NSString *openId = dic[@"openid"];
        NSString *unionId = dic[@"unionid"];
        NSString *nickName = dic[@"nickname"];
        int gender = [dic[@"sex"] intValue];
        if (gender == 2) {
            gender = 0;
        }else if (gender == 1){
            gender = 1;
        }else{
            gender = 2;
        }
        
        NSString *headImageUrl = dic[@"headimgurl"];
        NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
        NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
        if (nickName.length>0 || headImageUrl.length>0) {
            [[ServiceManager serviceManagerInstance] userBound:@"wechatApp" groupData:groupData sessionId:[LoginManager sharedManager].session.sessionId phoneNum:[LoginManager sharedManager].session.mobilePhone validateCode:nil isMobile:1 nickName:nickName gender:gender headImageUrl:headImageUrl callBack:^(id obj) {
                if (obj) {
                    NSString *backNickName = obj[@"nick_name"];
                    NSString *backHeadImg = obj[@"head_image"];
                    int gender = [obj[@"gender"] intValue];
                    [LoginManager sharedManager].session.nickName = backNickName;
                    [LoginManager sharedManager].session.headImage = backHeadImg;
                    [LoginManager sharedManager].session.gender = gender;
                }
            }];
        }
    }
}

- (void)deallocNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
}

@end
