//
//  Share.m
//  Eweek
//
//  Created by user on 13-9-17.
//  Copyright (c) 2013年 云高科技. All rights reserved.
//

#import "Share.h"

@implementation Share
@synthesize title = _title;
@synthesize content = _content;
@synthesize image = _image;
@synthesize url = _url;
@synthesize scene = _scene;


- (id)initWithTitle:(NSString*)aTitle content:(NSString*)aContent image:(UIImage*)aImage url:(NSString*)aUrl scene:(enum WXScene)aScene{
    if(self = [super init]){
        self.title = aTitle;
        self.content = aContent;
        self.image = [Utilities scaleToSize:aImage size:CGSizeMake(100, 100)];
        self.url = aUrl;
        self.scene = aScene;
    }
    return self;
}

- (BOOL) sendMsgToWX
{
    SendMessageToWXReq* req = [[SendMessageToWXReq alloc] init];
    if (_title.length >= 256) {
        _title = [_title substringToIndex:250];
        _title = [_title stringByAppendingString:@"..."];
    }
    if (_content.length >= 512) {
        _content = [_content substringToIndex:500];
        _content = [_content stringByAppendingString:@"..."];
    }
    BOOL isMedia = _title.length>0&&_url.length>0&&_content.length>0&&_image;
    if (isMedia) {
        WXMediaMessage *message = [WXMediaMessage message];
        if(_scene == WXSceneSession) {
            message.title = _title;
            message.description = _content;
        } else {
            if (_isSplit) {
                message.title = _content;
            }else{
                if ([_content isEqualToString:@" "]) {
                    message.title = _title;
                }else if ([_title isEqualToString:@" "]) {
                    message.title = _content;
                }else{
                    message.title = _title;// [NSString stringWithFormat:@"%@,%@",_title,_content];
                }
            }
            message.description = _content;
        }
        [message setThumbImage:_image];
        
        WXWebpageObject *ext = [WXWebpageObject object];
        ext.webpageUrl = _url;
        message.mediaObject = ext;
        
        req.bText = NO;
        req.message = message;
    }else{
        req.bText = YES;
        req.text = _content;
    }
    
    req.scene = _scene;
    
    NSUserDefaults *defaults=[NSUserDefaults standardUserDefaults];
    if (req.scene==0) {
        [defaults setInteger:1 forKey:@"reqScene"];
        
    }else if (req.scene==1){
        [defaults setInteger:2 forKey:@"reqScene"];
    }
    [defaults synchronize];
    
    if (self.type>0) {
        [GolfAppDelegate shareAppDelegate].type = self.type;
    }
    
    return [WXApi sendReq:req];
}

- (void)sendMsgToWB{
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:[self messageToShare]];
    [WeiboSDK sendRequest:request];
}

- (WBMessageObject *)messageToShare
{
    WBMessageObject *message = [WBMessageObject message];
    if (_title.length+_content.length+_url.length/2+4>=140) {
        NSInteger length=140-_title.length-_url.length/2-4;
        NSString *string=[_content substringToIndex:length];
        _content=[string stringByAppendingString:@"..."];
    }
    message.text = [NSString stringWithFormat:@"%@,%@.详情:%@",_title,_content,_url];
    if (!_title&&!_url) {
        message.text = _content;
    }
    if (_image) {
        WBImageObject *image = [WBImageObject object];
        image.imageData = UIImagePNGRepresentation(_image);
        message.imageObject = image;
    }
    
    return message;
}

@end
