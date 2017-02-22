//
//  GToolBar.m
//  Golf
//
//  Created by user on 13-9-29.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "GToolBar.h"

@implementation GToolBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.barStyle = UIBarStyleBlackTranslucent;
        
        _btnCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnCancel.frame = CGRectMake(10.0, 7.0, 50, 30.0);

        _btnCancel.tag = 1;
        [_btnCancel setTitle:@"取消" forState:UIControlStateNormal];
        _btnCancel.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_btnCancel addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnCancel];
        
        _btnConfirm = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnConfirm.frame = CGRectMake(Device_Width-60, 7.0, 50.0, 30.0);

        _btnConfirm.tag = 2;
        [_btnConfirm setTitle:@"确定" forState:UIControlStateNormal];
        _btnConfirm.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_btnConfirm addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnConfirm];
        
        _btnClear = [UIButton buttonWithType:UIButtonTypeCustom];
        _btnClear.frame = CGRectMake(Device_Width-110, 7.0, 50.0, 30.0);

        _btnClear.tag = 3;
        _btnClear.hidden = YES;
        [_btnClear setTitle:@"清除" forState:UIControlStateNormal];
        _btnClear.titleLabel.font = [UIFont systemFontOfSize:14.0f];
        [_btnClear addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:_btnClear];
    }
    return self;
}

- (void)setIsCancelBtnHide:(BOOL)isCancelBtnHide{
    if (isCancelBtnHide)
        _btnCancel.hidden = YES;
    else
        _btnCancel.hidden = NO;
}

- (void)setIsSureBtnHide:(BOOL)isSureBtnHide{
    if (isSureBtnHide)
        _btnConfirm.hidden = YES;
    else
        _btnConfirm.hidden = NO;
}

- (void)setIsClearBtnHide:(BOOL)isClearBtnHide{
    if (isClearBtnHide)
        _btnClear.hidden = YES;
    else
        _btnClear.hidden = NO;
}

- (void)buttonPressed:(UIButton*)button{
    if ([_toolBarDelegate respondsToSelector:@selector(toolBarActionWithIndex:)]) {
        [_toolBarDelegate toolBarActionWithIndex:button.tag];
    }
}

@end
