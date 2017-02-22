//
//  ScrollTeachTableViewCell.h
//  Golf
//
//  Created by Main on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScrollTeachTableViewCell : UITableViewCell

@property (nonatomic,copy) BlockReturn blockMore;
@property (strong, nonatomic) NSArray *datas;

- (void)loadDatas:(NSArray *)datas;


@end
