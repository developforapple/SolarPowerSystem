//
//  YGSearchCostomBar.m
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchCustomBar.h"
#import "YGCommon.h"
#import "ReactiveCocoa.h"
#import "YGUIKitCategories.h"

const CGFloat kYGSearchCustomBarBackWidth = 32.f;

@interface YGSearchCustomBar ()<UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchBarLeftConstraint;
@property (strong, nonatomic) UIImageView *leftIconImageView;
@end

@implementation YGSearchCustomBar

- (void)updateWithType:(YGSearchType)type
{
    _type = type;
    
    [UIView animateWithDuration:.2f animations:^{
        [self updateSearchBar];
        
        // 搜索全部类型时，不显示返回。搜索单项结果时显示返回。
        BOOL backBtnVisible = !self.alwaysHiddenBackBtn && YGSearchTypeAll!=type;
        self.searchBarLeftConstraint.constant = backBtnVisible?kYGSearchCustomBarBackWidth:0.f;
        [self.backBtn setHidden:!backBtnVisible animated:YES];
        [self layoutIfNeeded];
    }];
}

- (void)updateSearchBar
{
    if (self.type == YGSearchTypeAll && self.defaultPlaceholder.length > 0) {
        self.searchBar.placeholder = self.defaultPlaceholder;
    }else{
        self.searchBar.placeholder = [NSString stringWithFormat:@"搜索%@",SearchTitleOfType(self.type)];
    }
    [self.searchBar setImage:[UIImage imageNamed:SearchSmallIconNameOfType(self.type)] forSearchBarIcon:UISearchBarIconSearch state:UIControlStateNormal];
}

- (NSString *)keywords
{
    NSString *text = [self.searchBar.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (text.length == 0) {
        text = self.defaultPlaceholder;
    }
    return text;
}

#pragma mark - Action
- (IBAction)back:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(searchCustomBarWillBack)]) {
        [self.delegate searchCustomBarWillBack];
    }
}

#pragma mark - UISearchBar
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText
{
    if ([self.delegate respondsToSelector:@selector(searchCustomBarTextDidChanged:)]) {
        [self.delegate searchCustomBarTextDidChanged:searchText];
    }
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    [searchBar endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(searchCustomBarWillSearch)]) {
        [self.delegate searchCustomBarWillSearch];
    }
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar
{
    [self.searchBar endEditing:YES];
    if ([self.delegate respondsToSelector:@selector(searchCustomBarWillCancel)]) {
        [self.delegate searchCustomBarWillCancel];
    }
}

@end
