//
//  DDAssetsCameraCell.h
//  QuizUp
//
//  Created by Normal on 15/12/7.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import <UIKit/UIKit.h>

#define kDDAssetsCameraCell @"DDAssetsCameraCell"

@interface DDAssetsCameraCell : UICollectionViewCell
@property (weak, nonatomic) UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UIView *realTimePictureView;

@property (assign, getter=isVisible, nonatomic) BOOL visible;

@end
