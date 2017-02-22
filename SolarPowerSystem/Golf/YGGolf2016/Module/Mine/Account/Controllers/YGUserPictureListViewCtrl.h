//
//  YGUserPictureListViewCtrl.h
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "BaseNavController.h"

@interface YGUserPictureListViewCtrl : BaseNavController

@property (strong, nonatomic) NSMutableArray *images;
@property (assign, nonatomic) BOOL isMine;
@property (assign, nonatomic) NSInteger memberId;

// 当images为空时是否直接显示相册图片选择器。默认为NO
@property (assign, nonatomic) BOOL showAssetsPickerWithNoneImages;

@property (copy, nonatomic) void (^updateCallback)(void);
@property (copy, nonatomic) void (^didDeletedPicture)(NSArray *newImagesList);

@end
