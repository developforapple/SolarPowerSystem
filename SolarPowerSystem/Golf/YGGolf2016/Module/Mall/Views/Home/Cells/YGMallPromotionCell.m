

#import "YGMallPromotionCell.h"
#import "ActivityModel.h"

NSString *const kYGMallPromotionCell = @"YGMallPromotionCell";

@interface YGMallPromotionCell ()
@property (strong, nonatomic) IBOutletCollection(YGMallPromotionUnit) NSArray *units;
@end

@implementation YGMallPromotionCell

- (void)setActivityList:(NSArray *)activityList{
    _activityList = activityList;
    
    NSInteger basePoint = YGMallPointActivityPanel1;
    for (YGMallPromotionUnit *unit in self.units) {
        NSInteger idx = [self.units indexOfObject:unit];
        if (idx < activityList.count) {
            unit.activity = activityList[idx];
        }else{
            unit.activity = nil;
        }
        unit.tag = basePoint++;
    }
}

@end


@implementation YGMallPromotionUnit

- (IBAction)btnAction:(UIButton *)btn
{
    if (self.activity) {
        YGPostBuriedPoint(self.tag);
        
        NSDictionary *dic = @{@"data_type":self.activity.dataType,
                              @"data_id":@(self.activity.dataId),
                              @"data_model":self.activity,
                              @"sub_type":@(self.activity.subType),
                              @"data_extra":self.activity.activityPage
                              };
        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
    }
}

- (void)setActivity:(ActivityModel *)activity
{
    _activity = activity;
    if (activity) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:activity.activityPicture]];
        self.hidden = NO;
    }else{
        self.hidden = YES;
    }
}

@end
