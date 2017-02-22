//
//  NSData+HKPDataImage.h
//  LekuIndiana
//
//  Created by FlyGo on 16/2/25.
//  Copyright © 2016年 HKP_FlyGo. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSData (HKPDataImage)

/**
 *  缩放图片数据
 *
 *  @param toWidth   宽
 *  @param toHeight  高
 *
 *  @return 返回图片数据对象
 */
-(NSData *)scaleData:(NSInteger)toWidth toHeight:(NSInteger)toHeight;

@end
