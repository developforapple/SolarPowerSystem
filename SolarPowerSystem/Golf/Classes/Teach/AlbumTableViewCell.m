//
//  CourseSchoolAlbumTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/5/16.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "AlbumTableViewCell.h"
#import "UIView+AutoLayout.h"

#define kPointX 13
#define kPadding 10
#define kWidth 44



@implementation AlbumTableViewCell{
    UIImage *defaultImage;
}

-(void)awakeFromNib{
    [super awakeFromNib];
    defaultImage = [UIImage imageWithColor:[UIColor colorWithHexString:@"#e6e6e6"]];
}

- (void)loadAlbum:(NSArray *)album{
    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:5];
    if (Device_Width == 320.0 && album.count >= 5) {
        [arr addObjectsFromArray:[album subarrayWithRange:NSMakeRange(0, 5)]];
    }else if(Device_Width == 375 && album.count >= 6){
        [arr addObjectsFromArray:[album subarrayWithRange:NSMakeRange(0, 6)]];
    }else if(Device_Width == 414 && album.count >= 7){
        [arr addObjectsFromArray:[album subarrayWithRange:NSMakeRange(0, 7)]];
    }else{
        [arr addObjectsFromArray:album];
    }
    
    for (int i = 0; i < arr.count; i++) {
        UIImageView *img = [UIImageView autoLayoutView];
        img.contentMode = UIViewContentModeScaleAspectFit;
        [Utilities loadImageWithURL:[NSURL URLWithString:arr[i]]  inImageView:img placeholderImage:defaultImage];
        img.layer.cornerRadius = 22.0;
        img.clipsToBounds = YES;
        
        [self.contentView addSubview:img];
        
        [img constrainToSize:CGSizeMake(kWidth, kWidth)];
        [img centerInContainerOnAxis:NSLayoutAttributeCenterY];
        [img pinToSuperviewEdges:JRTViewPinLeftEdge inset:(kPointX + kWidth * i + kPadding * i)];
    }
}
@end
