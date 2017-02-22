//
//  TeachingListView.m
//  test2
//
//  Created by 廖瀚卿 on 15/6/4.
//  Copyright (c) 2015年 额度. All rights reserved.
//

#import "TeachingListView.h"
#import "TeachingItemView.h"
#import "UIView+AutoLayout.h"
#import "UIImageView+WebCache.h"
#import "CoachTimetable.h"

#define kCellHeight 44
#define kHeaderHeight 40

@implementation TeachingListView


-(void)loadList:(NSDictionary *)data{
    
    _labelDatetime.text = data[@"title"];
    
    CGFloat h = kHeaderHeight - (kCellHeight - 32) / 2;//kCellHeight + kPadding * 2; //上下间距
    
    UIView *view = nil;
    NSArray *arr = ((TimeList *)data[@"data"][@"modal"]).reservationList;
    for (int i = 0; i < [arr count]; i++) {
        ReservationModel *nd = (ReservationModel *)[arr objectAtIndex:i];
        
        TeachingItemView *cv = [[[NSBundle mainBundle] loadNibNamed:@"TeachingItemView" owner:nil options:0] firstObject];
        cv.translatesAutoresizingMaskIntoConstraints = NO;
        cv.reservationModel = nd;
        cv.blockCellPressed = ^(id data){
            if (_blockCellPressed) {
                _blockCellPressed(@{@"type":@"cell",@"data":data});
            }
        };
        cv.blockRightPressed = ^(id data){
            if (_blockRightPressed) {
                _blockRightPressed(@{@"type":@"right",@"data":data});
            }
        };
        switch (nd.reservationStatus) {
            case 1:
                [cv setCellType:CellTypeLabel];
                [cv.labelTitle setText:@"待上课"];
                break;
            case 2:
                [cv setCellType:CellTypeLabel];
                [cv.labelTitle setText:@"已完成"];
                break;
            case 3:
                [cv setCellType:CellTypeLabel];
                [cv.labelTitle setText:@"未到场"];
                break;
            case 4:
                [cv setCellType:CellTypeLabel];
                [cv.labelTitle setText:@"已取消"];
                break;
            case 5:
                [cv setCellType:CellTypeButton];
                [cv.labelTitle setText:@"待确认"];
                break;
            case 6:
                [cv setCellType:CellTypeLabel];
                [cv.labelTitle setText:@"待评价"];
                break;
            default:
                break;
        }
        
        
        cv.labelName.text = nd.nickName;
        [cv.imgHead sd_setImageWithURL:[NSURL URLWithString:nd.headImage] placeholderImage:[UIImage imageNamed:@"head_member"]];
        
        [self addSubview:cv];
        [cv pinAttribute:(NSLayoutAttributeTop) toAttribute:(NSLayoutAttributeBottom) ofItem:(i == 0 ? _labelDatetime:view) withConstant:0 relation:(NSLayoutRelationEqual)];
        [cv constrainToWidth:self.frame.size.width];
        [cv constrainToHeight:kCellHeight];
        [cv pinToSuperviewEdges:(JRTViewPinLeftEdge) inset:0];
        [cv pinToSuperviewEdges:(JRTViewPinRightEdge) inset:0];
        
        h += kCellHeight;
        view = cv;
    }
    
    self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, h+5);
}

@end
