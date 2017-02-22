//
//  YGLoginViewCtrlDelegate.h
//  Golf
//
//  Created by bo wang on 2016/12/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YGLoginViewCtrlDelegate <NSObject>
@optional
- (void)loginButtonPressed:(id)sender;
- (void)loginFinishHandle;
- (void)backToHome;
@end
