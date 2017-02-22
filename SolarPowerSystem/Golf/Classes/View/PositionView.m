//
//  PositionView.m
//  Golf
//
//  Created by user on 13-6-27.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "PositionView.h"

@implementation PositionView
@synthesize imageLabel,imageView,textLabel,delegate;

- (void)awakeFromNib{
    [super awakeFromNib];
    self.frame = CGRectMake(0, self.frame.origin.y, Device_Width, self.frame.size.height);
}

- (void)jisuanHeight:(NSString*)text{
    isOpen = YES;
    textLabel.text = text;
    size = [Utilities getSize:textLabel.text withFont:textLabel.font withWidth:textLabel.frame.size.width];
    CGRect rt;
    rt = textLabel.frame;
    rt.size.height = size.height + 15;
    textLabel.frame = rt;
    
    rt = self.frame;
    rt.size.height = 45 + size.height +15;
    self.frame = rt;
    
}

- (IBAction)btnAction:(id)sender{
    isOpen = !isOpen;
    CGRect rt;
    if (isOpen) {
        imageView.image = [UIImage imageNamed:@"zzz"];
        imageLabel.text = @"关闭";
        textLabel.hidden = NO;
        
        rt = self.frame;
        rt.size.height = 45 + size.height + 15;
        self.frame = rt;
    }else{
        imageView.image = [UIImage imageNamed:@"yyy"];
        imageLabel.text = @"展开";
        textLabel.hidden = YES;
        
        rt = self.frame;
        rt.size.height = 45;
        self.frame = rt;
    }
    if ([delegate respondsToSelector:@selector(changePositionView)]) {
        [delegate changePositionView];
    }
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
