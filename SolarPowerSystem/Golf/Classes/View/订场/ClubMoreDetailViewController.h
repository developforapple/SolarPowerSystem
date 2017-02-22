//
//  ClubMoreDetailViewController.h
//  Golf
//
//  Created by user on 13-5-30.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "ClubModel.h"

@interface ClubMoreDetailViewController : BaseNavController{

}
@property (nonatomic) int clubId;
@property (nonatomic,strong) ClubModel *clubInfo;

@end
