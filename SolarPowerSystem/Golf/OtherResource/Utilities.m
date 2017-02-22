//
//  Uitils.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-22.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import "Utilities.h"
#import <QuartzCore/QuartzCore.h>
#import <AVFoundation/AVFoundation.h>
#import "UIImage+scale.h"
#import "GTMBase64.h"
#import "GTMDefines.h"
#import "OpenUDID.h"
#import "searchClubModel.h"
#import "ServiceManager.h"
#import "Base64.h"
#import "M13BadgeView.h"
#import "service.h"
#import "RegexKitLite.h"

#define TAG_REGEX   @"(#[^#\\s]{2,20}#)"

NSString *const KDateFormatterYmd = @"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)$";

NSString *const KDateFormatterYmdhm = @"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)[\\s]+([0-1][0-9]|[2][0-3]):([0-5][0-9])$";

NSString *const KDateFormatterYmdhms = @"^(?:(?!0000)[0-9]{4}-(?:(?:0[1-9]|1[0-2])-(?:0[1-9]|1[0-9]|2[0-8])|(?:0[13-9]|1[0-2])-(?:29|30)|(?:0[13578]|1[02])-31)|(?:[0-9]{2}(?:0[48]|[2468][048]|[13579][26])|(?:0[48]|[2468][048]|[13579][26])00)-02-29)[\\s]+([0-1][0-9]|[2][0-3]):([0-5][0-9]):([0-5][0-9])$";

@implementation Utilities

+ (BOOL)isAllNum:(NSString *)string{
    unichar c;
    for (int i=0; i<string.length; i++) {
        c=[string characterAtIndex:i];
        if (!isdigit(c)) {
            return NO;
        }
    }
    return YES;
}

+ (Node *)nodeByKey:(NSString *)key inArray:(NSArray *)arr{
    if (arr == nil && arr.count == 0) {
        return nil;
    }
    NSArray *items = [arr linq_where:^BOOL(Node *item) {
        return (item && [item.key isEqualToString:key]);
    }];
    if (items && items.count > 0) {
        return items.firstObject;
    }
    return nil;
}

+ (M13BadgeView *)createBadgeWithRect:(CGRect)rect{
    M13BadgeView *badge = [[M13BadgeView alloc] initWithFrame:rect];
    badge.horizontalAlignment = M13BadgeViewHorizontalAlignmentCenter;
    badge.verticalAlignment = M13BadgeViewVerticalAlignmentMiddle;
    badge.hidesWhenZero = YES;
    return badge;
}

+ (UIImage *)getImageByBundlePathWithImageName:(NSString *)name
{
    NSString *path = [[NSBundle mainBundle] pathForResource:[name stringByDeletingPathExtension] ofType:[name pathExtension]];
    UIImage *image = [UIImage imageWithContentsOfFile:path];
    return image;
}

+ (UIImage *)scaleToSize:(UIImage *)img size:(CGSize)size{
    // 创建一个bitmap的context
    // 并把它设置成为当前正在使用的context
    UIGraphicsBeginImageContext(size);
    // 绘制改变大小的图片
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    // 从当前context中创建一个改变大小后的图片
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    // 使当前的context出堆栈
    UIGraphicsEndImageContext();
    // 返回新的改变大小后的图片
    return scaledImage;
}

+ (UIImage *)getImageBySmallPNG:(NSString *)name
{
    UIImage *image = [UIImage imageNamed:name];
    return image;
}

+ (UIImage *)getImageWithScale:(NSString *)name scale:(CGFloat)scale
{
    UIImage *image = [UIImage imageNamed:name];
    if(scale <= 0)
        return image;

    return [image scaleToSize:CGSizeMake(image.size.width * scale, image.size.height * scale)];
}

+ (NSDate *)getDateFromString:(NSString *)string
{
    if (!string || string.length == 0) {
        return nil;
    }
    
    if (![string isMatchedByRegex:KDateFormatterYmd]) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSDate *)getDateFromString:(NSString *)string WithFormatter:(NSString *)format{
    if (!string || string.length == 0) {
        return nil;
    }
    
    if (![string isMatchedByRegex:KDateFormatterYmd] && ![string isMatchedByRegex:KDateFormatterYmdhm] && ![string isMatchedByRegex:KDateFormatterYmdhms]) {
        return nil;
    }
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    NSDate *date = [formatter dateFromString:string];
    return date;
}

+ (NSString*)getDateStringFromString:(NSString *)string WithFormatter:(NSString*)format{
    if (!string || string.length == 0) {
        return nil;
    }
    if (![string isMatchedByRegex:KDateFormatterYmd]) {
        return nil;
    }
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:string];
    if (format.length > 0) {
        [formatter setDateFormat:format];
    }
    return [formatter stringFromDate:date];
}

+ (NSString *)getDateStringFromString:(NSString *)string WithAllFormatter:(NSString*)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:string];
    if (format.length > 0) {
        [formatter setDateFormat:format];
    }
    return [formatter stringFromDate:date];
}

+ (NSString *)getDateStringFromDate:(NSDate *)date WithAllFormatter:(NSString*)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    return [formatter stringFromDate:date];
}

+ (NSString *)getDateStringUTCFromDate:(NSDate *)date WithAllFormatter:(NSString*)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    [formatter setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    return [formatter stringFromDate:date];
}

+ (NSString *)stringwithDate:(NSDate *)date{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSString *dateStr = [formatter stringFromDate:date];
    return dateStr;
}

+ (NSString*)getCurrentTimeWithFormatter:(NSString*)format{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:format];
    NSDate *currDate = [NSDate date];
    NSString *time = [formatter stringFromDate:currDate];
    return time;
}

+ (NSTimeInterval)compareCurrentDateWithDate:(NSString *)aDate{
    NSDate * date = [Utilities getDateFromString:aDate WithFormatter:@"yyyy-MM-dd HH:mm:ss"];
    return [date timeIntervalSinceDate:[NSDate date]];
} 

+ (NSDate *)getTheDay:(NSDate *)date withNumberOfDays:(NSInteger)numDays{
    NSDate *newDate = [NSDate dateWithTimeIntervalSinceReferenceDate:[date timeIntervalSinceReferenceDate] + numDays*24*3600];
    return newDate;
}

+ (NSDate *)getDateWithDate:(NSDate *)date withMonth:(NSInteger)month{
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setMonth:month];
    // NSGregorianCalendar 阳历
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSCalendar *calender = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [calender dateByAddingComponents:comps toDate:date options:0];
#pragma clang diagnostic pop
}
 
+ (NSString *)getWeekDayByDate:(NSDate *)date{
    if (!date) {
        return @"";
    }
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *weekComp = [calendar components:NSWeekdayCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    NSInteger weekDayEnum = [weekComp weekday];
    NSString *weekDays = nil;
    switch (weekDayEnum) {
        case 1:
            weekDays = @"周日";
            break;
        case 2:
            weekDays = @"周一";
            break;
        case 3:
            weekDays = @"周二";
            break;
        case 4:
            weekDays = @"周三";
            break;
        case 5:
            weekDays = @"周四";
            break;
        case 6:
            weekDays = @"周五";
            break;
        case 7:
            weekDays = @"周六";
            break;
        default:
            break;
    }
    return weekDays;
}

+ (NSInteger)weekDayByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *weekComp = [calendar components:NSWeekdayCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    NSInteger weekDayEnum = [weekComp weekday];
    return weekDayEnum;
}

+ (NSInteger)numDayWithBeginDate:(NSDate*)beginDate endDate:(NSDate*)endDate{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    unsigned int unitFlags = NSDayCalendarUnit;
#pragma clang diagnostic pop
    NSDateComponents *comps = [gregorian components:unitFlags fromDate:beginDate  toDate:endDate  options:0];
    return [comps day];
}

+ (NSString *)getYearByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSYearCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%04tu",[dateComp year]];
}

+ (NSString *)getMonthByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSMonthCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%02tu",[dateComp month]];
}

+ (NSString *)getMonth1ByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSMonthCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%tu",[dateComp month]];
}

// 获取时分秒
+ (NSString *)getHourByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSHourCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%02tu",[dateComp hour]];
}
+ (NSString *)getMinuteByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSMinuteCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%02tu",[dateComp minute]];
}
+ (NSString *)getSecodeByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSSecondCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%02tu",[dateComp second]];
}

+ (BOOL)date:(NSDate *)date theSameDate:(NSDate *)sdate{
    double timezoneFix = [NSTimeZone localTimeZone].secondsFromGMT;
    return  ((int)(([date timeIntervalSince1970] + timezoneFix)/(24*3600)) - (int)(([sdate timeIntervalSince1970] + timezoneFix)/(24*3600))  == 0);
}

+ (NSString *)getDayByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSDayCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%02d",(int)[dateComp day]];
}

+ (NSString *)getDay1ByDate:(NSDate *)date{
    NSCalendar *calendar = [NSCalendar currentCalendar];
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSDateComponents *dateComp = [calendar components:NSDayCalendarUnit fromDate:date];
#pragma clang diagnostic pop
    return [NSString stringWithFormat:@"%d",(int)[dateComp day]];
}


+ (NSDate*)changeDateWithDate:(NSDate *)date{
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
    NSInteger flag = NSYearCalendarUnit |NSMonthCalendarUnit |NSDayCalendarUnit |NSHourCalendarUnit |NSMinuteCalendarUnit |NSSecondCalendarUnit;
#pragma clang diagnostic pop
    NSCalendar* calendar = [NSCalendar currentCalendar];
    NSDateComponents* components = [calendar components:flag fromDate:date];
    [components setHour:0];
    [components setMinute:0];
    [components setSecond:0];
    NSDate* today = [calendar dateFromComponents:components];
    return today;
}

+ (UIImage *)getImageWithStretchableByBundlePathWithImageName:(NSString *)name{
    UIImage *image = [self getImageBySmallPNG:name];
    image = [image stretchableImageWithLeftCapWidth:10 topCapHeight:10];
    return image;
}

+ (UIImage *)getImageWithWidthStretchableByBundlePathWithImageName:(NSString *)name{
    UIImage *image = [self getImageBySmallPNG:name];
    image = [image stretchableImageWithLeftCapWidth:0 topCapHeight:0];
    return image;
}

+ (NSString *)base64EncodeImage:(UIImage *)image{
    NSData *imageData = UIImageJPEGRepresentation(image,0.1);
    NSString *string = [Base64 encode:imageData];
    return string;
}

+ (NSString *)calculationTime:(NSString *)issueTime
{
    //计算时间差
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSDate *date = [formatter dateFromString:issueTime];
    
    
    NSTimeInterval late = [date timeIntervalSince1970]*1;
    
    NSDate* dat = [NSDate dateWithTimeIntervalSinceNow:0];
    NSTimeInterval now = [dat timeIntervalSince1970]*1;
    NSString *timeString = @"";
    
    NSTimeInterval cha = now - late;
    if (cha <= 0) {//lyf 加
        timeString=@"刚刚";
    }
    if (cha/60 > 0 && cha/60 < 1) {
        timeString = [NSString stringWithFormat:@"%f", cha];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@秒前", timeString];
    }
    if (cha/60 >= 1 && cha/3600 < 1) {//lyf 加了"="
        timeString = [NSString stringWithFormat:@"%f", cha/60];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@分钟前", timeString];
    }
    if (cha/3600 >= 1 && cha/86400 < 1) {//lyf 加了"="
        timeString = [NSString stringWithFormat:@"%f", cha/3600];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@小时前", timeString];
    }
    if (cha/86400 >= 1)//lyf 加了"="
    {
        timeString = [NSString stringWithFormat:@"%f", cha/86400];
        timeString = [timeString substringToIndex:timeString.length-7];
        timeString=[NSString stringWithFormat:@"%@天前", timeString];
    }
    return timeString;
}



+ (CGSize)getSize:(NSString *)contents withFont:(UIFont *)font withWidth:(CGFloat)width{
    if (!contents || !font) {
        return CGSizeZero;
    }
    
    if(contents.length > 0 && [contents characterAtIndex: contents.length - 1] == '\n' ){
        contents = [NSString stringWithFormat:@"%@%@", contents,@" "];
    }
    
    if ([contents respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        return [contents boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:@{NSFontAttributeName:font} context:nil].size;
    }else{
        return CGSizeZero;
    }
}

+ (CGSize)getSize:(NSString*)contents attributes:(nullable NSDictionary<NSString *, id> *)attributes withWidth:(CGFloat)width{
    if (!contents || !attributes) {
        return CGSizeZero;
    }
    
    if ([contents respondsToSelector:@selector(boundingRectWithSize:options:attributes:context:)]) {
        return [contents boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX) options:(NSStringDrawingUsesFontLeading | NSStringDrawingUsesLineFragmentOrigin) attributes:attributes context:nil].size;
    }else{
        return CGSizeZero;
    }
}

+ (UIColor *) R:(float)r G:(float)g B:(float)b{
    UIColor *color = [UIColor colorWithRed:r/255.0 green:g/255.0 blue:b/255.0 alpha:1.0];
    return color;
}

+ (NSDictionary *)webInterfaceToDic: (NSURL *) url prefix:(NSString*)prefix{
    NSString *urlStr = [url absoluteString];
    if([urlStr hasPrefix:prefix]) {
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        urlStr = [urlStr substringFromIndex:prefix.length];
        NSArray *array1 = [urlStr componentsSeparatedByString:@"&"];
        for (NSString *obj in array1){
            NSArray *array2 = [obj componentsSeparatedByString:@"="];
            if(array2.count>=2) {
                NSString *key = [array2 objectAtIndex:0];
                NSString *value = [[array2 objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [dic setObject:value forKey:key];
            }
        }
        return dic;
    }
    return nil;
}

+ (NSDictionary *)webLinkParamParser:(NSString*)url{
    NSString *urlStr = [NSString stringWithString:url];
    NSRange range = [urlStr rangeOfString:@"?"];
    if (range.location != NSNotFound) {
        urlStr = [urlStr substringFromIndex:range.location+1];
        NSMutableDictionary *dic = [NSMutableDictionary dictionary];
        NSArray *array1 = [urlStr componentsSeparatedByString:@"&"];
        for (NSString *obj in array1){
            NSArray *array2 = [obj componentsSeparatedByString:@"="];
            if(array2.count>=2) {
                NSString *key = [array2 objectAtIndex:0];
                NSString *value = [[array2 objectAtIndex:1] stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
                [dic setObject:value forKey:key];
            }
        }
        return dic;
    }
    return nil;
}

+ (BOOL)compareTimeWithCurrentTime:(NSString *)currentTime beginTime:(NSString*)beginTime endTime:(NSString *)endTime{
    int current = [self changeHourWithTime:currentTime];
    int begin = [self changeHourWithTime:beginTime];
    int end = [self changeHourWithTime:endTime];
    if (current >= begin && current <= end) {
        return YES;
    }
    else{
        return NO;
    }
}

+ (int)changeHourWithTime:(NSString *)time{
    if (time.length == 0) {
        return 0;
    }
    NSArray *array = [time componentsSeparatedByString:@":"];
    int hour = [[array objectAtIndex:0] intValue]*60;
    int min = [[array objectAtIndex:1] intValue];
    return hour+min;
}

+ (NSString*)minTimeWithDate:(NSString*)date_ time:(NSString*)time_{
    
    int now = [Utilities changeHourWithTime:time_];
    if (now>20*60)
        time_ = @"20:00";
    
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"HH:mm"];
    NSString *hourAndMin = [formatter stringFromDate:[NSDate date]];
    
    NSDate *theDate = [Utilities getDateFromString:date_];
    NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
    
    if ([theDate timeIntervalSinceDate:today]<=0) {
        int h_m = [Utilities changeHourWithTime:hourAndMin];
        now = MAX(now, h_m);
        int hour = now/60;
        int min = now%60;
        if (min == 0) {
            min = 0;
        }
        else if (min>0 &&min <= 30) {
            min = 30;
        }
        else{
            min = 0;
            hour += 1;
        }
        
        time_ = [NSString stringWithFormat:@"%02d:%02d",hour,min];
        now = [Utilities changeHourWithTime:time_];
        if (now>20*60)
            time_ = @"20:00";
    }
    return time_;
}

+ (NSString*)formatPhoneNum:(NSString*)phoneStr{
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"(" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@")" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@" " withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"+" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"-" withString:@""];
    phoneStr = [phoneStr stringByReplacingOccurrencesOfString:@"\\" withString:@""];
    if(phoneStr.length == 13 && [phoneStr hasPrefix:@"86"]) {
        phoneStr = [phoneStr substringFromIndex:2];
    }
    return phoneStr;
}

+ (UIImage *)imageOfUserType:(int)level{
    if (level == 2) {
        return [UIImage imageNamed:@"vip_aa.png"];
    }else if (level == 3){
        return [UIImage imageNamed:@"big.png"];
    }else{
        return nil;// [UIImage imageNamed:@"vip_un.png"];
    }
}


+ (NSString*)formatImageUrlWithStr:(NSString*)str withFormatStr:(NSString*)format{
    if(format.length > 0) {
        format = [NSString stringWithFormat:@"_%@",format];
    } else if(!format) {
        format = @"";
    }
    if (str&&str.length>0) {
        NSArray *array = [str componentsSeparatedByString:@"."];
        if (array.count<=2) {
            NSString *profixStr = [array objectAtIndex:0];
            if ([profixStr hasSuffix:@"_s"]||[profixStr hasSuffix:@"_l"]) {
                profixStr = [profixStr substringToIndex:profixStr.length-2];
            }
            return [NSString stringWithFormat:@"%@%@.%@",profixStr,format,[array objectAtIndex:1]];
        }else{
            NSString *last = [array objectAtIndex:array.count-1];
            NSInteger index = str.length-(last.length+1);
            NSString *profixStr = [str substringToIndex:index];
            if ([profixStr hasSuffix:@"_s"]||[profixStr hasSuffix:@"_l"]) {
                profixStr = [profixStr substringToIndex:profixStr.length-2];
            }
            return [NSString stringWithFormat:@"%@%@.%@",profixStr,format,last];
        }
    }
    return str;
}

+ (NSString*)videoDataWithPath:(NSString*)path{
    NSData *videoData = [NSData dataWithContentsOfFile:path];
    videoData = [GTMBase64 encodeData:videoData];
    return [[NSString alloc] initWithData:videoData encoding:NSUTF8StringEncoding];
}

+ (long long) fileSizeAtPath:(NSString*) path{
    NSFileManager* manager = [NSFileManager defaultManager];
    if ([manager fileExistsAtPath:path]){
        return [[manager attributesOfItemAtPath:path error:nil] fileSize];
    }
    return 0;
}

+ (NSString*)imageDataWithImage:(UIImage*)aImage{
    NSData *imageData = UIImageJPEGRepresentation(aImage,0.45);
    imageData = [GTMBase64 encodeData:imageData];
    return [[NSString alloc] initWithData:imageData encoding:NSUTF8StringEncoding];
}

+ (NSMutableAttributedString *)attributedStringWithString:(NSString*)string value1:(id)aValue_1 range1:(NSRange)aRange_1 value2:(id)aValue_2 range2:(NSRange)aRange_2 font:(float)aFont otherValue:(id)other otherRange:(NSRange)otherRange{
    if (!string) {
        return nil;
    }
    NSMutableAttributedString *str = [[NSMutableAttributedString alloc] initWithString:string];
    
    if (aValue_1) {
        if ([aValue_1 isKindOfClass:[UIColor class]]) {
            [str addAttribute:NSForegroundColorAttributeName value:aValue_1 range:aRange_1];
            [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:aFont] range:aRange_1];
        }else if ([aValue_1 isKindOfClass:[UIFont class]]){
            [str addAttribute:NSFontAttributeName value:aValue_1 range:aRange_1];
        }
    }
    
    if (aValue_2) {
        if ([aValue_2 isKindOfClass:[UIColor class]]) {
            [str addAttribute:NSForegroundColorAttributeName value:aValue_2 range:aRange_2];
            [str addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:aFont] range:aRange_2];
        }else if ([aValue_2 isKindOfClass:[UIFont class]]){
            [str addAttribute:NSFontAttributeName value:aValue_2 range:aRange_2];
        }
    }
    
    if (other) {
        if ([other isKindOfClass:[UIColor class]]) {
            [str addAttribute:NSForegroundColorAttributeName value:other range:otherRange];
        }else if ([other isKindOfClass:[UIFont class]]){
            [str addAttribute:NSFontAttributeName value:other range:otherRange];
        }
    }
    return str;
}

+ (void)drawView:(UIView*)view radius:(CGFloat)radius borderColor:(UIColor*)color{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    [layer setCornerRadius:radius];
    [layer setBorderWidth:0.5];
    [layer setBorderColor:[[color colorWithAlphaComponent:0.6] CGColor]];
    
    view.layer.shadowColor = [[UIColor redColor] CGColor];
    view.layer.shadowOffset = CGSizeMake(0,0);
    view.layer.shadowRadius = MAX(1, radius-2);
}

+ (void)drawView:(UIView*)view radius:(CGFloat)radius bordLineWidth:(CGFloat)lineWidth borderColor:(UIColor*)color{
    CALayer *layer = [view layer];
    [layer setMasksToBounds:YES];
    if (radius>0) {
        [layer setCornerRadius:radius];
    }
    if (lineWidth>0) {
        [layer setBorderWidth:lineWidth];
    }
    if (color) {
        [layer setBorderColor:[[color colorWithAlphaComponent:1] CGColor]];
    }
}

+ (NSString*)formatDate:(NSString*)aDate time:(NSString*)aTime{
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *date = [formatter dateFromString:aDate];
    [formatter setDateFormat:@"MM月dd日"];
    NSString *dateStr = [formatter stringFromDate:date];
    NSString *week = [Utilities getWeekDayByDate:date];
    
    NSDate *today = [Utilities changeDateWithDate:[NSDate date]];
    if ([date timeIntervalSinceDate:today] == 0) {
        dateStr = @"今天";
    }
    
    if ([date timeIntervalSinceDate:today] == 24*3600) {
        dateStr = @"明天";
    }
    
    NSString *dateStrComponent = [NSString stringWithFormat:@"%@%@",dateStr,week];
    return [NSString stringWithFormat:@"%@ %@",dateStrComponent,aTime];
}

+ (UIImageView *)lineviewWithFrame:(CGRect)rt forView:(UIView*)view{
    UIImageView *imageview = [[UIImageView alloc] initWithFrame:rt];
    imageview.image = [UIImage imageNamed:@"hengxian_a.png"];
    [view addSubview:imageview];
    return imageview;
}

+ (UIImage *)grachicsImageWithView:(UIView*)view size:(CGSize)sz{
    UIGraphicsBeginImageContext(sz);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    CGImageRef imageRef = viewImage.CGImage;
    CGRect rect =CGRectMake(0, 0, sz.width, sz.height);//这里可以设置想要截图的区域
    CGImageRef imageRefRect =CGImageCreateWithImageInRect(imageRef, rect);
    UIImage *sendImage = [UIImage imageWithCGImage:imageRefRect];
    CGImageRelease(imageRefRect);
    return sendImage;
}

+ (void)mutablePathMoveAnimationWithStartPoint:(CGPoint)st_pt endPoint:(CGPoint)en_pt controlPoint:(CGPoint)ct_pt view:(UIView*)aView duration:(float)duration completion:(void(^)(BOOL finished))completion{
    CAKeyframeAnimation *bounceAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef thePath = CGPathCreateMutable();
    CGPathMoveToPoint(thePath, NULL, st_pt.x, st_pt.y);
    CGPathAddQuadCurveToPoint(thePath, NULL, ct_pt.x, ct_pt.y, en_pt.x, en_pt.y);
    bounceAnimation.path = thePath;
    bounceAnimation.duration = duration;
    bounceAnimation.removedOnCompletion = NO;
    bounceAnimation.fillMode = kCAFillModeForwards;
    [aView.layer addAnimation:bounceAnimation forKey:@"move"];
    [UIView animateWithDuration:0.4 delay:duration-0.4 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        aView.alpha = 0.2;
    } completion:^(BOOL finished) {
        aView.alpha = 0;
        [aView removeFromSuperview];
        CGPathRelease(thePath);
        if (completion) {
            completion(finished);
        }
    }];
}

+ (int)agewithBirthday:(NSString*)aBirthday{
    if (!aBirthday || aBirthday.length == 0) {
        return 0;
    }
    NSString *currentYear = [Utilities getYearByDate:[NSDate date]];
    if (currentYear.length<4) {
        return 0;
    }
    currentYear = [currentYear substringToIndex:4];
    NSString *year = [Utilities getYearByDate:[Utilities getDateFromString:aBirthday]];
    
    return MAX([currentYear intValue]-[year intValue], 0);
}


/*
 “club_id”：25                    //球场ID(对应中心courseId)
 “city_id”:34                   //城市ID
 “province_id”:11              //省份ID
 “club_name”: “云海谷大众场”,     //球场名称(对应中心courseName)
 “longitude”:122,             //经度
 “latitude”:22.12,            //纬度
 “address”:”xxxxx”,         //地址
 “club_image”:”xxxx”,       //球场logo
 */

+ (id)valueByAllClubInfo:(int)clubId withKey:(NSString*)key allClub:(NSArray*)clubs{
    if (!clubs || clubs.count == 0 || clubId == 0) {
        return nil;
    }
    
    for (SearchClubModel *model in clubs) {
        if (model.clubId == clubId) {
            if (key && key.length > 0) {
                if (Equal(key, @"city_id")) {
                    return @(model.cityId);
                }else if (Equal(key, @"province_id")){
                    return @(model.provinceId);
                }else if (Equal(key, @"club_name")){
                    return model.clubName;
                }else if (Equal(key, @"address")){
                    return model.address;
                }else if (Equal(key, @"club_image")){
                    return model.clubImage;
                }else if (Equal(key, @"longitude")){
                    return @(model.longitude);
                }else if (Equal(key, @"latitude")){
                    return @(model.latitude);
                }
            }else{
                return model;
            }
            break;
        }
    }
    return nil;
}


+ (NSString *)getGolfServicePhone{
    NSString *servicePhone = [[NSUserDefaults standardUserDefaults] objectForKey:@"GolfClientPhone"];
    if (!servicePhone || servicePhone.length == 0) {
        servicePhone = kClientServicePhone;
    }
    return servicePhone;
}

//截取视频中的一张图
+ (UIImage *)getImageByVideoPath:(NSString *)path{
    if (!path || path.length == 0) {
        return nil;
    }
    NSURL *videoUrl = [NSURL fileURLWithPath:path];
    AVAsset *myAsset = [[AVURLAsset alloc] initWithURL:videoUrl options:nil];
    AVAssetImageGenerator *assetImageGenerator = [AVAssetImageGenerator assetImageGeneratorWithAsset:myAsset];
    
    assetImageGenerator.maximumSize = CGSizeMake(Device_Width, Device_Height);
    assetImageGenerator.appliesPreferredTrackTransform = YES;
    assetImageGenerator.apertureMode = AVAssetImageGeneratorApertureModeEncodedPixels;
    
    NSError *error;
    CMTime actualTime;
    CGImageRef halfWayImage = [assetImageGenerator copyCGImageAtTime:CMTimeMake(0.1,1) actualTime:&actualTime error:&error];
    if (halfWayImage != NULL) {
        return [[UIImage alloc] initWithCGImage:halfWayImage];
    }
    return nil;
}

+ (BOOL)phoneNumMatch:(NSString*)str{
    if (!str || str.length == 0) {
        return NO;
    }
    return [str isMatchedByRegex:@"^(852|853)\\d{8}$"] || [str isMatchedByRegex:@"^(886)\\d{9}$"] || [str isMatchedByRegex:@"^(1)\\d{10}$"];
}

+ (BOOL)isBlankString:(NSString *)string{
    if (string == nil) return YES;
    if (string == NULL) return YES;
    if ([string isKindOfClass:[NSNull class]]) return YES;
    if ([[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] length]==0) {
        return YES;
    }
    return NO;
}

#pragma mark - 逻辑控制相关方法
+ (NSAttributedString *)handleTagWithText:(NSString*)text
{
    if (text.length == 0) {
        return nil;
    }
    
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:text attributes:@{NSForegroundColorAttributeName : [UIColor colorWithHexString:@"333333"],NSFontAttributeName : [UIFont systemFontOfSize:15]}];
    
    text = [text stringByAppendingString:@" "];
    NSArray *arr = [text componentsSeparatedByRegex:TAG_REGEX];
    
    __block NSInteger location = 0;
    [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        
        NSString *unit_s = (NSString*)obj;
        if ([unit_s isMatchedByRegex:TAG_REGEX]) {
            [mas addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"249df3"] range:NSMakeRange(location, unit_s.length)];
        }
        location += unit_s.length;
    }];
    
    return mas;
}

+ (NSAttributedString*)handleTagWithAttributedText:(NSAttributedString*)aAttr{
    NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithAttributedString:aAttr];
    NSString *text = [[aAttr string] stringByAppendingString:@"!め"];
    NSArray *arr = [text componentsSeparatedByRegex:TAG_REGEX];
    
    __block NSInteger location = 0;

    if (arr.count == 0) {
        [mas removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(location, text.length)];
        if ([text isMatchedByRegex:TAG_REGEX]) {
            [mas addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"249df3"] range:NSMakeRange(location, text.length)];
        }else{
            [mas addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(location, text.length)];
        }
    }else{
        [arr enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *unit_s = (NSString*)obj;
            if (unit_s.length>0) {
                unit_s = [unit_s stringByReplacingOccurrencesOfString:@"!め" withString:@""];
                [mas removeAttribute:NSForegroundColorAttributeName range:NSMakeRange(location, unit_s.length)];
                if ([unit_s isMatchedByRegex:TAG_REGEX]) {
                    [mas addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"249df3"] range:NSMakeRange(location, unit_s.length)];
                }else if (!Equal(unit_s, @" ")){
                    [mas addAttribute:NSForegroundColorAttributeName value:[UIColor colorWithHexString:@"333333"] range:NSMakeRange(location, unit_s.length)];
                }
                location += unit_s.length;
            }
        }];
    }
    return mas;
}


+ (NSString *)decodeFromPercentEscapeString: (NSString *) input
{
    NSMutableString *outputStr = [NSMutableString stringWithString:input];
    [outputStr replaceOccurrencesOfString:@"+"
                               withString:@" "
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
}

// 链接文本转换为替换文本
+ (NSString*)plainTextWithText:(NSString*)aText{
    NSString *plainText = [NSString stringWithString:aText];
    plainText = [plainText stringByReplacingOccurrencesOfRegex:@"(https?|golfapi)://[A-Za-z\\d\\.-_\\?&#=]*" withString:@"查看链接"];
    return [plainText stringByReplacingOccurrencesOfString:@"~" withString:@""];
}

+ (void)changeView:(UIView *)view height:(CGFloat)height{
    for (NSLayoutConstraint *nl in view.constraints) {
        if (nl.firstAttribute == NSLayoutAttributeHeight) {
            nl.constant = height;
        }
    }
    if (view != nil) {
        [view layoutIfNeeded];
        [[view superview] layoutIfNeeded];
    }
}

+ (void)changeView:(UIView *)view width:(CGFloat)width{
    for (NSLayoutConstraint *nl in view.constraints) {
        if (nl.firstAttribute == NSLayoutAttributeWidth) {
            nl.constant = width;
        }
    }
    if (view != nil) {
        [view layoutIfNeeded];
        [[view superview] layoutIfNeeded];
    }
}

+ (void)removeHeightConstraintView:(UIView *)view{
    for (NSLayoutConstraint *nl in view.constraints) {
        if (nl.firstAttribute == NSLayoutAttributeHeight) {
            [view removeConstraint:nl];
        }
    }
    if (view != nil) {
        [view layoutIfNeeded];
        [[view superview] layoutIfNeeded];
    }
}

+ (void)changeView:(UIView *)view left:(CGFloat)left secondItemClass:(Class)clazz oldConstant:(CGFloat)constant{
    for (NSLayoutConstraint *ns in [[view superview] constraints]) {
        if (ns.firstItem == view && ns.firstAttribute == NSLayoutAttributeLeading) {
            if (clazz != nil) {
                if (![ns.secondItem isKindOfClass:clazz]) {
                    continue;
                }
            }
            if (ns.constant == constant) {
                ns.constant = left;
            }
            break;
        }
    }
    if (view != nil) {
        [view layoutIfNeeded];
        [[view superview] layoutIfNeeded];
    }
}


+ (void)changeView:(UIView *)view top:(CGFloat)top{
    for (NSLayoutConstraint *ns in [[view superview] constraints]) {
        if (ns.firstItem == view && ns.firstAttribute == NSLayoutAttributeTop) {
            ns.constant = top;
            break;
        }
    }
    if (view != nil) {
        [view layoutIfNeeded];
        [[view superview] layoutIfNeeded];
    }
}

+ (CGSize)imageSizeWithUrl:(NSString *)imageUrl{
    NSRange range = [imageUrl rangeOfString:@"_"];
    
    if (range.location != NSNotFound) {
        NSArray *array = [imageUrl componentsSeparatedByString:@"_"];
        if (array.count>2) {
            NSString *middle = array[array.count-2];
            range = [middle rangeOfString:@"x"];
            if (range.location != NSNotFound) {
                NSArray *ar = [middle componentsSeparatedByString:@"x"];
                if (ar.count==2) {
                    return CGSizeMake([ar[0] floatValue], [ar[1] floatValue]);
                }
            }
        }
    }
    return CGSizeMake(0, 0);
}

+ (void)loadImageWithURL:(NSURL *)url inImageView:(UIView *)imageView placeholderImage:(UIImage *)pimage{
    [Utilities loadImageWithURL:url inImageView:imageView placeholderImage:pimage changeContentMode:YES];
}

+ (void)loadImageWithURL:(NSURL *)url inImageView:(UIView *)imageView placeholderImage:(UIImage *)pimage changeContentMode:(BOOL)change
{
    if (!imageView) return;
    
    BOOL exist = [[SDWebImageManager sharedManager] cachedImageExistsForURL:url];
    imageView.alpha = exist?1.f:0.3f;
    if (change) {
        imageView.contentMode = UIViewContentModeCenter;
    }
    
    if ([imageView isKindOfClass:[UIButton class]]) {
        UIButton *btn = (UIButton *)imageView;
        [btn sd_setImageWithURL:url forState:(UIControlStateNormal) placeholderImage:pimage completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
            [UIView animateWithDuration:.2f animations:^{
                imageView.alpha = 1.f;
            }];
        }];
    }else if([imageView isKindOfClass:[UIImageView class]]){
        
        UIImageView *img = (UIImageView *)imageView;
        [img sd_setImageWithURL:url
               placeholderImage:pimage
                        options:0
                      completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL) {
                          if (change) {
                              imageView.contentMode = UIViewContentModeScaleAspectFill;
                          }
                          [UIView animateWithDuration:.2f animations:^{
                              imageView.alpha = 1.f;
                          }];
                      }];
    }
}

@end


