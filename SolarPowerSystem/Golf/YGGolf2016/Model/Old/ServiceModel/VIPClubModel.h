//
//  VIPClubModel.h
//  Golf
//
//  Created by 黄希望 on 12-7-25.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VIPClubModel : NSObject{
    /*球会id*/
    int _clubId;
    /*验证状态*/
    int _vipStatus;
    int _cityId;
    /*球会名字*/
    NSString *_clubName;
    /*会员证号*/
    NSString *_clubNo;
    NSString *_address;
}

@property (nonatomic) int clubId;
@property (nonatomic) int vipStatus;
@property (nonatomic) int cityId;
@property (nonatomic, copy) NSString *clubName;
@property (nonatomic, copy) NSString *clubNo;
@property (nonatomic, copy) NSString *address;

- (id)initWithDic:(id)data;

@end
