

#import <UIKit/UIKit.h>

@protocol YGMallSlideSwitchViewDelegate;
@interface YGMallSlideSwitchView : UIView<UIScrollViewDelegate>{
    BOOL _isBuildUI;                                //是否建立了ui
    UIImageView *_hengxianImg;
}

@property (nonatomic) CGFloat heightOfTopScrollView;
@property (nonatomic) CGFloat widthOfButtonMargin;
@property (nonatomic, strong) UIScrollView *rootScrollView;
@property (nonatomic, strong) UIScrollView *topScrollView;
@property (nonatomic) CGFloat userContentOffsetX;
@property (nonatomic) NSInteger userSelectedChannelID;
@property (nonatomic) NSInteger scrollViewSelectedChannelID;
@property (nonatomic, weak) id<YGMallSlideSwitchViewDelegate> slideSwitchViewDelegate;
@property (nonatomic, strong) UIColor *tabItemNormalColor;
@property (nonatomic, strong) UIColor *tabItemSelectedColor;
@property (nonatomic, strong) UIImage *tabItemNormalBackgroundImage;
@property (nonatomic, strong) UIImage *tabItemSelectedBackgroundImage;
@property (nonatomic, strong) UIImageView *shadowImageView;
@property (nonatomic, strong) NSMutableArray *viewArray;
@property (nonatomic) NSInteger selectViewControllerIndex;
@property (nonatomic) BOOL isCommodityList;


- (void)buildUI;
- (void)setButtonsName:(NSArray*)nameArray;
- (void)changeViewWithIndex:(NSInteger)index;

- (CGFloat)topPanelHeight;

@end

@protocol YGMallSlideSwitchViewDelegate <NSObject>

@required

- (NSUInteger)numberOfTab:(YGMallSlideSwitchView *)view;

- (UIViewController *)slideSwitchView:(YGMallSlideSwitchView *)view viewOfTab:(NSUInteger)number;

@optional

- (void)slideSwitchView:(YGMallSlideSwitchView *)view panLeftEdge:(UIPanGestureRecognizer*) panParam;

- (void)slideSwitchView:(YGMallSlideSwitchView *)view panRightEdge:(UIPanGestureRecognizer*) panParam;

- (void)slideSwitchView:(YGMallSlideSwitchView *)view didselectTab:(NSUInteger)number;

@end
