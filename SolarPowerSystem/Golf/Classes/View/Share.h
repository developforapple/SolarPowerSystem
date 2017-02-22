//
//  Share.h
//  Eweek
//
//  Created by user on 13-9-17.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WXApi.h"
#import "WeiboSDK.h"

@interface Share : NSObject<WXApiDelegate>

@property (nonatomic,copy) NSString *title;
@property (nonatomic,copy) NSString *content;
@property (nonatomic,strong) UIImage *image;
@property (nonatomic,copy) NSString *url;
@property (nonatomic) enum WXScene scene;
@property (nonatomic) BOOL isSplit;
@property (nonatomic) int type;

- (id)initWithTitle:(NSString*)aTitle
            content:(NSString*)aContent
              image:(UIImage*)aImage
                url:(NSString*)aUrl
              scene:(enum WXScene)aScene;

- (BOOL) sendMsgToWX;
- (void) sendMsgToWB;
@end
