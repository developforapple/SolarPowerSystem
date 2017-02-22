//
//  AwardView.h
//  Golf
//
//  Created by 黄希望 on 14-7-21.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol AwardViewDelegate <NSObject>

- (void)awardViewCallBackWithData:(AwardModel*)model;

@end

@interface AwardView : UIView{
    IBOutlet UILabel *awardCountLabel;
}

@property (nonatomic,weak) id <AwardViewDelegate> delegate;

- (IBAction)orangeBtnAction:(id)sender;
- (IBAction)whiteBtnAction:(id)sender;

+ (AwardView *)viewWithFrame:(CGRect)frame model:(AwardModel*)awardModel_ delegate:(id<AwardViewDelegate>)aDelegate;

@end
