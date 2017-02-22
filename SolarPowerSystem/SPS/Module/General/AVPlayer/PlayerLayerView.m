//
//  PlayerLayerView.m
//  Golf
//
//  Created by 黄希望 on 14-1-17.
//  Copyright (c) 2014年 云高科技. All rights reserved.
//

#import "PlayerLayerView.h"

@interface PlayerLayerView ()
{
    struct {
        PlayerControlType type;    //调整类型
        BOOL isLeft;                //起点是否是屏幕左侧
        BOOL isBeginning;           //是否开始调整
        BOOL isEnd;                 //是否结束调整
        CGPoint startPoint;         //手势起点
        CGPoint translationPoint;   //手势相对起点位置
        CGFloat startVolume;        //初始音量
        CGFloat startBrightness;    //初始亮度
    } _state;
}
@end

@implementation PlayerLayerView
@synthesize player;
@synthesize delegate;

+(Class)layerClass{
    return [AVPlayerLayer class];
}

-(AVPlayer*)player{
    return [(AVPlayerLayer*)[self layer]player];
}

-(void)setPlayer:(AVPlayer *)thePlayer{
    UITapGestureRecognizer *tagGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(gestureRecognizerAction:)];
    [self addGestureRecognizer:tagGestureRecognizer];
    
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panAction:)];
    pan.maximumNumberOfTouches = 1;
    [self addGestureRecognizer:pan];
    
    return [(AVPlayerLayer*)[self layer]setPlayer:thePlayer];
}

- (void)gestureRecognizerAction:(UITapGestureRecognizer*)tapGesture{
    if ([self.delegate respondsToSelector:@selector(touchShowHideControlPanel)]) {
        [self.delegate touchShowHideControlPanel];
    }
}

- (void)panAction:(UIPanGestureRecognizer *)gr
{
    UIGestureRecognizerState gestureState = gr.state;
    CGPoint point = [gr translationInView:self];
    
    switch (gestureState) {
        case UIGestureRecognizerStateBegan: {
            CGPoint startPoint = [gr locationInView:self];
            BOOL isLeft = startPoint.x < CGRectGetWidth(self.frame)/2.f;
            
            _state.isLeft = isLeft;
            _state.startPoint = startPoint;
            _state.startBrightness = [UIScreen mainScreen].brightness;
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            CGFloat xx = point.x;
            CGFloat yy = point.y;
            
            if (!_state.isBeginning) {
                _state.isBeginning = YES;
                if ([self.delegate respondsToSelector:@selector(playerLayer:currentVolume:)]) {
                    [self.delegate playerLayer:self currentVolume:&_state.startVolume];
                }else{
                    _state.startVolume = .5f;
                }
                
                if (yy != 0.f) {
                    CGFloat angle = atan(fabs(xx)/fabs(yy));//与垂直方向的夹角
                    if (angle > M_PI_2/3*2) { //大于60°。左右滑动调整进度
                        
                    }else if (angle < M_PI_2/3){ //小于30°。上下滑动
                        if (_state.isLeft) {
                            _state.type = PlayerControlTypeBrightness; //左侧调整亮度
                        }else{
                            _state.type = PlayerControlTypeVolume;//右侧调整音量
                        }
                    }
                }
            }
            
            _state.translationPoint = point;
            [self _callback:NO];
            
            break;
        }
        case UIGestureRecognizerStateEnded:
        case UIGestureRecognizerStateCancelled: {
            [self _callback:YES];
            [self _resetState];
            break;
        }
        case UIGestureRecognizerStateFailed: {
            [self _resetState];
            break;
        }
        default:break;
    }
}

- (void)_callback:(BOOL)didEnd
{
    switch (_state.type) {
        case PlayerControlTypeNone: {
            break;
        }
        case PlayerControlTypeVolume: {
            static CGFloat baseVolumeDistance = 20.f;   //移动20，音量改变 0.1
            CGFloat value = -0.1f * _state.translationPoint.y / baseVolumeDistance; //向下滑动 y 为正值，实际需要减小音量
            CGFloat startVolume = _state.startVolume;
            value+=startVolume;
            
            if ([self.delegate respondsToSelector:@selector(playerLayer:panGesture:value:finished:)]) {
                [self.delegate playerLayer:self panGesture:_state.type value:value finished:didEnd];
            }
            break;
        }
        case PlayerControlTypeBrightness: {
            static CGFloat baseBrightnessDistance = 20.f;
            CGFloat value = -0.1f * _state.translationPoint.y / baseBrightnessDistance;
            value+=_state.startBrightness;
            
            if ([self.delegate respondsToSelector:@selector(playerLayer:panGesture:value:finished:)]) {
                [self.delegate playerLayer:self panGesture:_state.type value:value finished:didEnd];
            }
            break;
        }
        default:break;
    }
}

#pragma mark - state
- (void)_resetState
{
    _state.type = PlayerControlTypeNone;
    _state.isLeft = NO;
    _state.isBeginning = NO;
    _state.isEnd = YES;
    _state.startPoint = CGPointZero;
    _state.translationPoint = CGPointZero;
    _state.startVolume = 0.f;
    _state.startBrightness = 0.f;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    x = (touchPoint.x);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint touchPoint = [touch locationInView:self];
    
    NSLog(@"%.2f, %.2f",touchPoint.x,touchPoint.y);
    
    if (self.tag != 100) {
        if ((touchPoint.x - x) >= 50) {
            if ([self.delegate respondsToSelector:@selector(touchMoveForwardBackWithDirection:)])
            {
                [self.delegate touchMoveForwardBackWithDirection:1];
            }
        }else{
            if ([self.delegate respondsToSelector:@selector(touchMoveForwardBackWithDirection:)])
            {
                [self.delegate touchMoveForwardBackWithDirection:-1];
            }
        }
    }
}



@end
