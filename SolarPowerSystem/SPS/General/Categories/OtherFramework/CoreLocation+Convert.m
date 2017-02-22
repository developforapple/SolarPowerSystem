//
//  CoreLocation+Convert.m
//  Golf
//
//  Created by bo wang on 2016/12/19.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "CoreLocation+Convert.h"

double transform_yj5(double x, double y){
    double tt;
    tt = 300 + 1 * x + 2 * y + 0.1 * x * x + 0.1 * x * y + 0.1 * sqrt(sqrt(x * x));
    tt = tt + (20 * sin(18.849555921538764 * x) + 20 * sin(6.283185307179588 * x)) * 0.6667;
    tt = tt + (20 * sin(3.141592653589794 * x) + 40 * sin(1.047197551196598 * x)) * 0.6667;
    tt = tt + (150 * sin(0.2617993877991495 * x) + 300 * sin(0.1047197551196598 * x)) * 0.6667;
    return tt;
}

double transform_yjy5(double x, double y){
    double tt;
    tt = -100 + 2 * x + 3 * y + 0.2 * y * y + 0.1 * x * y + 0.2 * sqrt(sqrt(x * x));
    tt = tt + (20 * sin(18.849555921538764 * x) + 20 * sin(6.283185307179588 * x)) * 0.6667;
    tt = tt + (20 * sin(3.141592653589794 * y) + 40 * sin(1.047197551196598 * y)) * 0.6667;
    tt = tt + (160 * sin(0.2617993877991495 * y) + 320 * sin(0.1047197551196598 * y)) * 0.6667;
    return tt;
}

double transform_jy5(double x, double xx){
    double n;
    double a;
    double e;
    a = 6378245;
    e = 0.00669342;
    n = sqrt(1 - e * sin(x * 0.0174532925199433) * sin(x * 0.0174532925199433));
    n = (xx * 180) / (a / n * cos(x * 0.0174532925199433) * 3.1415926);
    return n;
}


double transform_jyj5(double x, double yy){
    double m;
    double a;
    double e;
    double mm;
    a = 6378245;
    e = 0.00669342;
    mm = 1 - e * sin(x * 0.0174532925199433) * sin(x * 0.0174532925199433);
    m = (a * (1 - e)) / (mm * sqrt(mm));
    return (yy * 180) / (m * 3.1415926);
}

double random_yj(double casm_rr){
    double t;
    double casm_a = 314159269;
    double casm_c = 453806245;
    casm_rr = casm_a * casm_rr + casm_c;
    t = (int)(casm_rr / 2);
    casm_rr = casm_rr - t * 2;
    casm_rr = casm_rr / 2;
    return (casm_rr);
}

NSCoor _wgs2Gcj(double wg_lng, double wg_lat)
{
    NSCoor coor;
    if (wg_lng < 72.004 || wg_lng > 137.8347 || wg_lat < 0.8293 || wg_lat > 55.8271)
    {
        coor.latitude = wg_lat;
        coor.longitude = wg_lng;
        return coor;
    }
    double random = random_yj(0);
    double  x_add= transform_yj5(wg_lng - 105 ,wg_lat - 35 )+ random;
    double  y_add= transform_yjy5(wg_lng - 105 ,wg_lat - 35)+ random_yj(random);
    
    wg_lng += transform_jy5(wg_lat ,x_add);
    wg_lat += transform_jyj5(wg_lat ,y_add);
    
    coor.latitude = wg_lat;
    coor.longitude = wg_lng;
    return coor;
}

NSCoor gcj2Wgs(double wg_lng,double wg_lat){
    NSCoor coor ;
    coor.longitude = wg_lng;
    coor.latitude = wg_lat;
    
    for(int i=0;i<5;i++) {
        NSCoor c = _wgs2Gcj(wg_lng ,wg_lat);
        coor.longitude=wg_lng-(c.longitude - coor.longitude);
        coor.latitude=wg_lat-(c.latitude - coor.latitude);
    }
    return coor;
}

NSCoor wgs2Gcj(NSCoor lc2d)
{
    return _wgs2Gcj(lc2d.longitude, lc2d.latitude);
}

CGFloat distanceBetween(NSCoor c1, NSCoor c2)
{
    double lo_1 = c1.longitude;
    double la_1 = c1.latitude;
    double lo_2 = c2.longitude;
    double la_2 = c2.latitude;
    return 12756274 * asin(sqrt(pow(sin(la_1-la_2)*0.008726646, 2)+cos(la_1 * 0.0174533)*cos(la_2 * 0.0174533)*pow(sin((lo_1-lo_2)*0.008726646), 2)));
}
