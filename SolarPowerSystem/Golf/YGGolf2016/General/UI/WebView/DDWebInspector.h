//
//  DDPostWebInspector.h
//  QuizUp
//
//  Created by Normal on 16/4/15.
//  Copyright © 2016年 zhenailab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DDWebInspector : NSObject

+ (instancetype)shared;

/**
 *  @brief 待网页加载完成后向网页注入js代码获取内容
 *
 *  @param URLString   URL
 *  @param JSCode      注入的js代码
 *  @param executeCode 执行的js代码。如果为空，则返回注入的js代码的执行结果
 *  @param completion  回调
 */
- (void)inspectionURL:(NSString *)URLString
         infuseJSCode:(NSString *)JSCode
          executeCode:(NSString *)executeCode
           completion:(void (^)(BOOL suc,id object)) completion;

@end
