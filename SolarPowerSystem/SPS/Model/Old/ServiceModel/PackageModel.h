//
//  PackageModel.h
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PackageModel : NSObject{
    int _clubId;
    int _dayNum;
    int _currentPrice;
    int _packageId;
    int _agentId;
    
    NSString *_packageName;
    NSString *_beginDate;
    NSString *_endDate;
    NSString *_packageLogo;
    NSString *_agentName;
    NSInteger _index;
    UIImage *_imageIcon;
}

@property (nonatomic) int clubId;
@property (nonatomic) int dayNum;
@property (nonatomic) int currentPrice;
@property (nonatomic) int packageId;
@property (nonatomic) int agentId;
@property (nonatomic,copy) NSString *packageName;
@property (nonatomic,copy) NSString *beginDate;
@property (nonatomic,copy) NSString *endDate;
@property (nonatomic,copy) NSString *packageLogo;
@property (nonatomic,copy) NSString *agentName;
@property (nonatomic) NSInteger index;
@property (nonatomic,strong) UIImage *imageIcon;
@property (nonatomic) int giveYunbi;

- (id)initWithDic:(id)data;

@end
