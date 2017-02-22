//
//  CourseBuyView.h
//  Golf
//
//  Created by 廖瀚卿 on 15/5/18.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CourseBuyView : UIView

@property (copy, nonatomic) BlockReturn blockReturn;
@property (copy, nonatomic) BlockReturn blockHide;


- (void)loadData:(TeachProductDetail *)pd teachingCoachModel:(TeachingCoachModel *)tcm;
@end
