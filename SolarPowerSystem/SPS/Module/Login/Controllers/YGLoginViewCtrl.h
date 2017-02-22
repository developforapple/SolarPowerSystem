

#import "BaseNavController.h"

@interface YGLoginViewCtrl : BaseNavController

@property (nonatomic,copy) BlockReturn blockLonginReturn;
@property (nonatomic,copy) BlockReturn cancelReturn;
@property (nonatomic,weak) id<YGLoginViewCtrlDelegate> delegate;
@end
