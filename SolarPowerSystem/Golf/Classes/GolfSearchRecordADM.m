//
//  GolfSearchRecordADM.m
//  Golf
//
//  Created by 黄希望 on 15/5/22.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "GolfSearchRecordADM.h"
#import "JXRecordSearchController.h"

static GolfSearchRecordADM *admInstance = nil;

@interface GolfSearchRecordADM()

@property (nonatomic,strong) JXRecordSearchController *jx;

@end

@implementation GolfSearchRecordADM

+ (void)recordListWithCacheName:(NSString*)name
                     controller:(BaseNavController*)controller
                     completion:(void(^)(id obj))completion
                clearCompletion:(void(^)(void))clearCompletion
              disappearKeyboard:(void(^)(void))disappearKeyboard{
    if (admInstance) {
        if (admInstance.jx) {
            [admInstance.jx.view removeFromSuperview];
        }
        admInstance = nil;
    }
    admInstance = [[GolfSearchRecordADM alloc] init];
    admInstance.jx = [[JXRecordSearchController alloc] initWithNibName:@"JXRecordSearchController" bundle:nil];
    admInstance.jx.cacheName = name;
    admInstance.jx.completion = completion;
    admInstance.jx.clearCompletion = clearCompletion;
    admInstance.jx.disappearKeyboard = disappearKeyboard;
    admInstance.jx.view.frame = controller.view.bounds;
    [controller.view addSubview:admInstance.jx.view];
    admInstance.jx.hide = ^(JXRecordSearchController *jx){
        if (jx) {
            [jx.view removeFromSuperview];
        }
        admInstance = nil;
    };
}

+ (void)hide{
    if (admInstance) {
        if (admInstance.jx) {
            [admInstance.jx.view removeFromSuperview];
        }
        admInstance = nil;
    }
}

@end
