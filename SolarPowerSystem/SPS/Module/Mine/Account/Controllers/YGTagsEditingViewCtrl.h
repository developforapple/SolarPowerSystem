//
//  YGTagsEditingViewCtrl.h
//  Golf
//
//  Created by 黄希望 on 14-9-22.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@protocol YGTagsEditingDelegate;

@interface YGTagsEditingViewCtrl : BaseNavController

@property (nonatomic,weak) id<YGTagsEditingDelegate> delegate;
@property (nonatomic,copy) NSString *personalTag;

@end


@protocol YGTagsEditingDelegate <NSObject>

- (void)editPersonalTagCallBack:(NSString*)callBackString identifier:(NSString*)identifier;

@end
