//
//  YGMallAddressEditCell.h
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "IQTextView.h"
#import "YGAreaPickerView.h"

UIKIT_EXTERN NSString *const kYGMallAddressEditCell;

@class YGMallAddressEditModel;

@interface YGMallAddressEditCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *infoLabel;
@property (weak, nonatomic) IBOutlet IQTextView *inputTextView;

@property (strong, readonly, nonatomic) YGMallAddressEditModel *editModel;
- (void)configureWithEditModel:(YGMallAddressEditModel *)model;

@property (copy, nonatomic) void (^shouldUpdateHeight)(YGMallAddressEditModel *editModel,CGFloat height);

@end

@class YGMallAddressModel;

typedef NS_ENUM(NSUInteger, YGMallAddressEditRow) {
    YGMallAddressEditRowName,
    YGMallAddressEditRowPhone,
    YGMallAddressEditRowArea,
    YGMallAddressEditRowAddress,
    YGMallAddressEditRowPostcode
};

@interface YGMallAddressEditModel : NSObject
@property (assign, nonatomic) YGMallAddressEditRow row;
@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *contentPlaceholder;
@property (copy, nonatomic) NSString *content;
@property (strong, nonatomic) YGArea *area;
@property (assign, nonatomic) BOOL isInputArea;       //是否是区域
@property (assign, nonatomic) BOOL isRequired;        //是否必须填写
@property (assign, nonatomic) NSInteger maximumWords; //最大字数

+ (NSArray<YGMallAddressEditModel *> *)createEditModel:(YGMallAddressModel *)address;
+ (YGMallAddressModel *)createAddressModel:(NSArray<YGMallAddressEditModel *> *)editModels;

@end
