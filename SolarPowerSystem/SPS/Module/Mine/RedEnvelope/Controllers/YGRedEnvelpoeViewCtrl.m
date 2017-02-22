//
//  YGRedEnvelpoeViewCtrl.m
//  Golf
//
//  Created by 黄希望 on 14-8-25.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "YGRedEnvelpoeViewCtrl.h"
#import "YGRedEnvelpoeRecordViewCtrl.h"
#import "YGRedEnvelopeUnit.h"
#import "RegexKitLite.h"
#import "SharePackage.h"

@interface YGRedEnvelpoeViewCtrl (){
    SharePackage *share;
}
@property (nonatomic) int totalShareAmount;
@property (nonatomic,strong) NSMutableArray *redPaperList;

@end

@implementation YGRedEnvelpoeViewCtrl
@synthesize totalShareAmount;
@synthesize redPaperList;


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    noRedPaperNoteLabel.hidden = YES;
    self.redPaperList = [NSMutableArray array];
    [self getRedPaperListFromServer];
}

- (void)getRedPaperListFromServer{
    [[ServiceManager serviceManagerWithDelegate:self] getRedPackeList:[[LoginManager sharedManager] getSessionId] type:1 pageNo:1 pageSize:100];
}

- (void)serviceResult:(ServiceManager *)serviceManager Data:(id)data flag:(NSString *)flag{
    NSArray *array = (NSArray*)data;
    if (array && array.count > 0) {
        NSDictionary *dic = [array objectAtIndex:0];
        if ([dic objectForKey:@"total_used_amount"]) {
            self.totalShareAmount = [[dic objectForKey:@"total_used_amount"] intValue] / 100;
        }
        if ([dic objectForKey:@"redpacket_list"]) {
            NSArray *aa = [dic objectForKey:@"redpacket_list"];
            if (aa&&aa.count>0) {
                for (id obj in aa) {
                    RedPaperModel *model = [[RedPaperModel alloc] initWithDic:obj];
                    [self.redPaperList addObject:model];
                }
            }
        }
        NSString *total = [NSString stringWithFormat:@"¥%d",self.totalShareAmount];
        if (Device_SysVersion < 6.0) {
            totalAmountRedPaperLabel_r.text = total;
        }else{
            totalAmountRedPaperLabel_r.attributedText = [Utilities attributedStringWithString:total value1:[UIFont systemFontOfSize:12] range1:NSMakeRange(0, 1) value2:nil range2:NSMakeRange(0, 0) font:0 otherValue:nil otherRange:NSMakeRange(0, 0)];
        }
        [self createRedPapers];
    }
}

- (void)createRedPapers{
    if (self.redPaperList.count == 0) {
        noRedPaperNoteLabel.hidden = NO;
    }else{
        CGFloat loc_x = 10;
        if (self.redPaperList.count<3){
            loc_x = self.redPaperList.count == 1 ? (self.view.frame.size.width-126)/2 : 24;
        }else{
            scrollView.contentSize = CGSizeMake(loc_x+145*self.redPaperList.count, 200);
        }
        
        for (int i=0; i<self.redPaperList.count; i++) {
            RedPaperModel *redPaper = [self.redPaperList objectAtIndex:i];
            YGRedEnvelopeUnit *redPaperView = [[[NSBundle mainBundle] loadNibNamed:@"YGRedEnvelopeUnit" owner:self options:nil] lastObject];
            redPaperView.frame = CGRectMake(loc_x + 145*i, 28, 127, 146);
            redPaperView.shareBtn.tag = i+1;
            redPaperView.expireDateLabel.text = [self willExpireDate:redPaper.expireDate];
            redPaperView.redPaperNumLabel.text = [NSString stringWithFormat:@"%d",redPaper.totalQuantity-redPaper.usedQuantity];
            redPaperView.totalNumLabel.text = [NSString stringWithFormat:@"/%d个",redPaper.totalQuantity];
            [redPaperView.shareBtn addTarget:self action:@selector(shareAction:) forControlEvents:UIControlEventTouchUpInside];
            [scrollView addSubview:redPaperView];
        }
    }
}

- (NSString *)willExpireDate:(NSString*)expireDate{
    if (expireDate&&expireDate.length>0) {
        NSInteger dayNum = -1;
        if (expireDate&&expireDate.length>0) {
            NSDate *date = [Utilities getDateFromString:expireDate];
            NSString *currentDate = [Utilities stringwithDate:[NSDate date]];
            NSDate *cDate = [Utilities getDateFromString:currentDate];
            dayNum = [Utilities numDayWithBeginDate:cDate endDate:date];
        }
        
        if (dayNum == 0) {
            return @"今天过期";
        }else if (dayNum > 0){
            return [NSString stringWithFormat:@"%d天后过期",(int)dayNum];
        }else{
            return @"已过期";
        }
    }
    return @"已过期";
}

- (void)shareAction:(UIButton*)button{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    NSInteger index = button.tag -1;
    RedPaperModel *model = self.redPaperList[index];
    if (share) {
        share = nil;
    }
    share = [[SharePackage alloc] initWithTitle:model.shareTitle content:model.shareContent img:[UIImage imageNamed:@"award.png"] url:model.shareUrl];
    
    [share shareInfoForView:[GolfAppDelegate shareAppDelegate].currentController.view];
}

- (IBAction)checkAction:(id)sender{
    YGRedEnvelpoeRecordViewCtrl *allRedPaperRecord = [[YGRedEnvelpoeRecordViewCtrl alloc] init];
    [self pushViewController:allRedPaperRecord title:@"红包记录" hide:YES];
}

@end
