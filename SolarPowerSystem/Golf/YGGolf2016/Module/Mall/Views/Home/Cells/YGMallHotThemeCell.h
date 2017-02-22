

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGMallHotThemeCell;

/**
 商品首页，热主题cell。显示3个主题。
 */
@interface YGMallHotThemeCell : UITableViewCell
@property (nonatomic,strong) NSArray<YGMallThemeModel *> *themes;
@property (nonatomic,assign) BOOL hideLine;

@property (nonatomic, assign) YGMallPoint startPoint;

@end

/**
 商城首页热主题单元
 */
@interface YGMallHotThemeUnit : UIView
@property (nonatomic,weak) IBOutlet UILabel *mainTitleLabel;
@property (nonatomic,weak) IBOutlet UILabel *subTitleLabel;
@property (nonatomic,weak) IBOutlet UIImageView *photoImageView;
@property (nonatomic,strong) YGMallThemeModel *theme;
@end
