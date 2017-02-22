//
//  YGMallCommodityDetailDescView.m
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCommodityDetailDescView.h"
#import "DDWebViewController.h"

@interface YGMallCommodityDetailDescView () <DDWebViewControllerDelegate>
@property (strong, nonatomic) DDWebViewController *webViewCtrl;
@end

@implementation YGMallCommodityDetailDescView

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    
}

//- (void)layoutSubviews
//{
//    [super layoutSubviews];
//    self.webViewCtrl.view.frame = self.bounds;
//}
//
//- (void)setFrame:(CGRect)frame
//{
//    [super setFrame:frame];
//    self.webViewCtrl.view.frame = self.bounds;
//}

- (DDWebViewController *)webViewCtrl
{
    if (!_webViewCtrl) {
        _webViewCtrl = [DDWebViewController webViewInstance];
        _webViewCtrl.delegate = self;
        _webViewCtrl.progressViewHidden = YES;
        _webViewCtrl.scrollView.scrollEnabled = NO;
        _webViewCtrl.scrollView.scrollsToTop = NO;
        
        [self.viewCtrl addChildViewController:_webViewCtrl];
        _webViewCtrl.view.frame = self.bounds;
        [self addSubview:_webViewCtrl.view];
        
        _webViewCtrl.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        NSDictionary *views = @{@"web":_webViewCtrl.view};
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[web]-0-|" options:kNilOptions metrics:nil views:views]];
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[web]-0-|" options:kNilOptions metrics:nil views:views]];
    }
    return _webViewCtrl;
}

- (void)configureWithCommodity:(CommodityInfoModel *)commodity
{
    self.commodity = commodity;
    
    [self layoutIfNeeded];
    [self.webViewCtrl loadURL:[NSURL URLWithString:commodity.commodityDetail]];
}

- (void)updateHeigh:(CGFloat)height
{
    if (self.updateCallback) {
        self.updateCallback(height);
    }
}

- (void)webViewController:(DDWebViewController *)vc didStartLoadingURL:(NSURL *)URL
{
    ygweakify(self);
    [vc runJSCode:@"document.body.scrollHeight" completion:^(id obj, NSError *err) {
        ygstrongify(self);
        if ([obj respondsToSelector:@selector(floatValue)]) {
            [self updateHeigh:[obj floatValue]];
        }
    }];
}

- (void)webViewController:(DDWebViewController *)vc didFinishLoadingURL:(NSURL *)URL
{
    ygweakify(self);
    [vc runJSCode:@"document.body.scrollHeight" completion:^(id obj, NSError *err) {
        ygstrongify(self);
        if ([obj respondsToSelector:@selector(floatValue)]) {
            [self updateHeigh:[obj floatValue]];
        }
    }];
}

- (void)webViewController:(DDWebViewController *)vc didFailToLoadURL:(NSURL *)URL error:(NSError *)error
{
    ygweakify(self);
    [vc runJSCode:@"document.body.scrollHeight" completion:^(id obj, NSError *err) {
        ygstrongify(self);
        if ([obj respondsToSelector:@selector(floatValue)]) {
            [self updateHeigh:[obj floatValue]];
        }
    }];
}

@end
