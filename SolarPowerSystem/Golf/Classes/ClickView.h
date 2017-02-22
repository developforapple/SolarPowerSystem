//
//  ClickView.h
//  Golf
//
//  Created by 黄希望 on 15/6/2.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ClickView : UIView{
    @public
    BlockReturn _respEvent;
}

@property (nonatomic,copy) BlockReturn respEvent;

@end
