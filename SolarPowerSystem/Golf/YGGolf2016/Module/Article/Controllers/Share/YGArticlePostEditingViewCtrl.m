//
//  YGArticlePostEditingViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/6/24.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticlePostEditingViewCtrl.h"
#import "YGThriftInclude.h"
#import "SelectClubViewController.h"

@interface YGArticlePostEditingViewCtrl ()
@property (weak, nonatomic) IBOutlet UIButton *submitBtn;
@property (weak, nonatomic) IBOutlet UIView *articleContainer;
@property (weak, nonatomic) IBOutlet UIImageView *articleImageView;
@property (weak, nonatomic) IBOutlet UILabel *articleTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *locationContainer;
@property (weak, nonatomic) IBOutlet UIButton *locationBtn;

@property (strong, nonatomic) Location *location;
@property (strong, nonatomic) Course *course;

@end

@implementation YGArticlePostEditingViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initData];
    [self initUI];
    [self initSignal];
}

#pragma mark - init
- (void)initData
{
    self.location = [Location new];
    NSString *locality = [GolfAppDelegate shareAppDelegate].locality;
    if (locality.length > 0) {
        self.location.location = locality;
    }
    self.location.longitude = [[LoginManager sharedManager] currLongitudeString];
    self.location.latitude = [[LoginManager sharedManager] currLatitudeString];
    
    self.course = [Course new];
    self.course.courseId = -2;
    self.course.courseName = locality;
}

- (void)initUI
{
    if (self.article) {
        YueduArticleImageBean *image = [self.article.pictures firstObject];
        [self.articleImageView sd_setImageWithURL:[NSURL URLWithString:image.name]];
        self.articleTitleLabel.text = self.article.name;
    }else if(self.album){
        YueduArticleImageBean *image = self.album.cover;
        [self.articleImageView sd_setImageWithURL:[NSURL URLWithString:image.name]];
        self.articleTitleLabel.text = self.album.name;
    }
}

- (void)initSignal
{
    ygweakify(self);
    [RACObserve(self.location, location)
     subscribeNext:^(NSString *x) {
         ygstrongify(self);
         [self.locationBtn setTitle:x?:@"所在位置" forState:UIControlStateNormal];
     }];
    
   
    // 提交按钮事件
    [[[self.submitBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     doNext:^(UIButton *x) {
         x.enabled = NO;
     }]
     subscribeNext:^(id x) {
         ygstrongify(self);
         self.status = YGKeyboardStatusHidden;
         [self submit];
     }];
    
    
    // 位置按钮事件
    [[[self.locationBtn rac_signalForControlEvents:UIControlEventTouchUpInside]
     doNext:^(UIButton *x) {
         x.enabled = NO;
     }]          
     subscribeNext:^(UIButton *x) {
         ygstrongify(self);
         [self choiceLocatiton];
         x.enabled = YES;
     }];
}

#pragma mark - Actions
- (void)submit
{
    NSString *text = self.textView.text;
    if (text.length > self.maxLength) {
        text = [text substringToIndex:self.maxLength];
    }
    
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    [SVProgressHUD show];
    [YGRequest postYueduToFeed:@(self.article.id)
                       orAlbum:@(self.album.id)
                       content:text
                      location:self.location
                        clubid:@(self.course.courseId)
                       success:^(BOOL suc, id object) {
                           if (suc) {
                               [SVProgressHUD showImage:[UIImage imageNamed:@"icon_share_success"] status:@"发布完成"];
                               [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicList" object:nil];
                               RunAfter(1.f, ^{
                                   [self.navigationController popViewControllerAnimated:YES];
                               });
                           }else{
                               AckBean *ack = object;
                               [SVProgressHUD showInfoWithStatus:ack.err.errorMsg];
                           }
                       }
                       failure:^(Error *err) {
                           [SVProgressHUD showInfoWithStatus:@"当前网络不可用"];
                       }];
    
    //分享到动态的埋点统计
    YGPostBuriedPoint(YGYueduStatistics_ShareFeed);
    YGRecordEvent(YueduEvent_PostFeed, nil);
    self.submitBtn.enabled = YES;
}

- (void)choiceLocatiton
{
    self.status = YGKeyboardStatusHidden;
    
    SelectClubViewController *vc = [SelectClubViewController instanceFromStoryboard];
    vc.isTopicLocation = YES;
    vc.currentModel = self.course;
    [vc setSelectedClubBlock:^(CourseBean *data) {
        self.course.courseId = data.courseId;
        self.course.courseName = data.courseName;
        if (data.courseId == -1) {
            self.location.location = nil;
        }else{
            self.location.location = data.courseName;
        }
    }];
    [self.navigationController pushViewController:vc animated:YES];
}

- (IBAction)exit:(UIBarButtonItem *)item
{
    self.status = YGKeyboardStatusHidden;
    [self.navigationController popViewControllerAnimated:YES];
}

@end
