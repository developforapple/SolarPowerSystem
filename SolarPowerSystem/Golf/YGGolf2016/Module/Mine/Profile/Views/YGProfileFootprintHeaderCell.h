//
//  YGProfileFootprintHeaderCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/12/10.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface YGProfileFootprintHeaderCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *labelFootprintTimes;
@property (weak, nonatomic) IBOutlet UILabel *labelClubCount;

@property (copy, nonatomic) BlockReturn blockClubTaped;
@property (copy, nonatomic) BlockReturn blockMapTaped;

@end
