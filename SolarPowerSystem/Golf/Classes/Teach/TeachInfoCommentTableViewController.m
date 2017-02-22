//
//  TeachInfoCommentTableViewController.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/21.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TeachInfoCommentTableViewController.h"
#import "UIView+AutoLayout.h"
#import "YGTeachingArchiveService.h"
#import "CCAlertView.h"

#define CONTENT_MAX_COUNT 150   //字数最多150

@interface TeachInfoCommentTableViewController ()<UITextViewDelegate,ServiceManagerDelegate>

@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *btnSubmit;
@property (weak, nonatomic) IBOutlet UITextView *tvContent;
@property (weak, nonatomic) IBOutlet UILabel *labelCount;

@end

@implementation TeachInfoCommentTableViewController{
    int commentLevel;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    commentLevel = 0;
    
    _labelCount.text = [NSString stringWithFormat:@"%d字",CONTENT_MAX_COUNT];
    
    UIButton *navLeftButton = [UIButton buttonWithType:UIButtonTypeCustom];
    navLeftButton.frame = CGRectMake(0, 0, 50, 30);
    UIImage *img = [UIImage imageNamed:@"back_icon.png"];
    [navLeftButton setBackgroundImage:img forState:UIControlStateNormal];
    [navLeftButton setBackgroundImage:img forState:UIControlStateHighlighted];
    [navLeftButton addTarget:self action:@selector(doLeftNavAction) forControlEvents:UIControlEventTouchUpInside];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:navLeftButton];
    
}

- (void)doLeftNavAction
{
    if (self.navigationItem.rightBarButtonItem.enabled) {
        NSString *alertMsg = nil;
        if (self.tvContent.text && [self.tvContent.text length] > 0){
            alertMsg = @"放弃评论?";
        }
        if (alertMsg) {
            CGFloat time = 0;
            if ([self.tvContent isFirstResponder]) {
                time = 0.5;
                [self.tvContent resignFirstResponder];
            }
            
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(time * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                ygweakify(self)
                CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:alertMsg];
                [alert addButtonWithTitle:@"继续编辑" block:nil];
                [alert addButtonWithTitle:@"放弃" block:^{
                    ygstrongify(self)
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                [alert show];
                
            });
            
        } else{
            [self.tvContent resignFirstResponder];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    } else {
        [self.tvContent resignFirstResponder];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)submit:(id)sender
{
    // 提交评价
    [self _hanleSubmitComment];
}

/**
 * 提交评价
 */
-(void) _hanleSubmitComment
{
    NSString *txt = _tvContent.text;
    txt = [txt stringByTrim];
    
    if (!(txt && txt.length > 0)) {
        [SVProgressHUD showInfoWithStatus:@"请输入评价内容"];
        return;
    }
    
    [_tvContent resignFirstResponder];
    _btnSubmit.enabled = NO;
    
    if (self.classId > 0) { // 根据课程Id 评价
        [self _handleTeachInfoCommentWithClassId:txt];
        
    } else { // 根据预约Id 评价
        [self _handleTeachInfoCommentWithReservationId:txt];
        
    }
}

/**
 根据预约Id 评价

 @param txt
 */
-(void) _handleTeachInfoCommentWithReservationId:(NSString *) txt
{
    [[ServiceManager serviceManagerWithDelegate:self] addTeachingComment:txt commentLevel:commentLevel reservationId:_reservationId sessionId:[[LoginManager sharedManager] getSessionId]];
}

/**
 根据课程Id评价

 @param txt
 */
-(void)_handleTeachInfoCommentWithClassId:(NSString *) txt
{
    ygweakify(self)
    [[YGTeachingArchiveService new] teachingMemberCommentClassCoach:self.classId starLevel:commentLevel content:txt success:^(YGTAResultModel *resultModel) {
        ygstrongify(self)
        self.btnSubmit.enabled = YES;

        if (resultModel && resultModel.isSuccess) {
            [SVProgressHUD showSuccessWithStatus:@"评价成功"];
            if (self.blockReturn) {
                self.blockReturn(nil);
            }
        } else {
            [SVProgressHUD showErrorWithStatus:@"评价失败"];
            
        }
        
    } failure:^(Error *error) {
        ygstrongify(self);
        self.btnSubmit.enabled = YES;
        NSString *errorMsg = error.errorMsg;
        errorMsg = @"评价失败";
        if (errorMsg && [errorMsg length] > 0) {
            [SVProgressHUD showErrorWithStatus:errorMsg];
        }
        
    }];
}

- (void)serviceResult:(ServiceManager*)serviceManager Data:(id)d flag:(NSString*)flag
{
    NSArray *arr = (NSArray *)d;
    if (Equal(flag, @"teaching_comment_add")) {
        _btnSubmit.enabled = YES;
        NSNumber *n = [arr firstObject];
        if (n == 0) {
            return;
        }
        [SVProgressHUD showSuccessWithStatus:@"评价成功"];
        
        if (_data != nil) {
            ReservationModel *m = _data[@"data"];
            m.reservationStatus = 2;
            m.commentContent = _tvContent.text;
            [_data setValue:m forKey:@"data"];
        }
        if (_blockReturn) {
            _blockReturn(_data);
        }
    }
}

- (IBAction)btnPressed:(UIButton *)btn
{
    int tag = [@(btn.tag) intValue];
    [self starLevel:tag];
    
    commentLevel = tag;
    _btnSubmit.enabled = YES;
}

- (void)starLevel:(int)starLevel
{
    [Utilities changeView:_imgStar width:165.0/5 * starLevel];
}

#pragma mark - 
#pragma mark - UITextViewDelegate

- (void)textViewDidChange:(UITextView *)textView
{
    NSInteger number = [textView.text length];
    if (number > CONTENT_MAX_COUNT) {
        textView.text = [textView.text substringToIndex:CONTENT_MAX_COUNT];
        number = CONTENT_MAX_COUNT;
    }
    self.labelCount.text = [NSString stringWithFormat:@"%tu字",CONTENT_MAX_COUNT - number];
}



@end
