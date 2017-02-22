//
//  HttpErroCodeModel.h
//  Golf
//
//  Created by Dejohn Dong on 12-2-15.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HttpErroCodeModel : NSObject

@property(nonatomic,assign) NSInteger code;
@property(nonatomic,copy) NSString *errorMsg;

- (instancetype)initWithDic:(id)data;

@end
