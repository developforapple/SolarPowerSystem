//
//  SectionView.m
//  Golf
//
//  Created by user on 13-2-26.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import "SectionView.h"
#import "Utilities.h"

@implementation SectionView
@synthesize disclosureButton,provinceName,delegate,section;


- (id)initWithFrame:(CGRect)frame section:(NSInteger)section_ title:(NSString *)title open:(BOOL)isOpen delegate:(id<CitySectionViewDelegate>)delegate_
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor whiteColor];
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleOpen:)];
        [self addGestureRecognizer:tapGesture];
        
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(45, 10, 200, 20)];
        label.font = [UIFont boldSystemFontOfSize:14];
        label.textColor = [UIColor blackColor];
        label.text = title;
        label.backgroundColor = [UIColor clearColor];
        [self addSubview:label];
        self.provinceName = label;
        
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setFrame:CGRectMake(15.0, 10.0, 20.0, 20.0)];
        [button setImage:[UIImage imageNamed:@"carat.png"] forState:UIControlStateNormal];
        [button setImage:[UIImage imageNamed:@"carat_open.png"] forState:UIControlStateSelected];
        [button addTarget:self action:@selector(toggleOpen:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
        self.disclosureButton = button;
        disclosureButton.selected = isOpen;
        
        UIImageView *line = [[UIImageView alloc] initWithFrame:CGRectMake(15, 39, Device_Width, 1)];
        line.backgroundColor = [Utilities R:230 G:230 B:230];
        [self addSubview:line];
        
        self.delegate = delegate_;
        self.section = section_;
    }
    return self;
}

- (void)selectProvince:(id)sender{
    [self.delegate sectionheaderView:self selectProvince:self.section];
}

-(void)toggleOpen:(id)sender {
    [self sectionHeardOpen:YES];
}

-(void)sectionHeardOpen:(BOOL)isOpen {
    self.disclosureButton.selected = !self.disclosureButton.selected;
    if (isOpen) {
        if (self.disclosureButton.selected) {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionOpened:)]) {
                [self.delegate sectionHeaderView:self sectionOpened:self.section];
            }
        }
        else {
            if ([self.delegate respondsToSelector:@selector(sectionHeaderView:sectionClosed:)]) {
                [self.delegate sectionHeaderView:self sectionClosed:self.section];
            }
        }
    }
}

@end
