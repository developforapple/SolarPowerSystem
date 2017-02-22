

#import <UIKit/UIKit.h>

@interface YGMallBrandTitleView : UIView


@property (copy, nonatomic) void (^completion)(YGMallBrandTitleView *brandNavView);

+ (instancetype)shareInstance:(NSString *)title completion:(void(^)(YGMallBrandTitleView *brandNavView))completion;

@end
