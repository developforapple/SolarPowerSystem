//
//  MyGrayViewCell.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/3.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MDSpreadViewCell.h"

typedef NS_ENUM(NSInteger, ColorType) {
    ColorTypeGray = 0,
    ColorTypeBlack
};

@interface MyGrayViewCell : MDSpreadViewCell

@property (nonatomic) ColorType colorType;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
