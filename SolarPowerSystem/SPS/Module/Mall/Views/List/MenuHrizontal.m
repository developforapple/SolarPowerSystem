//
//  MenuHrizontal.m
//  ShowProduct
//
//  Created by lin on 14-5-22.
//  Copyright (c) 2014年 @"". All rights reserved.
//

#import "MenuHrizontal.h"

#define BUTTONITEMWIDTH   70

@implementation MenuHrizontal
- (id)initWithFrame:(CGRect)frame ButtonItems:(NSArray *)aItemsArray
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        
        lastIndex = -1;
        
        if (mButtonArray == nil) {
            mButtonArray = [[NSMutableArray alloc] init];
        }
        if (mScrollView == nil) {
            mScrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
            mScrollView.backgroundColor = [UIColor clearColor];
            mScrollView.showsHorizontalScrollIndicator = NO;
        }
        if (mItemInfoArray == nil) {
            mItemInfoArray = [[NSMutableArray alloc] init];
        }
        [mItemInfoArray removeAllObjects];
        
        [self createMenuItems:aItemsArray];
    }
    return self;
}

-(void)createMenuItems:(NSArray *)aItemsArray{
    int i = 0;
    float menuWidth = 0.0;
    for (NSDictionary *lDic in aItemsArray) {
        NSString *vTitleStr = [lDic objectForKey:TITLEKEY];
        float vButtonWidth = [[lDic objectForKey:TITLEWIDTH] floatValue];
        UIButton *vButton = [UIButton buttonWithType:UIButtonTypeCustom];
        vButton.backgroundColor = [UIColor clearColor];
        [vButton setTitle:vTitleStr forState:UIControlStateNormal];
        [vButton setTitleColor:[UIColor darkGrayColor] forState:UIControlStateNormal];
        [vButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
        [vButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 5)];
        vButton.titleLabel.font = [UIFont systemFontOfSize:13];
        [vButton setTag:i];
        [vButton.layer setBorderColor:[Utilities R:6 G:156 B:216].CGColor];
        [vButton.layer setCornerRadius:3];
        [vButton addTarget:self action:@selector(menuButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        [vButton setFrame:CGRectMake(menuWidth+14, 6, vButtonWidth-24, 24)];
        
        UIImageView *deleteImg = [[UIImageView alloc] initWithFrame:CGRectMake(vButton.frame.size.width-13, vButton.frame.size.height-13, 13, 13)];
        deleteImg.image = [UIImage imageNamed:@"sb_delete.png"];
        deleteImg.tag = 100;
        deleteImg.hidden = YES;
        [vButton addSubview:deleteImg];
        [mScrollView addSubview:vButton];
        [mButtonArray addObject:vButton];
        
        menuWidth += vButtonWidth;
        i++;
        
        //保存button资源信息，同时增加button.oringin.x的位置，方便点击button时，移动位置。
        NSMutableDictionary *vNewDic = [lDic mutableCopy];
        [vNewDic setObject:[NSNumber numberWithFloat:menuWidth] forKey:TOTALWIDTH];
        [mItemInfoArray addObject:vNewDic];
    }
    
    [Utilities lineviewWithFrame:CGRectMake(0, self.frame.size.height-1, Device_Width, 1) forView:self];
    
    [mScrollView setContentSize:CGSizeMake(menuWidth, self.frame.size.height)];
    [self addSubview:[[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)]];
    
    [self addSubview:mScrollView];
    // 保存menu总长度，如果小于320则不需要移动，方便点击button时移动位置的判断
    mTotalWidth = menuWidth;
}

#pragma mark - 其他辅助功能
#pragma mark 取消所有button点击状态
-(void)changeButtonsToNormalState{
    for (UIButton *vButton in mButtonArray) {
        vButton.selected = NO;
        UIImageView *imagev = (UIImageView*)[vButton viewWithTag:100];
        imagev.hidden = YES;
        [vButton.layer setBorderWidth:0];
    }
}

#pragma mark 模拟选中第几个button
-(void)clickButtonAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    [self menuButtonClicked:vButton];
}

#pragma mark 改变第几个button为选中状态，不发送delegate
-(void)changeButtonStateAtIndex:(NSInteger)aIndex{
    UIButton *vButton = [mButtonArray objectAtIndex:aIndex];
    BOOL selected = NO;
    if (lastIndex>=0 && lastIndex == aIndex) {
        UIButton *lastBtn = [mButtonArray objectAtIndex:aIndex];
        selected = lastBtn.selected;
    }
    [self changeButtonsToNormalState];
    selected = !selected;
    vButton.selected = selected;
    UIImageView *imagev = (UIImageView*)[vButton viewWithTag:100];
    if (selected) {
        imagev.hidden = NO;
        [vButton.layer setBorderWidth:1];
    }else{
        imagev.hidden = YES;
        [vButton.layer setBorderWidth:0];
    }
    [self moveScrolViewWithIndex:aIndex];
}

#pragma mark 移动button到可视的区域
-(void)moveScrolViewWithIndex:(NSInteger)aIndex{
    if (mItemInfoArray.count < aIndex) {
        return;
    }
     //宽度小于320肯定不需要移动
    if (mTotalWidth <= 320) {
        return;
    }

    NSDictionary *vDic = [mItemInfoArray objectAtIndex:aIndex];
    float vButtonOrigin = [[vDic objectForKey:TOTALWIDTH] floatValue];
    if (aIndex>0) {
        float offsetX = mScrollView.contentOffset.x;
        NSDictionary *vDic0 = [mItemInfoArray objectAtIndex:aIndex-1];
        float vButtonOrigin0 = [[vDic0 objectForKey:TOTALWIDTH] floatValue];
        float vButtonWidth = vButtonOrigin-vButtonOrigin0;
        float originX = vButtonOrigin0-mScrollView.contentOffset.x;
        if (originX+vButtonWidth>0 && originX <= vButtonWidth) {//向右
            if (aIndex>1) {
                NSDictionary *vDic2 = [mItemInfoArray objectAtIndex:aIndex-2];
                float vButtonOrigin2 = [[vDic2 objectForKey:TOTALWIDTH] floatValue];
                [mScrollView setContentOffset:CGPointMake(vButtonOrigin2, mScrollView.contentOffset.y) animated:YES];
            }else{
                [mScrollView setContentOffset:CGPointMake(0, mScrollView.contentOffset.y) animated:YES];
            }
            return;
        }
        
        if (vButtonOrigin >= 290) {
            if (vButtonOrigin+30>320+offsetX && vButtonOrigin0+30 < 320+offsetX) {
                if (aIndex<=mItemInfoArray.count-2) {
                    NSDictionary *vDic1 = [mItemInfoArray objectAtIndex:aIndex+1];
                    float vButtonOrigin1 = [[vDic1 objectForKey:TOTALWIDTH] floatValue];
                    [mScrollView setContentOffset:CGPointMake(vButtonOrigin1-320, mScrollView.contentOffset.y) animated:YES];
                }
            }
        }
    }
}

#pragma mark - 点击事件
-(void)menuButtonClicked:(UIButton *)aButton{
    [self changeButtonStateAtIndex:aButton.tag];
    lastIndex = aButton.tag;
    if ([_delegate respondsToSelector:@selector(didMenuHrizontalClickedButtonAtIndex:selected:)]) {
        [_delegate didMenuHrizontalClickedButtonAtIndex:aButton.tag selected:aButton.selected];
    }
}

@end
