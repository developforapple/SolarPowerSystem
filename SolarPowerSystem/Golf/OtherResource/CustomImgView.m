//
//  CustomImgView.m
//  Golf
//
//  Created by user on 13-3-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "CustomImgView.h"

@implementation CustomImgView
@synthesize delegate;

- (id)initWithFrame:(CGRect)frame withStyle:(ImageStyle)style Istouch:(BOOL)touch
{
    self = [super initWithFrame:frame];
    if (self) {
        if (touch) {
            self.userInteractionEnabled = YES;
            UITapGestureRecognizer *tapgesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(doneAction:)];
            [self addGestureRecognizer:tapgesture];
        }
        if (style > ImageStyleNome) {
            UIImageView *topImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_0.png"]];
            topImg.tag = 1;
            [topImg setFrame:CGRectMake(0, 0, frame.size.width, 12)];
            [self addSubview:topImg];
            
            UIImageView *bottomImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_2.png"]];
            bottomImg.tag = 3;
            [bottomImg setFrame:CGRectMake(0, frame.size.height - 22, frame.size.width, 22)];
            
            UIImageView *midImg = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_1.png"]];
            midImg.tag = 2;
            [midImg setFrame:CGRectMake(0, topImg.frame.size.height, frame.size.width, frame.size.height - 22)];
            [self addSubview:midImg];
            [self addSubview:bottomImg];
            
        }
        else{
            UIImageView *img = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"img_1.png"]];
            [img setFrame:self.frame];
            [self addSubview:img];
        }
    }
    return self;
}

- (void)doneAction:(UITapGestureRecognizer*)tapGestureRecognizer{
    if ([delegate respondsToSelector:@selector(tapgestureAction:)]) {
        [delegate performSelector:@selector(tapgestureAction:) withObject:tapGestureRecognizer];
    }
}

@end
