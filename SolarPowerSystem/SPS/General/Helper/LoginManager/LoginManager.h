//
//  LoginManager.h
//  Golf
//
//  Created by Dejohn Dong on 11-11-22.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UserSessionModel.h"
#import "SearchCityModel.h"
#import "DepositInfoModel.h"
#import "LoginService.h"
#import "YGLoginViewCtrl.h"
#import "ServiceManager.h"
#import "BaseService.h"
#import "HttpErroCodeModel.h"
#import "service.h"

@interface LoginManager : NSObject<ServiceManagerDelegate>{
    //当前登录用户的session;
    UserSessionModel *_session;
    //当前登录用户的登录状态
    BOOL _loginState;
    NSString *_userPassWord;
    //当前选中的城市
    SearchCityModel *_city;
    //会籍数组
    NSArray *_vipList;
    //保证金信息
    DepositInfoModel *_myDepositInfo;
    //价格数组
    NSArray *_priceArray;
    //帮助列表
    NSArray *_helpArray;
    NSString *_phoneNum;
}

//@property(nonatomic,strong) UserSessionModel *session;
@property(strong) UserSessionModel *session;
@property(nonatomic) BOOL loginState;
@property(nonatomic,copy) NSString *userPassWord;
@property(nonatomic,strong) SearchCityModel *city;
@property(nonatomic,strong) NSArray *vipList;
@property(nonatomic,strong) DepositInfoModel *myDepositInfo;
@property(nonatomic,strong) NSArray *priceArray;
@property(nonatomic,strong) NSArray *helpArray;
@property(nonatomic) double currLatitude;
@property(nonatomic) double currLongitude;
@property(nonatomic) BOOL positionIsValid;
//@property(nonatomic) BOOL hasPopLoginView;
@property(nonatomic,weak) id <YGLoginViewCtrlDelegate> delegate;
@property(nonatomic,assign) NSTimeInterval timeInterGab;
// 加载了用户备注 YES 已经加载过了【不重复加载】
@property(nonatomic,assign) BOOL isloadedUserRemarks;

- (NSString *)currLatitudeString;
- (NSString *)currLongitudeString;

+ (LoginManager *)sharedManager;

+ (Location *)getCurrentLocation;

- (void)setLoginState:(BOOL)state;
- (BOOL)getLoginState;

- (NSString *)getSessionId;
- (int)getUserId;
- (SearchCityModel *)getCityModel;
- (SearchCityModel *)getCityModelWithCityId: (NSNumber *)cityId;
- (SearchCityModel *)getCityModelWithCityName:(NSString *)cityName;
//- (void)loadVipListWithVipStatus:(int)status;
- (void)loadVipListWithVipStatus:(int)status clubId:(int)clubId statusBlock:(void(^)(int vipType))statusBlock;

- (BOOL)canAutoLoginInBackground;

- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate;
- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate blockRetrun:(BlockReturn)blockRetrun;
- (void)loginWithDelegate:(id<YGLoginViewCtrlDelegate>)aDelegate controller:(UIViewController*)controller animate:(BOOL)animate blockRetrun:(BlockReturn)blockRetrun cancelReturn:(BlockReturn)cancelReturn;

- (void)loginIfNeed:(UIViewController*)controller doSomething:(BlockReturn)todo;

- (void)judgeLoginOrRegestWithPhoneNum:(NSString*)phoneNum delegate:(id<YGLoginViewCtrlDelegate>)aDelegate blockRetrun:(BlockReturn)blockRetrun;

- (void)autoLoginInBackground:(id<YGLoginViewCtrlDelegate>)aDelegate success:(void (^)(BOOL flag))success failure:(void (^)(HttpErroCodeModel *error))failure;




@end

//存沙盒时的标识加上memberID
NS_INLINE NSString *IDENTIFIER(id identifier){
    return [NSString stringWithFormat:@"%@%d",identifier,[LoginManager sharedManager].session.memberId];
}
