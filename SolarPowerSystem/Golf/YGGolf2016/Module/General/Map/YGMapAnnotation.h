//
//  YGMapAnnotation.h
//  Golf
//
//  Created by bo wang on 2016/12/21.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

#define CLLC2DMake(la,lo) CLLocationCoordinate2DMake(la, lo)

@interface YGMapAnnotation : NSObject<MKAnnotation>
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic) ClubModel *club;
+ (NSArray<YGMapAnnotation *> *)annotations:(NSArray<ClubModel *> *)clubList;
@end
