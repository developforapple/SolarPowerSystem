//
//  GetLastVersionModel.h
//  Golf
//
//  Created by liangqing on 16/9/6.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GetLastVersionModel : NSObject
@property (nonatomic,copy) NSString *versionName;
@property (nonatomic,copy) NSString *versionDesc;
@property (nonatomic,assign) CGFloat versionNumber;

- (instancetype)initWithDic:(id)data;
@end
