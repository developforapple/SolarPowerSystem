//
//  PackageFillCell.h
//  Golf
//
//  Created by user on 12-12-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PackageFillCell : UITableViewCell{
    IBOutlet UILabel *_titleLabel;
    IBOutlet UITextField *_textField;
    IBOutlet UILabel *_noteLabel;
}

@property (nonatomic,strong) UILabel *titleLabel;
@property (nonatomic,strong) UITextField *textField;
@property (nonatomic,strong) UILabel *noteLabel;

@end
