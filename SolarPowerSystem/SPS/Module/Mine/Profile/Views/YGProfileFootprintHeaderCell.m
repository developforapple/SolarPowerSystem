//
//  YGProfileFootprintHeaderCell.m
//  Golf
//
//  Created by 廖瀚卿 on 15/12/10.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGProfileFootprintHeaderCell.h"

@implementation YGProfileFootprintHeaderCell

- (IBAction)onClubTaped:(id)sender {
    if (_blockClubTaped) {
        _blockClubTaped(nil);
    }
}

- (IBAction)onMapTaped:(id)sender {
    if (_blockMapTaped) {
        _blockMapTaped(nil);
    }
}

@end
