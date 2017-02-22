//
//  YGYueduImageDescView.m
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGYueduImageDescView.h"
#import "yueduService.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@interface YGYueduImageDescView ()
{
    CGFloat _scrollLimitOffsetY;
}
@end

@implementation YGYueduImageDescView

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.descLabel.preferredMaxLayoutWidth = Device_Width-30.f;
    self.descLabel.textAlignment = NSTextAlignmentJustified;
    self.contentWidthConstraint.constant = Device_Width;
    
    ygweakify(self);
    [RACObserve(self, contentOffset)
     subscribeNext:^(NSValue *x) {
         ygstrongify(self);
         CGPoint offset = [x CGPointValue];
         
         // 上拉时设定没有反弹效果
         if (offset.y > self->_scrollLimitOffsetY) {
             [self setContentOffset:CGPointMake(0, self->_scrollLimitOffsetY) animated:NO];
         }
     }];
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event
{
    UIView *view = [super hitTest:point withEvent:event];
    if (view == self) {
        // 在descView范围之外的触摸事件都传递给 图片缩放的 scrollView
        return self.imageZoomScrollView;
    }
    return view;
}

- (void)updateToIndex:(NSUInteger)index
{
    NSUInteger picturesCount = self.articleBean.pictures.count;
    self.indexLabel.text = [NSString stringWithFormat:@"%ld/%ld",(unsigned long)index+1,(unsigned long)picturesCount];
    self.titleLabel.text = self.articleBean.name;
    
    static CGFloat defaultHeight;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        defaultHeight = self.heightConstraint.constant;
    });
    
    YueduArticleImageBean *imageBean = self.articleBean.pictures[index];
    self.descLabel.text = imageBean.desc;
    
    CGSize size = [self.descView systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
    
    CGFloat targetHeight = size.height;
 
    if (targetHeight > defaultHeight) {
        CGFloat diff = targetHeight-defaultHeight;
        self.heightConstraint.constant = targetHeight;
        self.contentSize = CGSizeMake(Device_Width, targetHeight+diff);
        self.descViewTopConstraint.constant = diff;
        self->_scrollLimitOffsetY = diff;
    }else{
        self.heightConstraint.constant = defaultHeight;
        self.contentSize = CGSizeMake(Device_Width, size.height);
        self.descViewTopConstraint.constant = 0.f;
        self->_scrollLimitOffsetY = 0;
    }
    [self layoutIfNeeded];
}

@end
