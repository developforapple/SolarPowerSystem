//
//  SharePackage.h
//  Eweek
//
//  Created by user on 13-9-17.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDShareCommon.h"

typedef BOOL (^JudgeShareImageBlock) (NSArray *, int);

@protocol SharePackageDelegate <NSObject>

-(void)SharePackageRefreshTableviewCellShareImage:(NSDictionary*)dictionary judge:(JudgeShareImageBlock) judgeBlock;

@end

@interface SharePackage : NSObject{
    UIView *sharePanal;
    UIControl *control;
}

@property (nonatomic,copy) NSString *shareTitle;
@property (nonatomic,copy) NSString *shareContent;
@property (nonatomic,strong) UIImage *shareImg;
@property (nonatomic,copy) NSString *shareUrl;
@property (nonatomic,copy) NSString *shareUrlTem;
@property (nonatomic,assign) BOOL isShowView;
@property (nonatomic,assign) BOOL isNeedAddressBook;
@property (nonatomic,assign) BOOL isSplit;
@property (nonatomic,assign) BOOL isShowCommuty;
@property (nonatomic,assign) int type;
@property (nonatomic) int topicID;
@property (nonatomic) int tagId;
@property (nonatomic,strong) NSString *shareTopicNote;
@property (nonatomic) int shareTopicYunbi;
@property (nonatomic) int inviteNewUserYunbi;
@property (nonatomic,strong) NSString *inviteNewUserNote;
@property (nonatomic,strong) NSString *circleOfFriendsString;
@property (nonatomic) BOOL willSendToBackground;
//@property (nonatomic,copy) BlockReturn blockReturn;
@property (nonatomic) BOOL isInviteFriend;
@property (nonatomic) BOOL isInviteNewUser;
@property (nonatomic, strong) NSString *phoneNumber;
@property (nonatomic,assign) int activityID;

@property (weak, nonatomic) id <SharePackageDelegate> delegate;

- (id)initWithTitle:(NSString*)title content:(NSString*)content img:(UIImage *)img url:(NSString*)url;

- (void)shareInfoForView:(UIView*)view;

- (void)shareInfoForView:(UIView *)view callback:(void (^)(DDShareType))callback;


@end
