//
//  LunboTableViewCell.h
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LunboTableViewCell : UITableViewCell

@property (nonatomic,strong) NSArray *tempArr;

- (void)loadDatas:(NSArray *)arr;
@end
