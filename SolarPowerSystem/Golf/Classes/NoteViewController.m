//
//  NoteViewController.m
//  Golf
//
//  Created by user on 12-12-19.
//  Copyright (c) 2012年 大展. All rights reserved.
//

#import "NoteViewController.h"
#import "Utilities.h"

@interface NoteViewController ()

@end

@implementation NoteViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor colorWithRed:241/255.0 green:240/255.0 blue:246/255.0 alpha:1.0];//lq 改
    self.view.clipsToBounds = YES;
    self.title = @"备注信息";
    
    _firstEdit = YES;
    
    [self rightButtonAction:@"确定"];
        
    UIImageView *bgImg = [[UIImageView alloc] initWithFrame:CGRectMake(10, 10+64.f, Device_Width-20, 165)];
    bgImg.image = [UIImage imageNamed:@"textview_frame.png"];
    [self.view addSubview:bgImg];
    
    textView = [[UITextView alloc] initWithFrame:CGRectMake(15, 15+64.f, Device_Width-30, 155)];
    textView.backgroundColor = [UIColor clearColor];
    textView.font = [UIFont systemFontOfSize:14];
    textView.text = @"如有特殊说明或要求，请填写...";
    textView.textColor = [Utilities R:97 G:97 B:97];
    textView.delegate = self;
    textView.returnKeyType = UIReturnKeyDone;
    [textView becomeFirstResponder];
    [self.view addSubview:textView];
    
    if ([[NSUserDefaults standardUserDefaults] objectForKey:@"SpecialNoteInformation"]) {
        textView.text = [[NSUserDefaults standardUserDefaults] objectForKey:@"SpecialNoteInformation"];
        _firstEdit = NO;
    }
}

- (BOOL)textView:(UITextView *)txtView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        [self doRightNavAction];
        return NO;
    }
    if(_firstEdit) {
        _firstEdit = NO;
        txtView.text = @"";
        txtView.textColor = [UIColor blackColor];
    }
    return YES;
}

- (void)doRightNavAction{
    if ([textView.text isEqualToString:@"如有特殊说明或要求，请填写..."]){
        textView.text = @"";
    }
    [[NSUserDefaults standardUserDefaults] setObject:textView.text forKey:@"SpecialNoteInformation"];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
