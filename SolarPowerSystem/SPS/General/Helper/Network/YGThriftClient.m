//
//  YGThriftClient.m
//  Golf
//
//  Created by wwwbbat on 16/5/27.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGThriftClient.h"
#import "YGCommon.h"
#import "AFNetworking.h"
#import "TTransportException.h"
#import "TObjective-C.h"

@implementation YGThriftClient

- (size_t)readAll:(uint8_t *)buf offset:(size_t)offset length:(size_t)length
{
    return [super readAll:buf offset:offset length:length];
}

- (void)write:(const uint8_t *)data offset:(size_t)offset length:(size_t)length
{
    [super write:data offset:offset length:length];
}

- (void)flush
{
    [super flush];
}

- (void)flush:(dispatch_block_t)flushed failure:(TAsyncFailureBlock)failure
{
    [mRequest setHTTPBody: mRequestData]; // not sure if it copies the data
    
    ygweakify(self);
    
    static AFURLSessionManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:nil];
    });

    NSURLSessionDataTask *task =
    [manager dataTaskWithRequest:mRequest uploadProgress:^(NSProgress *uploadProgress) {
        
        ygstrongify(self);
        if (self.requestProgress) {
            CGFloat p = uploadProgress.completedUnitCount/(double)uploadProgress.totalUnitCount;
            self.requestProgress(p);
        }
        
    } downloadProgress:^(NSProgress *downloadProgress) {
        
        ygstrongify(self);
        
        CGFloat completedCount = downloadProgress.completedUnitCount;
        CGFloat totalCount = downloadProgress.totalUnitCount;
        CGFloat p = completedCount/totalCount;
        
        if (self.responseProcess) {
            self.responseProcess(completedCount,totalCount);
        }
        if (self.responseProgress) {
            self.responseProgress(p);
        }
        
    } completionHandler:^(NSURLResponse *response, NSData *responseObject, NSError *error) {
        
        TTransportException *exception;
        
        if (error || !responseObject) {
            exception = [TTransportException exceptionWithName: @"TTransportException"
                                                        reason: @"Could not make HTTP request"
                                                         error: error];
        }else if (![response isKindOfClass: [NSHTTPURLResponse class]]) {
            exception = [TTransportException exceptionWithName: @"TTransportException"
                                                        reason: [NSString stringWithFormat: @"Unexpected NSURLResponse type: %@",NSStringFromClass([response class])]];
        }else {
            NSHTTPURLResponse * httpResponse = (NSHTTPURLResponse *) response;
            if ([httpResponse statusCode] != 200) {
                exception = [TTransportException exceptionWithName: @"TTransportException"
                                                            reason: [NSString stringWithFormat: @"Bad response from HTTP server: %ld",
                                                                (long)[httpResponse statusCode]]];
            }
        }
        
        if (exception) {
            if (failure) {
                failure(exception);
            }
        }else{
            [mResponseData release_stub];
            mResponseData = [responseObject retain_stub];
            mResponseDataOffset = 0;
            
            if (flushed) {
                flushed();
            }
        }
    }];
    self.task = task;
}

@end
