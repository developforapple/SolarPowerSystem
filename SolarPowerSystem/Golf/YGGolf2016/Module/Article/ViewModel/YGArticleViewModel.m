//
//  YGArticleViewModel.m
//  Golf
//
//  Created by bo wang on 16/6/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleViewModel.h"
#import "YGThriftInclude.h"
#import "YYModel.h"
#import "YGCommon.h"

static const CGFloat kDefaultTitleLabelFont = 16.f;
//static const CGFloat kDefaultMicroLabelFont = 13.f;
static const CGFloat kDefaultMicroLabelHeight = 14.f;

@interface YGArticleViewModel ()
@property (assign, nonatomic) CGFloat titleHeight;
@property (strong, readwrite, nonatomic) NSString *title;        //标题内容
@property (strong, readwrite, nonatomic) NSString *sourceName;   //来源
@property (strong, readwrite, nonatomic) NSString *dateString;   //时间
@property (strong, readwrite, nonatomic) NSString *categoryName; //分类
@end

@implementation YGArticleViewModel
+ (instancetype)viewModelWithEntity:(id)entity
{
    if (![entity isKindOfClass:[YueduArticleBean class]]) return nil;
    
    YGArticleViewModel *vm = [super viewModelWithEntity:entity];
    YueduArticleBean *article = entity;
    
    vm->_title = article.name;
    vm->_sourceName = article.source;
    vm->_dateString = [article articleCreateTimeDescription];
    vm->_categoryName = [article.category name];
    
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:kDefaultTitleLabelFont]};
    CGRect boundingRect = [vm.title boundingRectWithSize:CGSizeMake(Device_Width-30.f, 100000) options:NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil];
    CGFloat height = CGRectGetHeight(boundingRect);
    vm->_titleHeight = ceilf(height);
    
    return vm;
}

YYModelDefaultCode
@end

@interface YGArticleNormalViewModel ()
@property (strong, readwrite, nonatomic) NSURL *imageURL;
@end

@implementation YGArticleNormalViewModel

+ (instancetype)viewModelWithEntity:(id)entity
{
    YGArticleNormalViewModel *vm = [super viewModelWithEntity:entity];
    [vm _setup];
    return vm;
}

- (void)_setup
{
    YueduArticleBean *article = self.entity;
    YueduArticleImageBean *imageBean = [article.pictures firstObject];
    
    self->_imageURL = [NSURL URLWithString:imageBean.name];
}

- (CGFloat)containerHeight
{
    return 110.f;
}

YYModelDefaultCode
@end

@interface YGArticleImagesViewModel ()
@property (strong, readwrite, nonatomic) NSArray<NSURL *> *imageURLs;
@end

@implementation YGArticleImagesViewModel

+ (instancetype)viewModelWithEntity:(id)entity
{
    YGArticleImagesViewModel *vm = [super viewModelWithEntity:entity];
    [vm _setup];
    return vm;
}

- (void)_setup
{
    YueduArticleBean *article = self.entity;
    NSArray *pictures = article.pictures;
    NSMutableArray *URLs = [NSMutableArray array];
    for (NSUInteger i = 0; i < 3; i++) {
        if (i < pictures.count) {
            YueduArticleImageBean *imageBean = pictures[i];
            NSURL *URL = [NSURL URLWithString:imageBean.name];
            if (URL) {
                [URLs addObject:URL];
            }
        }
    }
    self->_imageURLs = [NSArray arrayWithArray:URLs];
}

- (CGFloat)containerHeight
{
    CGFloat titleTop = 15.f;
    CGFloat titleH = self.titleHeight;
    CGFloat titleBottom = 15.f;
    CGFloat imageH =  ceilf(136.f/186.f*(Device_Width-15.f*2-5.f*2)/3);
    CGFloat imageBottom = 15.f;
    CGFloat sourceH = kDefaultMicroLabelHeight;
    CGFloat sourceBottom = 15.f;
    return titleTop + titleH + titleBottom + imageH + imageBottom + sourceH + sourceBottom + 1.f;
}

YYModelDefaultCode
@end

@interface YGArticleVideoViewModel ()
@property (strong, readwrite, nonatomic) NSURL *imageURL;
@end

@implementation YGArticleVideoViewModel

+ (instancetype)viewModelWithEntity:(id)entity
{
    YGArticleVideoViewModel *vm = [super viewModelWithEntity:entity];
    [vm _setup];
    return vm;
}

- (void)_setup
{
    YueduArticleBean *article = self.entity;
    YueduArticleImageBean *imageBean = [article.pictures firstObject];
    
    self->_imageURL = [NSURL URLWithString:imageBean.name];
}

- (CGFloat)containerHeight
{
    CGFloat imageTop = 15.f;
    CGFloat imageH = ceilf(300.f/580.f * (Device_Width-15.f*2));
    CGFloat imageBottom = 15.f;
    CGFloat titleH = self.titleHeight;
    CGFloat titleBottom = 15.f;
    CGFloat sourceH = kDefaultMicroLabelHeight;
    CGFloat sourceBottom = 15.f;
    return imageTop + imageH + imageBottom + titleH + titleBottom + sourceH + sourceBottom + 1.f;
}

YYModelDefaultCode
@end

@interface YGArticleVideo2ViewModel ()
@property (strong, readwrite, nonatomic) NSURL *imageURL;        //图片
@property (strong, readwrite, nonatomic) NSString *videoLengthString;
@end

@implementation YGArticleVideo2ViewModel

+ (instancetype)viewModelWithEntity:(id)entity
{
    YGArticleVideo2ViewModel *vm = [super viewModelWithEntity:entity];
    [vm _setup];
    return vm;
}

- (void)_setup
{
    YueduArticleBean *article = self.entity;
    YueduArticleImageBean *imageBean = [article.pictures firstObject];
    
    self->_imageURL = [NSURL URLWithString:imageBean.name];
    self->_videoLengthString = article.videoLength;
}

- (CGFloat)containerHeight
{
    return 110.f;
}

YYModelDefaultCode
@end
