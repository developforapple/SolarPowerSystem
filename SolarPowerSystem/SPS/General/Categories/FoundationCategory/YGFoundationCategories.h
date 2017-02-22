//
//  YGFoundationCategories.h
//  Golf
//
//  Created by bo wang on 16/6/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#ifndef YGFoundationCategories_h
#define YGFoundationCategories_h

#import "NSObject+YGPerformBlock.h"
#import "NSData+HKPDataImage.h"
#import "NSDate+Calendar.h"
#import "NSString+STRegex.h"
#import "NSString+StringHeight.h"
#import "NSString+Utils.h"
#import "NSCalendar+YGCategory.h"
#import "NSObject+KVCExceptionCatch.h"
#import "NSAttributedString+Units.h"

#import "NSMutableDictionary+Util.h"

#if __has_include(<LinqToObjectiveC/LinqToObjectiveC.h>)
    #import <LinqToObjectiveC/LinqToObjectiveC.h>
#endif

#if __has_include(<YYText/YYText.h>)
    #import <YYText/NSAttributedString+YYText.h>
    #import <YYText/NSParagraphStyle+YYText.h>
    #import <YYText/UIPasteboard+YYText.h>
#endif

#if __has_include(<YYModel/YYModel.h>)
    #import <YYModel/NSObject+YYModel.h>
#endif

#endif /* YGFoundationCategories_h */
