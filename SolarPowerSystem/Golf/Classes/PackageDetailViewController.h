//
//  PackageDetailViewController.h
//  Golf
//
//  Created by user on 12-12-13.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"
#import "PackageDetailModel.h"
#import "ConditionModel.h"
#import "ListModel.h"
#import "PriceSpecModel.h"
#import "PackageFillViewController.h"
#import "PackageConditionModel.h"
#import "ConditionModel.h"


@class SharePackage;

@interface PackageDetailViewController : BaseNavController<UITableViewDelegate,UITableViewDataSource,UIScrollViewDelegate,UIActionSheetDelegate>{
    IBOutlet UIImageView *_packageImgView;
    IBOutlet UIScrollView *_carryView;
    IBOutlet UIButton *_bookBtn;
    IBOutlet UIView *_floatView;
    IBOutlet UILabel *_lblPackageName;
    IBOutlet UILabel *_lblDate;
    IBOutlet UILabel *_lblSupplier;
    IBOutlet UIImageView *_shadowImg;
    IBOutlet UIView *infoView;
    UITableView *_clubTableView;

    PackageDetailModel *_packageDetail;
    ConditionModel *_myCondition;
    PackageConditionModel *_packageCondition;
    SharePackage *_share;
    
    int _packageId;
    int _clubId;
    int _agentId;
    
    CGFloat _tableHeight;
    NSMutableArray *_listArray;
    NSMutableArray *_specArray;
    NSMutableArray *_specNameArray;
    NSMutableArray *_specPriceArray;
    
    int floatView_y;
}

- (IBAction)bookButtonPressed:(id)sender;
- (IBAction)phoneBook:(id)sender;

@property (nonatomic) int packageId;
@property (nonatomic) int clubId;

/**
 中介ID
 */
@property (nonatomic) int agentId;
@property (nonatomic,strong) PackageDetailModel *packageDetail;

@end
