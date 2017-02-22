//
//  ActionBarTableViewCell.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol YGLoginViewCtrlDelegate;

@interface ActionBarTableViewCell : UITableViewCell

@property (copy, nonatomic) BlockReturn blockHome;
@property (copy, nonatomic) BlockReturn blockChat;
@property (copy, nonatomic) BlockReturn blockAdd;

@property (strong, nonatomic) TeachingCoachModel *teachingCoachModel;

@property (weak, nonatomic) IBOutlet UIButton *btnFollowed;

@property (nonatomic,weak) id<YGLoginViewCtrlDelegate> loginDelegeate;

-(void)followed:(BOOL)followed;

@end
