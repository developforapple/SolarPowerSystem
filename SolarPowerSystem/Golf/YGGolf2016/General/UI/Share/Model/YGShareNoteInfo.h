//
//  YGShareNoteInfo.h
//  Golf
//
//  Created by bo wang on 16/5/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, YGShareNoteType) {
    YGShareNoteTypeShare,   //分享
    YGShareNoteTypeInvite,  //邀请
};

@interface YGShareNoteInfo : NSObject

@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *desc;
@property (strong, nonatomic) NSString *prompt;

@property (assign, nonatomic) NSUInteger coins;

@property (strong, readonly, nonatomic) NSAttributedString *attributedDesc;
@property (assign, readonly, nonatomic) YGShareNoteType type;

- (instancetype)initWithType:(YGShareNoteType)type
                        desc:(NSString *)desc NS_DESIGNATED_INITIALIZER;

@end
