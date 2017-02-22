//
//  NoteViewController.h
//  Golf
//
//  Created by user on 12-12-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaseNavController.h"

@interface NoteViewController : BaseNavController<UITextViewDelegate>{
    UITextView *textView;
    BOOL _firstEdit;
}

@end
