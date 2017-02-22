
//
//  LoginManager.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-22.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import "LoginManager.h"
#import "SearchService.h"
#import "LoginParamsModel.h"
#import "OpenUDID.h"
#import "YGUserRemarkCacheHelper.h"
#import <BeaconAPI_Base/BeaconBaseInterface.h>
#import <PINCache/PINCache.h>
#import "YGBaseNavigationController.h"

static LoginManager *sharedLoginManager = nil;

@implementation LoginManager

+ (LoginManager *)sharedManager{
    static LoginManager *sharedLoginManager = nil;
    static dispatch_once_t once = 0;
    dispatch_once(&once, ^{
        sharedLoginManager = [[LoginManager alloc] init];
        sharedLoginManager.timeInterGab = KDefaultTimeInterGab;
        [[GolfAppDelegate shareAppDelegate] performBlock:^{
            if (!sharedLoginManager.positionIsValid) {
                sharedLoginManager.currLatitude = 22;
                sharedLoginManager.currLongitude = 114;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"LoadHomeBanner" object:nil];
            }
        } afterDelay:5];
    });
    return sharedLoginManager;
}

+(Location *)getCurrentLocation{
    // 地理位置信息
    NSString *longitudeString = @"0";
    NSString *latitudeString = @"0";
    if([LoginManager sharedManager].positionIsValid) {
        longitudeString = [NSString stringWithFormat:@"%f", [LoginManager sharedManager].currLongitude];
        latitudeString = [NSString stringWithFormat:@"%f", [LoginManager sharedManager].currLatitude];
    }
    
    Location *location = [Location new];
    location.longitude = longitudeString;
    location.latitude = latitudeString;
    return location;
}

+ (id)allocWithZone:(NSZone *)zone{
    @synchronized(self){
        if (sharedLoginManager == nil) {
            sharedLoginManager = [super allocWithZone:zone];
            return sharedLoginManager;
        }
    }
    return nil;
}

- (id)copyWithZone:(NSZone *)zone{
    return self;
}


//真release私有接口
- (void)realRelease
{
    /////////
}

- (NSString *) getSessionId{
	return [[NSUserDefaults standardUserDefaults] objectForKey:@"GolfSessionID"];
}

- (int) getUserId{
	return [[[NSUserDefaults standardUserDefaults] objectForKey:@"GolfUserID"] intValue];
}

- (void)setLoginState:(BOOL)state{
	_loginState = state;
    if (!_loginState) {
        //        [LoginManager sharedManager].hasPopLoginView = NO;
        //        [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGolfUserPassword];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GolfUserID"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"DepositUser"];
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:@"GolfSessionID"];
        //        _myDepositInfo = nil;
        _vipList = nil;
    }
}

- (BOOL)getLoginState{
    return _loginState;
}

- (NSString *)currLatitudeString
{
    if (![self positionIsValid])  return @"0";
    return [NSString stringWithFormat:@"%f",self.currLatitude];
}

- (NSString *)currLongitudeString
{
    if (![self positionIsValid])  return @"0";
    return [NSString stringWithFormat:@"%f",self.currLongitude];
}

//从系统获取城市Model
- (SearchCityModel *)getCityModel {
    if(_city){
        return _city;
    }
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    
    if (localArray) {
        id obj = [localArray objectAtIndex:0];
        SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
        return model;
    }
    return nil;
}

//从系统获取城市Model
- (SearchCityModel *)getCityModelWithCityId: (NSNumber *)cityId{
    NSInteger cityId_ = [cityId integerValue];
    
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    
    if (localArray) {
        for (id obj in localArray) {
            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
            if (model.cityId == cityId_) {
                return model;
            }
        }
    }
    return nil;
}

//从系统获取城市Model
- (SearchCityModel *)getCityModelWithCityName:(NSString *)cityName{
    if(_city){
        return _city;
    }
    NSString *path=[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES) objectAtIndex:0];
    NSString *filename=[path stringByAppendingPathComponent:@"GolfCityInfo.plist"];
    NSArray *localArray = [NSArray arrayWithContentsOfFile:filename];
    
    if (localArray) {
        for (id obj in localArray) {
            SearchCityModel *model = [[SearchCityModel alloc] initWithDic:obj];
            if ([model.cityName isEqualToString:cityName]) {
                return model;
            }
        }
    }
    return nil;
}


- (void)loadVipListWithVipStatus:(int)status clubId:(int)clubId statusBlock:(void(^)(int vipType))statusBlock{
    NSString *sessionId = [sharedLoginManager getSessionId];
    if(sessionId == nil || sessionId.length == 0) {
        sharedLoginManager.vipList = [NSArray array];
        if (statusBlock) {
            statusBlock (-1);
        }
    } else {
        [SearchService getVIPClubsWithSession:sessionId VipStatus:status success:^(NSArray *list) {
            int type = -1;
            if(list && [list count] > 0){
                NSMutableArray *arr_0 = [NSMutableArray array];
                for (VIPClubModel *vipcb in list) {
                    if (vipcb.vipStatus == 0) {
                        [arr_0 addObject:vipcb];
                    }
                    if (clubId == vipcb.clubId) {
                        type = vipcb.vipStatus;
                    }
                }
                sharedLoginManager.vipList = arr_0;
            }else{
                sharedLoginManager.vipList = [NSArray array];
            }
            if (statusBlock) {
                statusBlock (type);
            }
        } failure:^(id error) {
            
        }];
    }
}

- (BOOL)canAutoLoginInBackground{
    BOOL canAutoLogin = NO;
    if (!self.loginState && [GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if (([userDefault objectForKey:KGolfSessionPhone] && [userDefault objectForKey:KGolfUserPassword]) || (groupData&&groupData.length>0)) {
            canAutoLogin = YES;
        }
    }
    return canAutoLogin;
}

- (void)autoLoginInBackground:(id<YGLoginViewCtrlDelegate>)aDelegate success:(void (^)(BOOL flag))completion failure:(void (^)(HttpErroCodeModel *error))failure{
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (!self.loginState&&[GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if (([userDefault objectForKey:KGolfSessionPhone]&&[userDefault objectForKey:KGolfUserPassword]) || (groupData&&groupData.length>0)) {
            NSString *osName = [[UIDevice currentDevice] systemName];
            NSString *osVersion = [[UIDevice currentDevice] systemVersion];
            NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
            
            LoginParamsModel *model = [[LoginParamsModel alloc] init];
            model.phoneNum = [userDefault objectForKey:KGolfSessionPhone];
            model.password = [userDefault objectForKey:KGolfUserPassword];
            model.deviceName = [[UIDevice currentDevice] name];
            model.osName = osName;
            model.osVersion = [osVersion stringByAppendingFormat:@",%@",appVersion];
            model.imeiNum = [OpenUDID value];
            model.latitude = [LoginManager sharedManager].currLatitude;
            model.longitude = [LoginManager sharedManager].currLongitude;
            model.deviceToken = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
            
            if (groupData && groupData.length>0) {
                model.groupData = groupData;
                model.groupFlag = @"wechatApp";
            }
            
            __weak LoginManager *lm = self;
            
            [LoginService publicLogin:model needLoading:NO success:^(UserSessionModel *userSession) {
                if (userSession) {
                    lm.delegate = aDelegate;

                    NSString *n_t = [[YGUserRemarkCacheHelper shared] getUserRemarkName:userSession.memberId];
                    
                    if ([n_t isNotBlank]) {
                        userSession.displayName = n_t;
                    }
                    if(![userSession.sessionId isEqualToString:@""]){
                        [BeaconBaseInterface setUserId:[NSString stringWithFormat:@"%d",userSession.memberId]];
                        [lm finishThread:userSession];
                        if (completion) {
                            completion (YES);
                        }
                    }else{
                        if (failure) {
                            failure (nil);
                        }
                    }
                }
            } failure:^(HttpErroCodeModel *error) {
                if (failure) {
                    failure (error);
                }
            }];
        }else{
            if (failure) {
                failure (nil);
            }
        }
    }else{
        if (failure) {
            failure (nil);
        }
    }
}

- (void)judgeLoginOrRegestWithPhoneNum:(NSString*)phoneNum delegate:(id<YGLoginViewCtrlDelegate>)aDelegate blockRetrun:(BlockReturn)blockRetrun{
    self.delegate = aDelegate;
    _phoneNum = phoneNum;
    NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
    if (!self.loginState) {
        [LoginService checkPhoneNumber:_phoneNum success:^(NSDictionary *dic) {
            if (dic) {
                BOOL isregrest = [[dic objectForKey:@"flag"] boolValue];
                if (isregrest) {
                    [userDefault setObject:_phoneNum forKey:KGolfSessionPhone];
                    [self loginWithDelegate:_delegate controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES blockRetrun:blockRetrun];
                }else{
                    [self userRegist];
                }
            }
        } failure:^(id error) {
            
        }];
    }
}

- (void)userRegist
{
    NSString *osName = [[UIDevice currentDevice] systemName];
    NSString *deviceName = [[UIDevice currentDevice] name];
    NSString *osVersion = [[UIDevice currentDevice] systemVersion];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    
    [LoginService userRegist:_phoneNum withPassword:@"" withLongitude:[LoginManager sharedManager].currLongitude withLatitude:[LoginManager sharedManager].currLatitude withValidateCode:@"" withDeviceToken:[[PINCache sharedCache] objectForKey:WKDeviceTokenKey] withOsName:osName withDeviceName:deviceName withOsVersion:[osVersion stringByAppendingFormat:@",%@",appVersion] withActivationCode:@"" withGroupData:@"" withCountryCode:@"" success:^(UserSessionModel *userSession) {
        if (userSession) {
            [LoginManager sharedManager].session = userSession;
            [LoginManager sharedManager].loginState = YES;
            [[NSUserDefaults standardUserDefaults] setObject:_phoneNum forKey:KGolfSessionPhone];
            [LoginManager sharedManager].userPassWord = @"666666";
            [[NSUserDefaults standardUserDefaults] setObject:[LoginManager sharedManager].session.sessionId forKey:@"GolfSessionID"];
            [[NSUserDefaults standardUserDefaults] setObject:@"666666" forKey:KGolfUserPassword];
            [self regestAction];
        }
    } failure:^(id error) {
        
    }];

}

- (void)regestAction
{
    if (_delegate&&[_delegate respondsToSelector:@selector(loginButtonPressed:)]) {
        [_delegate loginButtonPressed:nil];
    }
}

- (void)finishThread:(id)sender{
    self.session = sender;
    [LoginManager sharedManager].session = sender;
    self.loginState = YES;
    
    ygweakify(self);
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:[LoginManager sharedManager].session.headImage]
                                                    options:SDWebImageLowPriority
                                                   progress:nil
                                                  completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                                      ygstrongify(self);
                                                      if (image != nil) {
                                                          self.session.imageHead = image;
                                                      }
                                                  }];
    
    [[NSUserDefaults standardUserDefaults] setObject:self.session.sessionId forKey:@"GolfSessionID"];
    [[NSUserDefaults standardUserDefaults] setObject:@(self.session.memberId) forKey:@"GolfUserID"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    

    if (_delegate&&[_delegate respondsToSelector:@selector(loginButtonPressed:)]) {
        [_delegate loginButtonPressed:nil];
    }
    if (_delegate&&[_delegate respondsToSelector:@selector(loginFinishHandle)]) {
        [_delegate loginFinishHandle];
    }
    
    if (![LoginManager sharedManager].isloadedUserRemarks) {
        [[ServiceManager serviceManagerWithDelegate:self] userFollowRemark:self.session.sessionId];
    }
    
}

- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate{
    if (!self.loginState && [GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if ((groupData && groupData.length > 0) || ([userDefault objectForKey:KGolfSessionPhone] && [userDefault objectForKey:KGolfUserPassword])){
//            [self autoLoginInBackground:aDelegate completion:^(BOOL boolen) {
//                if (boolen == NO && ) {
//                    
//                }
//            }];
            [self autoLoginInBackground:aDelegate success:^(BOOL flag) {
                
            } failure:^(HttpErroCodeModel *error) {
                if (controller != nil) {
                    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:nil cancelReturn:nil];
                }
                
            }];
            return;
        }
    } else if (self.loginState&&[GolfAppDelegate shareAppDelegate].autoLogIn) {//lyf 临时加
        if (aDelegate&&[aDelegate respondsToSelector:@selector(loginButtonPressed:)]) {
            [aDelegate loginButtonPressed:nil];
        }
        return;
    }
    if (controller != nil && ![controller isKindOfClass:[YGLoginViewCtrl class]]) {
        [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:nil cancelReturn:nil];
    }
}

- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate blockRetrun:(BlockReturn)blockRetrun{
    if (!self.loginState && [GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if (groupData && groupData.length > 0) {
            [self autoLoginInBackground:aDelegate success:^(BOOL flag) {
                if (flag) {
                    if (blockRetrun) {
                        blockRetrun(nil);
                    }
                }
            } failure:^(HttpErroCodeModel *error) {
                [userDefault removeObjectForKey:@"wechat_user_info"];
                [userDefault removeObjectForKey:KGroupData];
                [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
            }];
//            [self autoLoginInBackground:aDelegate completion:^(BOOL boolen) {
//                if (boolen == NO) {
//                    [userDefault removeObjectForKey:@"wechat_user_info"];
//                    [userDefault removeObjectForKey:KGroupData];
//                    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
//                }else{
//                    if (blockRetrun) {
//                        blockRetrun(nil);
//                    }
//                }
//            }];
            return;
        }else if ([userDefault objectForKey:KGolfSessionPhone]&&[userDefault objectForKey:KGolfUserPassword]){
            if (controller) { //其他地方调用了后台自动登录发现登录失败了，所以传递了controller对象进来希望弹出登录窗口。
                [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
            }else{
                [self autoLoginInBackground:aDelegate success:^(BOOL flag) {
                    if (flag) {
                        if (blockRetrun) {
                            blockRetrun(nil);
                        }
                    }
                } failure:^(HttpErroCodeModel *error) {
                    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
                }];
            }
            
//            [self autoLoginInBackground:aDelegate completion:^(BOOL boolen) {
//                if (boolen == NO) {
//                    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
//                }else{
//                    if (blockRetrun) {
//                        blockRetrun(nil);
//                    }
//                }
//            }];
            return;
        }
        
    }
    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:nil];
}

- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate blockRetrun:(BlockReturn)blockRetrun cancelReturn:(BlockReturn)cancelReturn{
    if (!self.loginState&&[GolfAppDelegate shareAppDelegate].autoLogIn) {
        NSUserDefaults *userDefault = [NSUserDefaults standardUserDefaults];
        NSString *groupData = [userDefault objectForKey:KGroupData];
        if ((groupData && groupData.length > 0) || ([userDefault objectForKey:KGolfSessionPhone]&&[userDefault objectForKey:KGolfUserPassword])){
            [self autoLoginInBackground:aDelegate success:^(BOOL flag) {
                if (flag) {
                    if (blockRetrun) {
                        blockRetrun(nil);
                    }
                }
            } failure:^(HttpErroCodeModel *error) {
                [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:cancelReturn];
            }];
            return;
        }
    }
    
    [self presentLoginViewWithDelegate:aDelegate controller:controller animate:animate blockRetrun:blockRetrun cancelReturn:cancelReturn];
}

- (void)loginIfNeed:(UIViewController*)controller doSomething:(BlockReturn)todo
{
    if ([self loginState]) {
        if (todo) todo(nil);
    }else{
        id <YGLoginViewCtrlDelegate> delegate;
        if ([controller conformsToProtocol:@protocol(YGLoginViewCtrlDelegate)]) {
            delegate = (id <YGLoginViewCtrlDelegate>)controller;
        }
        [self loginWithDelegate:delegate controller:controller animate:YES blockRetrun:todo];
    }
}

- (void)presentLoginViewWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate blockRetrun:(BlockReturn)blockRetrun cancelReturn:(BlockReturn)cancelReturn{
    if ([controller isKindOfClass:[YGLoginViewCtrl class]]) {
        return;
    }
    
    YGBaseNavigationController *navi = [YGBaseNavigationController instanceFromStoryboardWithIdentifier:@"YGLoginNaviCtrl"];
    
    YGLoginViewCtrl *loginView = (YGLoginViewCtrl *)navi.topViewController;
    loginView.delegate = aDelegate;
    loginView.blockLonginReturn = blockRetrun;
    loginView.cancelReturn = cancelReturn;
    [GolfAppDelegate shareAppDelegate].loginViewShowed = YES;
    [controller presentViewController:navi animated:animate completion:nil];
}

@end
