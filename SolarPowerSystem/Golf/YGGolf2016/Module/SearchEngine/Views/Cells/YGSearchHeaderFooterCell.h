//
//  YGSearchHeaderFooterCell.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchBaseCell.h"

/*!
 *  @brief 头部和尾部的cell。
 *  
 *  使用cell而不是sectionHeaderFooter不需要对分割线进行额外设置。
 */
@interface YGSearchHeaderFooterCell : YGSearchBaseCell

@property (weak, nonatomic) IBOutlet UILabel *headerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *footerBtn;

// 作为头部还是尾部使用。
@property (assign, nonatomic) BOOL usedForHeader;

@end
