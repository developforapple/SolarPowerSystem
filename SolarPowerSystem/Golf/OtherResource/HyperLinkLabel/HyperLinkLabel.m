//
//  HyperLinkLabel.m
//  Golf
//
//  Created by 黄希望 on 15/8/7.
//  Copyright (c) 2015年 云高科技. All rights reserved.
//

#import "HyperLinkLabel.h"

#import <CoreText/CoreText.h>
#import "NSString+HtmlText.h"
#import "CCActionSheet.h"
#import "YGCapabilityHelper.h"
#import "YGWebBrowser.h"
#import "RegexKitLite.h"

#define ZERORANGE ((NSRange){0, 0})
#define LONGPRESS_DURATION .3
#define LONGPRESS_ARG @[_touchingURL, [NSValue valueWithRange:_touchingURLRange], _touchingRects]

@interface HyperLinkLabel(){
    CFArrayRef _lines;
    CGRect *_lineImageRectsCArray;
    NSUInteger _numLines;
    NSURL *_touchingURL;
    NSRange _touchingURLRange;
    NSMutableArray *_touchingRects;
    NSRangePointer _rangesCArray;
    NSAttributedString *_attributedTextBeforeTouching;
    NSMutableArray *_URLs;
    NSMutableArray *_URLRanges;
    BOOL _isLongPress;
}

@property (nonatomic, copy) HyperlinkLabelURLHandler URLClickHandler;
@property (nonatomic, copy) HyperlinkLabelURLHandler URLLongPressHandler;
@property (nonatomic, strong) NSDictionary *linkAttributesWhenTouching;
@property (nonatomic) UILongPressGestureRecognizer *longPressGestureRecognizer;


@end

//IB_DESIGNABLE
@implementation HyperLinkLabel

- (void)hyperLinkWithText:(NSString*)aText
                textColor:(UIColor*)textColor
                linkColor:(UIColor*)linkColor
                 fontSize:(CGFloat)fontSize
          limitLineNumber:(NSInteger)limitLineNumber
          urlClickHandler:(HyperlinkLabelURLHandler)urlClickHandler
      urlLongPressHandler:(HyperlinkLabelURLHandler)urlLongPressHandler{
    
    if (aText.length > 0) {
        self.backgroundColor = [UIColor clearColor];
        self.clipsToBounds = YES;
        self.numberOfLines = limitLineNumber;
        
        __weak typeof(self) ws = self;
        [self attributedStringWithWithText:aText textColor:textColor linkColor:linkColor fontSize:fontSize dataCallBack:^(NSMutableAttributedString *mas, NSArray *urls, NSArray *urlRanges) {
            if (!_URLs){
                _URLs = [urls mutableCopy];
                _URLRanges = [urlRanges mutableCopy];
            }
            ws.attributedText = mas;
            [ws setURLs:urls forRanges:urlRanges];
        }];
        self.URLClickHandler = urlClickHandler;
        self.URLLongPressHandler = urlLongPressHandler;
    
    }
}

- (void)hyperLinkResp:(NSURL*)url{
    NSString *urlString = [url absoluteString];
    if ([urlString hasPrefix:@"golfapi://"]) {
        NSDictionary *data = [Utilities webLinkParamParser:urlString];
        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:data];
    }else if ([urlString hasPrefix:@"poundSign://"]){
        NSString *replaceString = [urlString stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSRange range = [replaceString rangeOfString:@"poundSign://?"];
        NSString *subString = [replaceString substringFromIndex:range.length];
        NSDictionary *data = @{@"data_type":@"topic",@"data_id":@(0),@"sub_type":@(4),@"data_extra":subString?subString:@""};
        [[GolfAppDelegate shareAppDelegate] handlePushControllerWithData:data];
    }else if ([urlString isMatchedByRegex:@"(https?|ftp|file)+://[^\\s]*"]) {
        
        YGWebBrowser *browser = [YGWebBrowser instanceFromStoryboard];
        [browser loadURL:[NSURL URLWithString:urlString]];
        [[GolfAppDelegate shareAppDelegate].naviController pushViewController:browser animated:YES];
    
//        CommodityTextViewController *commodityTextView = [[CommodityTextViewController alloc] init];
//        commodityTextView.commodityDetailUrl = urlString;
//        commodityTextView.title = @"详情";
//        [commodityTextView.navigationItem setHidesBackButton:YES];
//        commodityTextView.hidesBottomBarWhenPushed = YES;
//        [[GolfAppDelegate shareAppDelegate].naviController pushViewController:commodityTextView animated:YES];
    }else if ([urlString isMatchedByRegex:@"[A-Z0-9a-z\\._%+-]+@([A-Za-z0-9-]+\\.)+[A-Za-z]{2,4}"]){
        [[UIApplication sharedApplication] openURL:url];
    }else if ([urlString isMatchedByRegex:@"\\d{3}-\\d{8}|\\d{3}-\\d{7}|\\d{4}-\\d{8}|\\d{4}-\\d{7}|1+[358]+\\d{9}|\\d{8}|\\d{7}"]) {
        [YGCapabilityHelper call:urlString needConfirm:YES];
    }
}

- (void)attributedStringWithWithText:(NSString*)aText
                           textColor:(UIColor*)textColor
                           linkColor:(UIColor*)linkColor
                            fontSize:(CGFloat)fontSize
                            dataCallBack:(void(^)(NSMutableAttributedString *mas,NSArray *urls,NSArray *urlRanges))dataCallBack{
    [NSString plainTextWithText:aText callBack:^(NSString *plainText, NSArray *urls, NSArray *urlRanges) {
        
        NSMutableAttributedString *mas = [[NSMutableAttributedString alloc] initWithString:plainText attributes:@{NSForegroundColorAttributeName:textColor, NSFontAttributeName:[UIFont systemFontOfSize:fontSize]}];

        [urlRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
            NSRange range = [obj rangeValue];
            if (range.length+range.location<=mas.length) {
                [mas addAttributes:@{NSForegroundColorAttributeName : linkColor} range:range];
            }
        }];
        
        if (dataCallBack) {
            dataCallBack (mas,urls,urlRanges);
        }
    }];
}

#pragma mark - 初始化相关
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]){
        _linkAttributesWhenTouching = @{ NSBackgroundColorAttributeName : [UIColor colorWithHue:.41 saturation:.00 brightness:.76 alpha:1.00] };
        self.userInteractionEnabled = YES;
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        _linkAttributesWhenTouching = @{ NSBackgroundColorAttributeName : [UIColor colorWithHue:.41 saturation:.00 brightness:.76 alpha:1.00] };
        self.userInteractionEnabled = YES;
        [self setupGestureRecognizers];
    }
    return self;
}

- (void)dealloc
{
    if (_lines)
        CFRelease(_lines);
    
    if (_lineImageRectsCArray)
        free(_lineImageRectsCArray);
    
    if (_rangesCArray)
        free(_rangesCArray);
}

#pragma mark -
- (void)setURL:(NSURL *)URL forRange:(NSRange)range
{
    if (!_URLs){
        _URLs = [@[] mutableCopy];
        _URLRanges = [@[] mutableCopy];
    }
    
    NSValue *rng = [NSValue valueWithRange:range];
    NSUInteger idx = [_URLRanges indexOfObject:rng inSortedRange:NSMakeRange(0, [_URLRanges count]) options:NSBinarySearchingInsertionIndex usingComparator:^NSComparisonResult(id obj1, id obj2){
        NSRange r1 = [obj1 rangeValue];
        NSRange r2 = [obj2 rangeValue];
        if (r1.location < r2.location)
            return NSOrderedAscending;
        
        if (r1.location > r2.location)
            return NSOrderedDescending;
        
        return NSOrderedSame;
    }];
    
    [_URLs insertObject:URL atIndex:idx];
    [_URLRanges insertObject:rng atIndex:idx];
}

- (void)setURLs:(NSArray *)URLs forRanges:(NSArray *)ranges
{
    __weak typeof(self) weakSelf = self;
    if (!_URLs){
        _URLs = [URLs mutableCopy];
        _URLRanges = [ranges mutableCopy];
        return;
    }
    [_URLs removeAllObjects];
    [_URLRanges removeAllObjects];
    
    [URLs enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        [weakSelf setURL:obj forRange:[ranges[idx] rangeValue]];
    }];
}

- (void)removeAllURLs
{
    _URLs = nil;
    _URLRanges = nil;
    _touchingURL = nil;
    _touchingURLRange = ZERORANGE;
    _touchingRects = nil;
}

- (NSURL *)URLAtPoint:(CGPoint)point effectiveRange:(NSRangePointer)effectiveRange
{
    if (effectiveRange)
        *effectiveRange = ZERORANGE;
    
    if (![_URLRanges count] ||
        !CGRectContainsPoint(self.bounds, point))
        return nil;
    
    // 二分法查找(查找那一行，返回行数);
    void *found = bsearch_b(&point, _lineImageRectsCArray, _numLines, sizeof(CGRect), ^int(const void *key, const void *el){
        CGPoint *p = (CGPoint *)key;
        CGRect *r = (CGRect *)el;
        if (CGRectContainsPoint(*r, *p))
            return 0;
        
        if  (p->y > CGRectGetMaxY(*r))
            return 1;
        
        return -1;
    });
    
    if (!found)
        return nil;
    
    size_t idx = (CGRect *)found - _lineImageRectsCArray;
    CTLineRef line = CFArrayGetValueAtIndex(_lines, idx);
    CFIndex strIdx = CTLineGetStringIndexForPosition(line, point);
    if (strIdx == kCFNotFound)
        return nil;
    
    CGFloat offset = CTLineGetOffsetForStringIndex(line, strIdx, NULL);
    offset += _lineImageRectsCArray[idx].origin.x;
    if (point.x < offset)
        strIdx--;
    
    // 二分法查找 （查找range的索引值）
    found = bsearch_b(&strIdx, _rangesCArray, [_URLRanges count], sizeof(NSRange), ^int(const void *key, const void *el){
        NSUInteger *idx = (NSUInteger *)key;
        NSRangePointer rng = (NSRangePointer)el;
        if (NSLocationInRange(*idx, *rng))
            return 0;
        
        if (*idx < rng->location)
            return -1;
        
        return 1;
    });
    
    if (!found)
        return nil;
    
    idx = (NSRangePointer)found - _rangesCArray;
    if (effectiveRange)
        *effectiveRange = [_URLRanges[idx] rangeValue];
    
    return _URLs[idx];
}

#pragma mark -
- (void)drawTextInRect:(CGRect)rect
{
    if (!self.attributedText)
        return;
    
    if (_URLs.count == 0) {
        [super drawTextInRect:rect];
        return;
    }
    
    rect.size.height += 1000;
    
    CTFramesetterRef framesetter = CTFramesetterCreateWithAttributedString((__bridge CFAttributedStringRef)self.attributedText);
    CGPathRef path = CGPathCreateWithRect(rect, NULL);
    rect.size.height -= 1000;
    CGFloat rectHeight = CGRectGetHeight(rect);

    
    CTFrameRef frame = CTFramesetterCreateFrame(framesetter, CFRangeMake(0, [self.attributedText length]), path, NULL);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (_lines)
        CFRelease(_lines);
    
    _lines = CTFrameGetLines(frame);
    _numLines = CFArrayGetCount(_lines);
    
    if (_numLines == 0) {
        [super drawTextInRect:rect];
        return;
    }
    
    CGPoint *lineOrigins = malloc(sizeof(CGPoint) * _numLines);
    CTFrameGetLineOrigins(frame, CFRangeMake(0, _numLines), lineOrigins);
    
    if (_lineImageRectsCArray)
        free(_lineImageRectsCArray);
    
    _lineImageRectsCArray = malloc(sizeof(CGRect) * _numLines);
    
    CGFloat fontSize = [self.font pointSize];
    CGFloat f = 2.9;
    CGFloat pos = rect.size.height - (fontSize+f)*_numLines;
    for (CFIndex i=0; i<_numLines; i++){
        CTLineRef line = CFArrayGetValueAtIndex(_lines, i);
        CGRect imgBounds = CTLineGetImageBounds(line, context);
        lineOrigins[i].y = f + (fontSize+f)*(_numLines-(i+1)) + pos;
        CGFloat ascender, descender, leading;
        CTLineGetTypographicBounds(line, &ascender, &descender, &leading);
        CGFloat filpY = CGRectGetHeight(self.bounds) - lineOrigins[i].y - ascender;
        imgBounds.origin.y = filpY - imgBounds.origin.y;
        _lineImageRectsCArray[i] = imgBounds;
    }
    
    if (_rangesCArray)
        free(_rangesCArray);
    
    _rangesCArray = malloc(sizeof(NSRange) * [_URLs count]);
    
    [_URLRanges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop){
        _rangesCArray[idx] = [obj rangeValue];
    }];
    
    
    if (!_touchingRects)
        _touchingRects = [@[] mutableCopy];
    else
        [_touchingRects removeAllObjects];
    __weak typeof(self) weakSelf = self;
    CGContextTranslateCTM(context, 0, rectHeight);
    CGContextScaleCTM(context, 1, -1);
    CGContextSetTextMatrix(context, CGAffineTransformIdentity);
    [(__bridge NSArray *)_lines enumerateObjectsUsingBlock:^(id lineObj, NSUInteger lineIdx, BOOL *lineStop){
        CTLineRef line = (__bridge CTLineRef)lineObj;
        CFArrayRef runs = CTLineGetGlyphRuns(line);
        [(__bridge NSArray *)runs enumerateObjectsUsingBlock:^(id runObj, NSUInteger runIdx, BOOL *runStop){
            CTRunRef run = (__bridge CTRunRef)runObj;
            CFRange cfrng = CTRunGetStringRange(run);
            [weakSelf drawRun:run inContext:context lineOrigin:lineOrigins[lineIdx] isTouchingRun:NSLocationInRange(cfrng.location, _touchingURLRange)];
        }];
    }];
    
    free(lineOrigins);
    CFRelease(framesetter);
    CFRelease(path);
}

#pragma mark -
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isLongPress = NO;

    if (!_attributedTextBeforeTouching)
        _attributedTextBeforeTouching = self.attributedText;
    if (_touchingURL){
        _touchingURL = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpress:) object:LONGPRESS_ARG];
    }
    
    [self handleTouches:touches withEvent:event];
    
    if (_touchingURL){
        if (self.URLLongPressHandler){
            [self performSelector:@selector(longpress:) withObject:LONGPRESS_ARG afterDelay:LONGPRESS_DURATION];
        }
    }else{
        if (self.superResponseEnabled) {
            [super touchesBegan:touches withEvent:event];
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (_touchingURL){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpress:) object:LONGPRESS_ARG];
    }
    
    if (!_isLongPress) {
        if (_touchingURL&&self.URLClickHandler) {
            self.URLClickHandler(self, _touchingURL, _touchingURLRange, _touchingRects);
        }else if (!_touchingURL&&self.labelClickBlock){
            _labelClickBlock (_data);
        }else{
            if (!_touchingURL && self.superResponseEnabled) {
                [super touchesEnded:touches withEvent:event];
            }
        }
    }
    
    [self reset];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isLongPress = NO;

    if (_touchingURL){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpress:) object:LONGPRESS_ARG];
    }
    
    [self handleTouches:touches withEvent:event];
    if (!_touchingURL && self.superResponseEnabled)
        [super touchesMoved:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    _isLongPress = NO;

    if (_touchingURL){
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(longpress:) object:LONGPRESS_ARG];
    }
    
    [super touchesCancelled:touches withEvent:event];
    [self reset];
}

- (void)handleTouches:(NSSet *)touches
            withEvent:(UIEvent *)event
{
    NSRange prevHitURLRange = _touchingURLRange;
    _touchingURL = [self URLAtPoint:[[touches anyObject] locationInView:self] effectiveRange:&_touchingURLRange];
    
    if (_touchingURLRange.length){
        if (!prevHitURLRange.length ||
            !NSEqualRanges(prevHitURLRange, _touchingURLRange))
            [self highlightTouchingLinkAtRange:_touchingURLRange];
    }else {
        if (self.superResponseEnabled) {
            if (prevHitURLRange.length)
                self.attributedText = _attributedTextBeforeTouching;
        }else{
            [self highlightTouchingLinkAtRange:NSMakeRange(0, _attributedTextBeforeTouching.length)];
        }
    }
}

#pragma mark - privates
- (void)drawRun:(CTRunRef)run
      inContext:(CGContextRef)context
     lineOrigin:(CGPoint)lineOrigin
  isTouchingRun:(BOOL)isTouchingRun
{
    CFRange range = CFRangeMake(0, 0);
    CGFloat lineOriginX = ceilf(lineOrigin.x);
    CGFloat lineOriginY = ceilf(lineOrigin.y);
    const CGPoint *posPtr = CTRunGetPositionsPtr(run);
    CGPoint *pos = NULL;
    NSDictionary *attrs = (__bridge NSDictionary *)CTRunGetAttributes(run);
    UIColor *bgColor = attrs[NSBackgroundColorAttributeName];
    if (isTouchingRun || bgColor){
        if (!posPtr){
            pos = malloc(sizeof(CGPoint));
            CTRunGetPositions(run, CFRangeMake(0, 1), pos);
            posPtr = pos;
        }
        CGFloat ascender, descender, leading;
        CGFloat width = CTRunGetTypographicBounds(run, range, &ascender, &descender, &leading);
        CGRect rect = CGRectMake(lineOriginX + posPtr->x, lineOriginY - descender, width, ascender + descender);
        rect = CGRectIntegral(rect);
        rect = CGRectInset(rect, -2, -2);
        if (lineOriginX + posPtr->x <= 0){
            rect.origin.x += 2;
            rect.size.width -= 2;
        }
        
        if (lineOriginY <= 0){
            rect.origin.y += 2;
            rect.size.height -= 2;
        }
        
        if (bgColor){
            UIBezierPath *bp = [UIBezierPath bezierPathWithRoundedRect:rect cornerRadius:3.];
            CGContextSaveGState(context);
            CGContextAddPath(context, bp.CGPath);
            CGContextSetFillColorWithColor(context, bgColor.CGColor);
            CGContextFillPath(context);
            CGContextRestoreGState(context);
        }
        
        if (isTouchingRun){
            rect.origin.y = CGRectGetHeight(self.bounds) - CGRectGetMaxY(rect);
            [_touchingRects addObject:[NSValue valueWithCGRect:rect]];
        }
    }
    
    NSShadow *shadow = attrs[NSShadowAttributeName];
    if (shadow){
        CGContextSaveGState(context);
        CGContextSetShadowWithColor(context, shadow.shadowOffset, shadow.shadowBlurRadius, [shadow.shadowColor CGColor]);
    }
    
    CGContextSetTextPosition(context, lineOriginX, lineOriginY);
    CTRunDraw(run, context, range);
    if (shadow)
        CGContextRestoreGState(context);
    
    NSNumber *underlineStyle = attrs[NSUnderlineStyleAttributeName];
    if (underlineStyle && [underlineStyle intValue] == NSUnderlineStyleSingle){
        UIColor *fgColor = attrs[NSForegroundColorAttributeName];
        if (!fgColor)
            fgColor = [UIColor blackColor];
        
        CGFloat width = CTRunGetTypographicBounds(run, range, NULL, NULL, NULL);
        if (!posPtr){
            pos = malloc(sizeof(CGPoint));
            CTRunGetPositions(run, CFRangeMake(0, 1), pos);
            posPtr = pos;
        }
        
        CGContextSetStrokeColorWithColor(context, fgColor.CGColor);
        CGContextSetLineWidth(context, 1.);
        CGContextMoveToPoint(context, lineOriginX + posPtr->x, lineOriginY-1.5);
        CGContextAddLineToPoint(context, lineOriginX + posPtr->x + width, lineOriginY-1.5);
        CGContextSaveGState(context);
        CGContextStrokePath(context);
        CGContextRestoreGState(context);
        if (pos)
            free(pos);
    }
}

- (void)highlightTouchingLinkAtRange:(NSRange)range
{
    if (!self.linkAttributesWhenTouching)
        return;
    
    NSMutableAttributedString *mas = [_attributedTextBeforeTouching mutableCopy];
    [mas addAttributes:self.linkAttributesWhenTouching range:range];
    self.attributedText = mas;
}

- (void)reset
{
    //if ( _touchingURL){
        _isLongPress = NO;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAttributedText:) object:_attributedTextBeforeTouching];
        [self performSelector:@selector(setAttributedText:) withObject:_attributedTextBeforeTouching afterDelay:.2];
    //}
    
    _touchingURLRange = ZERORANGE;
    _touchingURL = nil;
    _attributedTextBeforeTouching = nil;
}

- (void)longpress:(NSArray *)info
{
    _isLongPress = YES;
    if (_touchingURL) {
        if (self.URLLongPressHandler) {
            self.URLLongPressHandler(self, info[0], [info[1] rangeValue], info[2]);
        }
    }
}

#pragma mark - UIResponder

- (BOOL)canBecomeFirstResponder
{
    return YES;
}

- (BOOL)canPerformAction:(SEL)action withSender:(id)sender
{
    BOOL retValue = NO;
    
    if (action == @selector(copyItemClicked:))
    {
        retValue = self.copyingEnabled;
    }
    else
    {
        // Pass the canPerformAction:withSender: message to the superclass
        // and possibly up the responder chain.
        retValue = [super canPerformAction:action withSender:sender];
    }
    
    return retValue;
}

- (void)copyItemClicked:(id)sender{
//    [UIPasteboard generalPasteboard].string = _labelContent.text;
    if (self.copyingEnabled) {
        if (_copyingBlock) {
            _copyingBlock(_data);
        }
    }
}

- (void)jubao{
    if (self.jubaoEnabled) {
        if (_jubaoBlock) {
            _jubaoBlock(_data);
        }
    }
}

-(void)deleteItemClick{
    if (self.deleteEnabled) {
        if (self.blockDeleteItem) {
            self.blockDeleteItem(_data);
        }
    }
}

#pragma mark - UI Actions

- (void) longPressGestureRecognized:(UIGestureRecognizer *) gestureRecognizer
{
    if (gestureRecognizer == self.longPressGestureRecognizer)
    {
        if (gestureRecognizer.state == UIGestureRecognizerStateBegan)
        {
            [self becomeFirstResponder];
            
            UIMenuController *menu = [UIMenuController sharedMenuController];
            NSMutableArray *items = [[NSMutableArray alloc] init];
            if (self.copyingEnabled) {
                [items addObject:[[UIMenuItem alloc] initWithTitle:@"复制" action:@selector(copyItemClicked:)]];
            }
            if (self.jubaoEnabled) {
                [items addObject:[[UIMenuItem alloc] initWithTitle:@"举报" action:@selector(jubao)]];
            }
            if (self.deleteEnabled || [LoginManager sharedManager].session.memberLevel == 10) {
                [items addObject:[[UIMenuItem alloc] initWithTitle:@"删除" action:@selector(deleteItemClick)]];
            }
            [menu setMenuItems:items];
            [menu setTargetRect:self.bounds inView:self];
            [menu setMenuVisible:YES animated:YES];
            
        }
    }
}

#pragma mark - Properties

-(BOOL)jubaoEnabled{
    return [objc_getAssociatedObject(self, @selector(jubaoEnabled)) boolValue];
}

-(void)setJubaoEnabled:(BOOL)jubaoEnabled{
    if (self.jubaoEnabled != jubaoEnabled) {
        objc_setAssociatedObject(self, @selector(jubaoEnabled), @(jubaoEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

-(BOOL)deleteEnabled{
    return [objc_getAssociatedObject(self, @selector(deleteEnabled)) boolValue];
}

-(void)setDeleteEnabled:(BOOL)deleteEnabled{
    if (self.deleteEnabled != deleteEnabled) {
        objc_setAssociatedObject(self, @selector(deleteEnabled), @(deleteEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)superResponseEnabled{
    return [objc_getAssociatedObject(self, @selector(superResponseEnabled)) boolValue];
}

- (void)setSuperResponseEnabled:(BOOL)superResponseEnabled{
    if (self.superResponseEnabled != superResponseEnabled) {
        objc_setAssociatedObject(self, @selector(superResponseEnabled), @(superResponseEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (BOOL)copyingEnabled {
    return [objc_getAssociatedObject(self, @selector(copyingEnabled)) boolValue];
}

- (void)setCopyingEnabled:(BOOL)copyingEnabled {
    if(self.copyingEnabled != copyingEnabled) {
        objc_setAssociatedObject(self, @selector(copyingEnabled), @(copyingEnabled), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

#pragma mark - Private Methods

- (void) setupGestureRecognizers
{
    // Remove gesture recognizer
    if(self.longPressGestureRecognizer) {
        [self removeGestureRecognizer:self.longPressGestureRecognizer];
        self.longPressGestureRecognizer = nil;
    }
    
    self.userInteractionEnabled = YES;
    // Enable gesture recognizer
    self.longPressGestureRecognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressGestureRecognized:)];
    [self addGestureRecognizer:self.longPressGestureRecognizer];
}

@end


