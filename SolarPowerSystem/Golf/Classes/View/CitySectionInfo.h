//
//  CitySectionInfo.h
//  Golf
//
//  Created by user on 13-2-26.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SectionView.h"

@interface CitySectionInfo : NSObject

@property (nonatomic) BOOL open;
@property (nonatomic) int cityCount;
@property (nonatomic) int provinceId;
@property (nonatomic,copy) NSString *provinceName;
@property (nonatomic,strong) SectionView *citySectionView;
@property (nonatomic,strong) NSArray *cityList;

@end
