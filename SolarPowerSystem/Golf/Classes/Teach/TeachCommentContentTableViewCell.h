//
//  TeachCommentContentTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachCommentContentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelContent;
@property (weak, nonatomic) IBOutlet UILabel *labelReplyContent;
@property (nonatomic,copy) BlockReturn blockReply;

- (void)loadCommentContent:(NSString *)content andReplyContent:(NSString *)reply starLevel:(int)starLevel;

@end
