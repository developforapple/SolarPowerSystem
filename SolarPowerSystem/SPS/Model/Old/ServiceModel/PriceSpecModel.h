//
//  PriceSpecModel.h
//  Golf
//
//  Created by user on 12-12-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PriceSpecModel : NSObject{
    int _specId;
    int _currentPrice;
    NSString *_specName;
}

@property (nonatomic) int specId;
@property (nonatomic) int currentPrice;
@property (nonatomic,strong) NSString *specName;

@end
