//
//  JXChooseSort.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/8.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JXChooseSort.h"
#import "JXChooseSortTableViewController.h"

#define LIST_HEIGHT 270

static JXChooseSort *instance = nil;


@interface JXChooseSort()

@property (weak, nonatomic) IBOutlet UIView *viewBg;
@property (nonatomic,copy) void(^completion)(id);
@property (nonatomic,copy) void(^showed)();
@property (nonatomic,copy) void(^hided)();

@property (nonatomic,assign) BOOL animated;
@property (nonatomic,strong) UIViewController *controller;
@end

@implementation JXChooseSort

+ (void)show:(int)sort
     supView:(UIView *)aView
belowSubview:(UIView *)siblingSubview
        posY:(CGFloat)posY
  controller:(UIViewController *)controller
  completion:(void (^)(id))completion
      showed:(void (^)())showed
       hided:(void (^)())hided{
    
    if (instance) {
        if (instance.superview) {
            [instance removeFromSuperview];
        }
        instance = nil;
    }
    
    UIControl *control = [[UIControl alloc] initWithFrame:CGRectMake(0, 0, Device_Width, Device_Height)];
    control.backgroundColor = [UIColor blackColor];
    control.alpha = 0.5;
    
    instance = [[[NSBundle mainBundle] loadNibNamed:@"JXChooseSort" owner:nil options:nil] lastObject];
    instance.frame = CGRectMake(0, posY, Device_Width, Device_Height);
    instance.viewBg.frame = CGRectMake(0, -LIST_HEIGHT, Device_Width, LIST_HEIGHT);
    JXChooseSortTableViewController *vc = [JXChooseSortTableViewController instanceFromStoryboard];
    vc.sort = sort;
    vc.blockReturn = ^(id data){
        [instance hideView:control];
        instance.completion(data);
    };
    
    vc.view.frame = CGRectMake(0, 0, Device_Width, LIST_HEIGHT);
    [instance.viewBg addSubview:vc.view];
    instance.controller = controller;
    [instance.controller addChildViewController:vc];
    
    [aView insertSubview:instance belowSubview:siblingSubview];
    
    
    [instance insertSubview:control atIndex:0];
    [control addTarget:instance action:@selector(hideView:) forControlEvents:UIControlEventTouchUpInside];
    
    instance.animated = YES;
    instance.completion = completion;
    instance.showed = showed;
    instance.hided = hided;
    [UIView animateWithDuration:0.2 animations:^{
        instance.viewBg.frame = CGRectMake(0, 0, Device_Width, LIST_HEIGHT);
        control.frame = CGRectMake(0, instance.viewBg.height - 10, Device_Width, Device_Height);
    } completion:^(BOOL finished) {
        if (instance.showed) {
            instance.showed();
        }
    }];
}

- (void)hideView:(UIControl*)control{
    
    [UIView animateWithDuration:0.2 animations:^{
        instance.viewBg.frame = CGRectMake(0, -LIST_HEIGHT, Device_Width, LIST_HEIGHT);
        control.frame = CGRectMake(0, 0, Device_Width, Device_Height);
        if (instance.hided) {
            instance.hided();
        }
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.07 animations:^{
            instance.alpha = 0.;
        } completion:^(BOOL finished) {
            [instance removeFromSuperview];
            instance = nil;
        }];
    }];
}

+ (void)hide{
    if (instance) {
        if (instance.superview) {
            [instance hideView:nil];
        }
    }
}

+ (void)hideAnimate:(BOOL)animate{
    if (instance) {
        if (instance.superview) {
            if (animate) {
                [instance hideView:nil];
            }else{
                [instance removeFromSuperview];
                if (instance.hided) {
                    instance.hided();
                }
                instance = nil;
            }
        }
    }
}

@end
