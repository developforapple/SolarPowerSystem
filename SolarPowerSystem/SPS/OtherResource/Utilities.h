//
//  Uitils.h
//  Golf
//
//  Created by Dejohn Dong on 11-11-22.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@class M13BadgeView;
@class Node;

FOUNDATION_EXTERN NSString *const KDateFormatterYmd;
FOUNDATION_EXTERN NSString *const KDateFormatterYmdhm;
FOUNDATION_EXTERN NSString *const KDateFormatterYmdhms;

@interface Utilities : NSObject

+ (BOOL)isAllNum:(nullable NSString *)string;

+ (Node * __nullable)nodeByKey:(NSString *__nullable)key inArray:(NSArray * __nullable)arr;

+ (M13BadgeView * __nullable)createBadgeWithRect:(CGRect)rect;

+ (UIImage *  __nullable)scaleToSize:(UIImage *  __nullable)img size:(CGSize)size;

//string转date
+ (NSDate *  __nullable)getDateFromString:(NSString *  __nullable)string;
+ (NSDate *  __nullable)getDateFromString:(NSString *  __nullable)string WithFormatter:(NSString *  __nullable)format;
+ (NSString *  __nullable)getDateStringFromString:(NSString *  __nullable)string WithFormatter:(NSString *  __nullable)format;
+ (NSString *  __nullable)getDateStringFromString:(NSString *  __nullable)string WithAllFormatter:(NSString *  __nullable)format;
+ (NSString *  __nullable)getDateStringUTCFromDate:(NSDate *  __nullable)date WithAllFormatter:(NSString *  __nullable)format;
+ (NSString *  __nullable)getDateStringFromDate:(NSDate *  __nullable)date WithAllFormatter:(NSString *  __nullable)format;

+ (NSString *  __nullable)stringwithDate:(NSDate *  __nullable)date;
//根据日期获取是星期几
+ (NSString *  __nullable)getWeekDayByDate:(NSDate *  __nullable)date;

+ (NSInteger)weekDayByDate:(NSDate *  __nullable)date;

//获取某天
/*以date为当前天，获取numdays之前或之后的某天 转化为秒*/
+ (NSDate *  __nullable)getTheDay:(NSDate *  __nullable)date withNumberOfDays:(NSInteger)numDays;

// month = 0:当前月 1:后一个月 -1:前一个月
+ (NSDate *  __nullable)getDateWithDate:(NSDate *  __nullable)date withMonth:(NSInteger)month;

// 两个日期间隔的天数
+ (NSInteger)numDayWithBeginDate:(NSDate*  __nullable)beginDate endDate:(NSDate*  __nullable)endDate;

//获取年份
+ (NSString *  __nullable)getYearByDate:(NSDate *  __nullable)date;

//获取月份
+ (NSString *  __nullable)getMonthByDate:(NSDate *  __nullable)date;
+ (NSString *  __nullable)getMonth1ByDate:(NSDate *  __nullable)date;

//获取日期
+ (NSString *  __nullable)getDayByDate:(NSDate *  __nullable)date;
+ (NSString *  __nullable)getDay1ByDate:(NSDate *  __nullable)date;

// 获取时分秒
+ (NSString *  __nullable)getHourByDate:(NSDate *  __nullable)date;
+ (NSString *  __nullable)getMinuteByDate:(NSDate *  __nullable)date;
+ (NSString *  __nullable)getSecodeByDate:(NSDate *  __nullable)date;

//计算两个日期是否是同一天
+ (BOOL)date:(NSDate *  __nullable)date theSameDate:(NSDate *  __nullable)sdate;

+ (NSDate*  __nullable)changeDateWithDate:(NSDate *  __nullable)date;

+ (NSTimeInterval)compareCurrentDateWithDate:(NSString *  __nullable)aDate;

//Get a UIImage with the imageName from the bundle path, ignore (imageNamed:)
//根据图片的名字用图片路径的方式获取一个UIImage,避免使用(imageNamed:);
+ (UIImage *  __nullable)getImageByBundlePathWithImageName:(NSString *  __nullable)name;

//Get a UIImage with the imageNamed
+ (UIImage *  __nullable)getImageBySmallPNG:(NSString *  __nullable)name;

+ (UIImage *  __nullable)getImageWithScale:(NSString *  __nullable)name scale:(CGFloat)scale;

//Get a UIImage with a stretchable image;
//获取一个可拉伸的图片;
+ (UIImage *  __nullable)getImageWithStretchableByBundlePathWithImageName:(NSString *  __nullable)name;

//获取一个可宽度拉伸的图片;
+ (UIImage *  __nullable)getImageWithWidthStretchableByBundlePathWithImageName:(NSString *  __nullable)name;

//Base64加密Image
+ (NSString *  __nullable)base64EncodeImage:(UIImage *  __nullable)image;

//计算issueTime与当前时间得时间差
+ (NSString *  __nullable)calculationTime:(NSString *  __nullable)issueTime;


//根据文字的长度,文字的字体大小以及限制宽度得到size;
+ (CGSize)getSize:(NSString *  __nullable)contents withFont:(UIFont *  __nullable)font withWidth:(CGFloat)width;
+ (CGSize)getSize:(NSString *  __nullable)contents attributes:(nullable NSDictionary<NSString *, id> *)attributes withWidth:(CGFloat)width;

+ (UIColor *  __nullable) R:(float)r G:(float)g B:(float)b;

+ (NSDictionary *  __nullable)webLinkParamParser:(NSString*  __nullable)url;

+ (NSDictionary *  __nullable)webInterfaceToDic: (NSURL *  __nullable) url prefix:(NSString*  __nullable)prefix;

+ (BOOL)compareTimeWithCurrentTime:(NSString *  __nullable)currentTime beginTime:(NSString*  __nullable)beginTime endTime:(NSString *  __nullable)endTime;

+ (int)changeHourWithTime:(NSString *  __nullable)time;

+ (NSString *  __nullable)getCurrentTimeWithFormatter:(NSString*  __nullable)format;

+ (NSString*  __nullable)minTimeWithDate:(NSString*  __nullable)date_ time:(NSString*  __nullable)time_;

+ (NSString*  __nullable)formatPhoneNum:(NSString*  __nullable)phoneStr;

+ (UIImage *  __nullable)imageOfUserType:(int)level;

+ (NSString*  __nullable)formatImageUrlWithStr:(NSString*  __nullable)str withFormatStr:(NSString*  __nullable)format;

+ (NSString*  __nullable)videoDataWithPath:(NSString*  __nullable)path;

+ (long long) fileSizeAtPath:(NSString*  __nullable) path;

+ (NSString*  __nullable)imageDataWithImage:(UIImage*  __nullable)aImage;

+ (NSMutableAttributedString *  __nullable)attributedStringWithString:(NSString*  __nullable)string value1:(id  __nullable)aValue_1 range1:(NSRange)aRange_1 value2:(id  __nullable)aValue_2 range2:(NSRange)aRange_2 font:(float)aFont otherValue:(id  __nullable)other otherRange:(NSRange)otherRange;

+ (void)drawView:(UIView*  __nullable)view radius:(CGFloat)radius borderColor:(UIColor * __nullable)color;
+ (void)drawView:(UIView*  __nullable)view radius:(CGFloat)radius bordLineWidth:(CGFloat)lineWidth borderColor:(UIColor*  __nullable)color;

+ (NSString *  __nullable)formatDate:(NSString*  __nullable)aDate time:(NSString*  __nullable)aTime;

+ (UIImageView*  __nullable)lineviewWithFrame:(CGRect)rt forView:(UIView*  __nullable)view;

+ (UIImage *  __nullable)grachicsImageWithView:(UIView*  __nullable)view size:(CGSize)sz;

+ (void)mutablePathMoveAnimationWithStartPoint:(CGPoint)st_pt endPoint:(CGPoint)en_pt controlPoint:(CGPoint)ct_pt view:(UIView*  __nullable)aView duration:(float)duration completion:(void(^  __nullable)(BOOL finished))completion;

+ (int)agewithBirthday:(NSString*  __nullable)aBirthday;

+ (id  __nullable)valueByAllClubInfo:(int)clubId withKey:(NSString*  __nullable)key allClub:(NSArray*  __nullable)clubs;

+ (NSString*  __nullable)getGolfServicePhone;

+ (UIImage *  __nullable)getImageByVideoPath:(NSString *  __nullable)path;

+ (BOOL)phoneNumMatch:(NSString*  __nullable)str;

+ (BOOL)isBlankString:(NSString *  __nullable)string;

+ (NSAttributedString *  __nullable)handleTagWithText:(NSString*  __nullable)text;
+ (NSAttributedString*  __nullable)handleTagWithAttributedText:(NSAttributedString*  __nullable)aAttr;

+ (NSString *  __nullable)decodeFromPercentEscapeString: (NSString *  __nullable) input;

+ (NSString *  __nullable)plainTextWithText:(NSString * __nullable)aText;

+ (void)changeView:(UIView *  __nullable)view width:(CGFloat)width;
+ (void)changeView:(UIView *  __nullable)view height:(CGFloat)height;

+ (void)removeHeightConstraintView:(UIView *  __nullable)view;

+ (void)changeView:(UIView *  __nullable)view left:(CGFloat)left secondItemClass:(Class  __nullable)clazz oldConstant:(CGFloat)constant;
+ (void)changeView:(UIView *  __nullable)view top:(CGFloat)top;

+ (CGSize)imageSizeWithUrl:(NSString *  __nullable)url;
+ (void)loadImageWithURL:(NSURL * __nullable)url inImageView:(UIView * __nullable)imageView placeholderImage:(UIImage * __nullable)pimage;
+ (void)loadImageWithURL:(NSURL * __nullable)url inImageView:(UIView * __nullable)imageView placeholderImage:(UIImage * __nullable)pimage changeContentMode:(BOOL)change;
@end

NS_ASSUME_NONNULL_END
