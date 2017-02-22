//
//  YGWalletTransferUserCell.m
//  Golf
//
//  Created by zhengxi on 15/12/14.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "YGWalletTransferUserCell.h"
#import "YGWalletTransferViewCtrl.h"

@interface YGWalletTransferUserCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *originalName;
@property (weak, nonatomic) IBOutlet UILabel *followLabel;
@end

@implementation YGWalletTransferUserCell

- (void)setModel:(UserFollowModel *)model {
    _model = model;
    [self freshenUI];
}

- (void)freshenUI {
    self.nameLabel.text = _model.displayName;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:_model.headImage] placeholderImage:[UIImage imageNamed:@"head_image.png"]];
    if (_model.isFollowed == 1) {
        self.followLabel.text = @"已关注";
    } else if (_model.isFollowed == 4) {
        self.followLabel.text = @"相互关注";
    }

    if (_isSearchResults) {
        if (![_model.displayName isEqualToString:_model.originalName] && _model.originalName.length > 0) {
            self.originalName.hidden = NO;
            self.originalName.attributedText = [self diplayNameMutableAttributedString];
        } else {
            self.originalName.hidden = YES;
        }

        self.nameLabel.attributedText = [self addressNameMutableAttributedString];
    } else {
        self.nameLabel.text = _model.displayName;
    }
}
#pragma mark -DiplayNameMutableAttributedString
- (NSRange)theSamePartOfString:(NSString *)stringA andString:(NSString *)stringB {
    stringB = [stringB stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSRange range= {0,0};
    for (int i = 1; i <= stringB.length; i++) {
        NSRange tempRange =[stringA rangeOfString:[stringB substringWithRange:NSMakeRange(0, i)] options:NSCaseInsensitiveSearch range:NSMakeRange(0, stringA.length) locale:[NSLocale currentLocale]];
        if (tempRange.location == NSNotFound) {
            break;
        }
        range = tempRange;
    }
    
    return range;
}

-(NSMutableAttributedString *)diplayNameMutableAttributedString {
    NSString *string = [NSString stringWithFormat:@"(%@)",_model.originalName];
    NSMutableAttributedString *mutableString=[[NSMutableAttributedString alloc]initWithString:string attributes:@{NSFontAttributeName:_originalName.font}];
    [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:41/255.0 green:89/255.0 blue:152/255.0 alpha:1] range:[self theSamePartOfString:string andString:((YGWalletTransferViewCtrl *)self.delegate).searchBar.text]];
    return mutableString;
}

-(NSMutableAttributedString *)addressNameMutableAttributedString {
    NSMutableAttributedString *mutableString=[[NSMutableAttributedString alloc]initWithString:_model.displayName attributes:@{NSFontAttributeName:_nameLabel.font}];
    [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:41/255.0 green:89/255.0 blue:152/255.0 alpha:1] range:[self theSamePartOfString:_model.displayName andString:((YGWalletTransferViewCtrl *)self.delegate).searchBar.text]];
    return mutableString;
}
@end
