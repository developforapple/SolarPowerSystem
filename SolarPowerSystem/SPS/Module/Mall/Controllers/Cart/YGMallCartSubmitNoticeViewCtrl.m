//
//  YGMallCartSubmitNoticeViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/10/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallCartSubmitNoticeViewCtrl.h"
#import "YGMallCart.h"
#import "YYText.h"

#define kDefaultFontSize 14
#define kMiniFontSize 12

@interface YGMallCartSubmitNoticeViewCtrl ()
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerWidthConstraint;


@property (weak, nonatomic) IBOutlet UIButton *selectionBtn_2; //为什么要用2 3 ？   
@property (weak, nonatomic) IBOutlet UIButton *selectionBtn_3; //因为曾经有一个1

@property (weak, nonatomic) IBOutlet YYLabel *sectionLabel_2;
@property (weak, nonatomic) IBOutlet YYLabel *sectionLabel_3;

@property (strong, nonatomic) NSArray *commodityList_2; //虚拟
@property (strong, nonatomic) NSArray *commodityList_3; //普通

@end

@implementation YGMallCartSubmitNoticeViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.commodityList_2 = [self.cart selectedCommoditiesOfType:2];
    self.commodityList_3 = [self.cart selectedCommoditiesOfType:1];
    
    [self initUI];
}

- (void)initUI
{
    self.containerWidthConstraint.constant = 240/320.f*Device_Width;
    
    self.sectionLabel_2.textVerticalAlignment = YYTextVerticalAlignmentTop;
    self.sectionLabel_3.textVerticalAlignment = YYTextVerticalAlignmentTop;
    
    self.sectionLabel_2.attributedText = [self sectionBtnTitle_2];
    self.sectionLabel_3.attributedText = [self sectionBtnTitle_3];
}

- (NSAttributedString *)sectionBtnTitle_2
{
    NSMutableAttributedString *fragment1 = [[NSMutableAttributedString alloc] initWithString:@"兑换码类商品（标签为）\n"];
    fragment1.yy_font = [UIFont systemFontOfSize:kDefaultFontSize];
    fragment1.yy_color = RGBColor(51, 51, 51, 1);
    
    NSMutableAttributedString *fragment2 = [NSMutableAttributedString yy_attachmentStringWithContent:[UIImage imageNamed:@"icon_mall_cart_exchange"] contentMode:UIViewContentModeScaleAspectFit attachmentSize:CGSizeMake(18, 12) alignToFont:[UIFont systemFontOfSize:kDefaultFontSize] alignment:YYTextVerticalAlignmentTop];
    
    NSMutableAttributedString *fragment3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%lu件",(unsigned long)self.commodityList_2.count]];
    fragment3.yy_font = [UIFont systemFontOfSize:kMiniFontSize];
    fragment3.yy_color = RGBColor(102, 102, 102, 1);
    
    [fragment1 insertAttributedString:fragment2 atIndex:fragment1.length-2];
    [fragment1 appendAttributedString:fragment3];
    
    fragment1.yy_lineSpacing = 6.f;
    
    return fragment1;
}

- (NSAttributedString *)sectionBtnTitle_3
{
    NSMutableAttributedString *fragment1 = [[NSMutableAttributedString alloc] initWithString:@"其他商品\n"];
    fragment1.yy_font = [UIFont systemFontOfSize:kDefaultFontSize];
    fragment1.yy_color = RGBColor(51, 51, 51, 1);
    
    NSMutableAttributedString *fragment3 = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"共%lu件",(unsigned long)self.commodityList_3.count]];
    fragment3.yy_font = [UIFont systemFontOfSize:kMiniFontSize];
    fragment3.yy_color = RGBColor(102, 102, 102, 1);
    
    [fragment1 appendAttributedString:fragment3];
    
    fragment1.yy_lineSpacing = 6.f;
    
    return fragment1;
}

- (IBAction)cancelBtnAction:(id)sender
{
    [self dismiss];
}

- (IBAction)doneBtnAction:(id)sender
{
    NSInteger type = self.selectionBtn_2.selected?2:(self.selectionBtn_3.selected?1:-1);
    if (type == -1) {
        [SVProgressHUD showInfoWithStatus:@"请选择商品类型"];
    }else if(self.willSubmitCommodity){
        self.willSubmitCommodity(type);
        [self dismiss];
    }
}

- (IBAction)selectionAction:(UIButton *)btn
{
    NSArray *commodityList;

    if (btn == self.selectionBtn_2){
        self.selectionBtn_2.selected = YES;
        self.selectionBtn_3.selected = NO;
        commodityList = self.commodityList_2;
    }else if (btn == self.selectionBtn_3){
        self.selectionBtn_2.selected = NO;
        self.selectionBtn_3.selected = YES;
        commodityList = self.commodityList_3;
    }
    
    if (commodityList && self.didChoiceCommodities) {
        self.didChoiceCommodities(commodityList);
    }
}

@end
