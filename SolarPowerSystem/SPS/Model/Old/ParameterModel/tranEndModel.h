//
//  tranEndModel.h
//  Golf
//
//  Created by user on 12-5-25.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface tranEndModel : NSObject{
    NSString *sessionId;
    int tranId;
    int tranStatus;
}
@property (nonatomic,copy) NSString *sessionId;
@property (nonatomic) int tranId;
@property (nonatomic) int tranStatus;
@end
