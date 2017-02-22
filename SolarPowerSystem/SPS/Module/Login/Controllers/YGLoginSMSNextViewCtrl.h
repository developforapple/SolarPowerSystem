

#import "BaseNavController.h"

@interface YGLoginSMSNextViewCtrl : BaseNavController

/**
 不带区号手机号
 */
@property (nonatomic,copy) NSString *phoneString;

/**
 带区号的手机号
 */
@property (nonatomic,copy) NSString *getYZMPhoneStr;

/**
 区号
 */
@property (nonatomic,copy) NSString *areaCodeStr;
@end
