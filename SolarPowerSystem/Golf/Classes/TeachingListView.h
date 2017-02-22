//
//  TeachingListView.h
//  test2
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TeachingListView : UIView

@property (weak, nonatomic) IBOutlet UILabel *labelDatetime;

@property (copy, nonatomic) BlockReturn blockRightPressed;
@property (copy, nonatomic) BlockReturn blockCellPressed;

- (void)loadList:(NSDictionary *)data;

@end
