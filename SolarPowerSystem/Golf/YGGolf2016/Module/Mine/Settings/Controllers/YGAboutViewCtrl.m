//
//  YGAboutViewCtrl.m
//  Golf
//
//  Created by User on 11-12-5.
//  Copyright 2011 大展. All rights reserved.
//

#import "YGAboutViewCtrl.h"
#import "GolfService.h"
#import "Utilities.h"
#import "IMLog.h"

@interface YGAboutViewCtrl()

@property (weak, nonatomic) IBOutlet UILabel *labelVersion;


@end

@implementation YGAboutViewCtrl

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于云高高尔夫";
    self.labelVersion.text = [NSString stringWithFormat:@"版本 %@",[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]];
}

- (IBAction)uploadLog:(id)sender {
    
    
    LogFileBean *bean = [[LogFileBean alloc] init];
    bean.files = [[NSMutableDictionary alloc] init];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentDirectory = [paths objectAtIndex:0];
    
    NSFileManager *manager = [NSFileManager defaultManager];
    // 路径下的所有文件名
    
    NSArray *filePathArr = [manager contentsOfDirectoryAtPath:[NSString stringWithFormat:@"%@/",documentDirectory] error:nil];
    NSLog(@"arr = %@",filePathArr);
    for (NSString *file in filePathArr) {
        if ([file rangeOfString:@"log_"].location != NSNotFound) {
            [bean.files setObject:[NSData dataWithContentsOfFile:[NSString stringWithFormat:@"%@/%@",documentDirectory,file]] forKey:file];
        }
    }
    
   
    [SVProgressHUD show];
    
    if (bean.files.count > 0) {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            [[API shareInstance] uploadLogFileBean:bean success:^(AckBean *data) {
                if (data.success) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showSuccessWithStatus:@"日志上报成功，非常感谢您对云高的支持！"];
                    });
                }else{
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [SVProgressHUD showErrorWithStatus:@"抱歉，日志上报失败！"];
                    });
                }
            } failure:^(Error *error) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    [SVProgressHUD showErrorWithStatus:[NSString stringWithFormat:@"抱歉，日志上报失败！%@",error.errorMsg]];
                });
            }];
        });
    }else{
        [SVProgressHUD showInfoWithStatus:@"本地没有日志，请重新登录app"];
    }
    
        
        
        
            
        
        
        
    
    
    
}


@end
