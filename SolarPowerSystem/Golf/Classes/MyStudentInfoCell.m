//
//  MyStudentInfoCell.m
//  Golf
//
//  Created by 黄希望 on 15/6/9.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "MyStudentInfoCell.h"
#import "TopicHelp.h"
#import "MyButton.h"
#import "WKDChatViewController.h"
#import "IMCore.h"
#import "YGCapabilityHelper.h"

@interface MyStudentInfoCell()<YGLoginViewCtrlDelegate>

@property (nonatomic,weak) IBOutlet UIImageView *headImageV;
@property (nonatomic,weak) IBOutlet UILabel *studentNameLabel;
@property (nonatomic,weak) IBOutlet MyButton *messageBtn;
@property (nonatomic,weak) IBOutlet MyButton *phoneBtn;
@property (nonatomic,strong) IBOutletCollection(UIView) NSArray *views;

@end

@implementation MyStudentInfoCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [Utilities drawView:_headImageV radius:30 bordLineWidth:0 borderColor:nil];
    [_messageBtn setBackgroundImage:[UIImage imageNamed:@"line_blue"] forState:UIControlStateNormal];
    [_phoneBtn setBackgroundImage:[UIImage imageNamed:@"line_blue"] forState:UIControlStateNormal];
    [Utilities drawView:_messageBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor whiteColor]];
    [Utilities drawView:_phoneBtn radius:3 bordLineWidth:0.5 borderColor:[UIColor whiteColor]];
    
    [_messageBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_phoneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_messageBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [_phoneBtn setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(clickHead:)];
    [_headImageV addGestureRecognizer:tap];
}

- (void)setStudent:(StudentModel *)student{
    _student = student;
    if (_student) {
        [_headImageV sd_setImageWithURL:[NSURL URLWithString:_student.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];

        _studentNameLabel.text = _student.nickName.length > 0 ?  _student.nickName : @" ";
        
        NSMutableArray *arr = [NSMutableArray array];
        [arr addObject:@[@"剩余课时",@(_student.remainHour)]];
        [arr addObject:@[@"待上课",@(_student.waitHour)]];
        [arr addObject:@[@"已完成",@(_student.completeHour)]];
        
        for (int i=0; i<arr.count; i++) {
            NSArray *a = arr[i];
            UIView *view = [self.contentView viewWithTag:i+1];
            view.hidden = NO;
            UILabel *titleLabel = (UILabel*)[view viewWithTag:(i+1)*10+1];
            UILabel *valueLabel = (UILabel*)[view viewWithTag:(i+1)*10+2];
            titleLabel.text = a[0];valueLabel.text = [a[1] description];
        }
    }
}

- (void)sendMessage {
//    if ([[IMCore shareInstance] isLogin]) {
         [self toChatViewController];
//    }
}

- (void)toChatViewController{
    [[BaiduMobStat defaultStat] logEvent:@"btnCoachMemberMessage" eventLabel:@"学员详情私信按钮点击"];
    [MobClick event:@"btnCoachMemberMessage" label:@"学员详情私信按钮点击"];
    WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
    chatVC.hidesBottomBarWhenPushed = YES;
    chatVC.targetImage = _headImageV.image;
    chatVC.memId = _student.memberId;
    chatVC.isFollow = _student.isFollowed;
    [[GolfAppDelegate shareAppDelegate].currentController pushViewController:chatVC title:_student.nickName hide:YES];;
}

- (IBAction)buttonPressed:(UIButton*)sender{
    if (sender.tag == 1) {
        if (![LoginManager sharedManager].loginState) {
            [[LoginManager sharedManager] loginWithDelegate:self controller:[GolfAppDelegate shareAppDelegate].currentController animate:YES];
            return;
        }
        [self sendMessage];
    }else {
        [[BaiduMobStat defaultStat] logEvent:@"btnCoachMemberPhone" eventLabel:@"学员详情电话按钮点击"];
        [MobClick event:@"btnCoachMemberPhone" label:@"学员详情电话按钮点击"];
        [YGCapabilityHelper call:self.student.mobilePhone needConfirm:YES];
    }
}

- (void)loginButtonPressed:(id)sender{
    [self sendMessage];
}

- (void)clickHead:(UITapGestureRecognizer*)tap{
    [[BaiduMobStat defaultStat] logEvent:@"btnCoachMemberHeadImage" eventLabel:@"学员详情头像点击"];
    [MobClick event:@"btnCoachMemberHeadImage" label:@"学员详情头像点击"];
    [[GolfAppDelegate shareAppDelegate].currentController toPersonalHomeControllerByMemberId:_student.memberId displayName:@"个人主页" target:[GolfAppDelegate shareAppDelegate].currentController];
    
}

@end
