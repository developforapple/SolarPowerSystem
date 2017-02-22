//
//  StarTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelRankTitle;

- (void)starLevel:(float)starLevel;

@end
