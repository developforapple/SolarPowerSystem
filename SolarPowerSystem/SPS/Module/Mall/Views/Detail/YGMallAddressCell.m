//
//  YGMallAddressCell.m
//  Golf
//
//  Created by bo wang on 2016/11/29.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallAddressCell.h"

NSString *const kYGMallAddressCell = @"YGMallAddressCell";

@implementation YGMallAddressCell

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)configureWithAddress:(YGMallAddressModel *)address
{
    _address = address;
    self.nameLabel.text = [address nameAndPhone];
    self.addressLabel.text = [address addressAndPostcode];
}

- (IBAction)edit:(id)sender
{
    if (self.willEditAddress) {
        self.willEditAddress(self.address);
    }
}

@end
