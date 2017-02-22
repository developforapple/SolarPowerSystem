

#import "YGBindingListWeChatCell.h"
#import "OpenUDID.h"
#import "CCAlertView.h"
#import "WXApi.h"
@implementation YGBindingListWeChatCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    if ([GolfAppDelegate shareAppDelegate].systemParamInfo.bindWeixin == 1) {//已绑定
        [self alreadyBindingWeChat];
    }else{
        [self noBindingWechat];
    }
}

- (void)alreadyBindingWeChat{
    [self.wechatBinding setTitle:@"已绑定" forState:0];
    self.wechatBinding.backgroundColor = [UIColor colorWithHexString:@"cccccc"];
    [self.wechatBinding setImage:[UIImage imageNamed:@""] forState:0];
    [self.wechatBinding removeTarget:self action:@selector(binding) forControlEvents:UIControlEventTouchUpInside];
    [self.wechatBinding addTarget:self action:@selector(unwrap) forControlEvents:UIControlEventTouchUpInside];
}

- (void)noBindingWechat{
    [self.wechatBinding setTitle:@"绑定" forState:0];
    [self.wechatBinding setImage:[UIImage imageNamed:@"plus"] forState:0];
    self.wechatBinding.backgroundColor = [UIColor colorWithHexString:@"249CF2"];
    [self.wechatBinding removeTarget:self action:@selector(unwrap) forControlEvents:UIControlEventTouchUpInside];
    [self.wechatBinding addTarget:self action:@selector(binding) forControlEvents:UIControlEventTouchUpInside];
}

- (void)unwrap{//解绑
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"解除微信账号绑定" message:@"解除后将不能作为登录方式登录该账号，确定解除微信账号绑定吗？" preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
    ygweakify(self);
    UIAlertAction *sureAction = [UIAlertAction actionWithTitle:@"解除绑定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        ygstrongify(self);
        [self unwrapAction];
    }];
    [alert addAction:cancelAction];
    [alert addAction:sureAction];
    [self.viewController presentViewController:alert animated:YES completion:nil];
}

/**
 解绑实现
 */
- (void)unwrapAction{
    if ([LoginManager sharedManager].session.mobilePhone.length > 0 && [LoginManager sharedManager].session.mobilePhone) {
        //有手机号允许解绑
        ygweakify(self);
        [[API shareInstance] unbindWithBindType:1 success:^(AckBean *data) {
            if (data.err.errorMsg == nil) {
                [SVProgressHUD showInfoWithStatus:@"解绑成功"];
                RunOnMainQueue(^{
                    ygstrongify(self);
                    [self noBindingWechat];
                });
                [[NSUserDefaults standardUserDefaults] removeObjectForKey:KGroupData];
                [[API shareInstance] timSignAuthWithSuccess:^(AckBean *ab) {
                    NSString *password = ab.success.extraMap[@"auth"];
                    [[NSUserDefaults standardUserDefaults] setObject:password forKey:KGolfUserPassword];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                } failure:^(Error *error) {
                }];
                [GolfAppDelegate shareAppDelegate].systemParamInfo.bindWeixin = 0;
            }
        } failure:^(Error *err) {
            [SVProgressHUD showInfoWithStatus:@"解绑失败"];
        }];
    }else{
        [SVProgressHUD showInfoWithStatus:@"请绑定手机号码以后，再进行微信解绑操作"];
    }
}

- (void)binding{//绑定
    if (![WXApi isWXAppInstalled]){
        [SVProgressHUD showInfoWithStatus:@"您未安装微信"];
        return;
    }else if (![WXApi isWXAppSupportApi]){
        [SVProgressHUD showInfoWithStatus:@"您的微信无法登录APP"];
    }

    //构造SendAuthReq结构体
    SendAuthReq* req = [[SendAuthReq alloc ] init];
    req.scope = @"snsapi_userinfo" ;
    req.state = @"123" ;
    //第三方向微信终端发送一个SendAuthReq消息结构
    [WXApi sendReq:req];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(accessTokenCode:) name:@"AccessTokenCode" object:nil];
}

- (void)accessTokenCode:(NSNotification*)notification{
    id obj = notification.object;
    [SVProgressHUD show];
    ygweakify(self);
    [[ServiceManager serviceManagerInstance] wechatUserInfo:@"wechatApp" code:obj callBack:^(id obj) {
        ygstrongify(self);
        [SVProgressHUD dismiss];
        NSDictionary *dic = (NSDictionary*)obj;
        if (dic){
            [[NSUserDefaults standardUserDefaults] setObject:dic forKey:@"wechat_user_info"];
            [[NSUserDefaults standardUserDefaults] synchronize];
            [self userBindWithDic:dic];
        }
    }];
}

- (void)userBindWithDic:(NSDictionary *)dic{
    if (dic) {
        NSString *openId = dic[@"openid"];
        NSString *unionId = dic[@"unionid"];
        NSString *apendStr = [NSString stringWithFormat:@"%@%@%@",openId,unionId,API_KEY];
        NSString *groupData = [NSString stringWithFormat:@"%@|%@|%@",openId,unionId,[apendStr md5String]];
        int gender = [dic[@"sex"] intValue];
        if (gender == 2) {
            gender = 0;
        }else if (gender == 1){
            gender = 1;
        }else{
            gender = 2;
        }
        NSString *nickName = nil;
        NSString *headImage = nil;
        if ([LoginManager sharedManager].session.headImage.length > 0) {
            headImage = @"";
        }else{
            headImage = dic[@"headimgurl"];
        }
        if ([LoginManager sharedManager].session.nickName.length > 0 && [LoginManager sharedManager].session.nickName) {
            nickName = @"";
        }else{
            nickName = dic[@"nickname"];
        }
        ygweakify(self);
        [ServerService userBound:@"wechatApp" groupData:groupData sessionId:[LoginManager sharedManager].session.sessionId phoneNum:[LoginManager sharedManager].session.mobilePhone validateCode:@"" isMobile:1 nickName:nickName gender:gender headImageUrl:headImage callBack:^(id obj) {
            ygstrongify(self);
            if (obj) {
                BaseService *baseSer = (BaseService *)obj;
                NSString *backNickName = baseSer.data[@"nick_name"];
                NSString *backHeadImg = baseSer.data[@"head_image"];
                int gender = [baseSer.data[@"gender"] intValue];
                [LoginManager sharedManager].session.nickName = backNickName;
                [LoginManager sharedManager].session.headImage = backHeadImg;
                [LoginManager sharedManager].session.gender = gender;
                [LoginManager sharedManager].session.sessionId = baseSer.data[@"session_id"];
                
                [[NSUserDefaults standardUserDefaults] setObject:groupData forKey:KGroupData];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            
            [self alreadyBindingWeChat];
            [GolfAppDelegate shareAppDelegate].systemParamInfo.bindWeixin = 1;
           
            [SVProgressHUD showInfoWithStatus:@"绑定微信成功"];
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
        } failure:^(id error) {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
        }];
    }
}
- (void)deallocNotification{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"AccessTokenCode" object:nil];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
