//
//  CityTitleView.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CityTitleView.h"
#import "UIView+AutoLayout.h"


@interface CityTitleView()


@property (weak, nonatomic) IBOutlet UILabel *labelTeach;
@property (weak, nonatomic) IBOutlet UIView *viewPoint;
@property (weak, nonatomic) IBOutlet UIImageView *imgArrow;

@end


@implementation CityTitleView

+ (CityTitleView *)nibWithName:(NSString *)name{
    return [[[NSBundle mainBundle] loadNibNamed:name owner:nil options:0] firstObject];
}


-(void)awakeFromNib{
    [super awakeFromNib];
    _labelTeach.alpha = 0;
    _viewPoint.alpha = 0;
    _imgArrow.alpha = 0;
}

- (IBAction)showCityList:(id)sender {
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

-(void)show{
    [UIView animateWithDuration:.4 animations:^{
        _labelTeach.alpha = 1.0;
        _viewPoint.alpha = 1.0;
        _imgArrow.alpha = 1.0;
    }];
}


@end
