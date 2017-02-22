

#import <UIKit/UIKit.h>

@class ActivityModel;

UIKIT_EXTERN NSString *const kYGMallPromotionCell;

/**
 商城首页，乐活动的显示内容
 */
@interface YGMallPromotionCell : UITableViewCell

@property (nonatomic,strong) NSArray<ActivityModel *> *activityList;

@end


@interface YGMallPromotionUnit : UIView
@property (weak, nonatomic) IBOutlet UIButton *btn;
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (strong, nonatomic) ActivityModel *activity;
@end
