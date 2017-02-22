//
//  YGProfileEditor.m
//  Golf
//
//  Created by bo wang on 2016/12/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGProfileEditor.h"
#import "UserDetailModel.h"
#import "GTMBase64.h"

@interface YGProfileEditor ()
@end

@implementation YGProfileEditor

- (instancetype)initWithProfileModel:(UserDetailModel *)profileModel
{
    self = [super init];
    if (self) {
        self.profile = profileModel;
    }
    return self;
}

- (void)update:(NSDictionary<NSString *,id > *)updateInfo
{
    // values
    id nickNameValue            = updateInfo[YGProfileEditorInfoKeyNickName];
    id genderValue              = updateInfo[YGProfileEditorInfoKeyGender];
    id headImageValue           = updateInfo[YGProfileEditorInfoKeyHeadImage];
//    id photoImageValue          = updateInfo[YGProfileEditorInfoKeyPhotoImage];
    id birthdayValue            = updateInfo[YGProfileEditorInfoKeyBirthday];
    id signatureValue           = updateInfo[YGProfileEditorInfoKeySignature];
    id locationValue            = updateInfo[YGProfileEditorInfoKeyLocation];
    id handicaValue             = updateInfo[YGProfileEditorInfoKeyHandicap];
    id tagValue                 = updateInfo[YGProfileEditorInfoKeyTag];
    id academyIdValue           = updateInfo[YGProfileEditorInfoKeyAcademyId];
    id seniorityValue           = updateInfo[YGProfileEditorInfoKeySeniority];
    id introductionValue        = updateInfo[YGProfileEditorInfoKeyIntroduction];
    id careerAchievementValue   = updateInfo[YGProfileEditorInfoKeyCareerAchievement];
    id teachAchievementValue    = updateInfo[YGProfileEditorInfoKeyTeachAchievement];
    
    NSString *nickName;
    if ([nickNameValue isKindOfClass:[NSString class]]) {
        nickName = nickNameValue;
    }else if (nickNameValue == YGProfileEditorNullValue){
        nickName = @"";
    }
    
    int gender = self.profile.gender;
    if ([genderValue isKindOfClass:[NSNumber class]]) {
        gender = [genderValue intValue];
    }
    
    NSString *headImageData;
    if ([headImageValue isKindOfClass:[NSData class]]) {
        NSData *imageData = [GTMBase64 encodeData:headImageValue];
        headImageData = [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
    }
    
    NSString *photoImageData;
    
    NSString *birthday;
    if ([birthdayValue isKindOfClass:[NSString class]]) {
        birthday = birthdayValue;
    }else if (birthdayValue == YGProfileEditorNullValue){
        birthday = @"";
    }
    
    NSString *signature;
    if ([signatureValue isKindOfClass:[NSString class]]) {
        signature = signatureValue;
    }else if (signatureValue == YGProfileEditorNullValue){
        signature = @"";
    }
    
    NSString *location;
    if ([locationValue isKindOfClass:[NSString class]]) {
        location = locationValue;
    }else if (locationValue == YGProfileEditorNullValue){
        location = @"";
    }
    
    int handicap = self.profile.handicap;
    if ([handicaValue isKindOfClass:[NSNumber class]]) {
        handicap = [handicaValue intValue];
    }else if (handicaValue == YGProfileEditorNullValue){
        handicap = -100;
    }
    
    NSString *tag;
    if ([tagValue isKindOfClass:[NSString class]]) {
        tag = tagValue;
    }else if (tagValue == YGProfileEditorNullValue){
        tag = @"";
    }
    
    int academyId = self.profile.academyId;
    if ([academyIdValue isKindOfClass:[NSNumber class]]) {
        academyId = [academyIdValue intValue];
    }
    
    int seniority = self.profile.seniority;
    if ([seniorityValue isKindOfClass:[NSNumber class]]) {
        seniority = [seniorityValue intValue];
    }else if (seniorityValue == YGProfileEditorNullValue){
        seniority = 0;
    }
    
    NSString *intro;
    if ([introductionValue isKindOfClass:[NSString class]]) {
        intro = introductionValue;
    }else if (introductionValue == YGProfileEditorNullValue){
        intro = @"";
    }
    
    NSString *careerAchievement;
    if ([careerAchievementValue isKindOfClass:[NSString class]]) {
        careerAchievement = careerAchievementValue;
    }else if (careerAchievementValue == YGProfileEditorNullValue){
        careerAchievement = @"";
    }
    
    NSString *teachingAchievement;
    if ([teachAchievementValue isKindOfClass:[NSString class]]) {
        teachingAchievement = teachAchievementValue;
    }else if(teachAchievementValue == YGProfileEditorNullValue){
        teachingAchievement = @"";
    }
    
    [SVProgressHUD show];
    [ServerService userEditInfo:[[LoginManager sharedManager] getSessionId]
                     memberName:nil
                       nickName:nickName
                         gender:gender
                  headImageData:headImageData
                 photoImageData:photoImageData
                       birthday:birthday
                      signature:signature
                       location:location
                       handicap:handicap
                    personalTag:tag
                      academyId:academyId
                      seniority:seniority
                   introduction:intro
              careerAchievement:careerAchievement
            teachingAchievement:teachingAchievement
                        success:^(id data) {
                            [SVProgressHUD dismiss];
                            
                            NSString *msg;
                            
                            if (nickName) {
                                self.profile.nickName = nickName;
                            }
                            self.profile.gender = gender;
                            
                            if (headImageData) {
                                //修改了头像
                                NSDictionary *nd = [data firstObject];
                                NSString *url = nd[@"head_image"];
                                self.profile.headImage = url;
                                [LoginManager sharedManager].session.headImage = url;
                                msg = @"上传完成";
                            }
                            
//                            if (photoImageData) {
//                                self.profile.photeImage = photoImageData;
//                            }
                            if (birthday) {
                                self.profile.birthday = birthday;
                            }
                            if (signature) {
                                self.profile.signature = signature;
                            }
                            if (location) {
                                self.profile.location = location;
                                [LoginManager sharedManager].session.location = location;
                            }
                            self.profile.handicap = handicap;
                            if (tag) {
                                self.profile.personalTag = tag;
                            }
                            self.profile.academyId = academyId;
                            self.profile.seniority = seniority;
                            if (intro) {
                                self.profile.introduction = intro;
                            }
                            if (careerAchievement) {
                                self.profile.achievement = careerAchievement;
                            }
                            if (teachingAchievement) {
                                self.profile.teachHarvest = teachingAchievement;
                            }
                            if (self.completion) {
                                self.completion(YES,msg);
                            }
                        }
                        failure:^(HttpErroCodeModel *error) {
                            [SVProgressHUD dismiss];
                            if (self.completion) {
                                self.completion(NO,error.errorMsg);
                            }
                        }];
}

@end

NSString *const YGProfileEditorInfoKeyNickName = @"nickName";
NSString *const YGProfileEditorInfoKeyGender = @"gender";
NSString *const YGProfileEditorInfoKeyHeadImage = @"headImage";
//NSString *const YGProfileEditorInfoKeyPhotoImage = @"photoImage";
NSString *const YGProfileEditorInfoKeyBirthday = @"birthday";
NSString *const YGProfileEditorInfoKeySignature = @"signature";
NSString *const YGProfileEditorInfoKeyLocation = @"location";
NSString *const YGProfileEditorInfoKeyHandicap = @"handicap";
NSString *const YGProfileEditorInfoKeyTag = @"tag";
NSString *const YGProfileEditorInfoKeyAcademyId = @"academyId";
NSString *const YGProfileEditorInfoKeySeniority = @"seniority";
NSString *const YGProfileEditorInfoKeyIntroduction = @"introduction";
NSString *const YGProfileEditorInfoKeyCareerAchievement = @"careerAchievement";
NSString *const YGProfileEditorInfoKeyTeachAchievement = @"teachAchievement";
