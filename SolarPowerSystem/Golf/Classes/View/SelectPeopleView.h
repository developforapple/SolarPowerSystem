//
//  SelectPeopleView.h
//  Golf
//
//  Created by 黄希望 on 13-12-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SelectPeopleViewDelegate <NSObject>

- (void)selectPeopleViewDelegateWithCount:(int)count;

@end

@interface SelectPeopleView : UIView{
    IBOutlet UIButton *decreaseBtn;
    IBOutlet UIButton *peopleBtn;
    IBOutlet UIButton *addBtn;
    int _peopleCount;
    int _ID;
    int _remainMans;
    int _minBuyQuantity;
}

@property (nonatomic,weak) id<SelectPeopleViewDelegate> delegate;

- (void) selectPeopleWithRemainMans:(int)remainMans minBuyQuantity:(int)minBuyQuantity curMans:(int)curMans;

- (IBAction)clickAction:(id)sender;

@end
