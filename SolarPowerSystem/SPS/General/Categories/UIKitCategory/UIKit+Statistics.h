//
//  UIControl+Statistics.h
//  Golf
//
//  Created by bo wang on 16/7/5.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

/*!
 *  设置 eventId_后，对于下列控件的事件会进行统计。
 *  控件不同，统计的事件类型也不一样。
 */
@protocol YGStatistics <NSObject>
@required
@property (strong, nonatomic) IBInspectable NSString *eventId_; //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end

// UIControl 的 event。对于UIButton统计touchUpInside。其他的统计valueChanged
@interface UIControl (YGStatistics) <YGStatistics>
@property (strong, nonatomic) IBInspectable NSString *eventId_; //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end
// 手势事件。只统计tap和longpress。其他手势不统计。
@interface UIGestureRecognizer (YGStatistics) <YGStatistics>
@property (strong, nonatomic) IBInspectable NSString *eventId_; //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end
// UIBarButtonItem的点击事件。
// 如果 UIBarButtonItem内包含了一个 UIButton，那么两者选其一来统计
@interface UIBarButtonItem (YGStatistics) <YGStatistics>
@property (strong, nonatomic) IBInspectable NSString *eventId_;         //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end
// cell的点击事件。
@interface UITableViewCell (YGStatistics) <YGStatistics>
@property (strong, nonatomic) IBInspectable NSString *eventId_; //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end
// cell的点击事件
@interface UICollectionViewCell (YGStatistics) <YGStatistics>
@property (strong, nonatomic) IBInspectable NSString *eventId_; //事件标识
@property (strong, nonatomic) IBInspectable NSString *eventLabel_;       //事件label
@end

