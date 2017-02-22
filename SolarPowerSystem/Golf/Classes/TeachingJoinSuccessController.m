//
//  TeachingJoinSuccessController.m
//  Golf
//
//  Created by 黄希望 on 15/5/14.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachingJoinSuccessController.h"
#import "SharePackage.h"
#import "PublicCourseDetailController.h"

@interface TeachingJoinSuccessController()

@property (nonatomic,weak) IBOutlet UIImageView *photoImageV;
@property (nonatomic,strong) SharePackage *share;
@property (nonatomic,strong) TeachProductDetail *detail;
@property (nonatomic,strong) UIImage *photoImage;
@property (nonatomic,weak) IBOutlet UIButton *shareBtn;

@end

@implementation TeachingJoinSuccessController

- (void)viewDidLoad{
    [super viewDidLoad];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUBLIC_COURSE_JOIN_REFRESH" object:nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"PUBLIC_COURSE_OBSERVER_REFRESH" object:nil];
    });
    
    for (NSLayoutConstraint *c in self.view.constraints) {
        if (c.firstAttribute == NSLayoutAttributeTop && c.firstItem == _shareBtn) {
            if (Device_Height == 480) {
                c.constant = 330;
            }else if (Device_Height == 568){
                c.constant = 410;
            }else if (Device_Height == 667){
                c.constant = 490;
            }else{
                c.constant = 550;
            }
            [self.view layoutIfNeeded];
        }
    }
    
    [self.photoImageV setImage:[UIImage imageNamed:@"join_success"]];
//    if (!self.shareTitle || !self.shareUrl) {
//        if (self.productId > 0) {
//            [[ServiceManager serviceManagerWithDelegate:self] teachingProductDetail:self.productId];
//        }
//    }
}

//- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
//    NSArray *array = (NSArray*)data;
//    if (Equal(flag, @"teaching_order_detail")) {
//        if (array.count > 0) {
//            self.detail = array[0];
//            
//            self.shareTitle = self.detail.productName;
//            self.shareContent = self.detail.productIntro;
//            self.shareImage = self.detail.productImage;
//            self.shareUrl = self.detail.productDetail;
//        }
//    }
//}

- (IBAction)shareAction:(id)sender{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    [GolfAppDelegate shareAppDelegate].currentController = self;
    if(self.shareTitle.length>0 && self.shareUrl.length>0) {
        if (!self.share) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.shareImage]]];
            if (image == nil) {
                image = [UIImage imageNamed:@"logo"];
            }
            image = [Utilities scaleToSize:image size:CGSizeMake(100, 100)];
            self.share = [[SharePackage alloc] initWithTitle:self.shareTitle content:self.shareContent img:image url:self.shareUrl];
        }
        self.share.type = 2;
        [self.share shareInfoForView:self.view];
    }
}

- (void)doLeftNavAction{
    if (!_blockReturn) {
        for (BaseNavController *basecon in self.navigationController.viewControllers) {
            if ([basecon isKindOfClass:[PublicCourseDetailController class]]) {
                [self.navigationController popToViewController:basecon animated:YES];
                break;
            }
        }
    }
    
}

-(void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    if (_blockReturn) {
        _blockReturn(nil);
    }
}

@end
