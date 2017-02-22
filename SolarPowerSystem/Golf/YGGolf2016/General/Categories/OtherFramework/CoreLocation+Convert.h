//
//  CoreLocation+Convert.h
//  Golf
//
//  Created by bo wang on 2016/12/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef __CORELOCATION_CONVERT__
#define __CORELOCATION_CONVERT__

#import <CoreLocation/CLLocation.h>

typedef CLLocationCoordinate2D NSCoor;

NS_INLINE NSCoor NSCoorMake(double la, double lo){
    return CLLocationCoordinate2DMake(la, lo);
}

FOUNDATION_EXTERN NSCoor wgs2Gcj(NSCoor lc2d);

FOUNDATION_EXTERN CGFloat distanceBetween(NSCoor c1, NSCoor c2);

#endif
