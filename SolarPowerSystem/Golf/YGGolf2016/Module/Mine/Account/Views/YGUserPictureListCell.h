//
//  YGUserPictureListCell.h
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

UIKIT_EXTERN NSString *const kYGUserPictureListCell;
UIKIT_EXTERN NSString *const kYGUserPictureListCellAdd;

@interface YGUserPictureListCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (strong, nonatomic) id image;
- (void)configureWithImage:(id)image;

@end
