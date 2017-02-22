//
//  MyLeftViewCell.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/2.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MyImageViewCell.h"
#import "UIView+AutoLayout.h"

@implementation MyImageViewCell

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier{
    if (self = [super initWithStyle:MDSpreadViewCellStyleDefault reuseIdentifier:reuseIdentifier]) {
        if (Device_SysVersion >= 8.0) {
            _imageHead = [UIImageView autoLayoutView];
            [self addSubview:_imageHead];
            [_imageHead pinToSuperviewEdges:(JRTViewPinAllEdges) inset:6];
        }else{
            _imageHead = [[UIImageView alloc] initWithFrame:CGRectMake(6, 6, 47 - 12, 47 - 12)];
            [self addSubview:_imageHead];
        }
        
        [_imageHead.layer setCornerRadius:(47 - 12 )/2];
        [_imageHead setClipsToBounds:YES];
        [_imageHead setContentMode:UIViewContentModeScaleAspectFill];
    }
    
    return self;
}
@end
