//
//  KDScrollView.h
//  Golf
//
//  Created by 黄希望 on 14-1-20.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class KDScrollView;
@protocol KDScrollViewDataSource <NSObject>

- (UIImageView *)infiniteImgView:(KDScrollView *)kscrollview forIndex:(NSInteger)index;
- (NSUInteger)numberOfInfiniteImgs;
- (void)handleAction:(int)direction;
- (void)touchWithStatus:(int)status;

@end

@interface KDScrollView : UIScrollView<UIScrollViewDelegate>

@property (nonatomic,strong) NSMutableArray *visibleImg;
@property (nonatomic,strong) NSMutableArray *imgReusableQueue;
@property (nonatomic) CGFloat pageWidth;
@property (nonatomic) NSInteger currentIndex;
@property (nonatomic,weak) IBOutlet id<KDScrollViewDataSource> aDataSource;

- (id)dequeueReusableImg;

@end
