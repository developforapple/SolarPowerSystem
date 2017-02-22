//
//  YGUserRemarkCacheHelper.m
//  Golf
//
//  Created by 梁荣辉 on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGUserRemarkCacheHelper.h"
#import "YYCache.h"

// 缓存全部备注的DB名称
NSString *const kYGYGUserRemarkDBName = @"kYGYGUserRemarkDB";

// 缓存备注的单个key值  key 值 + 目前登录用户Id + 被备注的用户Id 【例如：UserRemark_Sid_1000_Uid_10020】
NSString *const kYGUserRemarkKeyName = @"UserRemark_Sid_";

@interface YGUserRemarkCacheHelper ()

@property (strong, nonatomic) YYDiskCache *cache;

@end

@implementation YGUserRemarkCacheHelper

+ (instancetype)shared
{
    static YGUserRemarkCacheHelper *helper;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        helper = [YGUserRemarkCacheHelper new];
        NSString *basePath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask, YES) firstObject];
        basePath = [basePath stringByAppendingPathComponent:@"YGCache"];
        helper.cache = [[YYDiskCache alloc] initWithPath:[basePath stringByAppendingPathComponent:kYGYGUserRemarkDBName]];
    });
    
    return helper;
}

-(void) cacheUserAllRemarkNames:(NSArray *) userRemarkDictArray
{
    int currentLoginMemberId = [LoginManager sharedManager].session.memberId;
    if (currentLoginMemberId <= 0) {
        return;
    }
    
    ygweakify(self)
    RunOnGlobalQueue(^{
        ygstrongify(self)
        if (userRemarkDictArray && [userRemarkDictArray isKindOfClass:[NSArray class]] && [userRemarkDictArray count] > 0) {
            for (NSDictionary *dict in userRemarkDictArray) {
                if ([dict isKindOfClass:[NSDictionary class]] && dict[@"name_remark"] && dict[@"member_id"]) {
                    NSString *remarkName = dict[@"name_remark"];
                    int memberId = [dict[@"member_id"] intValue];
                    [self updateUserRemarkName:remarkName memberId:memberId];
                }
            }
        }
    });
}

-(NSString *) getUserRemarkName:(int) memberId
{
    NSString *remarkName = nil;
    int currentLoginMemberId = [LoginManager sharedManager].session.memberId;
    
    if (memberId > 0 && currentLoginMemberId > 0) {
        NSString *keyName = [NSString stringWithFormat:@"%@%d_Uid_%d",kYGUserRemarkKeyName,currentLoginMemberId,memberId];
        if (keyName && [self.cache containsObjectForKey:keyName]) {
            remarkName = (NSString *)[self.cache objectForKey:keyName];
        }
    }
    
    return remarkName;
}

-(void) updateUserRemarkName:(NSString *) remarkName memberId:(int) memberId
{
    int currentLoginMemberId = [LoginManager sharedManager].session.memberId;
    if (!remarkName) {
        remarkName = @"";
    }
    
    if (memberId > 0 && currentLoginMemberId > 0) {
        NSString *keyName = [NSString stringWithFormat:@"%@%d_Uid_%d",kYGUserRemarkKeyName,currentLoginMemberId,memberId];
        [self.cache setObject:remarkName forKey:keyName withBlock:^{}];
    }
}

+(BOOL) hasRemarkName:(int) memberId
{
    BOOL hasRemark = NO;
    
    NSString *remarkName = [[YGUserRemarkCacheHelper shared] getUserRemarkName:memberId];
    
    if (remarkName && [remarkName isKindOfClass:[NSString class]] && [remarkName length] > 0) {
        hasRemark = YES;
    }
    
    return hasRemark;
}


@end
