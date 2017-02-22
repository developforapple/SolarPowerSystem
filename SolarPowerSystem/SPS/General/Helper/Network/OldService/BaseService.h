//
//  BaseService.h
//  Golf
//
//  Created by 黄希望 on 15/7/6.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "JSONModel.h"

@interface BaseService : JSONModel

@property (assign, nonatomic) BOOL success;
@property (assign, nonatomic) NSInteger errorcode;
@property (strong, nonatomic) NSString<Optional> *errormessage;
@property (strong, nonatomic) id<Optional> data;
@property (strong, nonatomic) id<Optional> dataExtra;


/*!
 *  @brief bwang加。20160818
 */
@property (strong, nonatomic) id<Ignore> parameters;

//同步请求

+ (void)BSGet:(NSString*)mode
   parameters:(id)parameters
      encrypt:(BOOL)encrypt
  needLoading:(BOOL)needLoading
      success:(void (^)(BaseService *BS))success
      failure:(void (^)(id error))failure;

+ (void)BSPost:(NSString*)mode
    parameters:(id)parameters
       encrypt:(BOOL)encrypt
   needLoading:(BOOL)needLoading
       success:(void (^)(BaseService *BS))success
       failure:(void (^)(id error))failure;

@end
