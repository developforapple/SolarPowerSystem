//
//  YGOrderCell.m
//  Golf
//
//  Created by bo wang on 2016/10/28.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGOrderCell.h"
#import "YGOrderCommon.h"
#import "YGOrderListViewCtrl.h"

#define kStrongPriority 951
#define kWeakPriority 949

@interface YGOrderCell ()
@property (strong, readwrite, nonatomic) id order;
@end

@implementation YGOrderCell

+ (void)registerInTableView:(UITableView *)tableView
{
    @try {
        NSString *name = NSStringFromClass([self class]);
        [tableView registerNib:[UINib nibWithNibName:name bundle:[NSBundle mainBundle]] forCellReuseIdentifier:name];
    } @catch (NSException *exception) {}
}

+ (Class)validClass:(Class)cls
{
    return (cls && [cls isSubclassOfClass:[self class]])?cls:nil;
}

+ (CGFloat)estimatedRowHeight
{
    return 180.f;
}

- (id)order
{
    return _order;
}

- (void)configureWithOrder:(id)order
{
    _order = order;
    
    [self configureStatusPanel];
    [self configureContentPanel];
    [self configureActionPanel];
}

- (void)configureStatusPanel
{}

- (void)configureContentPanel
{}

- (void)configureActionPanel
{
    self.showOrderListBtn.hidden = !self.inManagerList;
    if (self.inManagerList) {
        YGOrderType type = typeOfOrder(self.order);
        [self.showOrderListBtn setTitle:getOrderTitle(type) forState:UIControlStateNormal];
    }
}

- (void)setSubPricePanelVisible:(BOOL)visible
{
    _subPricePanelVisible = visible;
    self.subPricePanel.hidden = !visible;
    self.subPricePanel.verticalZero_ = !visible;
}

- (void)setDeleteBtnVisible:(BOOL)visible
{
    _deleteBtnVisible = visible;
    self.deleteBtn.hidden = !visible;
    self.actionBtnRightToSuperConstraint.priority = visible?kWeakPriority:kStrongPriority;
}

- (void)setActionPanelVisible:(BOOL)actionPanelVisible
{
    _actionPanelVisible = actionPanelVisible;
    self.actionPanel.hidden = !self.actionPanelVisible;
    self.actionPanelHeightConstraint.constant = self.actionPanelVisible?52.f:12.f;
}

- (IBAction)showOrderListAction:(UIButton *)btn
{
    YGOrderListViewCtrl *vc = [YGOrderListViewCtrl instanceFromStoryboard];
    vc.orderType = typeOfOrder(self.order);
    [[self viewController].navigationController pushViewController:vc animated:YES];
}

- (IBAction)actionBtn1Action:(UIButton *)btn{}
- (IBAction)deleteBtnAction:(UIButton *)btn{}
@end

@interface _YGOrderActionBtn ()
{
    BOOL _touchBtnHighlighted;
    BOOL _touchBtnSelected;
}
@end

@implementation _YGOrderActionBtn

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    _touchBtnHighlighted = self.highlighted;
    _touchBtnSelected = self.selected;
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    return [super continueTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [super endTrackingWithTouch:touch withEvent:event];
    RunAfter(.1f, ^{
        self.highlighted = _touchBtnHighlighted;
        self.selected = _touchBtnSelected;
    });
}

- (void)cancelTrackingWithEvent:(UIEvent *)event
{
    [super cancelTrackingWithEvent:event];
    RunAfter(.1f, ^{
        self.highlighted = _touchBtnHighlighted;
        self.selected = _touchBtnSelected;
    });
}

@end
