//
//  YGUserPictureListCell.m
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGUserPictureListCell.h"
#import "DDAsset.h"

NSString *const kYGUserPictureListCell = @"YGUserPictureListCell";
NSString *const kYGUserPictureListCellAdd = @"YGUserPictureListCellAdd";

@implementation YGUserPictureListCell

- (void)configureWithImage:(id)image
{
    self.image = image;
    
    if ([image isKindOfClass:[NSString class]]) {
        [self.imageView sd_setImageWithURL:[NSURL URLWithString:image]];
    }else if ([image isKindOfClass:[UIImage class]]){
        self.imageView.image = image;
    }else if ([image isKindOfClass:[DDAsset class]]){
        [image thumbnailImage:^(UIImage *theImage) {
            self.imageView.image = theImage;
        }];
    }
}

@end
