//
//  CoachNavHead.m
//  Golf
//
//  Created by 黄希望 on 15/6/12.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "CoachNavHead.h"

@interface CoachNavHead()

@property (nonatomic,strong) IBOutletCollection(UIButton) NSArray *buttons;

@end

@implementation CoachNavHead

- (void)awakeFromNib{
    [super awakeFromNib];
    for (UIButton *btn in _buttons) {
        [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateSelected];
        [btn setTitleColor:[UIColor colorWithHexString:@"#B1E4F8"] forState:UIControlStateNormal];
        if (btn.tag == 1) {
            btn.selected = YES;
        }
    }
}

- (IBAction)buttonPressed:(UIButton*)sender{
    NSInteger index = sender.tag;
    [self actionWithIndex:index];
}

- (void)actionWithIndex:(NSInteger)index{
    for (UIButton *btn in _buttons) {
        btn.selected = index==btn.tag ? YES : NO;
        if (btn.selected) {
            [btn.titleLabel setFont:[UIFont systemFontOfSize:20]];
        }else{
            [btn.titleLabel setFont:[UIFont systemFontOfSize:16]];
        }
    }
    if (_respEvent) {
        _respEvent (@(index));
    }
}

@end
