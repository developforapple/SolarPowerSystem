//
//  UIView+YGGeometry.h
//  Golf
//
//  Created by bo wang on 2016/12/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (YGGeometry)

@property (setter=yg_setX:) CGFloat yg_x;
@property (setter=yg_setY:) CGFloat yg_y;
@property (setter=yg_setOrigin:) CGPoint yg_origin;
@property (readonly) CGFloat yg_maxX;
@property (readonly) CGFloat yg_maxY;

@property (setter=yg_setW:) CGFloat yg_w;
@property (setter=yg_setH:) CGFloat yg_h;
@property (setter=yg_setSize:) CGSize yg_size;

@property (setter=yg_setCenterX:) CGFloat yg_centerX;
@property (setter=yg_setCenterY:) CGFloat yg_centerY;

@end
