//
//  YGArticleDetailHeaderViewModel.m
//  Golf
//
//  Created by bo wang on 16/6/13.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGArticleDetailHeaderViewModel.h"
#import "YGThriftInclude.h"

@implementation YGArticleDetailHeaderViewModel

+ (DDViewModel *)viewModelWithEntity:(id)entity
{
    YGArticleDetailHeaderViewModel *vm = [super viewModelWithEntity:entity];  
    [vm _setup];
    return vm;
}

- (void)_setup
{
    YueduArticleBean  *article = self.entity;
    
    // video
    if ([article isVideo]) {
        self->_videoHeight = ceilf(200/320.f*Device_Width);
        self->_videoHidden = NO;
        self->_downloadVisible = YES;
        self->_downloadWidth = 60.f;
        
        YueduArticleImageBean *image = [article.pictures firstObject];
        self->_videoImageURL = [NSURL URLWithString:[image name]];
    }else{
        self->_videoHeight = 0.f;
        self->_videoHidden = YES;
        self->_downloadVisible = NO;
        self->_downloadWidth = 15.f;
    }
    
    // 目前不需要下载功能。
    self->_downloadVisible = NO;
    self->_downloadWidth = 15.f;
    
    // header title
    self->_headerHeight = 90.f;
    self->_title = article.name;
    self->_subtitle2 = [article articleCreateTimeDescription];
    self->_subtitle1 = article.category.name;
    
    // web
    NSString *html = article.html;
    if (html) {
        self->_hadContent = YES;
        self->_contentHeight = 200.f;
        self->_html = [NSString stringWithFormat:@" <html>\
                                                        <head>\
                                                            <meta name='viewport' content='user-scalable=no,width=device-width, initial-scale=1.0,maximum-scale=1.0'>\
                                                            <link type='text/css' href='Yuedu.css' rel='stylesheet' />\
                                                            <script type='text/javascript' src='%@'></script>\
                                                        </head>\
                                                        <body>\
                                                            %@\
                                                        </body>\
                                                    </html>",
                                            iOS8?@"Yuedu_iOS8.js":@"Yuedu_iOS7.js",    //不同的webView执行不同版本的js
                                            html];                                      //正文内容
    }else{
        self->_hadContent = NO;
        self->_contentHeight = 0.f;
        self->_html = nil;
    }
    
    self->_tagList = [NSArray arrayWithArray:article.tags];
    NSMutableArray *sizes = [NSMutableArray array];
    NSDictionary *arrtibutes = @{NSFontAttributeName:[UIFont systemFontOfSize:13]};
    for (NSString *tag in self.tagList) {
        CGSize size = [tag sizeWithAttributes:arrtibutes];
        size.width += 2*13.f;
        size.height = 28.f;
        [sizes addObject:[NSValue valueWithCGSize:size]];
    }
    self->_tagSizes = sizes;
    if (self.tagList.count != 0) {
        self->_tagHeight = 28.f*1;  // 1行
        self->_footerHeight = self.tagHeight + (article.album?20.f:50.f);
    }else{
        self->_tagHeight = 0.f;
        self->_footerHeight = article.album?20.f:30.f; //有内容但是没标签时
    }
    
    self->_sourceLink = [NSURL URLWithString:article.link];
}

- (void)estimateHeaderHeightInContainerView:(UIView *)view
{
    if (!view) {
        self->_headerHeight = 90.f;
    }else{
        [view layoutIfNeeded];
        CGSize size = [view systemLayoutSizeFittingSize:UILayoutFittingCompressedSize];
        self->_headerHeight = ceilf(size.height);
    }
}

- (void)setWebContentHeight:(CGFloat)height
{
    self->_contentHeight = self.hadContent?(height+30.f):height;
}

- (CGFloat)containerHeight
{
    return self.videoHeight + self.headerHeight + self.contentHeight + self.footerHeight;
}

@end
