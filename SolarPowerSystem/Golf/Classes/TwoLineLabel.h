//
//  TwoLineLabel.h
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TwoLineLabel : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelContent1;
@property (weak, nonatomic) IBOutlet UILabel *labelContent2;

+ (instancetype)nib;

@end
