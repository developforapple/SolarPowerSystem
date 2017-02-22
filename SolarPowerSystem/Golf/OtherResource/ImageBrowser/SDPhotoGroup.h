//
//  SDPhotoGroup.h
//  SDPhotoBrowser
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SDPhotoGroup : UIView 

@property (nonatomic, strong) NSMutableArray *photoItemArray;
@property (nonatomic, assign) BOOL isCollection;
@property (nonatomic, assign) NSInteger currentIndex;
@property (nonatomic, assign) CGRect initRt;
@property (nonatomic, assign) CGFloat imageMargin;
@property (nonatomic, assign) CGFloat imageSize;
@property (nonatomic, assign) NSInteger rowCount;
@property (nonatomic, assign) BOOL isEdit;
@property (nonatomic, assign) BOOL highQuality;
@property (nonatomic, assign) BOOL isAddPic,deleteTwoConfirm; //deleteTwoConfirm 是否直接删除
@property (nonatomic, assign) BOOL showCollectionButton; //右下角是否显示图集按钮
@property (nonatomic, assign) BOOL noCloseAnimation;//关闭是否有动画
@property (nonatomic,strong) NSString *actionTitle;
@property (nonatomic, copy) BlockReturn blockReturn;
@property (nonatomic, copy) BlockReturn imagesBlock;
@property (nonatomic, copy) BlockReturn addBlock;
@property (nonatomic, copy) BlockReturn blockAction;//底部按钮事件
@property (nonatomic, copy) BlockReturn blockDeleteAction;  //王波加 删除时的回调，参数为index
@property (nonatomic, copy) BlockReturn blockCollectionView;//底部工具栏图集按钮点击回调
@property (nonatomic, copy) CGRect (^backRtBlock)(NSInteger index);
@property (nonatomic, copy) void (^hideKeyboard)();

- (void)click:(int)index delay:(float)delay;

@end
