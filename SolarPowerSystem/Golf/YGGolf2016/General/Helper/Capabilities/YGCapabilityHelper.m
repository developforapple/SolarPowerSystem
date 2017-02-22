//
//  YGCapabilityHelper.m
//  Golf
//
//  Created by bo wang on 16/8/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGCapabilityHelper.h"
#import "CCAlertView.h"

@implementation YGCapabilityHelper

+ (void)call:(NSString *)phoneNumber
{
    return [self call:phoneNumber needConfirm:NO];
}

+ (void)call:(NSString *)phoneNumber needConfirm:(BOOL)needConfirm
{
    NSMutableString *phone = [NSMutableString stringWithFormat:@"tel://%@",phoneNumber];
    [phone stringByReplacingOccurrencesOfString:@" " withString:@""];
    [phone stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSURL *URL = [NSURL URLWithString:phone];
    
    if (!URL) {
        [SVProgressHUD showInfoWithStatus:@"无效的电话号码"];
    }else if(![[UIApplication sharedApplication] canOpenURL:URL]){
        [SVProgressHUD showInfoWithStatus:@"设备无法拨打电话"];
    }else{
        if (!needConfirm) {
            [[UIApplication sharedApplication] openURL:URL];
        }else{
            CCAlertView *alert = [[CCAlertView alloc] initWithTitle:@"" message:[NSString stringWithFormat:@"呼叫 %@",phoneNumber]];
            [alert addButtonWithTitle:@"取消" block:nil];
            [alert addButtonWithTitle:@"呼叫" block:^{
                [[UIApplication sharedApplication] openURL:URL];
            }];
            [alert show];
        }
    }
}

@end
