//
//  LunboTableViewCell.m
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "LunboTableViewCell.h"
#import "TwoLineLabel.h"

@interface LunboTableViewCell()

@property (weak, nonatomic) IBOutlet UIView *changeView;
@property (nonatomic,strong) NSTimer *changeTimer;
@property (nonatomic,assign) NSInteger indexView;
@property (nonatomic,assign) NSInteger indexData;
@property (nonatomic,strong) NSMutableArray *datas;
@property (nonatomic,assign) BOOL datasHaveData;

@end

@implementation LunboTableViewCell
- (NSMutableArray *)datas{
    if (_datas == nil) {
        _datas = [NSMutableArray array];
    }
    return _datas;
}

-(void)loadDatas:(NSArray *)datas{
    _tempArr = datas;
    self.datasHaveData = datas.count == 0 || (self.datas == nil && self.datas.count == 0);
    if (_datasHaveData) {
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [path stringByAppendingPathComponent:@"GolfHeadlineData.archiver"];
        NSArray *headLis = [NSKeyedUnarchiver unarchiveObjectWithFile:fileName];
        [self.datas removeAllObjects];
        for (int i = 0; i < headLis.count; i = i + 2) {
            NSArray *arr;
            if (i + 1 < headLis.count) {
                arr = @[headLis[i],headLis[i + 1]];
            }else{
                arr = @[headLis[i],[NSNull null]];
            }
            [self.datas addObject:arr];
        }
    }else{
        [self.datas removeAllObjects];
        for (int i = 0; i < datas.count;i = i + 2) {
            NSArray *arr;
            if (i + 1 < datas.count) {
                arr = @[datas[i],datas[i + 1]];
            }else{
                arr = @[datas[i],[NSNull null]];
            }
            [self.datas addObject:arr];
        }
        
        NSString *path = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
        NSString *fileName = [path stringByAppendingPathComponent:@"GolfHeadlineData.archiver"];
        NSMutableArray *headLineArr = [NSMutableArray array];
        for (HeadLineBean *bean in datas) {
            [headLineArr addObject:bean.linkTitle];
        }
        [NSKeyedArchiver archiveRootObject:headLineArr toFile:fileName];
    }
                            
    TwoLineLabel *tl = [self getTwoLineLabel];
    NSArray *arr = [self getData];
    if (arr && arr.count > 0 && tl) {
        if (_datasHaveData) {
            tl.labelContent1.text = arr[0];
            tl.labelContent2.text = arr[1];
        }else{
            HeadLineBean *healineBean0 = arr[0];
            HeadLineBean *healineBean1 = arr[1];
            tl.labelContent1.text = healineBean0.linkTitle;
            tl.labelContent2.text = healineBean1.linkTitle;
        }
    }
    [self.changeTimer invalidate];
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(repeadShow) userInfo:self repeats:YES];
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.indexView = 1;
    
    TwoLineLabel *tl = [TwoLineLabel nib];
    tl.frame = CGRectMake(0, 0, self.changeView.width, self.changeView.height);
    tl.tag = self.indexView;
    [self.changeView addSubview:tl];
 
    self.changeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f target:self selector:@selector(repeadShow) userInfo:self repeats:YES];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [[UIColor colorWithHexString:@"#eeeeee"] colorWithAlphaComponent:.5];
    self.selectedBackgroundView = view;
}

- (void)layoutSubviews{
    [super layoutSubviews];
    
}

- (TwoLineLabel *)getTwoLineLabel{
    return [self.changeView viewWithTag:self.indexView];
}

- (NSArray *)getData{
    if (self.datas.count > _indexData) {
        NSArray *arr = self.datas[_indexData];
        self.indexData++;
        
        if (self.indexData >= self.datas.count) {
            self.indexData = 0;
        }
        
        return arr;
    }
    return nil;
     
}

-(void)repeadShow{
    TwoLineLabel *tl = [TwoLineLabel nib];
    tl.frame = CGRectMake(0, 68, self.changeView.width, 68);
    NSArray *arr = [self getData];
    if (arr && arr.count > 0) {
        if (_datasHaveData) {
            tl.labelContent1.text = arr[0];
            tl.labelContent2.text = arr[1];
        }else{
            HeadLineBean *healineBean0 = arr[0];
            HeadLineBean *healineBean1 = arr[1];
            tl.labelContent1.text = healineBean0.linkTitle;
            tl.labelContent2.text = healineBean1.linkTitle;
        }
    }
    
    if (self.indexView == 1) {
        tl.tag = 2;
    }else{
        tl.tag = 1;
    }
    [self.changeView addSubview:tl];
    
    
    TwoLineLabel *labelOnChangeView = [self getTwoLineLabel];
    [UIView animateWithDuration:1 animations:^{
        labelOnChangeView.frame = CGRectMake(0, -68, self.changeView.width, 68);
        tl.frame = CGRectMake(0, 0, self.changeView.width, 68);
    } completion:^(BOOL finished){
        [labelOnChangeView removeFromSuperview];
    }];
    if (self.indexView == 1) {
        self.indexView = 2;
    }else{
        self.indexView = 1;
    }
}

@end
