//
//  CityMultiplePackageViewController.h
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "PackageDetailModel.h"

@interface CityMultiplePackageViewController : BaseNavController<UITableViewDataSource,UITableViewDelegate>{
    UITableView *_tableView;
    UIImageView *shadowImg;
    NSArray *_multipleList;
    int _clubId;
}

@property (nonatomic) int clubId;
@property (nonatomic,strong) NSArray *multipleList;

@end
