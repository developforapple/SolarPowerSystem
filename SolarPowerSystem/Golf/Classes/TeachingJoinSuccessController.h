//
//  TeachingJoinSuccessController.h
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface TeachingJoinSuccessController : BaseNavController

@property (nonatomic,strong) NSString *shareTitle;
@property (nonatomic,strong) NSString *shareContent;
@property (nonatomic,strong) NSString *shareImage;
@property (nonatomic,strong) NSString *shareUrl;

@property (nonatomic,assign) int productId;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
