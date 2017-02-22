//
//  CommentTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CoachDetailCommentModel.h"

@interface CommentTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelComment;
@property (weak, nonatomic) IBOutlet UILabel *labelReply;


@property(copy,nonatomic) BlockReturn blockReturn;
@property(copy,nonatomic) BlockReturn blockReplyPressed;
@property(copy,nonatomic) BlockReturn blockFromPressed;
@property(nonatomic) NSInteger cellRow;

- (void)loadData:(CoachDetailCommentModel *)tcm;
@end
