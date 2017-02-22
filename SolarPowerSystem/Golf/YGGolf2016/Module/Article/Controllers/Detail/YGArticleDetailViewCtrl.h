//
//  YGArticleDetailViewCtrl.h
//  Golf
//
//  Created by bo wang on 16/5/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGBaseViewController.h"

// 文章详情页
@interface YGArticleDetailViewCtrl : YGBaseViewController

@property (strong, nonatomic) NSNumber *articleId;

// 文章来自于一个专题内容。默认为NO
@property (assign, nonatomic) BOOL isFromAlbum;

@end
