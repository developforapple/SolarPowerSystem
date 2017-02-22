

#import "BaseNavController.h"

@interface YGResetPasswordViewCtrl : BaseNavController

/**
 不带区号手机号
 */
@property (nonatomic,copy) NSString *phoneString;//不带区号手机号

/**
 带区号手机号
 */
@property (nonatomic,copy) NSString *getYZMPhoneStr;

/**
 区号
 */
@property (nonatomic,copy) NSString *areaCodeStr;
@end
