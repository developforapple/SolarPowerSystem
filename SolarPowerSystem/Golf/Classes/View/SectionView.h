//
//  SectionView.h
//  Golf
//
//  Created by user on 13-2-26.
//  Copyright (c) 2013年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol CitySectionViewDelegate;

@interface SectionView : UIView

@property (nonatomic,strong) UIButton *disclosureButton;
@property (nonatomic,strong) UILabel *provinceName;
@property (nonatomic) NSInteger section;
@property (nonatomic,weak) id<CitySectionViewDelegate> delegate;

- (void)sectionHeardOpen:(BOOL)isOpen;
- (id)initWithFrame:(CGRect)frame section:(NSInteger)section title:(NSString *)title open:(BOOL)isOpen delegate:(id<CitySectionViewDelegate>)delegate_;
-(void)toggleOpen:(id)sender ;

@end

@protocol CitySectionViewDelegate <NSObject>

@optional
-(void)sectionHeaderView:(SectionView*)sectionHeaderView sectionOpened:(NSInteger)section;
-(void)sectionHeaderView:(SectionView*)sectionHeaderView sectionClosed:(NSInteger)section;
-(void)sectionheaderView:(SectionView*)sectionHeaderView selectProvince:(NSInteger)section;
@end