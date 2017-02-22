//
//  DDAssetsCameraCell.m
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsCameraCell.h"
#import <AVFoundation/AVFoundation.h>

@interface DDAssetsCameraCell ()

@property (strong, nonatomic) AVCaptureSession *session;
@property (strong, nonatomic) AVCaptureDeviceInput *input;
@property (strong, nonatomic) AVCaptureVideoPreviewLayer *previewLayer;

@end

@implementation DDAssetsCameraCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.realTimePictureView.backgroundColor = [UIColor lightGrayColor];
    
    if (self.visible && self.input) {
        [self.session addInput:self.input];
    }
}

- (BOOL)isCellVisible
{
    NSArray *cells = [self.collectionView visibleCells];
    return [cells containsObject:self];
}

- (void)setVisible:(BOOL)visible
{
    _visible = visible;
    
    if (_visible) {
        [self startCapture];
    }else{
        [self stopCapture];
    }
}

- (void)startCapture
{
    if (![self.session isRunning]) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [self.session startRunning];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.previewLayer.frame = self.realTimePictureView.bounds;
                [self.realTimePictureView.layer addSublayer:self.previewLayer];
            });
        });
    }
}

- (void)stopCapture
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.session stopRunning];
        dispatch_async(dispatch_get_main_queue(), ^{
            [self.previewLayer removeFromSuperlayer];
        });
    });
}

#pragma mark - Getter
- (AVCaptureSession *)session
{
    if (!_session) {
        _session = [[AVCaptureSession alloc] init];
    }
    return _session;
}

- (AVCaptureDeviceInput *)input
{
    if (!_input) {
        NSError *error;
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        AVCaptureDeviceInput *input = [AVCaptureDeviceInput deviceInputWithDevice:device error:&error];
        _input = input;
    }
    return _input;
}

- (AVCaptureVideoPreviewLayer *)previewLayer
{
    if (!_previewLayer) {
        _previewLayer = [[AVCaptureVideoPreviewLayer alloc] initWithSession:self.session];
        _previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    return _previewLayer;
}

@end
