//
//  MyLeftViewCell.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/2.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "MDSpreadViewCell.h"

@interface MyImageViewCell : MDSpreadViewCell

@property (nonatomic, strong) UIImageView *imageHead;

- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;

@end
