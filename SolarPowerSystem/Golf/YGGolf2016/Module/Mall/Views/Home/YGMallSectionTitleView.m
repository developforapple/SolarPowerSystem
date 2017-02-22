//
//  YGMallSectionTitleView.m
//  Golf
//
//  Created by bo wang on 2016/10/18.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallSectionTitleView.h"

const CGFloat kDefaultHeaderHeight = 48.f;
NSString *const kYGMallSectionTitleView = @"YGMallSectionTitleView";

@interface YGMallSectionTitleView ()
@property (strong, readwrite, nonatomic) YGMallSectionHeaderModel *header;
@end

@implementation YGMallSectionTitleView

- (void)awakeFromNib
{
    [super awakeFromNib];
//    self.backgroundColor = [UIColor whiteColor];
//    self.contentView.backgroundColor = [UIColor whiteColor];
}

+ (void)registerIn:(UITableView *)tableView
{
    [tableView registerNib:[UINib nibWithNibName:@"YGMallSectionTitleView" bundle:nil] forHeaderFooterViewReuseIdentifier:kYGMallSectionTitleView];
}

- (void)configureWithHeader:(YGMallSectionHeaderModel *)header
{
    self.header = header;
    
    self.colorlumpView.image = [UIImage imageNamed:header.iconName];
    
//    self.colorlumpView.image = header.colorlumpImage;
//    self.colorlumpView.tintColor = header.tintColor;
    self.sectionTitleLabel.text = header.title;
    self.moreBtn.hidden = !header.showMoreBtn;
}

- (IBAction)more:(id)sender
{
    if (self.header.moreActionBlock) {
        self.header.moreActionBlock(self.header);
    }
}
@end


@implementation YGMallSectionHeaderModel

+ (instancetype)header:(YGMallSectionType)type
{
    NSString *title,*icon;
    switch (type) {
        case YGMallSectionTypeCate:
        case YGMallSectionTypeAuction: break;
        case YGMallSectionTypeBrand:{
            title = @"品牌热榜";
            icon = @"icon_mall_index_brand";
        }   break;
        case YGMallSectionTypeActivity:{
            title = @"乐活动";
            icon = @"icon_mall_index_activity";
        }   break;
        case YGMallSectionTypeTheme:{
            title = @"热主题";
            icon = @"icon_mall_index_theme";
        }   break;
        case YGMallSectionTypeCommodity:{
            title = @"偶·遇";
            icon = @"icon_mall_index_commodity";
        }   break;
    }
    YGMallSectionHeaderModel *header = [YGMallSectionHeaderModel header:type title:title icon:icon callback:nil];
    return header;
}

+ (instancetype)header:(YGMallSectionType)type
                 title:(NSString *)title
                  icon:(NSString *)iconName
              callback:(void(^)(YGMallSectionHeaderModel *))callback
{
    YGMallSectionHeaderModel *theme = [YGMallSectionHeaderModel new];
    theme.type = type;
    theme.title = title;
    theme.iconName = iconName;
    theme.moreActionBlock = callback;
    return theme;
}

+ (NSArray<YGMallSectionHeaderModel *> *)defaultSectionHeaders:(void(^)(YGMallSectionHeaderModel *header))callback
{
    NSArray *tmp = @[[YGMallSectionHeaderModel header:YGMallSectionTypeCate],
                     [YGMallSectionHeaderModel header:YGMallSectionTypeAuction],
                     [YGMallSectionHeaderModel header:YGMallSectionTypeBrand],
                     [YGMallSectionHeaderModel header:YGMallSectionTypeActivity],
                     [YGMallSectionHeaderModel header:YGMallSectionTypeTheme],
                     [YGMallSectionHeaderModel header:YGMallSectionTypeCommodity]];
    for (YGMallSectionHeaderModel *header in tmp) {
        header.moreActionBlock = callback;
    }
    return tmp;
}

@end
