//
//  NoResultView.h
//  Golf
//
//  Created by 黄希望 on 15/5/28.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, NoResultType) {
    NoResultTypeBill,
    NoResultTypeList,
    NoResultTypeSearch,
    NoResultTypeWifi,
};

@interface NoResultView : UIView

+ (NoResultView *)text:(NSString *)text type:(NoResultType)type superView:(UIView *)sv show:(void(^)(void))show hide:(void(^)(void))hide;
+ (NoResultView *)text:(NSString *)text type:(NoResultType)type superView:(UIView *)sv
              btnTaped:(void (^)(void))btnTaped
                  show:(void (^)(void))show
                  hide:(void (^)(void))hide;
 

- (void)show:(BOOL)isShow;

@end
