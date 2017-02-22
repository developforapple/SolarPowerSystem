

#import <UIKit/UIKit.h>

@interface YGFillInProfileCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *nicknameTextField;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UIButton *maleButton;
@property (weak, nonatomic) IBOutlet UIButton *femaleButton;
@property (weak, nonatomic) IBOutlet UIButton *completeButton;
@property (weak, nonatomic) IBOutlet UIButton *headimageButton;
@property (strong, nonatomic) void (^selectHeadimageBlock) (void);
@property (strong, nonatomic) void (^selectGenderBlock) (int);
@property (strong, nonatomic) void (^clickCompleteButtonBlock) (void);
@property (strong, nonatomic) void (^textFieldBlock) (NSString *);

@end
