//
//  CoachTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachTableViewCell.h"
#import "UIView+AutoLayout.h"

@interface CoachTableViewCell()


@property (weak, nonatomic) IBOutlet UILabel *labelName;
@property (weak, nonatomic) IBOutlet UIImageView *imgStar;
@property (weak, nonatomic) IBOutlet UILabel *labelTeachCount;
@property (weak, nonatomic) IBOutlet UILabel *labelPrice;
@property (weak, nonatomic) IBOutlet UILabel *labelKM;
@property (weak, nonatomic) IBOutlet UILabel *labelAddress;
@property (weak, nonatomic) IBOutlet UIImageView *imgAuthentication;
@property (weak, nonatomic) IBOutlet UILabel *labelUnit;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *widthConstraints;//lyf 加

@end

@implementation CoachTableViewCell{
    UIImage *defaultImage;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    defaultImage = [UIImage imageNamed:@"head_image.png"];
    [self setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
}

-(void)loadData:(TeachingCoachModel *)tcm{
    if (_tcm == nil || _tcm != tcm) {
        [Utilities loadImageWithURL:[NSURL URLWithString:tcm.headImage] inImageView:_imgHeader placeholderImage:defaultImage];
        [_labelName setText:((tcm.nickName == nil || tcm.nickName.length == 0) ? tcm.displayName:tcm.nickName)];
        [_labelTeachCount setText:[NSString stringWithFormat:@"%d次教学",tcm.teachingCount]];
        [_labelAddress setText:tcm.shortAddress];
        [_labelKM setText:[NSString stringWithFormat:@"%.2f km",tcm.distance]];
        
        [self starLevel:tcm.starLevel];
        
        if (tcm.coachLevel > 0) {
            [_labelPrice setText:[NSString stringWithFormat:@"%d起",tcm.classFee]];
            [_labelPrice setTextColor:[UIColor colorWithRed:255/255.0 green:109/255.0 blue:0 alpha:1.0]];
            _labelUnit.hidden = NO;
            _imgAuthentication.image = [UIImage imageNamed:[NSString stringWithFormat:@"ic_%da",tcm.coachLevel]];
        }else{
            [_labelPrice setText:@"暂无价格"];
            _labelUnit.hidden = YES;
            [_labelPrice setTextColor:[UIColor colorWithRed:102/255.0 green:102/255.0 blue:102/255.0 alpha:1.0]];
            [_imgAuthentication setImage:[UIImage imageNamed:@"ic_0a"]];
        }
    }else{
        
    }
    _tcm = tcm;
}

//设置星星级别  //浦发红酒300176
- (void)starLevel:(float)starLevel{
    CGFloat width = 80.0/5 * starLevel;
    _widthConstraints.constant = width;//lyf 加
}

- (IBAction)btnAction:(id)sender {
    if (_blockAuthenticationPressed) {
        _blockAuthenticationPressed(_tcm);
    }
}

- (IBAction)btnImageAction:(id)sender {
    if (_blockReturn) {
        _blockReturn(_tcm);
    }
}



@end
