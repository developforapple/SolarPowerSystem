//
//  TrendsObject.h
//  Golf
//
//  Created by 廖瀚卿 on 15/8/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SearchClubModel;

@interface TrendsModel : NSObject

@property(nonatomic,strong) NSMutableArray *topicList;
@property(nonatomic,strong) NSMutableArray *tagList;
// 球场话题【球场的数据对象】
@property (strong, nonatomic) SearchClubModel *clubModel;

- (id)initWithDic:(id)data;

@end
