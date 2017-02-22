//
//  YGShareNoteInfo.m
//  Golf
//
//  Created by bo wang on 16/5/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGShareNoteInfo.h"

@implementation YGShareNoteInfo

- (instancetype)init
{
    return [self initWithType:YGShareNoteTypeShare desc:nil];
}

- (instancetype)initWithType:(YGShareNoteType)type
                        desc:(NSString *)desc
{
    self = [super init];
    if (self) {
        self.type = type;
        self.desc = desc;
    }
    return self;
}

- (void)setDesc:(NSString *)desc
{
    _desc = desc;
    
    if (!_desc) {
        return;
    }
    
    NSRange range1;
    NSRange range2;
    NSRange range;
    NSMutableArray *array = [NSMutableArray array];
    NSString *string1 = desc;
    while (1) {
        range1 = [string1 rangeOfString:@"{"];
        range2 = [string1 rangeOfString:@"}"];
        range.location = range1.location;
        if (range.location == NSNotFound) {
            break;
        }
        range.length = range2.location - range1.location;
        string1 =  [string1 stringByReplacingCharactersInRange:range1 withString:@" "];
        string1 = [string1 stringByReplacingCharactersInRange:range2 withString:@""];
        [array addObject:[NSValue valueWithRange:range]];
    }
    
    NSDictionary *attribute = @{NSFontAttributeName:[UIFont systemFontOfSize:12],
                                NSForegroundColorAttributeName:RGBColor(254, 146, 41, 1)};
    NSMutableAttributedString *mutableString=[[NSMutableAttributedString alloc]initWithString:string1 attributes:attribute];
    
    for (NSValue *value in array) {
        NSRange theRange = [value rangeValue];
        [mutableString addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithRed:249/255.0 green:100/255.0 blue:100/255.0 alpha:1] range:theRange];
    }
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
    [paragraphStyle setLineSpacing:1];
    [paragraphStyle setAlignment:NSTextAlignmentCenter];
    [mutableString addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, [mutableString length])];
    self->_attributedDesc = mutableString;
}

- (void)setType:(YGShareNoteType)type
{
    _type = type;
    
    switch (type) {
        case YGShareNoteTypeShare:{
            self.title = @"分享赚云币";
            self.prompt = @"分享成功后，奖励自动放入您的账户";
        }    break;
        case YGShareNoteTypeInvite:{
            self.title = @"邀请赚云币";
            self.prompt = @"好友注册成功后，奖励将自动放入你们的账户";
        }    break;
        default:
            break;
    }
}

@end
