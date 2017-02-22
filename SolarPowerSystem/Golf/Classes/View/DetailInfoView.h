//
//  DetailInfoView.h
//  Golf
//
//  Created by user on 13-3-13.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DetailInfoView : UIView{
}

@property (nonatomic,strong) NSArray *componentArray;
@property (nonatomic) CGFloat orgX;

- (id)initWithFrame:(CGRect)frame withHeadTitle:(NSString *)title withContentArray:(NSArray *)contentArray withlocation:(CGFloat)org_x;

@end
