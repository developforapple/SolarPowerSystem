

#import "YGMallHotThemeCell.h"
#import "YGMallHotSellListViewCtrl.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation YGMallHotThemeUnit
- (IBAction)btnAction:(UIButton *)btn
{
    if (self.theme) {
        YGPostBuriedPoint(self.tag);
        YGMallHotSellListViewCtrl *vc = [YGMallHotSellListViewCtrl instanceFromStoryboard];
        vc.title = self.theme.theme_name;
        vc.themeId = self.theme.theme_id;
        [[self viewController].navigationController pushViewController:vc animated:YES];
    }
}

- (void)setTheme:(YGMallThemeModel *)theme
{
    _theme = theme;
    if (theme) {
        self.mainTitleLabel.text = theme.theme_name;
        self.subTitleLabel.text = theme.subtitle;
        [self.photoImageView sd_setImageWithURL:[NSURL URLWithString:theme.photo_image] placeholderImage:[UIImage imageNamed:@"cgit_s"]];
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}

@end

NSString *const kYGMallHotThemeCell = @"YGMallHotThemeCell";

@interface YGMallHotThemeCell ()
@property (strong, nonatomic) IBOutletCollection(YGMallHotThemeUnit) NSArray *units;
@property (nonatomic,weak) IBOutlet UIView *lineView;
@end

@implementation YGMallHotThemeCell

- (void)setHideLine:(BOOL)hideLine
{
    _lineView.hidden = hideLine;
}

- (void)setThemes:(NSArray *)themes
{
    _themes = themes;
    YGMallPoint p = self.startPoint;
    for (YGMallHotThemeUnit *unit in self.units) {
        NSInteger idx = [self.units indexOfObject:unit];
        if (idx < themes.count) {
            unit.theme = themes[idx];
        }else{
            unit.theme = nil;
        }
        unit.tag = p++;
    }
}


@end
