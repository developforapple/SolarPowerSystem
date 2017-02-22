

#import <UIKit/UIKit.h>

/**
 商城商品评论列表cell
 */
@interface YGMallCommodityCommentCell : UITableViewCell

@property (nonatomic) int memberId;
@property (nonatomic,strong) IBOutlet UIImageView *headImage;
@property (nonatomic,strong) IBOutlet UIImageView *memberLevelImg;
@property (nonatomic,strong) IBOutlet UILabel *memberNameLabel;
@property (nonatomic,strong) IBOutlet UILabel *commentContentLabel;
@property (nonatomic,strong) IBOutlet UILabel *commentDateLabel;

-(void)cellAutoLayoutHeight:(NSString *)str;
@end
