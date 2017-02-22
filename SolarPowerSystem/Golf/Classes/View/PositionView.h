//
//  PositionView.h
//  Golf
//
//  Created by user on 13-6-27.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PositionViewDelegate <NSObject>

- (void)changePositionView;

@end

@interface PositionView : UIView{
    BOOL isOpen;
    CGSize size;
}

@property (nonatomic,strong) IBOutlet UIImageView *imageView;
@property (nonatomic,strong) IBOutlet UILabel *imageLabel;
@property (nonatomic,strong) IBOutlet UILabel *textLabel;
@property (nonatomic,weak) id<PositionViewDelegate> delegate;

- (void)jisuanHeight:(NSString*)text;
- (IBAction)btnAction:(id)sender;

@end
