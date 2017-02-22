//
//  YGNoFloatHeaderView.h
//  Golf
//
//  Created by bo wang on 16/6/17.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

// 使用于 UITableView Plain 风格中。
// 作为section的headerView使用时，将无悬停效果。
// 需要设置tableView和section。
@interface YGNoFloatHeaderView : UIView

// 默认为 0， 可以在xib中直接设置值
@property (assign, nonatomic) IBInspectable NSUInteger section;

// 需要设置！可以在xib连线到tableView
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@end