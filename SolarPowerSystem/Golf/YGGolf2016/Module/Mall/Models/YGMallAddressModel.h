//
//  YGMallAddressModel.h
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface YGMallAddressModel : NSObject <NSCoding, NSCopying>

@property (assign, nonatomic) NSInteger address_id;     //id
@property (assign, nonatomic) BOOL is_default;          //是否是默认地址
@property (copy, nonatomic) NSString *link_man;         //联系人姓名
@property (copy, nonatomic) NSString *link_phone;       //联系人电话
@property (copy, nonatomic) NSString *province_name;    //省
@property (copy, nonatomic) NSString *city_name;        //市
@property (copy, nonatomic) NSString *district_name;    //区
@property (copy, nonatomic) NSString *post_code;        //邮编
@property (copy, nonatomic) NSString *address;          //详细地址

- (NSString *)nameAndPhone; //姓名+电话
- (NSString *)addressAndPostcode;//详细地址+邮编

+ (void)fetchDefaultAddress:(void (^)(YGMallAddressModel *address))completion;
+ (void)fetchAddressList:(void (^)(NSArray *addressList))completion;

@end
