//
//  TopicHelp.m
//  Golf
//
//  Created by 黄希望 on 15/10/28.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import "TopicHelp.h"
#import "TrendsDetailsViewController.h"
#import "TopicDetailsViewController.h"
#import "NSArray+LinqExtensions.h"
#import "YGProfileViewCtrl.h"
#import "FootprintDetialsViewController.h"
#import "YGTAMediaPicModel.h"

@implementation TopicHelp

+ (void)registerNibs:(UITableView *)tableView{
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCellNoneImages" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCellNoneImages"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCell1" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCell1"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCellVideo" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCellVideo"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCell2-3" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCell2-3"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCell4-6" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCell4-6"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsTableViewCell7-9" bundle:nil] forCellReuseIdentifier:@"TrendsTableViewCell7-9"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsReadEnjoyCell" bundle:nil] forCellReuseIdentifier:@"TrendsReadEnjoyCell"];
    
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCell1" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCell1"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCell2-3" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCell2-3"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCell4-6" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCell4-6"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCell7-9" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCell7-9"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCellNoneImages" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCellNoneImages"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedCellVideo" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedCellVideo"];
    [tableView registerNib:[UINib nibWithNibName:@"TrendsFeaturedReadEnjoyCell" bundle:nil] forCellReuseIdentifier:@"TrendsFeaturedReadEnjoyCell"];
}

+ (CGFloat)cellHeightWithData:(TopicModel*)model topicType:(int)_topicType hasDetail:(BOOL)hasDetail refresh:(BOOL)refresh{
    if (model.cellHeight > 0 && refresh == NO) {
        return model.cellHeight;
    }
    CGFloat imgHeight = 0;
    CGFloat contentWidth = 0;
    CGFloat replyWidth = 0;
    
    if (IS_3_5_INCH_SCREEN){
        imgHeight = 74;
        contentWidth = 240;
        replyWidth = 222;
    }else if( IS_4_0_INCH_SCREEN) {
        imgHeight = 74;
        contentWidth = 240;
        replyWidth = 222;
    }else if(IS_4_7_INCH_SCREEN){
        imgHeight = 92.5;
        contentWidth = 295;//
        replyWidth = 277;//287;
    }else if(IS_5_5_INCH_SCREEN) {
        imgHeight = 105.33333333333334;
        contentWidth = 334;
        replyWidth = 316;
    }
    
    CGFloat height = 55; //头像高度55
    if (_topicType == 4) { //动态列表类型 是 精选
        height += 5;//灰色分割条高度
    }
    //内容文本高度
    if (model.plainContent && model.plainContent.length > 0) {
        CGSize size = [model.plainContent boundingRectWithSize:CGSizeMake(contentWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName :[UIFont systemFontOfSize:15]} context:nil].size;
        
        int count = size.height / 17.895;
        
        if (model.showAllContent) {
            height += size.height;
            height += 21; //查看全文按钮高度
        }else{
            if (count > 5) {
                height += 17.895 * 5;  //超过5行只显示5行
                height += 21; //查看全文按钮高度
            }else{
                height += size.height;
            }
        }
        
        height += 8;//文字顶部距离
    }
    if ([model.topicType intValue] == 0 || model.topicType.intValue == 2) {//普通动态
        switch (model.topicPictures.count) { //4.72.5  6.  6p.
            case 1:{
                BOOL hasVideo = (model.topicVideo && model.topicVideo.length > 0);
                
                id obj = model.topicPictures[0];
                CGFloat imageHeight = [TopicHelp heightWithImage:obj hasVideo:hasVideo];
                if (model.imageHeight != imageHeight) {
                    model.imageHeight = imageHeight;
                }
                height += (model.imageHeight == 0 ? 152:model.imageHeight);
            }
                break;
            case 2:
            case 3:
                height += imgHeight;
                break;
            case 4:
            case 5:
            case 6:
                height += (imgHeight * 2 + 4);
                break;
            case 7:
            case 8:
            case 9:
                height += (imgHeight * 3 + (4 * 2));
                break;
            default:
                break;
        }
        
        //公里、地址、高度
        if (model.topicPictures.count > 0) {
            height += 24;
        }else{
            height += 14;
        }
    }else if ([model.topicType intValue] == 1){//悦读分享
        height += 80;
    }
    
    //下场时间等足迹信息的高度
    if (model.teeDate != nil) {
        if (model.cardId == 0 || model.publicMode == 0) {
            height += 20;
        }else{
            height += 70 + 20;
        }
    }else{
        if (model.sourceInfo.length > 0) {
            height += 20;
        }
    }
    
    //三个按钮高度 + 按钮距离上部分空间的高度 + 按钮下部分距离
    height += (24 + 13 + 15);
    
    
    if (hasDetail) {
        //赞、分享、回复评论视图的高度
        if (model.praiseList.count == 0 && model.commentList.count == 0 && model.shareList.count == 0) {
            height += 6; //单元格最底部间距
        }else{
            //赞视图高度
            if (model.praiseList.count > 0) {
                height += 52;
            }else{
                height += 0;
            }
            
            //分享视图高度
            if (model.shareList.count > 0) {
                height += 52;
            }else{
                height += 0;
            }
            
            //回复视图高度
            if (model.commentCount > 0) {
                
                NSMutableArray *list5 = [[NSMutableArray alloc] initWithCapacity:5];
                if (model.commentList.count <= 5) {
                    [list5 addObjectsFromArray:model.commentList];
                }else{
                    [list5 addObjectsFromArray:[model.commentList subarrayWithRange:NSMakeRange(model.commentList.count - 5, 5)]];
                }
                
                for (int i = 1; i <= 5; i++) {
                    if (i <= list5.count) {
                        ArticleCommentModel *nd = list5[i -1];
                        
                        NSString *text = @"";
                        
                        if (nd.toMemberId > 0) {
                            if (nd.toMemberId == model.memberId) {
                                text = [NSString stringWithFormat:@"%@@:%@",nd.displayName,nd.commentContent];
                            }else{
                                text = [NSString stringWithFormat:@"%@ 回复 %@:%@",nd.displayName,nd.toDisplayName,nd.commentContent];
                            }
                        }else{
                            text = [NSString stringWithFormat:@"%@:%@",nd.displayName,nd.commentContent];
                        }
                        
                        CGSize size = [text boundingRectWithSize:CGSizeMake(replyWidth, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]} context:nil].size;
                        
                        if (size.height >= (16.701999999999998 * 2)) {  //如果超过两行则是算两行高度
                            height += (16.701999999999998 * 2);
                        }else{
                            height += size.height;
                        }
                        height += 6; //6是标签之间的高度
                    }
                }
                if (model.commentCount > 5) { //查看全部评论按钮的高度
                    height += 34;
                }else{
                    height += 4;
                }
                height += 13;//容器内容底部的间距
            }else{
                if ((model.praiseList.count > 0 && model.shareList.count == 0) || (model.praiseList.count == 0 && model.shareList.count > 0)) {
                    height += 10;
                }
                if (model.praiseCount > 0 && model.shareCount > 0) {
                    height += 10;
                }
            }
            height += 12;
        }
    }else{
        height += 12;
    }
    model.cellHeight = height;
    return height;
}

+ (CGFloat)heightWithImage:(UIImage *)image hasVideo:(BOOL)hasVideo{
    
    CGFloat imageViewWidth = (hasVideo ? 200:230);
    CGFloat imageViewHeight = (hasVideo ? 152:152);
    
    __block CGFloat height = 0;//image.size.height;
    __block CGFloat width = 0;//image.size.width;
    if ([image isKindOfClass:[UIImage class]]) {
        height = image.size.height;
        width = image.size.width;
    }else if([image isKindOfClass:[NSString class]]){
        NSString *imageUrl = (NSString *)image;
        CGSize s = [Utilities imageSizeWithUrl:imageUrl];
        height = s.height;
        width = s.width;
    }else if([image isKindOfClass:[YGTAMediaPicModel class]]){
        YGTAMediaPicModel *mo = (YGTAMediaPicModel *)image;
        [mo.imageAsset previewImage:^(UIImage *img) {
            if (img) {
                height = img.size.height;
                width = img.size.width;
            }
        }];
    }
    
    
    if (height == 0 && width == 0) {
        return imageViewHeight;
    }
    
    CGFloat cellHeight = 152;
    
    if (height > width) {
        
        if (height > imageViewWidth) {
            cellHeight = imageViewWidth;
        }else{
            cellHeight = height;
        }
    }else{
        
        if (width > imageViewHeight) {
            cellHeight = imageViewHeight / (width / height);
        }else{
            cellHeight = height;
        }
    }
    return cellHeight;
}


+ (void)userFollowAddWithTopicModel:(TopicModel *)m cell:(UITableViewCell *)weakCell tableView:(UITableView*)tableView{
    [ServerService userFollowAddWithSessionId:[[LoginManager sharedManager] getSessionId] toMemberId:m.memberId nameRemark:nil operation:1 success:^(id data) {
        
        [tableView reloadRowsAtIndexPaths:@[[tableView indexPathForCell:weakCell]] withRowAnimation:(UITableViewRowAnimationNone)];
        
        int operation = [data[@"operation"] intValue];
        m.isFollowed = [data[@"is_followed"] intValue];
        
        
        if (operation != 3) {
            UserFollowModel *model = [[UserFollowModel alloc] init];
            model.isFollowed = m.isFollowed;
            model.memberId = m.memberId;
            NSDictionary *dic = [NSDictionary dictionaryWithObjects:@[m.isFollowed ? @"1":@"2",model] forKeys:@[@"flag",@"data"]];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshAttentList" object:dic];
        }
        
    } failure:nil];
}

+ (void)toTrendsDetailsViewController:(TopicModel *)m indexPath:(NSIndexPath *)indexPath target:(BaseNavController*)target blockDelete:(BlockReturn)blockDelete{
    if (m.isTemp) {
        return;
    }
    
    [target pushWithStoryboard:@"Trends" title:@"动态详情" identifier:@"TrendsDetailsViewController" completion:^(BaseNavController *controller) {
        TrendsDetailsViewController *vc = (TrendsDetailsViewController *)controller;
        vc.topicModel = m;
        vc.title = @"动态详情";
        vc.blockDeleted = blockDelete;
    }];
}

+ (void)toTopicDetailsViewController:(TagModel *)m target:(BaseNavController*)target topicType:(int)topicType{
    [target pushWithStoryboard:@"Trends" title:@"" identifier:@"TopicDetailsViewController" completion:^(BaseNavController *controller) {
        TopicDetailsViewController *vc = (TopicDetailsViewController *)controller;
        vc.topicType = topicType;
        vc.tagId = m.tagId;
        vc.tagName = m.tagName;
    }];
}


+ (void)zanActionWithModel:(TopicModel *)m  tableViewCell:(UITableViewCell *)weakCell tableView:(UITableView*)tableView block:(BlockReturn)block{
    [ServerService topicPraiseAdd:[[LoginManager sharedManager] getSessionId] topicId:m.topicId success:^(id data) {
        
        int memberId = [[LoginManager sharedManager] getUserId];
        int praiseCount = [[data valueForKeyPath:@"praise_count"] intValue];
        int praised =  [[data valueForKeyPath:@"praised"] intValue];
        
        m.praised = praised;
        m.praiseCount = praiseCount;
        
        NSString *headImage = [data valueForKeyPath:@"head_image"];
        if (praised == 1) {
            NSMutableArray *arr = [[NSMutableArray alloc] init];
            if (m.praiseList.count > 0) {
                [arr addObjectsFromArray:m.praiseList];
            }
            [arr insertObject:@{@"member_id":@(memberId),@"head_image":headImage} atIndex:0];
            m.praiseList = arr;
        }else{
            NSArray *arr = [m.praiseList linq_where:^BOOL(id item) {
                return [[item valueForKeyPath:@"member_id"] intValue] != memberId;
            }];
            m.praiseList = arr;
        }
        
        NSDictionary *model = @{@"topicModel":m,@"api":@"topic_praise_add"};
        [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshTopicSignalCell" object:model];
        
        [tableView reloadData];
        
        if (block) {
            block (nil);
        }
    } failure:^(id error) {
        if (block) {
            block (nil);
        }
    }];
}


+ (NSAttributedString *)getFootprintSourceByTopicModel:(TopicModel *)model{
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:@"来自足迹 · "
                                                                            attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],
                                                                                         NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]}];
    [str appendAttributedString:[[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"%@下场",[Utilities getDateStringFromString:model.teeDate WithFormatter:@"MM月dd日"]]
                                                                       attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],
                                                                                    NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]}]];
    [str appendAttributedString:[[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@" · %d杆",model.gross]
                                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:11],
                                                                             NSForegroundColorAttributeName:[UIColor colorWithHexString:@"#999999"]}]];
    
    return str;
}

+ (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString*)displayName target:(BaseNavController*)target{
    
    YGProfileViewCtrl *vc = [YGProfileViewCtrl instanceFromStoryboard];
    vc.memberId = memberId;
    [target.navigationController pushViewController:vc animated:YES];
}

+ (void)toFootprintDetailsByTrendsModel:(TopicModel *)model target:(BaseNavController *)target blockDeleteSuccessed:(BlockReturn)blockDeleteSuccessed{
    if (model && model.cardId > 0) {
        __weak BaseNavController *weakSelf = target;
        [SVProgressHUD show];
        
        [[API shareInstance] cardInfo:model.cardId toMemberId:model.memberId success:^(CardInfo *data) {
            [weakSelf pushWithStoryboard:@"Footprint" title:@"足迹详情" identifier:@"FootprintDetialsViewController" completion:^(BaseNavController *controller) {
                FootprintDetialsViewController *vc = (FootprintDetialsViewController *)controller;
                vc.topicModel = model;
                vc.isDetails = YES;
                vc.cardId = data.cardId;
                vc.footprintId = model.footprintId;
                if (data) {
                    vc.cardInfo = data;
                }
                
                vc.blockDeleted = ^(id data){
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD show];
                    });
                    
                    [ServerService footprintDeleteWithSessionId:[[LoginManager sharedManager] getSessionId]
                                                    footprintId:model.footprintId
                                                         clubId:model.clubId
                                                        success:^(id data) {
                                                            if (blockDeleteSuccessed) {
                                                                blockDeleteSuccessed(nil);
                                                            }
                                                            [SVProgressHUD dismiss];
                                                        } failure:^(id error) {
                                                            [SVProgressHUD showErrorWithStatus:@"足迹删除失败"];
                                                        }];
                    
                    
                };
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD dismiss];
                });
            }];
        } failure:^(Error *error) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [SVProgressHUD dismiss];
            });
        }];
    }
}

+ (NSString *)identifierWithTopicModel:(TopicModel *)m initIdentifier:(NSString *)identifier{
    if ([m.topicType intValue] == 0 || [m.topicType intValue] == 2) {
        switch (m.topicPictures.count) {
            case 9:
            case 8:
            case 7:
                if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                    identifier = @"TrendsFeaturedCell7-9";
                }else{
                    identifier = @"TrendsTableViewCell7-9";
                }
                break;
            case 6:
            case 5:
            case 4:
                if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                    identifier = @"TrendsFeaturedCell4-6";
                }else{
                    identifier = @"TrendsTableViewCell4-6";
                }
                break;
            case 3:
            case 2:
                if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                    identifier = @"TrendsFeaturedCell2-3";
                }else{
                    identifier = @"TrendsTableViewCell2-3";
                }
                
                break;
            case 1:
            {
                if (m.topicVideo && m.topicVideo.length > 0) {
                    if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                        identifier = @"TrendsFeaturedCellVideo";
                    }else{
                        identifier = @"TrendsTableViewCellVideo";
                    }
                    
                }else{
                    if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                        identifier = @"TrendsFeaturedCell1";
                    }else{
                        identifier = @"TrendsTableViewCell1";
                    }
                }
            }
                break;
            case 0:
                if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
                    identifier = @"TrendsFeaturedCellNoneImages";
                }else{
                    identifier = @"TrendsTableViewCellNoneImages";
                }
                
                break;
            default:
                break;
        }
    }else if ([m.topicType intValue] == 1){
        if ([identifier isEqualToString:@"TrendsFeaturedCell7-9"]) {
            identifier = @"TrendsFeaturedReadEnjoyCell";
        }else{
            identifier = @"TrendsReadEnjoyCell";
        }
    }
    return identifier;
}

@end
