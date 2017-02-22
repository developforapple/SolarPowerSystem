//
//  VoucherMoreTableViewCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/4/10.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "VoucherMoreTableViewCell.h"

@interface VoucherMoreTableViewCell()
@property (weak, nonatomic) IBOutlet UILabel *labelMore;
@end

@implementation VoucherMoreTableViewCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.frame.size.width/2, 12, 64, 20)];
        label.text = @"查看更多";
        label.font = [UIFont systemFontOfSize:16];
        [self.contentView addSubview:label];
        label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
        if ([self respondsToSelector:@selector(setSeparatorInset:)]) {
            self.separatorInset = UIEdgeInsetsMake(0, 1000, 0, 0);
        }
    }
    return self;
    
}
@end
