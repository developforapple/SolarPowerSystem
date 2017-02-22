//
//  MyGrayViewCell.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MyGrayViewCell.h"
#import "UIView+AutoLayout.h"

@interface MyGrayViewCell()

@property (nonatomic, strong) UIView *colorView;

@end

@implementation MyGrayViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        
        if (Device_SysVersion >= 8.0) {
            _colorView = [UIView autoLayoutView];
             [self addSubview:_colorView];
            [_colorView pinToSuperviewEdgesWithInset:(UIEdgeInsetsMake(0, 0, .5, .5))];
        }else{
            _colorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 46.5, 46.5)];
             [self addSubview:_colorView];
        }
    }
    
    return self;
}
//
//-(void)layoutSubviews{
//    [super layoutSubviews];
//}

- (void)setColorType:(ColorType)colorType{
    _colorType = colorType;
    switch (colorType) {
        case ColorTypeBlack:
            self.colorView.backgroundColor = [UIColor colorWithRed:187/255.0 green:187/255.0 blue:187/255.0 alpha:1.0];
            break;
        case ColorTypeGray:
            self.colorView.backgroundColor = [UIColor colorWithRed:230/255.0 green:230/255.0 blue:230/255.0 alpha:1.0];
            break;
        default:
            self.colorView.backgroundColor = [UIColor whiteColor];
            break;
    }
}

@end
