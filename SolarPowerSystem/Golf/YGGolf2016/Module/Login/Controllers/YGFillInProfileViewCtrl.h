

#import <UIKit/UIKit.h>

@interface YGFillInProfileNaviCtrl : UINavigationController

/*!
 *  @brief 将会判断是否需要补充用户资料。并且出现提示框。如果用户选择完善资料。则弹出完善资料界面。否则什么都不做。
 *
 *  @param from          从哪个控制器弹出
 *  @param finishedBlock 完成判断后的回调
 *
 *  @return YES：需要补充资料。NO：不需要补充资料。
 */
+ (BOOL)presentIfNeed:(UIViewController *)from
             finished:(void (^)(YGFillInProfileNaviCtrl *))finishedBlock;


@property (copy, nonatomic) void (^completion)(BOOL canceled);
@end

@interface YGFillInProfileViewCtrl : BaseNavController
@property (nonatomic, strong) NSString *nickName;
@property (nonatomic) int gender;
@property (nonatomic, strong) NSString *headImageStr;
@property (nonatomic, strong) NSString *locationString;
@property (nonatomic,strong) UIImage *headImage;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end
