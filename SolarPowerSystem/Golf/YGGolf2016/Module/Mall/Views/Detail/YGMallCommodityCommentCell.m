

#import "YGMallCommodityCommentCell.h"
#import "TopicHelp.h"

@implementation YGMallCommodityCommentCell

-(void)cellAutoLayoutHeight:(NSString *)str{
//    self.commentContentLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.commentContentLabel.preferredMaxLayoutWidth = CGRectGetWidth(self.commentContentLabel.frame);
    self.commentContentLabel.text = str;
}

@end
