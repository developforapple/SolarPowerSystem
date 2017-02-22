//
//  YGMallAddressModel.m
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallAddressModel.h"
#import <YYModel/YYModel.h>

@implementation YGMallAddressModel
YYModelDefaultCode

- (NSString *)nameAndPhone
{
    return [NSString stringWithFormat:@"%@ %@",self.link_man,self.link_phone];
}

- (NSString *)addressAndPostcode
{
    return [NSString stringWithFormat:@"%@%@%@\n%@%@",self.province_name,self.city_name,self.district_name,self.address,self.post_code.length?[NSString stringWithFormat:@"\n%@",self.post_code]:@""];
}

+ (void)fetchDefaultAddress:(void (^)(YGMallAddressModel *address))completion
{
    if (!completion) return;
    
    [self fetchAddressList:^(NSArray *addressList) {
        
        if (addressList) {
            YGMallAddressModel *model;
            for (YGMallAddressModel *aAddress in addressList) {
                if (aAddress.is_default) {
                    model = aAddress;
                    break;
                }
            }
            if (!model) {
                model = [addressList firstObject];
            }
            if (completion) {
                completion(model);
            }
        }else{
            completion(nil);
        }
    }];
}

+ (void)fetchAddressList:(void (^)(NSArray *addressList))completion
{
    if (!completion) return;
    [ServerService fetchMallAddressList:completion failure:^(id error) {
        completion(nil);
    }];
}

@end
