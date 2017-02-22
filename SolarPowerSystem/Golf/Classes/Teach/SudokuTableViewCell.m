//
//  SudokuTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "SudokuTableViewCell.h"
#import "ActivityModel.h"

@interface SudokuTableViewCell()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *imgs;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *btns;

@end

@implementation SudokuTableViewCell{
    UIImage *defautlImage;
}


- (void)awakeFromNib {
    [super awakeFromNib];
    defautlImage = [UIImage imageNamed:@"pic_zhanwei"];
}



-(void)loadDatas:(NSArray *)datas{
    if (_datas == nil || _datas != datas) {
        NSArray *arr = datas.count > 4 ? [datas subarrayWithRange:NSMakeRange(0, 4)]:datas;
        for (int i = 0; i < _imgs.count ; i++) {
            UIImageView *img = _imgs[i];
            UIButton *btn = _btns[i];
            if (arr.count > i) {
                ActivityModel *m = [datas objectAtIndex:i];
                [Utilities loadImageWithURL:[NSURL URLWithString:m.activityPicture] inImageView:img placeholderImage:defautlImage changeContentMode:NO];
                [btn setEnabled:YES];
            }else{
                [img setImage:defautlImage];
                [btn setEnabled:NO];
            }
        }
    }
    _datas = datas;
    
}

- (IBAction)btnTouched:(UIButton *)btn {
    if (_blockReturn) {
        _blockReturn(@(btn.tag));
    }
}

- (IBAction)btn1Pressed:(id)sender {
    if (_blockReturn1) {
        _blockReturn1(_activityModel1);
    }
}

- (IBAction)btn2Pressed:(id)sender {
    if (_blockReturn2) {
        _blockReturn2(_activityModel2);
    }
}


@end
