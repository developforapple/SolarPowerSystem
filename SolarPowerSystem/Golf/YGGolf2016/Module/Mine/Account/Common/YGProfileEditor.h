//
//  YGProfileEditor.h
//  Golf
//
//  Created by bo wang on 2016/12/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@class UserDetailModel;

@interface YGProfileEditor : NSObject

@property (strong, nonatomic) UserDetailModel *profile;

- (instancetype)initWithProfileModel:(UserDetailModel *)profileModel;

@property (copy, nonatomic) void (^completion)(BOOL suc,NSString *msg);

- (void)update:(NSDictionary<NSString *,id > *)updateInfo;

@end

// 标记这个key需要清空对应的值。只有部分key支持。
#define YGProfileEditorNullValue [NSNull null]

// updateInfo keys
// 昵称 v:NSString
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyNickName;
// 性别 v:NSNumner
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyGender;
// 头像 v:NSData
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyHeadImage;
// 照片 v:NSData
//FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyPhotoImage;
// 生日 v:NSString 1900-01-01
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyBirthday;
// 个性签名 v:NSString
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeySignature;
// 位置 v:NSString
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyLocation;
// 差点 v:NSNumber
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyHandicap;
// 标签 v:NSString 逗号分隔符分隔
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyTag;
// 学院id v:NSNumber
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyAcademyId;
// 教龄 v:NSNumber
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeySeniority;
// 个人简介 v:NSString
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyIntroduction;
// 职业生涯成就 v:todo
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyCareerAchievement;
// 教练成就  v:todo
FOUNDATION_EXTERN NSString *const YGProfileEditorInfoKeyTeachAchievement;
