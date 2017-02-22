//
//  YGSearch.c
//  Golf
//
//  Created by bo wang on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#include "YGSearch.h"

static NSUInteger
IndexOfSearchType(YGSearchType type){
    if (!IsValidSearchType(type)) return 0;
    if (YGSearchTypeAll == type) return 0;
    for (int i=0; i<10; i++) {
        if (type & 1<<i){
            return i+1;
        }
    }
    return NSNotFound;
}

BOOL
IsValidSearchType(NSInteger aType){
    if (aType<0) return NO;
    return aType<=YGSearchTypeCoach;
}

NSString *
SearchTitleOfType(YGSearchType type){
    static NSArray *titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titles = @[@"",
                   @"球场",
                   @"商品",
                   @"动态",
                   @"用户",
                   @"头条",
                   @"教练"];
    });
    NSUInteger index = IndexOfSearchType(type);
    if (index != NSNotFound) {
        return titles[index];
    }
    return nil;
}

NSString *
SearchFooterOfType(YGSearchType type){
    NSString *title = SearchTitleOfType(type);
    return [NSString stringWithFormat:@"查看更多%@",title];
}

NSString *
SearchIconNameOfType(YGSearchType type){
    static NSArray *titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titles = @[@"search_index",
                   @"ic_GlobalSearch_GolfCourse",
                   @"ic_GlobalSearch_store",
                   @"ic_GlobalSearch_dynamic",
                   @"ic_GlobalSearch_user",
                   @"ic_GlobalSearch_read",
                   @"ic_GlobalSearch_coach"];
    });
    NSUInteger index = IndexOfSearchType(type);
    if (index != NSNotFound) {
        return titles[index];
    }
    return nil;
}

NSString *
SearchSmallIconNameOfType(YGSearchType type){
    static NSArray *titles;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        titles = @[@"search_index",
                   @"ic_GlobalSearch_GolfCourse_small",
                   @"ic_GlobalSearch_store_small",
                   @"ic_GlobalSearch_dynamic_small",
                   @"ic_GlobalSearch_user_small",
                   @"ic_GlobalSearch_read_small",
                   @"ic_GlobalSearch_coach_small"];
    });
    NSUInteger index = IndexOfSearchType(type);
    if (index != NSNotFound) {
        return titles[index];
    }
    return nil;
}

NSUInteger
SearchQueryValue(YGSearchType type){
    NSUInteger index = IndexOfSearchType(type);
    return index==NSNotFound?0:index;
}
