//
//  Player.m
//  Golf
//
//  Created by 黄希望 on 15/7/13.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "Player.h"
#import <AVFoundation/AVFoundation.h>
#import "PlayerLayerView.h"
#import "KDScrollView.h"
#import "UIImage+ImageEffects.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "CCActionSheet.h"
#import "YGCoreMotionHelper.h"
#import "DDVideoPlayerIndicatorView.h"
#import <MediaPlayer/MediaPlayer.h>

#define KdurationDelayTime 5.0f
#define KbufferLength 10.0f

@implementation UIApplication (ALAppDimensions)

+ (CGSize)sizeInOrientation:(UIInterfaceOrientation)orientation {
    CGSize size = [UIScreen mainScreen].bounds.size;
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        size = CGSizeMake(size.height, size.width);
    }
    return size;
}

@end

@interface Player ()<PlayerLayerViewMoveDelegate,KDScrollViewDataSource,UITableViewDelegate,UITableViewDataSource>{
    CGFloat     totalMovieDuration;
    CGFloat     currentDuration;
    BOOL        isPlaying;
    
    BOOL    _isFullScreen;
    BOOL    _isTableViewExist;
    BOOL    _isShowing;
    float   _pubbleTime;
    float   _lastScrollTime;
    NSInteger   lastSelectIndex;
    NSTimeInterval  slowPlaySleepTime;
    
    UITableView *_tableView;
    UIToolbar *tb;
    
    UIInterfaceOrientation lastOrientation;
}

@property (nonatomic,assign) BOOL isSupportSlowedPlay;
@property (nonatomic,assign) BOOL isSupportCircle;
@property (nonatomic,strong) NSString *viderUrl;
@property (nonatomic,copy) void (^completion)(void);

// 界面属性
@property (nonatomic,strong) AVPlayer *player;
@property (nonatomic,strong) AVPlayerItem *playerItem;
@property (nonatomic,strong) IBOutlet PlayerLayerView *layerView;

@property (nonatomic,weak) IBOutlet UIButton *playPauseBtn;
@property (nonatomic,weak) IBOutlet UIButton *fullScreenBtn;
@property (nonatomic,weak) IBOutlet UIButton *pubbleBtn;
@property (nonatomic,weak) IBOutlet KDScrollView *kdScrollView;
@property (nonatomic,weak) IBOutlet UIActivityIndicatorView *activityView;
@property (nonatomic,weak) IBOutlet UILabel *timeLabel;
@property (nonatomic,weak) IBOutlet UIView *slowBtnView;
@property (nonatomic,weak) IBOutlet UIButton *slowBtn;
@property (nonatomic,weak) IBOutlet UISlider *progressSliderView;
@property (nonatomic,weak) IBOutlet UIView *botView;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet DDVideoPlayerIndicatorView *playerIndicator;

@property (strong, nonatomic) YGCoreMotionHelper *cmHelper;

@property (strong, nonatomic) MPVolumeView *volumeView;

- (IBAction)playPauseBtnAction:(id)sender;
- (IBAction)fullScreenAction:(id)sender;
- (IBAction)slowPlayAction:(id)sender;
- (IBAction)backAction:(id)sender;

- (void) initializesVideo;
- (void) switchPlayStatus:(BOOL)isPlay;
- (void) videoStartWithurl:(NSString*)url;
- (void) rotateMoviePlayerForOrientation:(UIInterfaceOrientation)orientation;

- (CGFloat)getVideoTotalTime:(AVPlayerItem *)aPlayerItem;
- (CGFloat)getVideoCurrentTime:(AVPlayerItem *)aCurrentItem;
- (CGFloat)getVideoLoadedDuration:(AVPlayerItem *)aCurrentItem;
- (void)setTimeLabelTextWithDuration1:(CGFloat)d1 Duration2:(CGFloat)d2;

@end

@implementation Player

+ (instancetype)playWithUrl:(NSString*)url
                         rt:(CGRect)rt
              supportSlowed:(BOOL)sptSlowed
              supportCircle:(BOOL)sptCircle
                         vc:(UIViewController*)vc
                 completion:(void(^)(void))completion{
    
    NSString *sbName = sptSlowed ? @"Player_slow" : @"Player_unslow";
    Player *player = [Player instanceFromStoryboardWithIdentifier:sbName];

    player.isSupportSlowedPlay = sptSlowed;
    player.isSupportCircle = sptCircle;
    player.viderUrl = url;
    player.completion = completion;
    [vc.view addSubview:player.view];
    [vc addChildViewController:player];

    player.view.frame = rt;
    [UIView animateWithDuration:0.5 animations:^{
        player.view.frame = CGRectMake(0, 0, Device_Width, Device_Height);
    } completion:^(BOOL finished) {
        player.botView.hidden = NO;
    }];
    
    [player videoStartWithurl:url];

    return player;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initializesVideo];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    self.navigationController.navigationBarHidden=YES;
    if (!isPlaying) {
        [self.player play];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [self.player pause];
    isPlaying=NO;
    [GolfAppDelegate shareAppDelegate].window.backgroundColor = [UIColor whiteColor];//lyf 加 改回window的颜色
}

- (void)initializesVideo{
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deviceOrientationDidChange:) name:kYGDeviceOrientationDidChangedNotification object:nil];
    
    self.cmHelper = [[YGCoreMotionHelper alloc] init];
//    self.cmHelper.logEnabled = YES;
    [self.cmHelper startMonitorOrientation];
    
    [[UIApplication sharedApplication] setIdleTimerDisabled: YES];

    [GolfAppDelegate shareAppDelegate].window.backgroundColor = [UIColor blackColor];
    
    _isFullScreen = NO;
    _isShowing = YES;
    _lastScrollTime = 0;
    if (_isSupportSlowedPlay) {
        _pubbleBtn.alpha = 0.0;
    }
    
    self.progressSliderView.value = 0;
    
    [self.progressSliderView setThumbImage:[UIImage imageNamed:@"slider.png"] forState:UIControlStateNormal];
    [self.progressSliderView addTarget:self action:@selector(sliderDidBegin:) forControlEvents:UIControlEventTouchDown];
    [self.progressSliderView addTarget:self action:@selector(sliderIsScrolling:) forControlEvents:UIControlEventValueChanged];
    [self.progressSliderView addTarget:self action:@selector(sliderDidEnd:) forControlEvents:(UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside)];
    
    [_activityView startAnimating];
    
    [self rotateMoviePlayerForOrientation:UIInterfaceOrientationPortrait];
}

- (void) videoStartWithurl:(NSString*)url{
    //url = @"http://v1.swwy.com/91/91/8740/MD4-O3A8Pg.mp4";
    AVPlayerItem *aPlayerItem;
    NSRange range;
    range.length=1;
    range.location=0;
    if ([[url substringWithRange:range] isEqualToString:@"/"]) {
        aPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL fileURLWithPath:url]];//动态列表已经显示，但其实未发布时候的预览
    }else{
        aPlayerItem = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:url]];
    }
    AVPlayer *aPlayer = [AVPlayer playerWithPlayerItem:aPlayerItem];
    AVPlayerLayer *aPlayerLayer = [AVPlayerLayer playerLayerWithPlayer:aPlayer];
    aPlayerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    [self.layerView setPlayer:aPlayer];
    self.layerView.delegate = self;
    self.player = aPlayer;
    self.playerItem = aPlayerItem;
    
    _isTableViewExist = NO;
    [self.player play];
    [self switchPlayStatus:YES];
    
    
    //检测视频加载状态，加载完成隐藏风火轮
    [self.player.currentItem addObserver:self forKeyPath:@"status"
                                 options:NSKeyValueObservingOptionNew
                                 context:nil];
    
    //添加视频播放完成的 notifation
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:self.player.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidPlaybackStakked:) name:AVPlayerItemPlaybackStalledNotification object:self.player.currentItem];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillResignActive:)name:UIApplicationWillResignActiveNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:)name:UIApplicationDidBecomeActiveNotification object:nil];
    
    __weak Player *blockSelf = self;
    __weak UIButton *button = _pubbleBtn;
    [self.player addPeriodicTimeObserverForInterval:CMTimeMake(1, 5) queue:NULL usingBlock:^(CMTime time){
        CGFloat _totalDuration = [blockSelf getVideoTotalTime:blockSelf.playerItem];
        CGFloat _currentDuration = [blockSelf getVideoCurrentTime:blockSelf.player.currentItem];
        blockSelf.progressSliderView.value = _currentDuration/_totalDuration;
        
        if (blockSelf.isSupportSlowedPlay) {
            [blockSelf setPubbleBtnPosition];
            
            NSDate *d = [NSDate dateWithTimeIntervalSince1970:_currentDuration];
            NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
            [formatter setDateFormat:@"ss.SSSSSS"];
            NSString *ss = [formatter stringFromDate:d];
            NSString *text = nil;
            
            if ([ss floatValue] < 10.) {
                text = [NSString stringWithFormat:@"0%2.02f",[ss floatValue]];
            }else{
                text = [NSString stringWithFormat:@"%.02f",[ss floatValue]];
            }
            [button setTitle:text forState:UIControlStateNormal];
        }
        
        [blockSelf setTimeLabelTextWithDuration1:_currentDuration Duration2:_totalDuration];
    }];
}

// 调整滑块的Leading约束
- (void)setPubbleBtnPosition{
    for (NSLayoutConstraint *con in self.layerView.constraints) {
        if (con.firstAttribute == NSLayoutAttributeLeading && con.firstItem == _pubbleBtn) {
            con.constant = _progressSliderView.yg_x+(_progressSliderView.width-13)*_progressSliderView.value+6.5;
        }
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"status"]) {
        AVPlayerItem *playerItem = (AVPlayerItem*)object;
        if (playerItem.status == AVPlayerStatusReadyToPlay) {
            [_activityView stopAnimating];
            _activityView.hidden = YES;
        }
    }
}

- (IBAction)playPauseBtnAction:(id)sender{
    [self switchPlayStatus:!isPlaying];
}

- (IBAction) fullScreenAction:(id)sender{
    if (_isFullScreen) {
        [self rotateMoviePlayerForOrientation:UIInterfaceOrientationPortrait];
    }else{
        [self rotateMoviePlayerForOrientation: UIInterfaceOrientationIsPortrait(lastOrientation) ?  UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    }
}

- (IBAction) slowPlayAction:(id)sender{
    if (!_isTableViewExist) {
        [self tableviewAppear];
    }else{
        [self tableviewDisAppear];
    }
    _isTableViewExist = !_isTableViewExist;
}

- (IBAction)backAction:(id)sender{
    if (lastOrientation == UIInterfaceOrientationPortrait) {
        [self.player pause];

        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(showControlPanel) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(waitDataBuffering) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slowPlay) object:nil];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pubDisappear) object:nil];

        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];

        [self.player.currentItem removeObserver:self forKeyPath:@"status" context:nil];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemPlaybackStalledNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification object:nil];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationDidBecomeActiveNotification object:nil];
        
//        [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
        [self.cmHelper endMonitorOrientation];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:kYGDeviceOrientationDidChangedNotification object:nil];
        
        [[UIApplication sharedApplication] setIdleTimerDisabled: NO];
        
        if (_completion) {
            _completion ();
        }
        
        if (self.presentingViewController) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }else{
            [self.view removeFromSuperview];
            [self removeFromParentViewController];
        }
        
    }else{
        [self rotateMoviePlayerForOrientation: UIInterfaceOrientationIsPortrait(lastOrientation) ?  UIInterfaceOrientationLandscapeRight : UIInterfaceOrientationPortrait];
    }
}

#pragma mark - UITableView 相关
- (void)tableviewAppear{
    if (!_tableView) {
        _slowBtnView.alpha = 0.f;
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(-8, self.botView.frame.origin.y - 160 , 55, 160) style:UITableViewStylePlain];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.scrollEnabled = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.alpha = 0.f;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        tb = [[UIToolbar alloc] initWithFrame:_tableView.frame];
        tb.barStyle = UIBarStyleBlack;
        tb.translucent = YES;
        [self.view addSubview:tb];
        [self.view addSubview:_tableView];
        
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.alpha = 0.7f;
        } completion:^(BOOL finished) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
        }];
    }
}

- (void)tableviewDisAppear{
    if (_tableView) {
        _slowBtnView.alpha = 0.6f;
        [UIView animateWithDuration:0.3 animations:^{
            _tableView.alpha = 0.f;
            tb.alpha = 0.f;
        } completion:^(BOOL finished) {
            [_tableView removeFromSuperview];
            _tableView = nil;
            [tb removeFromSuperview];
            tb = nil;
        }];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 4;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor blackColor];
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == lastSelectIndex) {
        cell.textLabel.textColor = MainHighlightColor;
    }
    
    NSArray *titleArray = [NSArray arrayWithObjects:@"1/1",@"1/2",@"1/4",@"1/8",nil];
    cell.textLabel.text = [titleArray objectAtIndex:indexPath.row];
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    switch (indexPath.row) {
        case 0:
            [_slowBtn setTitle:@"慢放" forState:UIControlStateNormal];
            break;
        case 1:
            [_slowBtn setTitle:@"1/2" forState:UIControlStateNormal];
            break;
        case 2:
            [_slowBtn setTitle:@"1/4" forState:UIControlStateNormal];
            break;
        case 3:
            [_slowBtn setTitle:@"1/8" forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    lastSelectIndex = indexPath.row;
    _isTableViewExist = !_isTableViewExist;
    [self switchPlayStatus:isPlaying];
    [self tableviewDisAppear];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (void)switchPlayStatus:(BOOL)isPlay{
    isPlaying = isPlay;
    
    if(isPlaying) {
        if(currentDuration >= totalMovieDuration) {
            [self.player.currentItem seekToTime:CMTimeMake(0, 1)];
            currentDuration = 0;
        }else{
            [self reCountHideControlPanel];
        }
        [_playPauseBtn setImage:[UIImage imageNamed:@"ic_pause.png"] forState:UIControlStateNormal];
    }
    else {
        [_playPauseBtn setImage:[UIImage imageNamed:@"ic_play.png"] forState:UIControlStateNormal];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
        [self reCountHideControlPanel];
    }
    if ([_activityView isAnimating]) {
        return;
    }
    if(lastSelectIndex == 0) {
        if (isPlaying) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slowPlay) object:nil];
            [self.player play];
        }else{
            [self.player pause];
        }
    } else if(isPlaying) {
        slowPlaySleepTime = pow(2, lastSelectIndex) * 0.04;
        [self.player pause];
        [self performSelector:@selector(slowPlay) withObject:nil afterDelay:0];
    }
    
    if(!isPlaying && !_activityView.hidden) {
        _activityView.hidden = NO;
        [_activityView startAnimating];
    }
}

- (void)slowPlay{
    if(isPlaying) {
        if(currentDuration < totalMovieDuration) {
            [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(slowPlay) object:nil];
            [self.player.currentItem stepByCount:1];
            [self performSelector:@selector(slowPlay) withObject:nil afterDelay:slowPlaySleepTime];
        } else {
            [self switchPlayStatus:NO];
        }
    }
}

#pragma mark - NSNOTIFICATION
-(void)moviePlayDidEnd:(NSNotification *)notification{
    if (self.isSupportCircle) {
        [self switchPlayStatus:YES];
    }else{
        [self switchPlayStatus:NO];
    }
}

- (void) rotateMoviePlayerForOrientation:(UIInterfaceOrientation)orientation{
    if(lastOrientation == orientation) {
        return;
    }
    
    CGFloat angle;
    CGRect avplayerFrame;
    CGSize windowSize = [UIApplication sizeInOrientation:orientation];
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            angle = - M_PI_2;
            avplayerFrame = CGRectMake(0, 0, windowSize.height, windowSize.width);
            break;
        case UIInterfaceOrientationLandscapeRight:
            angle = M_PI_2;
            avplayerFrame = CGRectMake(0, 0, windowSize.height, windowSize.width);
            break;
        default:
            angle = 0.f;
            if(windowSize.width < windowSize.height) {
                avplayerFrame = CGRectMake(0, 0, windowSize.width, windowSize.height);
            } else {
                avplayerFrame = CGRectMake(0, 0, windowSize.height, windowSize.width);
            }
            break;
    }
    lastOrientation = orientation;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        _isFullScreen = YES;
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ic_halfscreen.png"] forState:UIControlStateNormal];

        if(!_isShowing)
            [self hideControlPanel];
        else
            [self showControlPanel];
        
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }else{
        _isFullScreen = NO;
        [_fullScreenBtn setImage:[UIImage imageNamed:@"ic_fullscreen.png"] forState:UIControlStateNormal];

        [self showControlPanel];
        
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    }
    
    [UIView animateWithDuration:0.3 animations:^{
        self.view.transform = CGAffineTransformMakeRotation(angle);
        self.view.frame = avplayerFrame;
//        [GolfAppDelegate shareAppDelegate].naviController.view.transform = CGAffineTransformMakeRotation(angle);
//        [GolfAppDelegate shareAppDelegate].naviController.view.frame = avplayerFrame;
    }];
}


- (CGFloat)getVideoTotalTime:(AVPlayerItem *)aPlayerItem{
    CMTime totalTime = aPlayerItem.duration;
    return (CGFloat)totalTime.value/totalTime.timescale;
}

- (CGFloat)getVideoCurrentTime:(AVPlayerItem *)aCurrentItem{
    CMTime currentTime = aCurrentItem.currentTime;
    return (CGFloat)currentTime.value/currentTime.timescale;
}

- (CGFloat)getVideoLoadedDuration:(AVPlayerItem *)aCurrentItem{
    NSArray *loadedTimeRanges = [aCurrentItem loadedTimeRanges];
    if ([loadedTimeRanges count] > 0) {
        CMTimeRange timeRange = [[loadedTimeRanges objectAtIndex:0] CMTimeRangeValue];
        float startSeconds = CMTimeGetSeconds(timeRange.start);
        float durationSeconds = CMTimeGetSeconds(timeRange.duration);
        return (startSeconds + durationSeconds);
    } else {
        return 0.0f;
    }
}

- (void)setTimeLabelTextWithDuration1:(CGFloat)d1 Duration2:(CGFloat)d2{
    currentDuration = d1; totalMovieDuration = d2;
    NSString *curStr = [self formatterDateWithDuration:d1];
    NSString *totStr = [self formatterDateWithDuration:d2];
    _timeLabel.text = [NSString stringWithFormat:@"%@/%@",curStr,totStr];
}

- (NSString*)formatterDateWithDuration:(CGFloat)duration{
    NSDate *date = [NSDate dateWithTimeIntervalSince1970:duration];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if (duration/3600 >= 1)
        [formatter setDateFormat:@"HH:mm:ss"];
    else
        [formatter setDateFormat:@"mm:ss"];
    return [formatter stringFromDate:date];
}


#pragma mark - NSNotification
-(void)applicationWillResignActive:(NSNotification *)notification{
    
    NSLog(@"applicationWillResignActive");
    
    if(isPlaying) {
        [self switchPlayStatus:NO];
        isPlaying = YES;
    }
}

- (void)applicationDidBecomeActive:(NSNotification *)notification{
    
    NSLog(@"applicationDidBecomeActive");
    
    if (isPlaying) {
        [self switchPlayStatus:YES];
    }
}

-(void)moviePlayDidPlaybackStakked:(NSNotification *)notification{
    if(isPlaying) {
        [self.player pause];
        _activityView.hidden = NO;
        [_activityView startAnimating];
        [self performSelector:@selector(waitDataBuffering) withObject:nil afterDelay:0.1];
    }
}

- (void)waitDataBuffering {
    float bufferTime = [self getVideoLoadedDuration:self.player.currentItem];
    if(totalMovieDuration > 0 && (bufferTime >= totalMovieDuration || bufferTime - currentDuration >= (totalMovieDuration > 10 ? 3.0f : KbufferLength))) {
        if (isPlaying) {
            [self.player play];
        }
        _activityView.hidden = YES;
        [_activityView stopAnimating];
    } else {
        [self performSelector:@selector(waitDataBuffering) withObject:nil afterDelay:0.1];
    }
}


#pragma mark - UISlider
- (void)sliderDidBegin:(UISlider *)slider{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(pubDisappear) object:nil];
    [self.player pause];
}

- (void)sliderIsScrolling:(UISlider *)slider{
    double currentTime = floor(totalMovieDuration *self.progressSliderView.value);
    CMTime dragedCMTime = CMTimeMake(currentTime, 1);
    [self.player seekToTime:dragedCMTime];
}

- (void)sliderDidEnd:(UISlider *)slider{
    if (isPlaying == YES)
    {
        [self.player play];
    }
    [self performSelector:@selector(hideControlPanel) withObject:nil afterDelay:KdurationDelayTime];
    [self performSelector:@selector(pubDisappear) withObject:nil afterDelay:KdurationDelayTime];
}

#pragma mark KDScrollView dataSource
- (UIImageView *)infiniteImgView:(KDScrollView *)kscrollview forIndex:(NSInteger)index{
    UIImageView *imgv = [kscrollview dequeueReusableImg];
    if (imgv == nil) {
        imgv = [[UIImageView alloc] initWithFrame:CGRectMake(0, 25, 6.0, 23)];
    }
    return imgv ;
}

- (NSUInteger)numberOfInfiniteImgs{
    return Device_Height*2/6;
}

- (void)touchWithStatus:(int)status{
    if(status == 0){
        [self performSelector:@selector(pubDisappear) withObject:nil afterDelay:KdurationDelayTime];
    } else {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
    }
}

- (void)handleAction:(int)direction{
    if(self.player.currentItem.status != AVPlayerItemStatusReadyToPlay) {
        return;
    }
    [self switchPlayStatus:NO];
    
    _pubbleBtn.alpha = 1.f;
    
    if(direction > 0 && currentDuration>=totalMovieDuration) {
        [self.player.currentItem seekToTime:CMTimeMake(0,1)];
    } else if(direction < 0  && currentDuration<=0) {
        [self.player.currentItem seekToTime:CMTimeMake(totalMovieDuration,1)];
    }
    [self.player.currentItem stepByCount: direction];
}

#pragma mark - 面板控制相关
- (void)showControlPanel{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
    if(!_isShowing) {
        _slowBtnView.alpha = 1.0f;
        _progressSliderView.alpha = 1.0f;
        _botView.alpha = 1.f;
    }
    if(isPlaying) {
        [self performSelector:@selector(hideControlPanel) withObject:nil afterDelay:KdurationDelayTime];
    }
    if (!UIInterfaceOrientationIsLandscape(lastOrientation)) {
        [[UIApplication sharedApplication] setStatusBarHidden:![UIApplication sharedApplication].statusBarHidden withAnimation:UIStatusBarAnimationFade];
    }
    _isShowing = YES;
}

- (void)hideControlPanel{
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideControlPanel) object:nil];
    if ( _isShowing) {
        _isTableViewExist = NO;
        [self tableviewDisAppear];
        self.botView.alpha = 0.f;
        self.progressSliderView.alpha = 0.f;
        _slowBtnView.alpha = 0.f;
        _pubbleBtn.alpha = 0.F;
        [[UIApplication sharedApplication] setStatusBarHidden:YES];
        _isShowing = NO;
    }
}

- (void)reCountHideControlPanel{
    if(!_isShowing) {
        [self showControlPanel];
    }
    if(isPlaying) {
        [self performSelector:@selector(hideControlPanel) withObject:nil afterDelay:KdurationDelayTime];
    }
}

- (void)pubDisappear{
    if (self.isSupportSlowedPlay) {
        [UIView animateWithDuration:0.3 animations:^{
            _pubbleBtn.alpha = 0.f;
        }];
    }
}

- (void)touchShowHideControlPanel{
    //if(_isFullScreen) {
        _isShowing ? [self hideControlPanel] : [self showControlPanel];
    //}
}

- (void)playerLayer:(PlayerLayerView *)view panGesture:(PlayerControlType)type value:(CGFloat)value finished:(BOOL)finished
{
    switch (type) {
        case PlayerControlTypeNone: {break;}
        case PlayerControlTypeVolume: {
            UISlider *slider = [self volumeSlider];
            [slider setValue:value animated:NO];
            [slider sendActionsForControlEvents:UIControlEventTouchUpInside];
            if (finished) {
                self.volumeView = nil;
            }
            break;
        }
        case PlayerControlTypeBrightness: {
            [[UIScreen mainScreen] setBrightness:value];
            [self.playerIndicator setBrightness:value hidden:finished];
            break;
        }
    }
}

- (void)playerLayer:(PlayerLayerView *)view currentVolume:(CGFloat *)volume
{
    *volume = [self currentVolume];
}

- (MPVolumeView *)volumeView
{
    if (!_volumeView) {
        _volumeView = [[MPVolumeView alloc] init];
        _volumeView.showsRouteButton = NO;
        _volumeView.showsVolumeSlider = NO;
    }
    return _volumeView;
}

- (UISlider *)volumeSlider
{
    UISlider *volumeViewSlider = nil;
    for (UIView *view in self.volumeView.subviews) {
        if ([view.class.description isEqualToString:@"MPVolumeSlider"]){
            volumeViewSlider = (UISlider*)view;
            break;
        }
    }
    return volumeViewSlider;
}

- (CGFloat)currentVolume
{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [MPMusicPlayerController applicationMusicPlayer].volume;
#pragma clang diagnostic pop
    // 第二种方式获取当前音量
//    UISlider *slider = [self volumeSlider];
//    @try {
//        CGFloat volume = [[[slider valueForKey:@"volumeController"] valueForKey:@"volumeValue"] floatValue];
//        return volume;
//    } @catch (NSException *exception) {
//        return 0.f;
//    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [self touchShowHideControlPanel];
}

-(void)deviceOrientationDidChange:(NSNotification *)sender
{
    
    UIDeviceOrientation orientation = self.cmHelper.orientation;
    if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
        return;
    }
    UIInterfaceOrientation interfaceOrientation = UIDeviceOrientationIsPortrait(orientation)?UIInterfaceOrientationPortrait:(UIInterfaceOrientation)orientation;
    [self rotateMoviePlayerForOrientation:interfaceOrientation];
    
    
//    UIApplicationState state = [UIApplication sharedApplication].applicationState;
//    NSLog(@"state: %d",state);
//    
//    // wangBo 不活跃时避免强制转动屏幕
//    if ([UIApplication sharedApplication].applicationState != UIApplicationStateActive) {
//        return;
//    }
//    
//    UIDevice *device = sender.object;
//    UIDeviceOrientation orientation1 = [device orientation];
//    
//    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
//    NSLog(@"Orientation: %d,,,, %d",orientation,orientation1);
//    if (!UIDeviceOrientationIsValidInterfaceOrientation(orientation)) {
//        return;
//    }
//    UIInterfaceOrientation interfaceOrientation = UIDeviceOrientationIsPortrait(orientation)?UIInterfaceOrientationPortrait:(UIInterfaceOrientation)orientation;
//    [self rotateMoviePlayerForOrientation:interfaceOrientation];
}

#pragma mark - writeVideoAtPathToSavedPhotosAlbum
- (IBAction)findLongPressGestureRecognizer:(id)sender {
    _pauseButton.hidden = NO;
    [_player pause];
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *archiveAction = [UIAlertAction actionWithTitle:@"保存到手机" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [_player play];
        _pauseButton.hidden = YES;
        [self downLoadVideo];
    }];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [_player play];
        _pauseButton.hidden = YES;
    }];
    [alert addAction:archiveAction];
    [alert addAction:cancelAction];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)saveToAlbum:(NSURL *)url {
    ALAssetsLibrary *assets = [[ALAssetsLibrary alloc] init];
    [assets writeVideoAtPathToSavedPhotosAlbum:url completionBlock:^(NSURL *assetURL, NSError *error) {
        if (!error) {
            [SVProgressHUD showSuccessWithStatus:@"已保存至相册"];
            [[NSFileManager defaultManager] removeItemAtURL:url error:nil];
        } else {
            [SVProgressHUD showInfoWithStatus:@"取消保存"];
        }
    }];
}

- (void)downLoadVideo {
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:_viderUrl]];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionDownloadTask *downloadTask = [session downloadTaskWithRequest:request completionHandler:^(NSURL * _Nullable location, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSString *documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
            NSURL *documentsDirectoryURL = [NSURL fileURLWithPath:documentsPath];
            NSURL *fileURL = [documentsDirectoryURL URLByAppendingPathComponent:[[response URL] lastPathComponent]];
            NSFileManager *fileManager = [NSFileManager defaultManager];
            [fileManager moveItemAtURL:location toURL:fileURL error:NULL];
            dispatch_async(dispatch_get_main_queue(), ^{
                [self saveToAlbum:fileURL];
            });
        }
    }];
                                              
    [downloadTask resume];
}

@end
