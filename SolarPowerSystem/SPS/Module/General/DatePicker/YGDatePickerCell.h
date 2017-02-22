//
//  YGDatePickerCell.h
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGDatePickerCell;

@interface YGDatePickerCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@end
