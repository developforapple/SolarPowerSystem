//
//  YGSearchViewModel.h
//  Golf
//
//  Created by bo wang on 16/7/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "DDViewModel.h"
#import "YYText.h"

NS_ASSUME_NONNULL_BEGIN

#define kYGSearchNormalColor RGBColor(51,51,51,1)       //普通黑色文本颜色
#define kYGSearchLightGrayColor RGBColor(153,153,153,1) //普通灰色文本颜色
#define kYGSearchHighlightColor RGBColor(6,156,216,1)   //高亮的颜色

@interface YGSearchViewModel : DDViewModel

// 可以先设置 keywords 再使用create来创建viewModel内容
@property (strong, nullable, nonatomic) NSString *keywords;

@end

/*!
 *  @brief 适用于 YGSearchCourseCell
 */
@interface YGSearchCourseViewModel : YGSearchViewModel
// 球场名字
@property (strong, readonly, nonatomic) YYTextLayout *nameLayout;
@end

/*!
 *  @brief 适用于 YGSearchCommodityCell
 */
@interface YGSearchCommodityViewModel : YGSearchViewModel
@property (strong, readonly, nonatomic) NSURL *commodityImageURL;
@property (strong, readonly, nonatomic) YYTextLayout *commodityTitleLayout;
@end

typedef NS_ENUM(NSUInteger, YGSearchFeedType) {
    YGSearchFeedTypeNormal,     //普通内容、单图、视频
    YGSearchFeedTypeMultiImage, //多图
    YGSearchFeedTypeShare,      //头条、头条视频、计分卡
};

typedef NS_ENUM(NSUInteger, YGSearchFeedSubType) {
    
    // 中间区域的类型
    YGSearchFeedSubTypeNormal,      //普通内容
    YGSearchFeedSubTypeSingleImage, //单图
    YGSearchFeedSubTypeVideo,       //视频
    
    // 底部区域的类型
    YGSearchFeedSubTypeNormalLink,  //普通头条
    YGSearchFeedSubTypeVideoLink,   //头条视频
//    YGSearchFeedSubTypePointCard,   // 计分卡是否显示，由 pointCardVisible 来确定。
};

/*!
 *  @brief 适用于 YGSearchFeedCell
 */
@interface YGSearchFeedViewModel : YGSearchViewModel

@property (assign, readonly, nonatomic) YGSearchFeedType type;      //类型
@property (assign, readonly, nonatomic) YGSearchFeedSubType subType;//子类型

@property (strong, readonly, nonatomic) NSURL *userImageURL;        //头像

@property (strong, readonly, nonatomic) NSString *nickName;          //昵称
@property (strong, readonly, nonatomic) NSString *date;              //时间
@property (strong, readonly, nonatomic) YYTextLayout *locationLayout;//位置

@property (strong, readonly, nonatomic) YYTextLayout *contentLayout;//动态内容
@property (assign, readonly, nonatomic) CGFloat contentHeight;  //动态高度

@property (strong, nullable, readonly, nonatomic) NSArray<NSURL *> *imageURLs;//动态图片
@property (strong, nullable, readonly, nonatomic) NSURL *videoURL;            //动态视频
@property (assign, readonly, nonatomic) CGFloat imageWidth;
@property (assign, readonly, nonatomic) CGFloat imageHeight;
@property (assign, readonly, nonatomic) BOOL playViewVisible;   //播放按钮是否显示

@property (strong, nullable, readonly, nonatomic) YYTextLayout *shareInfoLayout; //底部分享内容

@property (strong, nullable, readonly, nonatomic) NSString *shareImageName;     //底部分享的图标名。本地图片。

@property (assign, readonly, nonatomic) BOOL pointCardVisible;  //计分卡是否可见。在发布计分卡动态时，是可以携带图片的

@end

/*!
 *  @brief 适用于 YGSearchUserCell
 */
@interface YGSearchUserViewModel : YGSearchViewModel
@property (strong, readonly, nonatomic) NSURL *imageURL;    //头像URL
@property (strong, readonly, nonatomic) YYTextLayout *titleLayout;//名称
@property (strong, nullable, readonly, nonatomic) YYTextLayout *subtitleLayout;     //信息
@end

/*!
 *  @brief 适用于 YGSearchYueduCell
 */
@interface YGSearchNewsViewModel : YGSearchViewModel
@property (strong, readonly, nonatomic) NSURL *imageURL;        //图片URL
@property (assign, readonly, nonatomic) BOOL videoIndicatorVisible;//是否显示视频标志
@property (strong, readonly, nonatomic) YYTextLayout *titleLayout;//标题
@property (strong, readonly, nonatomic) NSString *leftDesc;     //底部左侧内容
@property (strong, readonly, nonatomic) NSString *rightDesc;    //底部右侧内容
@end

NS_ASSUME_NONNULL_END
