//
//  YGMallOrderCDKeyPanel.m
//  Golf
//
//  Created by bo wang on 2016/11/11.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallOrderCDKeyPanel.h"

@interface YGMallOrderCDKeyView : UIView
@property (strong, nonatomic) YGMallOrderEvidence *cdkey;
@property (strong, nonatomic) UILabel *titleLabel;
@property (strong, nonatomic) UILabel *codeLabel;
@property (strong, nonatomic) UILabel *stateLabel;
@property (assign, nonatomic) BOOL firstEvidence;
@property (assign, nonatomic) BOOL useForDate;
@end

@implementation YGMallOrderCDKeyView

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.codeLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.stateLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        
        self.titleLabel.font = self.codeLabel.font = self.stateLabel.font = [UIFont systemFontOfSize:12];
        self.titleLabel.textColor = self.codeLabel.textColor = self.stateLabel.textColor = RGBColor(153, 153, 153, 1);
        self.titleLabel.highlightedTextColor = self.codeLabel.highlightedTextColor = self.stateLabel.highlightedTextColor = MainHighlightColor;
        
        self.userInteractionEnabled = YES;
        ygweakify(self);
        [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithActionBlock:^(id sender) {
            ygstrongify(self);
            [self tapAction];
        }]];
        
        [self addSubview:self.titleLabel];
        [self addSubview:self.codeLabel];
        [self addSubview:self.stateLabel];
        
        self.firstEvidence = YES;
        self.useForDate = NO;
        
        [self setupAutoLayout];
    }
    return self;
}

- (void)setFirstEvidence:(BOOL)firstEvidence
{
    _firstEvidence = firstEvidence;
    self.titleLabel.hidden = !firstEvidence;
}

- (void)setup:(id)object
{
    if ([object isKindOfClass:[YGMallOrderEvidence class]]) {
        self.userInteractionEnabled = YES;
        self.titleLabel.text = @"兑换券:";
        self.stateLabel.hidden = NO;
        
        YGMallOrderEvidence *cdkey = object;
        self.cdkey = cdkey;
        self.codeLabel.text = cdkey.evidence_code;
        
        NSString *state;
        switch (cdkey.evidence_state) {
            case YGMallOrderEvidenceStatusUnuse: state = @"未使用";break;
            case YGMallOrderEvidenceStatusUsed: state = @"已使用";break;
            case YGMallOrderEvidenceStatusExpired: state = @"已过期";break;
        }
        self.stateLabel.text = state;
        self.stateLabel.highlighted = self.codeLabel.highlighted = cdkey.evidence_state==YGMallOrderEvidenceStatusUnuse;
    }else{
        self.userInteractionEnabled = NO;
        self.titleLabel.text = @"有效期:";
        self.codeLabel.text = object;
        self.codeLabel.highlighted = NO;
        self.stateLabel.hidden = YES;
    }
}

- (void)setupAutoLayout
{
    self.translatesAutoresizingMaskIntoConstraints = NO;
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.codeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.stateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSDictionary *views = @{@"tl":self.titleLabel,
                            @"cl":self.codeLabel,
                            @"sl":self.stateLabel};
    
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[tl]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[cl]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-0-[sl]-0-|" options:0 metrics:nil views:views]];
    [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-5-[tl(44)]-8-[cl]-8-[sl(40)]-5-|" options:0 metrics:nil views:views]];
}

- (void)tapAction
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"" message:self.cdkey.evidence_code preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"复制兑换码" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        UIPasteboard *pb = [UIPasteboard generalPasteboard];
        pb.string = self.cdkey.evidence_code;
        [SVProgressHUD showSuccessWithStatus:@"已复制"];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [[self viewController] presentViewController:alert animated:YES completion:nil];
}

@end

@interface YGMallOrderCDKeyPanel ()
@property (strong, nonatomic) CAShapeLayer *lineLayer;
@property (strong, nonatomic) NSMutableArray<YGMallOrderCDKeyView *> *cdKeyViews;
@end

@implementation YGMallOrderCDKeyPanel

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.cdKeyViews = [NSMutableArray array];
    
    self.lineLayer = [CAShapeLayer layer];
    self.lineLayer.fillColor = [UIColor clearColor].CGColor;
    self.lineLayer.strokeColor = RGBColor(167, 216, 250, 1).CGColor;
    [self.layer addSublayer:self.lineLayer];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.lineLayer.frame = CGRectMake(0, 0, CGRectGetWidth(self.frame), 1.f);
    self.lineLayer.lineJoin = kCALineJoinRound;
    self.lineLayer.lineDashPattern  = @[@4,@4];
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:CGPointMake(5.f, 0)];
    [path addLineToPoint:CGPointMake(CGRectGetWidth(self.frame)-10.f, 0)];
    self.lineLayer.path = path.CGPath;
}

- (void)setupWithCommodity:(YGMallOrderCommodity *)commodity
                   inOrder:(YGMallOrderModel *)order
{
    [self.cdKeyViews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableArray *curViews = [NSMutableArray array];
    for (YGMallOrderEvidence *evidence in commodity.evidence_list) {
        NSInteger idx = [commodity.evidence_list indexOfObject:evidence];
        YGMallOrderCDKeyView *view = [self cdKeyViewAtIndex:idx];
        [view setup:evidence];
        view.firstEvidence = idx==0;
        [curViews addObject:view];
    }
    
    YGMallOrderCDKeyView *lastView = [self cdKeyViewAtIndex:commodity.evidence_list.count];
    [lastView setup:[[commodity.evidence_list firstObject] expire_date]];
    [curViews addObject:lastView];
    
    [self setupAutoLayout:curViews];
}

- (void)setupAutoLayout:(NSArray *)views
{
    UIView *lastView;
    
    NSDictionary *metrics = @{@"sp":@(kEvidenceSpacing),
                              @"lh":@(kEvidenceUnitHeight)};
    
    for (UIView *view in views) {
        view.translatesAutoresizingMaskIntoConstraints = NO;
        if (view.superview) {
            [view removeFromSuperview];
            [view removeConstraints:view.constraints];
        }
        [self addSubview:view];
        
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        dic[@"v"] = view;
        dic[@"last"] = lastView;
        
        [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|-0-[v]-0-|" options:0 metrics:nil views:dic]];
        
        if (!lastView) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|-sp-[v(lh)]" options:0 metrics:metrics views:dic]];
        }else{
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[last]-sp-[v(lh)]" options:0 metrics:metrics views:dic]];
        }
        if (view == [views lastObject]) {
            [self addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:[v]-sp-|" options:0 metrics:metrics views:dic]];
        }
        lastView = view;
    }
}

- (YGMallOrderCDKeyView *)cdKeyViewAtIndex:(NSInteger)idx
{
    YGMallOrderCDKeyView *view;
    if (idx >= self.cdKeyViews.count) {
        view = [[YGMallOrderCDKeyView alloc] initWithFrame:CGRectZero];
        [self.cdKeyViews addObject:view];
    }else{
        view = self.cdKeyViews[idx];
    }
    return view;
}

@end
