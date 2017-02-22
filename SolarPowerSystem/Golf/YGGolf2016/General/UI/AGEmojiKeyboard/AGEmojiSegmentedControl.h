//
//  AGEmojiSegmentedControl.h
//  Golf
//
//  Created by 廖瀚卿 on 15/10/23.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AGEmojiSegmentedControl : UIView

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;

@property (weak, nonatomic) IBOutlet UIButton *btnSend;

@property (copy, nonatomic) BlockReturn blockSendPressed;
@property (copy, nonatomic) BlockReturn blockBtnSelectChanged;


@property (nonatomic) int selectedSegmentIndex;

+ (UINib *)nib;


@end
