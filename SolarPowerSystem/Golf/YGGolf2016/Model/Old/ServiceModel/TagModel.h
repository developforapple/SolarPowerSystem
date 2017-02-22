//
//  TagModel.h
//  Golf
//
//  Created by 黄希望 on 15/8/20.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TagModel : NSObject

@property (nonatomic,assign) int tagId;
@property (nonatomic,strong) NSString *tagName;
@property (nonatomic,strong) NSString *tagImage;
@property (nonatomic,strong) NSString *tagDescription;
@property (nonatomic,assign) int hotRank;
@property (nonatomic,assign) int displayOrder;
@property (nonatomic,strong) NSString *tagSubtitle;
- (id)initWithDic:(id)dic;

@end
