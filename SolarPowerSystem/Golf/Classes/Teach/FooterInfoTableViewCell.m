//
//  FooterInfoTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "FooterInfoTableViewCell.h"
#import "CCAlertView.h"

@interface FooterInfoTableViewCell()
@end

@implementation FooterInfoTableViewCell

- (IBAction)btnCallPhone:(id)sender {
    if (_mobilePhone.length > 0) {
        CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"呼叫 %@",_mobilePhone]];
        [alert addButtonWithTitle:@"取消" block:nil];
        [alert addButtonWithTitle:@"呼叫" block:^{
            [[BaiduMobStat defaultStat] logEvent:@"btnReservationDetailPhone" eventLabel:@"预约详情电话点击"];
            [MobClick event:@"btnReservationDetailPhone" label:@"预约详情电话点击"];
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"tel://%@",_mobilePhone]]];
        }];
        [alert show];
    }
}

@end
