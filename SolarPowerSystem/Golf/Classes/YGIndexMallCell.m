//
//  YGIndexMallCell.m
//  Golf
//
//  Created by bo wang on 2016/11/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGIndexMallCell.h"
//#import "YGIndexMallViewModel.h"
#import "YGMallHotSellListViewCtrl.h"

@interface _YGIndexMallUnit : UIView
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (copy, nonatomic) void (^unitAction)(_YGIndexMallUnit *unit);
@property (strong, nonatomic) ThemeCommodityBean *bean;
@end

@implementation _YGIndexMallUnit

- (void)setBean:(ThemeCommodityBean *)bean
{
    _bean = bean;
    
    [Utilities loadImageWithURL:[NSURL URLWithString:bean.photoImage] inImageView:self.imageView placeholderImage:[UIImage imageNamed:@"default_"] changeContentMode:YES];
    
    self.titleLabel.text = bean.themeName;
    self.subTitleLabel.text = bean.subTitle;
}

- (IBAction)btnAction:(id)sender
{
    if (self.unitAction) {
        self.unitAction(self);
    }
}

@end

NSString *const kYGIndexMallCell = @"YGIndexMallCell";

@interface YGIndexMallCell ()
@property (weak, nonatomic) IBOutlet _YGIndexMallUnit *unit0;
@property (weak, nonatomic) IBOutlet _YGIndexMallUnit *unit1;
@property (weak, nonatomic) IBOutlet _YGIndexMallUnit *unit2;
@property (weak, nonatomic) IBOutlet _YGIndexMallUnit *unit3;

//@property (strong, readwrite, nonatomic) YGIndexMallViewModel *vm;

@property (strong, nonatomic) ThemeCommodityList *list;

@end

@implementation YGIndexMallCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    ygweakify(self);
    void (^unitAction)(_YGIndexMallUnit *unit) = ^(_YGIndexMallUnit *unit){
        ygstrongify(self);
        [self showCommodity:unit.bean];
    };
    self.unit0.unitAction = [unitAction copy];
    self.unit1.unitAction = [unitAction copy];
    self.unit2.unitAction = [unitAction copy];
    self.unit3.unitAction = [unitAction copy];
}

- (void)configureWithData:(ThemeCommodityList *)data
{
    if (self.list != data) {
        self.list = data;
        
        self.unit0.hidden = !data;
        self.unit1.hidden = !data;
        self.unit2.hidden = !data;
        self.unit3.hidden = !data;
    
        self.unit0.bean = [self beanAtIndex:0];
        self.unit1.bean = [self beanAtIndex:1];
        self.unit2.bean = [self beanAtIndex:2];
        self.unit3.bean = [self beanAtIndex:3];
    }
}

//- (void)configureWithViewModel:(YGIndexMallViewModel *)vm
//{
//    self.unit0.hidden = !vm;
//    self.unit1.hidden = !vm;
//    self.unit2.hidden = !vm;
//    self.unit3.hidden = !vm;
//    
//    if (!vm || vm == self.vm) return;
//    if (![vm isKindOfClass:[YGIndexMallViewModel class]]) return;
//    
//    self.vm = vm;
//    
//    self.unit0.bean = [self beanAtIndex:0];
//    self.unit1.bean = [self beanAtIndex:1];
//    self.unit2.bean = [self beanAtIndex:2];
//    self.unit3.bean = [self beanAtIndex:3];
//}

- (ThemeCommodityBean *)beanAtIndex:(NSInteger)idx
{
    if (idx < self.list.themeCommodityList.count) {
        return self.list.themeCommodityList[idx];
    }
    return nil;
    
//    if (idx < self.vm.commodityList.count) {
//        return self.vm.commodityList[idx];
//    }
//    return nil;
}

- (void)showCommodity:(ThemeCommodityBean *)bean
{
    [[API shareInstance] statisticalNewWithBuriedpoint:29 objectID:0 Success:nil failure:nil];
    
    YGMallHotSellListViewCtrl *vc = [YGMallHotSellListViewCtrl instanceFromStoryboard];
    vc.themeId = bean.themeId;
    vc.title = bean.themeName;
    vc.feedbackInvisible = YES;
    [[[self viewController] navigationController] pushViewController:vc animated:YES];
}

@end
