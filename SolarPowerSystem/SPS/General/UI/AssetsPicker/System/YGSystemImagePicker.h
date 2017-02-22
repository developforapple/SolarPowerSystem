//
//  YGSystemImagePicker.h
//  Golf
//
//  Created by bo wang on 2016/12/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void(^YGSystemImagePickerCompletion)(UIImage *image);

typedef NS_ENUM(NSUInteger, YGImagePickerMode) {
    YGImagePickerModePhoto = UIImagePickerControllerSourceTypePhotoLibrary,  //相册
    YGImagePickerModeCamera = UIImagePickerControllerSourceTypeCamera, //相机
};

#define YGSystemImagePickerModes [YGSystemImagePicker availableModes]

@interface YGSystemImagePicker : NSObject

// 直接显示相册或相机
+ (void)presentFrom:(UIViewController *)vc
               mode:(YGImagePickerMode)mode
            editing:(BOOL)allowEditing
         completion:(YGSystemImagePickerCompletion)completion;

// 弹出选择器选择从相册或相机选择图片
+ (void)presentSheetFrom:(UIViewController *)vc
                   modes:(NSArray *)modes
            allowEditing:(BOOL)allowEditing
              completion:(YGSystemImagePickerCompletion)completion;

// 当前可用的图片选择方式
+ (NSArray *)availableModes;

@end
