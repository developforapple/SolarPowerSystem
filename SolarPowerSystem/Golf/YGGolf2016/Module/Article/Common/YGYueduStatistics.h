//
//  YGYueduStatistics.h
//  Golf
//
//  Created by bo wang on 16/7/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGYueduStatistics_h
#define YGYueduStatistics_h

// 自己的统计项目
#define YGYueduStatisticsBasePoint          10000  //基本id       //Done
// 从主列表打开文章时 id = basePoint+columnid                       //Done
// 点击分类导航      id = basePoint+categoryid                      //TODO

#define YGYueduStatistics_LikeArticle       10004   //收藏文章      //Done
#define YGYueduStatistics_LikeAlbum         10005   //收藏专题      //Done
#define YGYueduStatistics_ShareSocial       10006   //社会化分享     //Done
#define YGYueduStatistics_ShareFeed         10007   //分享到动态     //Done
#define YGYueduStatistics_SearchHotKeywords 10008   //搜索热词      //Done
#define YGYueduStatistics_SearchKeywords    10009   //搜索关键词     //Done
#define YGYueduStatistics_ArticleDetail     10010   //打开文章详情   //Done
#define YGYueduStatistics_AlbumDetail       10011   //打开专题详情   //Done
#define YGYueduStatistics_Search            10012   //进入搜索界面    //Done
#define YGYueduStatistics_VideoTap          10013   //点击视频      //Done
#define YGYueduStatistics_PlayVideoFailed   10014   //播放视频失败    //Done
#define YGYueduStatistics_MyLikedArticle    10015   //我收藏的文章点击  //Done
#define YGYueduStatistics_MyAlbumArticle    10016   //我收藏的专题点击  //Done
#define YGYueduStatistics_RelatedArticle    10017   //相关文章点击    //Done

// 友盟和百度的统计项目

#define YueduPage_Main          @"YueduPage_Main"           //悦读主界面
#define YueduPage_List          @"YueduPage_List_%@"        //悦读主列表 具体为 @"YueduPage_List_"+ id
#define YueduPage_ArticleDetail @"YueduPage_ArticleDetail"  //文章详情
#define YueduPage_AlbumDetail   @"YueduPage_AlbumDetail"    //专题详情
#define YueduPage_Search        @"YueduPage_Search"         //搜索
#define YueduPage_LikedAlbum    @"YueduPage_LikedAlbum"     //我收藏的专题
#define YueduPage_LikedArticle  @"YueduPage_LikedArticle"   //我收藏的文章

#define YueduEvent_PlayVideo        @"Yuedu_PlayVideo"      //准备播放视频
#define YueduEvent_PlayVideoFailed  @"Yuedu_PlayVideoFailed"//播放视频失败
#define YueduEvent_HotKeywords      @"Yuedu_HotKeywords"    //搜索热词点击
#define YueduEvent_Keywords         @"Yuedu_Keywords"       //搜索点击
#define YueduEvent_LikeArticle      @"Yuedu_LikeArticle"    //收藏文章
#define YueduEvent_LikeAlbum        @"Yuedu_LikeAlbum" //收藏专题
#define YueduEvent_ShareSocial      @"Yuedu_ShareSocial"    //社交平添分享
#define YueduEvent_ShareFeed        @"Yuedu_ShareFeed"      //准备分享到动态
#define YueduEvent_PostFeed         @"Yuedu_PostFeed"       //分享到动态发出

#endif /* YGYueduStatistics_h */
