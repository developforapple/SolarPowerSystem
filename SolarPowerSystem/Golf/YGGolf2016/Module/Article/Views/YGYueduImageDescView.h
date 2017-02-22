//
//  YGYueduImageDescView.h
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YueduArticleBean;

/*!
 *  @brief 图片详情页底部的描述文字View
 */
@interface YGYueduImageDescView : UIScrollView

@property (weak, nonatomic) UIScrollView *imageZoomScrollView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *heightConstraint;  //外部高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentHeightConstraint;//内部高度
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentWidthConstraint; //内部宽度

@property (weak, nonatomic) IBOutlet UIView *descView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descViewTopConstraint;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *indexLabel;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;

@property (strong, nonatomic) YueduArticleBean *articleBean;

- (void)updateToIndex:(NSUInteger)index;

@end
