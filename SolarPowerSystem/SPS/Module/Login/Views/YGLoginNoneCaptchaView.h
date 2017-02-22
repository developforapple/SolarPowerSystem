

#import <UIKit/UIKit.h>

@interface YGLoginNoneCaptchaView : UIView
@property (weak, nonatomic) IBOutlet UIButton *buttonTelphone;
@property (weak, nonatomic) IBOutlet UIButton *buttonWechat;
@property (weak, nonatomic) IBOutlet UIView *viewTelphone;
@property (weak, nonatomic) IBOutlet UIView *viewWechat;
@property (weak, nonatomic) IBOutlet UILabel *labelPhone;
@property (nonatomic,copy) BlockReturn blockClose;
@property (nonatomic,copy) NSString *phoneString;
@property (nonatomic,copy) BlockReturn blockPhoneString;
@property (nonatomic,copy) BlockReturn blockReturnLogin;
@property (nonatomic,copy) BlockReturn blockWechatLogin;
+(YGLoginNoneCaptchaView *)show;
@end
