//
//  YGRefreshHeader.h
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <MJRefresh/MJRefresh.h>

// 定制的loading
@interface YGRefreshHeader : MJRefreshGifHeader
@property (strong, nonatomic) UIImageView *loading;//如果动画做完之后还没有结束刷新，就显示这个loading
@property (assign, nonatomic) float minimumRefreshingDuration;   //最小刷新时间。当实际刷新时间小于这个值时会停留一会再结束刷新
@end

// 只有菊花
@interface YGRefreshFooter : MJRefreshAutoNormalFooter
@property (copy, nonatomic) NSString *noMoreDataNotice;
@end

typedef NS_ENUM(NSUInteger, YGRefreshType) {
    YGRefreshTypeHeader,
    YGRefreshTypeFooter,
};

typedef void(^YGRefreshCallback)(YGRefreshType type);

@interface UIScrollView (Refresh)

@property (assign, nonatomic) BOOL refreshHeaderEnable;
@property (assign, nonatomic) BOOL refreshFooterEnable;
@property (copy, nonatomic) YGRefreshCallback refreshCallback;

@property (copy, nonatomic) NSString *noMoreDataNotice;

- (void)setRefreshHeaderEnable:(BOOL)headerEnabled
                  footerEnable:(BOOL)footerEnabled
                      callback:(YGRefreshCallback)callback;

@end
