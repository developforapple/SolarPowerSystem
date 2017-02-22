//
//  YGUserRemarkCacheHelper.h
//  Golf
//
//  Created by 梁荣辉 on 2016/10/12.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

// 缓存全部备注的DB名称
extern NSString *const kYGYGUserRemarkDBName;

// 缓存备注的单个key值  key 值 + 目前登录用户Id + 被备注的用户Id 【例如：UserRemark_Sid_1000_Uid_10020】
extern NSString *const kYGUserRemarkKeyName;

@interface YGUserRemarkCacheHelper : NSObject

+ (instancetype)shared;

/**
 缓存用户备注相关信息

 @param userRemarkDictArray 当前登录用户的备注信息集合
 */
-(void) cacheUserAllRemarkNames:(NSArray *) userRemarkDictArray;

/**
 根据用户Id获取用户的备注信息

 @param memberId 用户Id

 @return 返回用户的备注信息
 */
-(NSString *) getUserRemarkName:(int) memberId;

/**
 根据用户Id 更新 用户备注相关信息【如果不存在，直接添加】
 
 @param remarkName 备注名称
 @param memberId   用户Id
 */
-(void) updateUserRemarkName:(NSString *) remarkName memberId:(int) memberId;

/**
 判断是否有备注【且备注不能为空】

 @param memberId 被备注的用户Id

 @return YES 有备注且备注不为空
 */
+(BOOL) hasRemarkName:(int) memberId;

@end
