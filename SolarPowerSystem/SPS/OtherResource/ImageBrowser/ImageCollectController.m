//
//  ImageCollectController.m
//  Golf
//
//  Created by 黄希望 on 15/7/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "ImageCollectController.h"
#import "SDPhotoGroup.h"
#import "SDPhotoItem.h"

@interface ImageCollectController ()

@property (nonatomic, strong) SDPhotoGroup *sdPhotoGroup;

@end

@implementation ImageCollectController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setUp];
}

- (void)setUp{
    self.title = [NSString stringWithFormat:@"图片浏览(%d)",(int)self.srcStringArray.count];
    self.sdPhotoGroup = [[SDPhotoGroup alloc] init];
    self.sdPhotoGroup.isCollection = self.isCollection;
    self.sdPhotoGroup.currentIndex = self.currentIndex;
    self.sdPhotoGroup.isEdit = self.isEdit;
    self.sdPhotoGroup.highQuality = self.highQuality;
    
    __weak ImageCollectController *ic = self;
    self.sdPhotoGroup.blockReturn = ^(id obj){
        if (ic.blockReturn) {
            ic.blockReturn (obj);
            if (![obj isKindOfClass:[SDPhotoGroup class]]) {
                NSInteger index = [obj integerValue];
                [ic.srcStringArray removeObjectAtIndex:index];
                ic.currentIndex = MIN(index, ic.srcStringArray.count-1);
                [ic.sdPhotoGroup removeFromSuperview];
                if (ic.srcStringArray.count>0) {
                    [ic setUp];
                }
            }
        }
    };
    
    NSMutableArray *temp = [NSMutableArray array];
    [_srcStringArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        SDPhotoItem *item = [[SDPhotoItem alloc] init];
        item.thumbnail_pic = obj;
        [temp addObject:item];
    }];
    
    _sdPhotoGroup.photoItemArray = [temp mutableCopy];
    
    [self.view addSubview:_sdPhotoGroup];
}

- (void)clickIndex:(int)index{
    [self.sdPhotoGroup click:index delay:0];
}

@end
