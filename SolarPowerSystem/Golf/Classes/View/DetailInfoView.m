//
//  DetailInfoView.m
//  Golf
//
//  Created by user on 13-3-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "DetailInfoView.h"
#import "Utilities.h"
#import "CustomImgView.h"

@implementation DetailInfoView
@synthesize componentArray,orgX;


- (id)initWithFrame:(CGRect)frame withHeadTitle:(NSString *)title withContentArray:(NSArray *)contentArray withlocation:(CGFloat)org_x
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.componentArray = contentArray;
        self.orgX = org_x;
        CGFloat y = 15.0f;
        
        if (title && title.length > 0) {
            UILabel *titleLabel = [self createLabelwithTitle:title textColor:[UIColor blackColor]];
            [titleLabel setFrame:CGRectMake(10, y, self.frame.size.width-orgX - 10, 15)];
            y += titleLabel.frame.size.height +5;
            [self addSubview:titleLabel];
        }
        for (NSString *componentStr in componentArray){
            NSArray *theArray = [componentStr componentsSeparatedByString:@"#"];
            NSString *titleLeft = [theArray objectAtIndex:0];
            NSString *titleRight = [theArray objectAtIndex:1];
            NSString *colorStr = nil;
            if (theArray.count > 2) {
                colorStr = [theArray objectAtIndex:2];
            }
            y = [self createLabel:y WithLeftTitle:titleLeft withRightTitle:titleRight withColorStr:colorStr];
        }
        
        [self setFrame:CGRectMake(frame.origin.x, frame.origin.y, frame.size.width, y + 15)];
        if (frame.origin.x > 0) {
            CustomImgView *bgImg = [[CustomImgView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height) withStyle:ImageStyleRoundRect Istouch:NO];
            [self insertSubview:bgImg atIndex:0];
        }
        else{
            CustomImgView *bgImg = [[CustomImgView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height - 4) withStyle:ImageStyleNome Istouch:NO];
            [self insertSubview:bgImg atIndex:0];
            
            UIImageView *bgImg_ = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hengxian_a.png"]];
            bgImg_.frame = CGRectMake(0, self.frame.size.height - 4, frame.size.width, 1);
            [self insertSubview:bgImg_ atIndex:1];
        }
    }
    return self;
}

- (CGFloat)createLabel:(CGFloat)origin_y WithLeftTitle:(NSString *)leftTitle withRightTitle:(NSString *)rightTitle withColorStr:(NSString *)colorStr{
    UIColor *textColor;
    UILabel *leftLabel = [self createLabelwithTitle:leftTitle textColor:[Utilities R:100 G:100 B:100]];
    if (colorStr && colorStr.length > 0) {
        textColor = [self colorWithHexString:colorStr];
    }
    else{
        textColor = [Utilities R:40 G:40 B:40];
    }
    UILabel *rightLabel = [self createLabelwithTitle:rightTitle textColor:textColor];
    
    [self calculateWithLeftLabel:leftLabel withRightLabel:rightLabel withOrigin:origin_y];
    
    [self addSubview:leftLabel];
    [self addSubview:rightLabel];
    
    return rightLabel.frame.origin.y + rightLabel.frame.size.height+5;
}

- (UILabel *)createLabelwithTitle:(NSString *)title textColor:(UIColor *)textColor{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont systemFontOfSize:14];
    label.text = title;
    label.numberOfLines = 0;
    label.textColor = textColor;
    return label;
}

- (void)calculateWithLeftLabel:(UILabel *)l_label withRightLabel:(UILabel *)r_label withOrigin:(CGFloat)y{
    CGSize size = [Utilities getSize:l_label.text withFont:[UIFont systemFontOfSize:14] withWidth:Device_Width];
    [l_label setFrame:CGRectMake(10, y + 2, size.width, size.height)];
    
    size = [Utilities getSize:r_label.text withFont:[UIFont systemFontOfSize:14] withWidth:self.frame.size.width-orgX - 10];
    [r_label setFrame:CGRectMake(orgX, y + 2, size.width, size.height)];
}

- (UIColor *) colorWithHexString: (NSString *)color
{
    NSString *cString = [[color stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    
    if ([cString length] < 6) {
        return [Utilities R:40 G:40 B:40];
    }
    
    if ([cString hasPrefix:@"0X"])
        cString = [cString substringFromIndex:2];
    if ([cString hasPrefix:@"#"])
        cString = [cString substringFromIndex:1];
    if ([cString length] != 6)
        return [Utilities R:40 G:40 B:40];
    
    NSRange range;
    range.location = 0;
    range.length = 2;
    
    NSString *rString = [cString substringWithRange:range];
    
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    
    return [UIColor colorWithRed:((float) r / 255.0f) green:((float) g / 255.0f) blue:((float) b / 255.0f) alpha:1.0f];
}

@end
