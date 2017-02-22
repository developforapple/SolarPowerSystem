

#import "BaseNavController.h"

@interface YGBindingPhoneVerifyViewCtrl : BaseNavController
@property (nonatomic,copy) NSString *phoneString;//不带区号的手机号
@property (nonatomic,copy) NSString *areaCodePhoneStr;//带区号的手机号
@property (nonatomic,copy) NSString *areaCodeStr;

@property (assign, nonatomic) BOOL isExchangePhoneBinding;

@end
