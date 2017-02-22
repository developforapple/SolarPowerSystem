

#import "BaseNavController.h"

@interface YGRegisterNextStepViewCtrl : BaseNavController
@property (nonatomic,copy) NSString *phoneString;//没加区号的手机号
@property (nonatomic,copy) NSString *getYZMPhoneStr;//获取验证码的号码，需要加上区号
@property (nonatomic,copy) NSString *areaCodeStr;//区号
@end
