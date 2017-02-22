//
//  ScrollTeachTableViewCell.m
//  Golf
//
//  Created by Main on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "ScrollTeachTableViewCell.h"
#import "ActivityModel.h"

@interface ScrollTeachTableViewCell() <UICollectionViewDelegate,UICollectionViewDataSource>
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;

@end

@implementation ScrollTeachTableViewCell{
    UIImage *defaultImage;
}
-(void)awakeFromNib{
    [super awakeFromNib];
    self.collectionView.scrollsToTop = NO;
    defaultImage = [UIImage imageNamed:@"defeat_booking_"];
}

- (void)loadDatas:(NSArray *)datas
{
    _datas = datas;
    [self.collectionView reloadData];
}

- (ActivityModel *)activityModelWithActivityBean:(ActivityBean *)activityBean{
    ActivityModel *model = [[ActivityModel alloc] init];
    model.activityId = activityBean.activityId;
    model.activityName = activityBean.activityName;
    model.activityPicture = activityBean.activityPicture;
    model.activityPage = activityBean.activityPage;
    model.beginDate = activityBean.beginDate;
    model.endDate = activityBean.endDate;
    model.dataId = activityBean.dataId;
    model.dataType = activityBean.dataType;
    model.subType = activityBean.subType;
    return model;
}

#pragma mark - UICollectioView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.datas.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"ScrollTeachItemCell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    UIImageView *imageView = [cell viewWithTag:10086];
    
    ActivityBean *bean = self.datas[indexPath.item];
    
    [Utilities loadImageWithURL:[NSURL URLWithString:bean.activityPicture] inImageView:imageView placeholderImage:defaultImage];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [[API shareInstance] statisticalNewWithBuriedpoint:31 objectID:0 Success:nil failure:nil];//埋点
    ActivityBean *bean = self.datas[indexPath.item];
    ActivityModel *m = [self activityModelWithActivityBean:bean];
    NSDictionary *dic = @{@"data_type":m.dataType,
                          @"data_id":@(m.dataId),
                          @"data_model":m,
                          @"sub_type":@(m.subType),
                          @"data_extra":m.activityPage
                          };
    [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:dic];
}

- (IBAction)moreClick:(id)sender {
    [[API shareInstance] statisticalNewWithBuriedpoint:30 objectID:0 Success:nil failure:nil];//埋点
    if (self.blockMore) {
        self.blockMore(nil);
    }
}

@end
