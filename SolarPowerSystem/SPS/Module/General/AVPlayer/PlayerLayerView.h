//
//  PlayerLayerView.h
//  Golf
//
//  Created by 黄希望 on 14-1-17.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

typedef NS_ENUM(NSUInteger, PlayerControlType) {
    PlayerControlTypeNone,
    PlayerControlTypeVolume,
    PlayerControlTypeBrightness,
};

@class PlayerLayerView;
@protocol PlayerLayerViewMoveDelegate <NSObject>

@optional
- (void)touchMoveForwardBackWithDirection:(int)direction;
- (void)touchShowHideControlPanel;

- (void)playerLayer:(PlayerLayerView *)view currentVolume:(CGFloat *)volume;
- (void)playerLayer:(PlayerLayerView *)view panGesture:(PlayerControlType)type value:(CGFloat)value finished:(BOOL)finished;

@end

@interface PlayerLayerView : UIView{
    float x;
}

@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,weak) id<PlayerLayerViewMoveDelegate> delegate;

@end
