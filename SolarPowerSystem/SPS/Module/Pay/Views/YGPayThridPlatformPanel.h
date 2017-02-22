//
//  YGPayThridPlatformPanel.h
//  Golf
//
//  Created by bo wang on 2016/12/2.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@class YGPayThirdPlatformPanelConfig;

UIKIT_EXTERN CGFloat kYGPayThirdPlatformPanelHeight;

@interface YGPayThridPlatformPanel : UIView

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) YGPayThirdPlatformPanelConfig *config;

- (void)updateWithConfig:(YGPayThirdPlatformPanelConfig *)cofig;

// 当前选中的平台。如果为nil，则一个都没选中
@property (assign, nonatomic) NSNumber *curPlatform;
// 选中的平台发生了变化时的回调
@property (copy, nonatomic) void (^selectedPlatformDidChangedCallback)(NSNumber *platform);

// 内容高度发生变化时的回调。通知外部调整容器高度。 和 kYGPayThirdPlatformPanelHeight 的值一致
@property (copy, nonatomic) void (^shouldAdjustHeightCallback)(CGFloat height);

@end


@interface YGPayThirdPlatformPanelConfig : NSObject
// 默认显示的个数。默认值3
@property (assign, nonatomic) NSInteger defaultVisibleCount;
// 当前是否显示更多按钮。
@property (assign, nonatomic) BOOL moreBtnHidden;
// 全部可显示的平台
@property (strong, nonatomic) NSArray<NSNumber *> *platforms;
@end
