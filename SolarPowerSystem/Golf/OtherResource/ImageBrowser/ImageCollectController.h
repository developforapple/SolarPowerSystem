//
//  ImageCollectController.h
//  Golf
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface ImageCollectController : BaseNavController

@property (nonatomic, strong) NSMutableArray *srcStringArray;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) BOOL isCollection;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) BOOL highQuality;
@property (nonatomic, copy) BlockReturn blockReturn;

- (void)clickIndex:(int)index;

@end
