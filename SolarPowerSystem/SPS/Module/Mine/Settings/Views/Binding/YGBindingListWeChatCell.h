

#import <UIKit/UIKit.h>

@interface YGBindingListWeChatCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *wechatBinding;
@property (nonatomic,strong) UIViewController *viewController;

- (void)deallocNotification;
@end
