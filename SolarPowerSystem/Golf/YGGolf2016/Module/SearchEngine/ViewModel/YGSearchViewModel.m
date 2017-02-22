//
//  YGSearchViewModel.m
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGSearchViewModel.h"
#import "YGSearch.h"
#import "YGFoundationCategories.h"
#import "Utilities.h"

@implementation YGSearchViewModel
- (NSDictionary *)attributes:(UIFont *)font color:(UIColor *)color
{
    NSMutableDictionary *dict = [NSMutableDictionary dictionary];
    dict[NSFontAttributeName] = font;
    dict[NSForegroundColorAttributeName] = color;
    return dict;
}
@end

@implementation YGSearchCourseViewModel

- (void)create
{
    CourseResultBean *bean = self.entity;
    if (![bean isKindOfClass:[CourseResultBean class]]) return;
    
    NSString *name = bean.courseName;
    
    CGFloat margin = 15.f;
    CGFloat perferWidth = Device_Width - 2 * margin;
    
    NSDictionary *normal = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchNormalColor];
    NSDictionary *highlight = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchHighlightColor];
    self->_nameLayout = [NSAttributedString layoutOfOriginString:name
                                                 highlightString:self.keywords
                                                normalAttributes:normal
                                             highlightAttributes:highlight
                                                    maximumLines:1
                                                     perferWidth:perferWidth
                                                    clipWordsLen:0
                                                     lineSpacing:0];
}

- (CGFloat)containerHeight
{
    CGFloat minimum = 44.f,top = 15.f,bottom = 15.f;
    CGSize size = [self.nameLayout textBoundingSize];
    CGFloat h = top + size.height + bottom;
    
    // 有一个最小高度
    return MAX(minimum, h);
}
@end

@implementation YGSearchCommodityViewModel

- (void)create
{
    CommodityResultBean *bean = self.entity;
    if (![bean isKindOfClass:[CommodityResultBean class]]) return;
    
    CGFloat margin = 15.f;  //左右边距
    CGFloat spacing = 10.f; //中间间距
    CGFloat imageW = 42.f;  //图片宽度
    
    self->_commodityImageURL = [NSURL URLWithString:bean.photoImage];
    
    CGFloat perferWidth = Device_Width - 2 * margin - spacing - imageW;
    
    NSDictionary *normal = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchNormalColor];
    NSDictionary *highlight = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchHighlightColor];
    
    NSString *title = bean.commodityName;
    self->_commodityTitleLayout = [NSAttributedString layoutOfOriginString:title
                                                         highlightString:self.keywords
                                                        normalAttributes:normal
                                                     highlightAttributes:highlight
                                                            maximumLines:2
                                                             perferWidth:perferWidth
                                                            clipWordsLen:0
                                                             lineSpacing:4.f];
}

- (CGFloat)containerHeight
{
//    CGFloat minimum = 64.f,top = 10.f,bottom = 10.f;
//    CGSize size = [self.commodityTitleLayout textBoundingSize];
//    CGFloat h = top + size.height + bottom;
//    
//    // 有一个最小高度
//    return MAX(minimum, h);
    
    // 固定高度
    return 62.f;
}

@end

@implementation YGSearchFeedViewModel
- (void)create
{
    TopicResultBean *bean = self.entity;
    if (![bean isKindOfClass:[TopicResultBean class]]) return;

    CGFloat margin = 15.f;  //左右边距
    CGFloat spacing = 8.f; //中间间距
    CGFloat imageW = 20.f;  //图片宽度
    
    self->_userImageURL = [NSURL URLWithString:bean.headImage];
    
    CGFloat perferWidth = Device_Width - 2 * margin - spacing - imageW;
    NSDictionary *normal = [self attributes:[UIFont systemFontOfSize:13] color:kYGSearchLightGrayColor];
    NSDictionary *highlight = [self attributes:[UIFont systemFontOfSize:13] color:kYGSearchHighlightColor];
    
    self->_nickName = bean.displayName;
    self->_date = bean.topicTime?:@"";
    
    NSString *location = bean.location;
    if (location.length != 0) {
        self->_locationLayout = [NSAttributedString layoutOfOriginString:location
                                                         highlightString:self.keywords
                                                        normalAttributes:normal
                                                     highlightAttributes:highlight
                                                            maximumLines:1
                                                             perferWidth:perferWidth
                                                            clipWordsLen:0
                                                             lineSpacing:0];
    }
    
    
    NSDictionary *normal2 = [self attributes:[UIFont systemFontOfSize:14] color:kYGSearchNormalColor];
    NSDictionary *highlight2 = [self attributes:[UIFont systemFontOfSize:14] color:kYGSearchHighlightColor];
    self->_contentLayout = [NSAttributedString layoutOfOriginString:bean.topicContent
                                                    highlightString:self.keywords
                                                   normalAttributes:normal2
                                                highlightAttributes:highlight2
                                                       maximumLines:2
                                                        perferWidth:perferWidth
                                                       clipWordsLen:0
                                                        lineSpacing:4.f];
    self->_contentHeight = [self.contentLayout textBoundingSize].height;
    
    int32_t linkType = bean.linkType;
    YGSearchFeedType feedType = YGSearchFeedTypeNormal;
    YGSearchFeedSubType subType = YGSearchFeedSubTypeNormal;
    
    // 这里存在同时有图片和计分卡的情况
    self->_pointCardVisible = linkType==3;
    
    if (linkType == 1) {
        // 分享了普通文章
        feedType = YGSearchFeedTypeShare;
        subType = YGSearchFeedSubTypeNormalLink;
    }else if (linkType == 2){
        // 分享了视频
        feedType = YGSearchFeedTypeShare;
        subType = YGSearchFeedSubTypeVideoLink;
    }else{
        if (bean.topicVideo.length != 0) {
            subType = YGSearchFeedSubTypeVideo; //视频
        }else if(bean.topicPictures.count == 1){
            subType = YGSearchFeedSubTypeSingleImage;//单图
        }else if (bean.topicPictures.count > 1){
            feedType = YGSearchFeedTypeMultiImage;  //多图
        }
    }

    self->_type = feedType;
    self->_subType = subType;
    
    switch (self.type) {
        case YGSearchFeedTypeNormal:
        case YGSearchFeedTypeMultiImage: {
            NSMutableArray *imageURLs = [NSMutableArray array];
            for (NSString *pic in bean.topicPictures) {
                NSURL *URL = [NSURL URLWithString:pic];
                URL?[imageURLs addObject:URL]:0;
            }
            self->_imageURLs = imageURLs;
            
            if (YGSearchFeedTypeNormal == self.type && self.imageURLs.count == 1) {
                //显示单张图
                static const CGFloat imageMaxWidth = 150.f;
                static const CGFloat imageMaxHeight = 100.f;
                CGFloat ratio = imageMaxHeight/imageMaxWidth;
                
                NSString *URLString = [[imageURLs firstObject] absoluteString];
                CGSize size = [Utilities imageSizeWithUrl:URLString];

                CGFloat imageOriginW = size.width<=0?imageMaxWidth:size.width;
                CGFloat imageOriginH = size.height<=0?imageMaxHeight:size.height;
                
                CGFloat imageH = imageOriginH,imageW = imageOriginW;
                
                if (imageOriginW > imageMaxWidth || imageOriginH > imageMaxHeight) {
                    CGFloat imageRatio = imageOriginH/imageOriginW;
                    
                    if (imageRatio < ratio) {
                        //以宽为基准计算高
                        imageW = imageMaxWidth;
                        imageH = imageW * imageOriginH / imageOriginW;
                    }else{
                        //以高为基准计算宽度
                        imageH = imageMaxHeight;
                        imageW = imageH * imageOriginW / imageOriginH;
                    }
                }
                self->_imageWidth = imageW;
                self->_imageHeight = imageH;
            }
            break;
        }
        case YGSearchFeedTypeShare: {
            switch (self.subType) {
                case YGSearchFeedSubTypeNormal:         //不处理
                case YGSearchFeedSubTypeSingleImage:    //不处理
                case YGSearchFeedSubTypeVideo: {        //不处理
                    break;
                }
                case YGSearchFeedSubTypeNormalLink:
                case YGSearchFeedSubTypeVideoLink: {
                    // 左侧有个小图标
                    CGFloat bottomPerferWidth = perferWidth - 25.f;
                    self->_shareInfoLayout = [NSAttributedString layoutOfOriginString:bean.linkTitle
                                                                      highlightString:self.keywords
                                                                     normalAttributes:normal
                                                                  highlightAttributes:highlight
                                                                         maximumLines:1
                                                                          perferWidth:bottomPerferWidth
                                                                         clipWordsLen:0
                                                                          lineSpacing:0];
                    self->_shareImageName = self.subType==YGSearchFeedSubTypeVideoLink?@"ic_GlobalSearch_video":@"ic_GlobalSearch_link";
                    break;
                }
            }
            break;
        }
    }
    
    if (self.pointCardVisible) {
        CGFloat bottomPerferWidth = perferWidth - 25.f;
        self->_shareInfoLayout = [NSAttributedString layoutOfOriginString:@"我的记分卡"
                                                          highlightString:nil
                                                         normalAttributes:normal
                                                      highlightAttributes:nil
                                                             maximumLines:1
                                                              perferWidth:bottomPerferWidth
                                                             clipWordsLen:0
                                                              lineSpacing:0];
        self->_shareImageName = @"ic_GlobalSearch_IntegralCard";
    }
}

- (CGFloat)containerHeight
{
    // 垂直方向
    CGFloat top = 15.f;         //上边距
    CGFloat topInfoH = 20.f;    //顶部信息label
    CGFloat contentTop = 8.f;   //主文本内容上边距
    CGFloat contentH = self.contentHeight;  //主文本内容高度
    CGFloat contentBottom = 8.f;            //主文本内容下边距
    
    CGFloat subContentH = 0.f;              //子内容高度
    switch (self.type) {
        case YGSearchFeedTypeNormal: {
            //单图的高度
            subContentH = self.imageHeight;
            break;
        }
        case YGSearchFeedTypeMultiImage: {
            //多图的高度，为固定值
            subContentH = 60.f;
            break;
        }
        case YGSearchFeedTypeShare: {
            //分享内容的高度，为固定值
            subContentH = 20.f;
            break;
        }
    }
    
    // 额外显示的计分卡高度
    // 分享的内容和计分卡是公用一个view的。这里计算高度时不会出现重复计算的问题。因为分享和计分卡不会同时出现。
    CGFloat cardH = 0.f;
    if (self.pointCardVisible) {
        cardH = 8.f + 20.f; //计分卡上边距 + 高度
    }
    
    CGFloat bottom = 15.f;
    
    return top + topInfoH + contentTop + contentH + contentBottom + subContentH + cardH + bottom;
}
@end

@implementation YGSearchUserViewModel
- (void)create
{
    id entity = self.entity;
    NSString *avatar,*title,*subtitle;
    
    if ([entity isKindOfClass:[MemberResultBean class]]) {
        //普通用户
        MemberResultBean *bean = entity;
        avatar = bean.headImage;
        title = bean.displayName;
        subtitle = bean.location;
    }else if ([entity isKindOfClass:[CoachResultBean class]]){
        //教练
        CoachResultBean *bean = entity;
        avatar = bean.headImage;
        title = bean.nickName;
        subtitle = bean.academyName;
    }else{
        return;
    }
    
    CGFloat margin = 15.f;
    CGFloat spacing = 10.f;
    CGFloat imageW = 42.f;
    CGFloat perferWidth = Device_Width - 2 * margin - spacing - imageW;
    
    self->_imageURL = [NSURL URLWithString:avatar];
    
    NSDictionary *normal = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchNormalColor];
    NSDictionary *highlight = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchHighlightColor];
    self->_titleLayout = [NSAttributedString layoutOfOriginString:title
                                                  highlightString:self.keywords
                                                 normalAttributes:normal
                                              highlightAttributes:highlight
                                                     maximumLines:1
                                                      perferWidth:perferWidth
                                                     clipWordsLen:0
                                                      lineSpacing:0];
    
    NSDictionary *normal2 = [self attributes:[UIFont systemFontOfSize:12] color:kYGSearchLightGrayColor];
    NSDictionary *highlight2 = [self attributes:[UIFont systemFontOfSize:12] color:kYGSearchHighlightColor];
    self->_subtitleLayout = [NSAttributedString layoutOfOriginString:subtitle
                                                     highlightString:self.keywords
                                                    normalAttributes:normal2
                                                 highlightAttributes:highlight2
                                                        maximumLines:1
                                                         perferWidth:perferWidth
                                                        clipWordsLen:0
                                                         lineSpacing:0];
}

- (CGFloat)containerHeight
{
    // 固定高度
    return 62.f;
}
@end

@implementation YGSearchNewsViewModel
- (void)create
{
    HeadLineResultBean *bean = self.entity;
    if (![bean isKindOfClass:[HeadLineResultBean class]]) {
        return;
    }
    
    CGFloat margin = 15.f;
    CGFloat spacing = 10.f;
    CGFloat imageW = 60.f;
    CGFloat perferWidth = Device_Width - 2 * margin - spacing - imageW;
    
    self->_imageURL = [NSURL URLWithString:bean.picUrl];
    self->_videoIndicatorVisible = bean.type==1;    //0 普通 1 视频 2 多图
    
    NSDictionary *normal = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchNormalColor];
    NSDictionary *highlight = [self attributes:[UIFont systemFontOfSize:15] color:kYGSearchHighlightColor];
    
    self->_titleLayout = [NSAttributedString layoutOfOriginString:bean.linkTitle
                                                  highlightString:self.keywords
                                                 normalAttributes:normal
                                              highlightAttributes:highlight
                                                     maximumLines:2
                                                      perferWidth:perferWidth
                                                     clipWordsLen:0
                                                      lineSpacing:4.f];
    
    self->_leftDesc = [NSString stringWithFormat:@"%@ %@",bean.accountName,bean.createdAt];
    self->_rightDesc = bean.categoryName;
}

- (CGFloat)containerHeight
{
    // 固定高度
    return 90.f;
}
@end

