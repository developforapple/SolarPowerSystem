//
//  ListModel.h
//  Golf
//
//  Created by user on 12-12-18.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ListModel : NSObject{
    int _clubId;
    NSString *_clubName;
}

@property (nonatomic) int clubId;
@property (nonatomic, strong) NSString *clubName;

@end

