//
//  ClubPictureModel.h
//  Golf
//
//  Created by 黄希望 on 12-9-10.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClubPictureModel : NSObject{
    NSString *_ImgAddress;
}

@property (nonatomic,copy) NSString *ImgAddress;

- (id)initWithDic:(id)data;

@end
