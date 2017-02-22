//
//  CityTitleView.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityTitleView : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelTitle;

@property (copy, nonatomic) BlockReturn blockReturn;

+ (CityTitleView *)nibWithName:(NSString *)name;


- (void)show;
- (IBAction)showCityList:(id)sender;

@end
