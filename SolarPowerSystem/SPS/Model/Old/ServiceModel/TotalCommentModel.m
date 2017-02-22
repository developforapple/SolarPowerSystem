//
//  TotalCommentModel.m
//  Golf
//
//  Created by user on 13-6-4.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "TotalCommentModel.h"
#import "CommentModel.h"
#import "YGUserRemarkCacheHelper.h"

@implementation TotalCommentModel

- (id)initWithDic:(id)data{
    if (!data || ![data isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    self = [super init];
    if(!self) {
        return nil;
    }

    NSDictionary *dic = (NSDictionary *)data;
    if ([dic objectForKey:@"comment_count"]) {
        self.commentCount = [[dic objectForKey:@"comment_count"] intValue];
    }
    if ([dic objectForKey:@"total_level"]) {
        self.totalLevel = ceil([[dic objectForKey:@"total_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"grass_level"]) {
        self.grassLevel = ceil([[dic objectForKey:@"grass_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"service_level"]) {
        self.serviceLevel = ceil([[dic objectForKey:@"service_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"difficulty_level"]) {
        self.difficultyLevel = ceil([[dic objectForKey:@"difficulty_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"scenery_level"]) {
        self.sceneryLevel = ceil([[dic objectForKey:@"scenery_level"] floatValue]*100.0/5.0);
    }
    if ([dic objectForKey:@"data_list"]) {
        NSMutableArray *dataList = [NSMutableArray arrayWithCapacity:0];
        NSArray *list = [dic objectForKey:@"data_list"];
        if (list) {
            for(id obj in list){
                CommentModel *model = [[CommentModel alloc] initWithDic:obj];
                NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:model.memberId];
                if ([remarkName isNotBlank]) {
                    model.displayName = remarkName;
                }
                [dataList addObject:model];
            }
        }
        self.commentList = dataList;
    }
    
    return self;
}

@end
