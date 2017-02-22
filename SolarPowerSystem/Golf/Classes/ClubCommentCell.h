//
//  ClubCommentCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CommentModel;

@interface ClubCommentCell : UITableViewCell

@property (nonatomic,strong) CommentModel *cm;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
