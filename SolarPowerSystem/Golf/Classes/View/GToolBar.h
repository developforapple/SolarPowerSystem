//
//  GToolBar.h
//  Golf
//
//  Created by user on 13-9-29.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol GToolBarDelegate <NSObject>

- (void)toolBarActionWithIndex:(NSInteger)index;

@end

@interface GToolBar : UIToolbar{
    UIButton *_btnCancel;
    UIButton *_btnConfirm;
    UIButton *_btnClear;
}
@property (nonatomic) BOOL isCancelBtnHide;
@property (nonatomic) BOOL isSureBtnHide;
@property (nonatomic) BOOL isClearBtnHide;
@property (nonatomic,weak) id<GToolBarDelegate> toolBarDelegate;

@end
