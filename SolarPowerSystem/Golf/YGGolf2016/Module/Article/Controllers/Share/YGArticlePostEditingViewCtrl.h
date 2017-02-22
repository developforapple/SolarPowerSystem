//
//  YGArticlePostEditingViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/6/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGEmojiKeyboardViewCtrl.h"

@class YueduArticleBean;
@class YueduAlbumBean;

@interface YGArticlePostEditingViewCtrl : YGEmojiKeyboardViewCtrl

@property (strong, nonatomic) YueduArticleBean *article;
@property (strong, nonatomic) YueduAlbumBean *album;

@end
