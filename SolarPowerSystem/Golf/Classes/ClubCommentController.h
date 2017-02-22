//
//  ClubCommentController.h
//  Golf
//
//  Created by 黄希望 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ClubCommentController : BaseNavController

@property (nonatomic) int clubId;
@property (nonatomic,copy) BlockReturn refreshBlock;

@end
