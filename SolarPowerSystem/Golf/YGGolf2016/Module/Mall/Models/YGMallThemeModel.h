//
//  YGMallThemeModel.h
//  Golf
//
//  Created by bo wang on 2016/12/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGMallThemeModel : NSObject <NSCopying,NSCoding>
@property (assign, nonatomic) NSInteger theme_id;
@property (copy, nonatomic) NSString *theme_name;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) NSInteger commodity_id;
@property (copy, nonatomic) NSString *photo_image;
@end
