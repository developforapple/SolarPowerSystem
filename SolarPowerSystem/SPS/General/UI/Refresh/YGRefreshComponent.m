//
//  YGRefreshHeader.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGRefreshComponent.h"
#import "UIImageView+RefreshGifCategory.h"

static NSArray<UIImage *> *progressImages;  //进度动画
static NSArray<UIImage *> *pullingImages;   //等待刷新的图片
static NSArray<UIImage *> *gifImages;       //播放gif的动画
static NSArray<UIImage *> *loadingImages;   //播放gif完成后的loading

@interface YGRefreshHeader ()
{
    NSTimeInterval _startTime;
    BOOL _flag;
}
@end

@implementation YGRefreshHeader

- (void)prepare
{
    [super prepare];
    
    self.lastUpdatedTimeLabel.hidden = YES;
    self.stateLabel.hidden = YES;
    self.gifView.hidden = YES;
    self.minimumRefreshingDuration = 0.8f;
    self.gifView.animationRepeatCount = 1;
    
    self.loading = [[UIImageView alloc] initWithFrame:CGRectZero];
    self.loading.animationRepeatCount = 0;
    self.loading.animationDuration = 1.2f;
    self.loading.hidden = YES;
    [self addSubview:self.loading];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *(^loading)(NSUInteger from,NSUInteger to) = ^NSArray*(NSUInteger from,NSUInteger to){
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Loading" ofType:@"bundle"];
            NSMutableArray *tmp = [NSMutableArray array];
            for (NSUInteger idx = from; idx <= to; idx++) {
                NSString *path = [bundlePath stringByAppendingPathComponent:[NSString stringWithFormat:@"%02lu.png",(unsigned long)idx]];
                UIImage *image = [UIImage imageWithContentsOfFile:path];
                if (image) {
                    [tmp addObject:image];
                }
            }
            return tmp;
        };
        
        progressImages = loading(1,30);
        pullingImages = loading(31,31);
        gifImages = loading(31,49);
        loadingImages = loading(100,111);
    });
    
    self.gifView.yg_animationKeepLastStatus = YES;
    self.loading.animationImages = loadingImages;
    
    [self setImages:progressImages forState:MJRefreshStateIdle];
    [self setImages:pullingImages forState:MJRefreshStatePulling];
    [self setImages:gifImages duration:self.minimumRefreshingDuration forState:MJRefreshStateRefreshing];
}

- (void)placeSubviews
{
    [super placeSubviews];
    self.loading.frame = CGRectMake(0, 0, 60, 60);
    [self.loading setCenter:CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds))];
}

- (void)setPullingPercent:(CGFloat)pullingPercent
{
    CGFloat origin = self.pullingPercent;
    
    if (pullingPercent == 0.f) {
        _flag = YES;
        [self setImages:@[] forState:MJRefreshStateIdle];
    }else if(_flag){
        _flag = NO;
        [self setImages:progressImages forState:MJRefreshStateIdle];
    }
    
    [super setPullingPercent:pullingPercent];
    if (origin > pullingPercent && pullingPercent < 0.05f) {
        RunAfter(.2f, ^{
            [self setGifViewHidden:YES];
        });
    }else if(origin != pullingPercent){
        [self setGifViewHidden:NO];
    }
}

- (void)setState:(MJRefreshState)state
{
    BOOL willStartTimer = NO;
    if (self.state != state && state == MJRefreshStateRefreshing) {
        // 记录刷新开始时间
        _startTime = [[NSDate date] timeIntervalSince1970];
        willStartTimer = YES;
    }
    
    if (self.state != state && state == MJRefreshStateIdle) {
        [UIView animateWithDuration:.2f animations:^{
            [self.gifView setHidden:YES animated:YES];
        }];
    }
    
    [self.loading stopAnimating];
    
    if (willStartTimer) {
        RunAfter(self.minimumRefreshingDuration+.2f, ^{
            //动画做完了还没有完成刷新，就隐藏gifView 显示loading
            if ([self isRefreshing]) {
                [self setGifViewHidden:YES];
                [self.loading startAnimating];
                [self.loading setHidden:NO animated:YES];
            }else{
                [self.loading stopAnimating];
                [self.loading setHidden:YES animated:YES];
            }
        });
    }
    
    [super setState:state];
}

- (void)endRefreshing
{
    NSTimeInterval endTime = [[NSDate date] timeIntervalSince1970];
    NSTimeInterval duration = endTime - _startTime;
    
    if (duration <= self.minimumRefreshingDuration) {
        NSTimeInterval delay = self.minimumRefreshingDuration - duration;
        RunAfter(delay, ^{
            [super endRefreshing];
        });
    }else{
        [super endRefreshing];
    }
}

- (void)setGifViewHidden:(BOOL)hidden
{
    if (self.gifView.hidden == hidden) return;
    
    if (!hidden) {
        self.gifView.alpha = 0.f;
        self.gifView.hidden = NO;
    }
    [UIView animateWithDuration:.2f animations:^{
        self.gifView.alpha = hidden?0.f:1.f;
    } completion:^(BOOL finished) {
        if (hidden) {
            self.gifView.hidden = YES;
            self.gifView.alpha = 1.f;
        }
    }];
}

@end

@implementation YGRefreshFooter

- (void)prepare
{
    [super prepare];
    
    self.refreshingTitleHidden = YES;
    self.triggerAutomaticallyRefreshPercent = -4.f;
    
    self.stateLabel.hidden = YES;
    [self setTitle:self.noMoreDataNotice?:@"数据已加载完毕" forState:MJRefreshStateNoMoreData];
    self.stateLabel.font = [UIFont systemFontOfSize:13];
    self.stateLabel.textColor = RGBColor(187, 187, 187, 1);
}

- (void)setNoMoreDataNotice:(NSString *)noMoreDataNotice
{
    _noMoreDataNotice = [noMoreDataNotice copy];
    [self setTitle:noMoreDataNotice?:@"数据已加载完毕" forState:MJRefreshStateNoMoreData];
}

- (void)setState:(MJRefreshState)state
{
    [super setState:state];
    [self updateStateLabelVisible];
}

- (void)scrollViewContentSizeDidChange:(NSDictionary *)change
{
    [super scrollViewContentSizeDidChange:change];
    [self updateStateLabelVisible];
}

- (void)updateStateLabelVisible
{
    CGFloat scrollViewH = CGRectGetHeight(self.scrollView.bounds);
    CGFloat y = CGRectGetMinY(self.frame);
    
    // footer必须在屏幕之外
    BOOL condition1 = y>=scrollViewH;
    // 没有更多数据
    BOOL condition2 = self.state==MJRefreshStateNoMoreData;
    
    // 满足上述两条件下才显示状态提示
    self.stateLabel.hidden = !(condition1&&condition2);
}

@end

static const void *kHeaderEnableKey = &kHeaderEnableKey;
static const void *kFooterEnableKey = &kFooterEnableKey;
static const void *kRefreshCallbackKey = &kRefreshCallbackKey;

@implementation UIScrollView (Refresh)

- (BOOL)refreshHeaderEnable
{
    return [objc_getAssociatedObject(self, kHeaderEnableKey) boolValue];
}

- (void)setRefreshHeaderEnable:(BOOL)refreshHeaderEnable
{
    objc_setAssociatedObject(self, kHeaderEnableKey, @(refreshHeaderEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!refreshHeaderEnable) {
        self.mj_header = nil;
    }else{
        ygweakify(self);
        self.mj_header = [YGRefreshHeader headerWithRefreshingBlock:^{
            ygstrongify(self);
            if (self.refreshCallback) {
                self.refreshCallback(YGRefreshTypeHeader);
            }
        }];
    }
}

- (BOOL)refreshFooterEnable
{
    return [objc_getAssociatedObject(self, kFooterEnableKey) boolValue];
}

- (void)setRefreshFooterEnable:(BOOL)refreshFooterEnable
{
    objc_setAssociatedObject(self, kFooterEnableKey, @(refreshFooterEnable), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    if (!refreshFooterEnable) {
        self.mj_footer = nil;
    }else{
        ygweakify(self);
        self.mj_footer = [YGRefreshFooter footerWithRefreshingBlock:^{
            ygstrongify(self);
            if (self.refreshCallback) {
                self.refreshCallback(YGRefreshTypeFooter);
            }
        }];
    }
}

- (void)setRefreshCallback:(YGRefreshCallback)refreshCallback
{
    objc_setAssociatedObject(self, kRefreshCallbackKey, refreshCallback, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (YGRefreshCallback)refreshCallback
{
    return objc_getAssociatedObject(self, kRefreshCallbackKey);
}

- (void)setNoMoreDataNotice:(NSString *)noMoreDataNotice
{
    YGRefreshFooter *footer = (YGRefreshFooter *)self.mj_footer;
    if ([footer isKindOfClass:[YGRefreshFooter class]]) {
        footer.noMoreDataNotice = noMoreDataNotice;
    }
}

- (NSString *)noMoreDataNotice
{
    YGRefreshFooter *footer = (YGRefreshFooter *)self.mj_footer;
    if ([footer isKindOfClass:[YGRefreshFooter class]]) {
        return footer.noMoreDataNotice;
    }
    return nil;
}

- (void)setRefreshHeaderEnable:(BOOL)headerEnabled
                  footerEnable:(BOOL)footerEnabled
                      callback:(YGRefreshCallback)callback
{
    self.refreshHeaderEnable = headerEnabled;
    self.refreshFooterEnable = footerEnabled;
    self.refreshCallback = callback;
}

@end
