//
//  YGInputViewCtrl.h
//  Golf
//
//  Created by Main on 2016/10/31.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGEmojiKeyboardViewCtrl.h"


@interface YGInputViewCtrl : YGEmojiKeyboardViewCtrl

@property (nonatomic,copy) NSString *defaultText;
@property (nonatomic) BOOL isTextField; //如果是单行文本框则==YES
@property (nonatomic,copy) NSString *placeHolderText;
@property (nonatomic,copy) BlockReturn blockReturn;

@end
