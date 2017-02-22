//
//  TimeViewCell.h
//  Golf
//
//  Created by 黄希望 on 15/10/21.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimeViewCell : UITableViewCell

@property (nonatomic,assign) BOOL hasPrice;

@property (nonatomic,strong) NSArray *times;

@property (nonatomic,copy) BOOL (^scrolling) (void);


@end
