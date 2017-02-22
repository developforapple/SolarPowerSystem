//
//  YGMallStatistics.h
//  Golf
//
//  Created by bo wang on 2016/11/25.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGMallStatistics_h
#define YGMallStatistics_h

typedef NS_ENUM(NSUInteger, YGMallPoint) {
    YGMallPointMall = 4,                //精选商城首页
    
    YGMallPointActivity YG_DEPRECATED(7.3,"7.3版本中被54~57代替") = 51, //乐活动任意item
    
    YGMallPointFlashSaleList = 52,      //限时抢购列表
    YGMallPointBrandList  = 53,         //品牌列表
    YGMallPointActivityPanel1 = 54,     //乐活动 左1
    YGMallPointActivityPanel2 = 55,     //乐活动 右上1
    YGMallPointActivityPanel3 = 56,     //乐活动 右下 左
    YGMallPointActivityPanel4 = 57,     //乐活动 右下 右
    YGMallPointHotTheme1 = 58,          //热主题 1
    YGMallPointHotTheme2 = 59,          //热主题 2
    YGMallPointHotTheme3 = 60,          //热主题 3
    YGMallPointHotTheme4 = 61,          //热主题 4
    YGMallPointHotTheme5 = 62,          //热主题 5
    YGMallPointHotTheme6 = 63,          //热主题 6
    YGMallPointOuyu = 64,               //偶遇商品点击
    YGMallPointCommodityDetail = 65,    //商品详情
    YGMallPointCommodityReviewList = 66,//商品评价列表
    YGMallPointBuy = 67,                //商品直接购买
    YGMallPointAddToCart = 68,          //商品加入购物车
    YGMallPointSubmitOrder = 69,        //商品提交订单
    YGMallPointPay = 70,                //商品支付
    YGMallPointCart = 71,               //商品购物车列表
    YGMallPointCancelOrder = 72,        //取消商城订单
    
    YGMallPointCommodityList = 76,      //分类商品列表页
    YGMallPointThemeDetail = 77,        //主题下的商品列表页
};

#define YGMallPage_CommodityDetail @"CommodityDetailPage"

#endif /* YGMallStatistics_h */
