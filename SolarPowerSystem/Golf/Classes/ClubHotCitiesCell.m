//
//  ClubHotCitiesCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubHotCitiesCell.h"
#import "MyButton.h"

@interface ClubHotCitiesCell ()

@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *cityBtns;
@property (nonatomic,strong) NSArray *hotCities;
@end

@implementation ClubHotCitiesCell

-(void)loadHotCities:(NSArray *)hotCities reload:(BOOL)flag{
    _hotCities = hotCities;
    if (_hotCities.count > 0 && flag == YES) {
        for (MyButton *button in self.cityBtns) {
            if (button.tag-1<_hotCities.count) {
                SearchCityModel *city = _hotCities[button.tag-1];
                [button setAttributedTitle:[self setHotCItyButtonsTitle:city] forState:UIControlStateNormal];
                button.dataExtra = city;
            }
        }
    }
}


- (NSAttributedString*)setHotCItyButtonsTitle:(SearchCityModel*)city{
    NSMutableAttributedString *cn;
    if (city) {
        cn = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@",city.cityName]];
        [cn addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"333333"],NSFontAttributeName:[UIFont systemFontOfSize:14]} range:NSMakeRange(0, city.cityName.length)];
        NSString *c = [NSString stringWithFormat:@"/%d",city.clubCount];
        NSMutableAttributedString *count = [[NSMutableAttributedString alloc] initWithString:c];
        [count addAttributes:@{NSForegroundColorAttributeName:[UIColor colorWithHexString:@"999999"],NSFontAttributeName:[UIFont systemFontOfSize:11]} range:NSMakeRange(0, c.length)];
        [cn appendAttributedString:count];
    }
    return cn;
}

- (IBAction)hotCityClickAction:(MyButton*)sender{
    if (_hotCityBlock) {
        _hotCityBlock (sender.dataExtra);
    }
}

@end
