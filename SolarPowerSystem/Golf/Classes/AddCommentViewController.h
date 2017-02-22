//
//  AddCommentViewController.h
//  Golf
//
//  Created by user on 13-6-5.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "StarView.h"
#import "UserCommentModel.h"
#import "LoginManager.h"
#import "YGEmojiKeyboardViewCtrl.h"

@protocol AddCommentDelegate <NSObject>

@optional
- (void)AddCommentSuccessRefreshData;

@end

@interface AddCommentViewController : YGEmojiKeyboardViewCtrl{
    IBOutlet UILabel *grassStatus;
    IBOutlet UILabel *serviceStatus;
    IBOutlet UILabel *difficultyStatus;
    IBOutlet UILabel *sceneryStatus;
    IBOutlet UIView *topView;
    IBOutlet UIView *footView;
    IBOutlet UILabel *wordsNumLabel;
    
    int _grassValue;
    int _serviceValue;
    int _difficultyValue;
    int _sceneryValue;

}

@property (nonatomic,strong) IBOutlet StarView *grassView;
@property (nonatomic,strong) IBOutlet StarView *serviceView;
@property (nonatomic,strong) IBOutlet StarView *difficultyView;
@property (nonatomic,strong) IBOutlet StarView *sceneryView;
@property (nonatomic,strong) UserCommentModel *userComment;
@property (nonatomic,weak) id<AddCommentDelegate> delegate;

@end
