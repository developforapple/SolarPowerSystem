//
//  TrendsObject.m
//  Golf
//
//  Created by 廖瀚卿 on 15/8/19.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "TrendsModel.h"
#import "TopicModel.h"
#import "TagModel.h"
#import "SearchClubModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation TrendsModel

- (id)initWithDic:(id)data{
    if(!data || ![data isKindOfClass:[NSDictionary class]]){
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }
    
    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"topic_list"]) {
        NSArray *array = [dic objectForKey:@"topic_list"];
        if (array && array.count>0) {
            NSMutableArray *mutArray = [NSMutableArray array];
            
            NSString *path = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0];
            
            for (id obj in array) {
                TopicModel *m = [[TopicModel alloc] initWithDic:obj];
                NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:m.memberId];
                if ([remarkName isNotBlank]) {
                    m.displayName = remarkName;
                }
                
                [mutArray addObject:m];
                
                NSString *filepath = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%d",m.topicId]];
                BOOL ok = [NSKeyedArchiver archiveRootObject:m toFile:filepath];
                if (ok) {
                    //NSLog(@"***** 存储成功");
                }
            }
            self.topicList = mutArray;
        }
    }
    
    if ([dic objectForKey:@"tag_list"]) {
        NSArray *array = [dic objectForKey:@"tag_list"];
        if (array && array.count > 0) {
            NSMutableArray *ma = [NSMutableArray array];
            for (id obj in array) {
                TagModel *m = [[TagModel alloc] initWithDic:obj];
                [ma addObject:m];
            }
            self.tagList = ma;
        }
    }
    
    // 球场信息
    if ([dic objectForKey:@"clubInfo"]) {
        NSDictionary *clubDict = dic[@"clubInfo"];
        self.clubModel = [[SearchClubModel alloc] initWithDic:clubDict];
    }
    
    return self;
}
@end
