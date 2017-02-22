//
//  IndexViewController.h
//  Golf
//
//  Created by Main on 16/7/26.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IndexViewController : BaseNavController

- (void)locationToTeetimeMainVc:(NSString *)urlStr;

- (void)updateSearchKeywords:(NSString *)keywords;

@end
