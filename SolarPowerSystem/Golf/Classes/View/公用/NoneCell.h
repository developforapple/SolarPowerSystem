//
//  NoneCell.h
//  Golf
//
//  Created by user on 12-11-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NoneCell : UITableViewCell{
    UILabel *_mainTitle;
    UILabel *_subTitle;
}

@property (nonatomic,strong) UILabel *mainTitle;
@property (nonatomic,strong) UILabel *subTitle;

+ (NoneCell *) shareCell;

@end
