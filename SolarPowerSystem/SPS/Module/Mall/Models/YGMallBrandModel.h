//
//  YGMallBrandModel.h
//  Golf
//
//  Created by bo wang on 2016/12/8.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGMallBrandModel : NSObject <NSCopying, NSCoding>
@property (assign, nonatomic) NSInteger brand_id;
@property (copy, nonatomic) NSString *brand_name;
@property (copy, nonatomic) NSString *brand_logo;
@property (assign, nonatomic) NSInteger display_order;
@end
