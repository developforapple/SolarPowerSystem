//
//  YGOrderCell.h
//  Golf
//
//  Created by bo wang on 2016/10/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YGOrderModel;

/**
 订单管理内的订单cell基类。
 */
@interface YGOrderCell : UITableViewCell

/**
 在UITableView中注册该cell。
 默认是以Class名为identieri注册xib。需要更改注册方式，请在子类中重写。
 */
+ (void)registerInTableView:(UITableView *)tableView;

+ (Class)validClass:(Class)cls;

+ (CGFloat)estimatedRowHeight;

@property (assign, nonatomic) BOOL inManagerList;
// 设置subPrice区域是否可见。YES，高度为20。NO，高度为0。默认为NO
@property (assign, readonly, nonatomic) BOOL subPricePanelVisible;
// 设置删除按钮是否可见。默认为NO
@property (assign, readonly, nonatomic) BOOL deleteBtnVisible;
// 设置actionPanel是否是可见的。YES，acitonPanel高度50。NO，actionPanel高度 12。默认为NO
@property (assign, readonly, nonatomic) BOOL actionPanelVisible;

@property (strong, readonly, nonatomic) id<YGOrderModel> order;
- (id<YGOrderModel>)order;

// 子类可重写的方法
- (void)configureWithOrder:(id)theOrder NS_REQUIRES_SUPER;
- (void)configureStatusPanel NS_REQUIRES_SUPER;
- (void)configureContentPanel NS_REQUIRES_SUPER;
- (void)configureActionPanel NS_REQUIRES_SUPER;
- (void)setSubPricePanelVisible:(BOOL)visible NS_REQUIRES_SUPER;
- (void)setActionPanelVisible:(BOOL)actionPanelVisible NS_REQUIRES_SUPER;
- (void)setDeleteBtnVisible:(BOOL)visible NS_REQUIRES_SUPER;
- (IBAction)showOrderListAction:(UIButton *)btn NS_REQUIRES_SUPER;
- (IBAction)actionBtn1Action:(UIButton *)btn NS_REQUIRES_SUPER;
- (IBAction)deleteBtnAction:(UIButton *)btn NS_REQUIRES_SUPER;

@property (weak, nonatomic) IBOutlet UIView *statusPanel;
@property (weak, nonatomic) IBOutlet UIView *contentPanel;
@property (weak, nonatomic) IBOutlet UIView *actionPanel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionPanelHeightConstraint;

// statusPanel
@property (weak, nonatomic) IBOutlet UILabel *statusLabel;
@property (weak, nonatomic) IBOutlet UIView *statusRightPanel;
@property (weak, nonatomic) IBOutlet UILabel *priceTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *subPricePanel;
@property (weak, nonatomic) IBOutlet UIView *subPriceTitlePanel;
@property (weak, nonatomic) IBOutlet UILabel *subPriceTitleLabel;

// actionPanel
@property (weak, nonatomic) IBOutlet UIButton *showOrderListBtn;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
// selected: 蓝底白字 highlight：白底蓝字蓝框 normal：白底黑字黑框
@property (weak, nonatomic) IBOutlet UIButton *actionBtn_1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *actionBtnRightToSuperConstraint;

@end

@interface _YGOrderActionBtn : UIButton
@end
