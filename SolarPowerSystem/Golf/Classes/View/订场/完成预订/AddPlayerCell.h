//
//  AddPlayerCell.h
//  Golf
//
//  Created by user on 12-11-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AddPlayerCell : UITableViewCell{
    UIImageView *_markImageView;
    UILabel *_nameLabel;
    BOOL _isSelected;
}

@property (nonatomic,strong) IBOutlet UIImageView *markImageView;
@property (nonatomic,strong) IBOutlet UILabel *nameLabel;
@property (nonatomic,assign) BOOL isSelected;

@end
