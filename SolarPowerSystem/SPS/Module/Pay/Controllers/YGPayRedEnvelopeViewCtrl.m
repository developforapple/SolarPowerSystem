//
//  YGPayRedEnvelopeViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGPayRedEnvelopeViewCtrl.h"

@interface YGPayRedEnvelopeViewCtrl ()
@property (weak, nonatomic) IBOutlet UILabel *redEnvelopeTitleLabel;

@end

@implementation YGPayRedEnvelopeViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.redEnvelopeTitleLabel.text = [NSString stringWithFormat:@"恭喜您获得%ld个红包",(long)self.redEnvelopeAmount];
}

- (IBAction)sendToFriend:(id)sender
{
    if (self.sendToFriendAction) {
        self.sendToFriendAction();
    }
    [self dismiss];
}

- (IBAction)sendLeater:(id)sender
{
    [self dismiss];
}

@end
