//
//  main.m
//  Golf
//
//  Created by Dejohn Dong on 11-11-14.
//  Copyright (c) 2011年 Achievo. All rights reserved.
//

#import <UIKit/UIKit.h>

//static NSUncaughtExceptionHandler *handler;
//
//static void myUncaughtExceptionHandler(NSException *ex){
//    if (handler) {
//        handler(ex);
//    }
//    
//    NSLog(@"");
//}

int main(int argc, char *argv[])
{
    @autoreleasepool {
        
//        handler = NSGetUncaughtExceptionHandler();
//        NSSetUncaughtExceptionHandler(&myUncaughtExceptionHandler);
        
        UIApplicationMain(argc, argv, nil, NSStringFromClass([GolfAppDelegate class]));
    }
}
