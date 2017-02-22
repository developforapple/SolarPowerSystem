//
//  CustomImgView.h
//  Golf
//
//  Created by user on 13-3-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    ImageStyleNome = 0,
    ImageStyleRoundRect
}ImageStyle;

@protocol CustomImgViewDelegate;

@interface CustomImgView : UIImageView

@property (nonatomic,weak) id<CustomImgViewDelegate> delegate;
- (id)initWithFrame:(CGRect)frame withStyle:(ImageStyle)style Istouch:(BOOL)touch;

@end

@protocol CustomImgViewDelegate <NSObject>

@optional
- (void)tapgestureAction:(UITapGestureRecognizer *)tapGestureRecognizer;

@end