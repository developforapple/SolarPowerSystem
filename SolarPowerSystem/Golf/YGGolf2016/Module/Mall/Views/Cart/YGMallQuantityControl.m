//
//  YGMallQuantityControl.m
//  Golf
//
//  Created by bo wang on 2016/10/10.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMallQuantityControl.h"
#import "ReactiveCocoa.h"

@interface YGMallQuantityControl ()
@property (weak, nonatomic) IBOutlet UIButton *incrementBtn;
@property (weak, nonatomic) IBOutlet UIButton *decrementBtn;
@property (weak, nonatomic) IBOutlet UILabel *valueLabel;
@end

@implementation YGMallQuantityControl

- (instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self) {
        [self setup];
    }
    return self;
}

- (void)setup
{
    _value = 0;
    _stepValue = 1;
}

- (void)changeValueTo:(NSInteger)value
{
    BOOL shouldChange = YES;
    if ([self.delegate respondsToSelector:@selector(quantityControl:shouldChangeValue:from:)]) {
        shouldChange = [self.delegate quantityControl:self shouldChangeValue:value from:self.value];
    }
    if (shouldChange) {
        self.value = value;
        self.valueLabel.text = [NSString stringWithFormat:@"%ld",(long)value];
        if ([self.delegate respondsToSelector:@selector(quantityControl:didChangedValue:)]) {
            [self.delegate quantityControl:self didChangedValue:self.value];
        }
    }
}

- (void)setValue:(NSInteger)value
{
    _value = value;
    self.valueLabel.text = [@(value) stringValue];
}

- (IBAction)decrement:(id)sender
{
    NSInteger value = self.value - self.stepValue;
    [self changeValueTo:value];
}

- (IBAction)increment:(id)sender
{
    NSInteger value = self.value + self.stepValue;
    [self changeValueTo:value];
}

@end
