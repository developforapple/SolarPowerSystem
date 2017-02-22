//
//  TopicHelp.h
//  Golf
//
//  Created by 黄希望 on 15/10/28.
//  Copyright © 2015年 云高科技. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TopicHelp : NSObject

+ (void)registerNibs:(UITableView *)tableView;

+ (CGFloat)cellHeightWithData:(TopicModel*)model topicType:(int)_topicType hasDetail:(BOOL)hasDetail refresh:(BOOL)refresh;

+ (CGFloat)heightWithImage:(UIImage *)image hasVideo:(BOOL)hasVideo;

+ (void)userFollowAddWithTopicModel:(TopicModel *)m cell:(UITableViewCell *)weakCell tableView:(UITableView*)tableView;

+ (void)toTrendsDetailsViewController:(TopicModel *)m indexPath:(NSIndexPath *)indexPath target:(BaseNavController*)target blockDelete:(BlockReturn)blockDelete;

+ (void)toTopicDetailsViewController:(TagModel *)m target:(BaseNavController*)target topicType:(int)topicType;

+ (void)zanActionWithModel:(TopicModel *)m  tableViewCell:(UITableViewCell *)weakCell tableView:(UITableView*)tableView block:(BlockReturn)block;

+ (void)toPersonalHomeControllerByMemberId:(int)memberId displayName:(NSString*)displayName target:(BaseNavController*)target;
+ (void)toFootprintDetailsByTrendsModel:(TopicModel *)model target:(BaseNavController *)target blockDeleteSuccessed:(BlockReturn)blockDeleteSuccessed;

+ (NSAttributedString *)getFootprintSourceByTopicModel:(TopicModel *)model;

+ (NSString *)identifierWithTopicModel:(TopicModel *)m initIdentifier:(NSString *)identifier;

@end
