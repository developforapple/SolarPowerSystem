

#import "YGMallBrandTitleView.h"

@implementation YGMallBrandTitleView

- (instancetype)initWithFrame:(CGRect)frame title:(NSString*)title completion:(void(^)(YGMallBrandTitleView *brandNavView))completion{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
        self.completion = completion;
        if (title.length > 0) {
            CGSize sz = [Utilities getSize:title withFont:[UIFont systemFontOfSize:17] withWidth:100];
            sz.width = MAX(sz.width, 50.f);
                        
            UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, sz.width+25, 20)];
            titleLabel.font = [UIFont boldSystemFontOfSize:18];
            titleLabel.backgroundColor = [UIColor clearColor];
            titleLabel.textColor = MainHighlightColor;
            titleLabel.textAlignment = NSTextAlignmentCenter;
            titleLabel.text = title;
            [self addSubview:titleLabel];
            
            UILabel *deleteLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(titleLabel.frame), 4, 20, 20)];
            deleteLabel.font = [UIFont boldSystemFontOfSize:20];
            deleteLabel.backgroundColor  = [UIColor clearColor];
            deleteLabel.textColor = MainHighlightColor;
            deleteLabel.textAlignment = NSTextAlignmentLeft;
            deleteLabel.text = @"×";
            [self addSubview:deleteLabel];
            
            [Utilities drawView:self radius:5 borderColor:MainHighlightColor];
            
            self.frame = CGRectMake(0, 0, CGRectGetMaxX(deleteLabel.frame), 30);
        }
    }
    return self;
}

+ (instancetype)shareInstance:(NSString *)title completion:(void(^)(YGMallBrandTitleView *brandNavView))completion{
    return [[self alloc] initWithFrame:CGRectZero title:title completion:completion];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    if (self.completion) {
        self.completion(self);
    }
}

@end
