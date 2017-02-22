//
//  ClubScrollImageCell.m
//  Golf
//
//  Created by 黄希望 on 15/11/13.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "ClubScrollImageCell.h"
#import "XLCycleScrollView.h"
//#import "ActivityMainViewController.h"
#import "YGWebBrowser.h"
#import "ActivityModel.h"

@interface ClubScrollImageCell ()<XLCycleScrollViewDatasource,XLCycleScrollViewDelegate>

@property (nonatomic, strong) XLCycleScrollView *cycleScrollView;

@end

@implementation ClubScrollImageCell

- (IBAction)checkNearbyAction:(id)sender{
    if (_checkNearbyBlock) {
        _checkNearbyBlock (nil);
    }
}



-(void)setDatas:(NSArray *)activityList reload:(BOOL)flag{
    _activityList = activityList;
    if (_activityList.count > 0 && flag == YES) {
        [self createXLCycleScrollView];
    }
}

// 创建广告
- (void)createXLCycleScrollView{
    if (_cycleScrollView) {
        _cycleScrollView.delegate = nil;
        _cycleScrollView.datasource = nil;
        [_cycleScrollView clear];
        [_cycleScrollView removeFromSuperview];
        _cycleScrollView = nil;
    }
    
//    UIImageView *corverImg = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 160)];
//    corverImg.image = [UIImage imageNamed:@"bg_BookingFirst_masking_up"];
    
    self.cycleScrollView = [[XLCycleScrollView alloc] initWithFrame:CGRectMake(0, 0, Device_Width, 140) autoScroll:YES];
    _cycleScrollView.delegate = self;
    _cycleScrollView.datasource = self;
    [self.contentView insertSubview:_cycleScrollView atIndex:1];
//    [_cycleScrollView addSubview:corverImg];
}

// 滚动视图数据源方法
- (NSInteger)numberOfPages
{
    return [_activityList count];
}

- (NSString *)pageAtIndex:(NSInteger)index{
    if (_activityList.count>0) {
        index = MIN(index, [_activityList count]-1);
        ActivityModel *model = [_activityList objectAtIndex:index];
        return model.activityPicture;
    }else{
        return nil;
    }
}

// 活动动作 0:无  1:订场  2:套餐 3:搜省份 4:搜城市 5:买商品
- (void)XLCycleScrollViewClickAction:(NSInteger)page{
    if (page < _activityList.count) {
        ActivityModel *model = [_activityList objectAtIndex:page];
        if (model.dataType.length == 0 && model.activityPage.length > 0) {
            
            YGWebBrowser *activityMain = [YGWebBrowser instanceFromStoryboard];
//            ActivityMainViewController *activityMain = [[ActivityMainViewController alloc] initWithNibName:@"ActivityMainViewController" bundle:nil];
            activityMain.title = @"活动详情";
            activityMain.activityModel = model;
            activityMain.activityId = model.activityId;
            [[GolfAppDelegate shareAppDelegate].currentController pushViewController:activityMain title:@"活动详情" hide:YES];
        }else{
            NSDictionary *dic = @{@"data_type":model.dataType,
                                  @"data_id":@(model.dataId),
                                  @"sub_type":@(model.subType),
                                  @"data_extra":model.dataExtra
                                  };
            [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
        }
    }
}

@end
