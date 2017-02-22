//
//  NoResultView.m
//  Golf
//
//  Created by 黄希望 on 15/5/28.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "NoResultView.h"

static NoResultView *instance = nil;

@interface NoResultView ()

@property (nonatomic,weak) IBOutlet UIImageView *imgv;
@property (nonatomic,weak) IBOutlet UILabel *textLabel;
@property (weak, nonatomic) IBOutlet UIButton *btn;

@property (nonatomic,copy) void (^show)(void);
@property (nonatomic,copy) void (^hide)(void);
@property (nonatomic,copy) void (^btnTaped)(void);

@end

@implementation NoResultView

- (IBAction)btnPressed:(id)sender{
    if (self.btnTaped) {
        self.btnTaped();
    }
}


+ (NoResultView *)text:(NSString *)text type:(NoResultType)type superView:(UIView *)sv show:(void (^)(void))show hide:(void (^)(void))hide{
    NoResultView *view = [[[NSBundle mainBundle] loadNibNamed:@"NoResultView" owner:self options:nil] lastObject];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [sv insertSubview:view atIndex:0];
    [view centerInView:sv];
    view.show = show;
    view.hide = hide;
    view.hidden = YES;
    view.imgv.image = [NoResultView getImageByType:type];
    view.textLabel.text = text;
    
    return view;
}

+ (NoResultView *)text:(NSString *)text type:(NoResultType)type superView:(UIView *)sv
              btnTaped:(void (^)(void))btnTaped
                  show:(void (^)(void))show
                  hide:(void (^)(void))hide{
    NoResultView *view = [[[NSBundle mainBundle] loadNibNamed:@"NoResultView" owner:self options:nil] lastObject];
    view.translatesAutoresizingMaskIntoConstraints = NO;
    [sv insertSubview:view atIndex:0];
    [view centerInView:sv];
    [view pinToSuperviewEdges:(JRTViewPinAllEdges) inset:0];
    
    if (btnTaped) {
        view.btnTaped = btnTaped;
        view.btn.hidden = NO;
    }else{
        view.btn.hidden = YES;
    }
    
    view.show = show;
    view.hide = hide;
    view.hidden = YES;
    view.imgv.image =  [NoResultView getImageByType:type];;
    view.textLabel.text = text;
    
    return view;
}



+ (UIImage *)getImageByType:(NoResultType)type{
    UIImage *img = nil;
    switch (type) {
        case NoResultTypeBill:
            img = [UIImage imageNamed:@"img_none_bill_gray"];
            break;
        case NoResultTypeSearch:
            img = [UIImage imageNamed:@"img_none_search_gray"];
            break;
        case NoResultTypeWifi:
            img = [UIImage imageNamed:@"img_none_wifi_gray"];
            break;
        case NoResultTypeList:
        default:
            img = [UIImage imageNamed:@"img_none_list_gray"];
            break;
    }
    return img;
}


- (void)show:(BOOL)isShow{
    self.hidden = !isShow;
    if (isShow) {
        if (self.show) {
            self.show();
        }
    }else{
        if (self.hide) {
            self.hide();
        }
    }
}
 

@end
