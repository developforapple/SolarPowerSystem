//
//  CourseDetailController.m
//  Golf
//
//  Created by 黄希望 on 15/5/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CourseDetailController.h"
#import "SharePackage.h"
#import "PublicCourseJoinView.h"
#import "TeachingJoinSuccessController.h"
#import "BridgeWebView.h"

@interface CourseDetailController ()

@property (nonatomic,strong) IBOutlet BridgeWebView *webView;
@property (nonatomic,strong) SharePackage *share;
@property (nonatomic,strong) TeachProductDetail *teachProductDetail;

@end

@implementation CourseDetailController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self rightButtonAction:@"分享"];;
    
    if(self.courseUrl.length>0 && self.courseName.length>0 && self.courseIntro.length>0 && self.courseImage.length>0){
        [self loadWeb];
    }else{
        [self getCourseDetail];
    }
}

- (void)loadWeb{
    NSURL * url = [NSURL URLWithString:self.courseUrl];
    NSURLRequest * request = [NSURLRequest requestWithURL:url];
    [self.webView loadRequest:request];
    
    [self.webView webviewJavaScriptImplement:self];
}

- (void)getCourseDetail{
    [[ServiceManager serviceManagerWithDelegate:self] teachingProductDetail:self.productId];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (Equal(flag, @"teaching_product_detail")) {
        if (array.count > 0) {
            self.teachProductDetail = array[0];
            self.courseName = self.teachProductDetail.productName;
            self.courseIntro = self.teachProductDetail.productIntro;
            self.courseImage = self.teachProductDetail.productImage;
            self.courseUrl = self.teachProductDetail.productDetail;
            
            [self loadWeb];
        }
    }
}

- (void)doRightNavAction{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    [GolfAppDelegate shareAppDelegate].currentController = self;
    
    if(self.courseUrl.length>0 && self.courseName.length>0 && self.courseIntro.length>0 && self.courseImage.length>0) {
        if (!self.share) {
            UIImage *image = [UIImage imageWithData:[NSData dataWithContentsOfURL:[NSURL URLWithString:self.courseImage]]];
            image = [Utilities scaleToSize:image size:CGSizeMake(100, 100)];
            self.share = [[SharePackage alloc] initWithTitle:self.courseName content:self.courseIntro img:image url:self.courseUrl];
        }
        [self.share shareInfoForView:self.view];
    }
}

@end
