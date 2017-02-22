//
//  YGSystemImagePicker.m
//  Golf
//
//  Created by bo wang on 2016/12/23.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSystemImagePicker.h"

@interface UIImagePickerController (YGUniqueID)
@end

@implementation UIImagePickerController (YGUniqueID)
- (NSString *)uniqueID
{
    static void *YGUniqueIDKey = &YGUniqueIDKey;
    NSString *theID = objc_getAssociatedObject(self, YGUniqueIDKey);
    if (!theID) {
        theID = [@(arc4random_uniform(UINT32_MAX)) stringValue];
        objc_setAssociatedObject(self, YGUniqueIDKey, theID, OBJC_ASSOCIATION_COPY_NONATOMIC);
    }
    return theID;
}
@end

@interface _YGSystemImagePickerPuppet : NSObject <UINavigationControllerDelegate,UIImagePickerControllerDelegate>
@property (strong, nonatomic) NSMutableDictionary *completions;
@end

@implementation _YGSystemImagePickerPuppet

+ (instancetype)puppet
{
    static _YGSystemImagePickerPuppet *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [_YGSystemImagePickerPuppet new];
        instance.completions = [NSMutableDictionary dictionary];
    });
    return instance;
}

- (void)setCompletion:(YGSystemImagePickerCompletion)completion forPicker:(UIImagePickerController *)picker
{
    if (!picker || !completion) return;
    picker.delegate = self;
    self.completions[[picker uniqueID]] = completion;
}

- (void)removeCompletion:(UIImagePickerController *)picker
{
    if (!picker) return;
    self.completions[[picker uniqueID]] = nil;
}

#pragma mark

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [UIImagePickerController yg_setIgnored:NO];
    [self removeCompletion:picker];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [UIImagePickerController yg_setIgnored:NO];
    
    UIImage *image;
    if (picker.allowsEditing) {
        image = info[UIImagePickerControllerEditedImage];
    }else{
        image = info[UIImagePickerControllerOriginalImage];
    }
    YGSystemImagePickerCompletion completiton = self.completions[[picker uniqueID]];
    if (completiton) {
        completiton(image);
    }
    [self removeCompletion:picker];
    [picker dismissViewControllerAnimated:YES completion:nil];
}

@end

@interface YGSystemImagePicker ()
@property (assign, nonatomic) BOOL allowEditing;
@property (assign, nonatomic) YGImagePickerMode mode;
@end

@implementation YGSystemImagePicker

+ (void)presentFrom:(UIViewController *)vc
               mode:(YGImagePickerMode)mode
            editing:(BOOL)allowEditing
         completion:(YGSystemImagePickerCompletion)completion
{
    if (mode == YGImagePickerModeCamera && ![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [SVProgressHUD showErrorWithStatus:@"相机不可用!"];
        return;
    }
    
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.allowsEditing = allowEditing;
    switch (mode) {
        case YGImagePickerModePhoto:{
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        }   break;
        case YGImagePickerModeCamera:{
            picker.sourceType = UIImagePickerControllerSourceTypeCamera;
            [UIImagePickerController yg_setIgnored:YES];
        }   break;
    }
    [vc?:[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:picker animated:YES completion:^{
        [[_YGSystemImagePickerPuppet puppet] setCompletion:completion forPicker:picker];
    }];
}

+ (void)presentSheetFrom:(UIViewController *)vc
                   modes:(NSArray *)modes
            allowEditing:(BOOL)allowEditing
              completion:(YGSystemImagePickerCompletion)completion
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    
    for (NSNumber *aMode in modes) {
        YGImagePickerMode mode = [aMode integerValue];
        switch (mode) {
            case YGImagePickerModePhoto:{
                [sheet addAction:[UIAlertAction actionWithTitle:@"从相册选择" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
                    [self presentFrom:vc mode:mode editing:allowEditing completion:[completion copy]];
                }]];
            }   break;
            case YGImagePickerModeCamera:{
                [sheet addAction:[UIAlertAction actionWithTitle:@"拍照" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    [self presentFrom:vc mode:mode editing:allowEditing completion:[completion copy]];
                }]];
            }   break;
        }
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [vc?:[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:sheet animated:YES completion:nil];
}

+ (NSArray *)availableModes
{
    NSMutableArray *modes = [NSMutableArray array];
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        [modes addObject:@(YGImagePickerModePhoto)];
    }
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        [modes addObject:@(YGImagePickerModeCamera)];
    }
    return modes;
}

@end
