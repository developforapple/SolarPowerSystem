//
//  ClubFairwayModel.h
//  Golf
//
//  Created by 黄希望 on 12-9-10.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ClubFairwayModel : NSObject{
    int _fairwayNo;
    NSString *_fairwayIntro;
    NSString *_fairwayPicture;
}

@property (nonatomic) int fairwayNo;
@property (nonatomic,copy) NSString *fairwayIntro;
@property (nonatomic,copy) NSString *fairwayPicture;

- (id)initWithDic:(id)data;

@end
