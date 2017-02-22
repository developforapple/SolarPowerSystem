//
//  YGUserPictureListViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/16.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGUserPictureListViewCtrl.h"
#import "YGUserPictureListCell.h"
#import "YGReorderableLayout.h"
#import "ImageBrowser.h"
#import "DDAssetsViewController.h"

static const NSInteger kPicturesPerRow = 3;

@interface YGUserPictureListViewCtrl () <YGReorderableLayoutDelegate,YGReorderableLayoutDataSource>
@property (weak, nonatomic) IBOutlet UIView *reorderTipView;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet YGReorderableLayout *flowLayout;

@property (strong, nonatomic) NSMutableArray *selectImgList;

@property (assign, nonatomic) NSInteger draggedIdx;

@end

@implementation YGUserPictureListViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.selectImgList = [NSMutableArray array];
    
    [self initUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    if (self.images.count == 0 && self.showAssetsPickerWithNoneImages) {
        [self showAssetsPicker];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    if (self.updateCallback) {
        self.updateCallback();
    }
}

- (void)initUI
{
    [self.reorderTipView layoutIfNeeded];
    CGFloat top = self.isMine?CGRectGetHeight(self.reorderTipView.bounds):0.f;
    CGFloat interitemSpacing = self.flowLayout.minimumInteritemSpacing;
    
    self.flowLayout.sectionInset = UIEdgeInsetsMake(top, 0, 0, 0);
    self.flowLayout.reorderingItemAlpha = .25f;
    self.flowLayout.dragEnabled = self.isMine;
    
    CGFloat itemW = (Device_Width - (kPicturesPerRow - 1) * interitemSpacing)/kPicturesPerRow;
    itemW = floor(itemW);
    self.flowLayout.itemSize = CGSizeMake(itemW, itemW);
    self.reorderTipView.hidden = !self.isMine;
    self.navigationItem.title = [NSString stringWithFormat:@"%lu张照片",(unsigned long)self.images.count];
}

- (void)showAssetsPicker
{
    ygweakify(self);
    DDAssetsPicker *picker = [DDAssetsPicker instanceFromStoryboard];
    picker.maxSelectCount = IS_iPod?3:9;
    [picker setDidSelectedAssetsBlock:^(DDAssetsPicker *thePicker, NSArray<DDAsset *> *assets) {
        ygstrongify(self);
        [thePicker dismissViewControllerAnimated:YES completion:nil];
        [self.selectImgList addObjectsFromArray:assets];
        [self.images insertObjects:assets atIndex:0];
        [self.collectionView reloadData];
        [self uploadPictures];
    }];
    [self presentViewController:picker animated:YES completion:nil];
}

#pragma mark - UICollectionView

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.images.count + (self.isMine?1:0);
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMine && indexPath.row == 0) {
        YGUserPictureListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGUserPictureListCellAdd forIndexPath:indexPath];
        return cell;
    }
    
    YGUserPictureListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kYGUserPictureListCell forIndexPath:indexPath];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(YGUserPictureListCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.isMine && indexPath.row == 0) return;
    
    id aImage = self.images[self.isMine?(indexPath.item-1):indexPath.item];
    [cell configureWithImage:aImage];
}

- (void)collectionView:(UICollectionView *)collectionView didMoveItemAtIndexPath:(NSIndexPath *)at toIndexPath:(NSIndexPath *)to
{
    NSInteger atIdx = self.isMine?at.item-1:at.item;
    NSInteger toIdx = self.isMine?to.item-1:to.item;
    
    id image = self.images[atIdx];
    [self.images removeObjectAtIndex:atIdx];
    [self.images insertObject:image atIndex:toIdx];
}

- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout didBeginDraggingItemAt:(NSIndexPath *)indexPath
{
    self.draggedIdx = self.isMine?indexPath.item-1:indexPath.item;
}

- (void)collectionView:(UICollectionView *)collectionView layout:(YGReorderableLayout *)layout willEndDraggingItemTo:(NSIndexPath *)indexPath
{
    NSInteger toIdx = self.isMine?indexPath.item-1:indexPath.item;
    
    [ServerService userEditAlbumWithSessionId:[LoginManager sharedManager].getSessionId imageData:nil imageDelete:nil currentPosition:self.draggedIdx newPosition:toIdx success:^(NSArray *list) {
    } failure:^(id error) {
    }];
}

- (BOOL)collectionView:(UICollectionView *)collectionView allowMoveItemAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isMine?(indexPath.item!=0):YES;
}

- (BOOL)collectionView:(UICollectionView *)collectionView canMoveItemAtIndexPath:(NSIndexPath *)at toIndexPath:(NSIndexPath *)to
{
    return self.isMine?(to.item!=0):YES;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    
    if (self.isMine && indexPath.item == 0) {
        [self showAssetsPicker];
        return;
    }
    
    UICollectionViewCell *cell = [collectionView cellForItemAtIndexPath:indexPath];
    CGRect rt = [cell.superview convertRect:cell.frame toView:self.view.window];
    NSInteger currentIndex = self.isMine?indexPath.item-1:indexPath.item;
    
    [ImageBrowser IBWithImages:self.images currentIndex:currentIndex initRt:rt isEdit:self.isMine highQuality:YES vc:self backRtBlock:^CGRect(NSInteger i) {
        UICollectionViewCell *c = [collectionView cellForItemAtIndexPath:[NSIndexPath indexPathForItem:(self.isMine?i+1:i) inSection:0]];
        return [c.superview convertRect:c.frame toView:[GolfAppDelegate shareAppDelegate].window];
    } blockDelete:^(NSDictionary *obj) {
        if (obj) {
            NSInteger index = [obj[@"index"] integerValue]; //删除图片的index
            NSString *url = [self.images objectAtIndex:index];
            
            [SVProgressHUD show];
            
            RunOnGlobalQueue(^{
                [ServerService userEditAlbumWithSessionId:[LoginManager sharedManager].getSessionId imageData:nil imageDelete:url currentPosition:0 newPosition:0 success:^(NSArray *list) {
                    NSDictionary *nd = list.firstObject;
                    if ([url isEqualToString:nd[@"image_delete"]]) {
                        [self.images removeObjectAtIndex:index];
                        
                        if (self.didDeletedPicture) {
                            self.didDeletedPicture(self.images);
                        }
                        
                        BlockReturn block = obj[@"block"];
                        block(nil);
                        BlockReturn removeBlock = obj[@"removeBlock"];
                        removeBlock(nil);
                        
                        RunAfter(.5f, ^{
                            [SVProgressHUD showSuccessWithStatus:@"图片已删除!"];
                            self.navigationItem.title = [NSString stringWithFormat:@"%tu张照片",self.images.count];
                        });
                    }
                    [self.collectionView reloadData];
                } failure:^(id error) {
                    RunAfter(.5f, ^{
                        [SVProgressHUD showErrorWithStatus:@"图片删除失败!"];
                    });
                }];
            });
        }
    }];
    
}

#pragma mark - Upload

- (void)uploadPictures{
    self.navigationItem.title = [NSString stringWithFormat:@"%tu张照片",self.images.count];
    
    [SVProgressHUD show];
    
    if (self.selectImgList.count == 1) {
        //上传单张图片
        
        __block UIImage *image;
        [[self.selectImgList firstObject] previewImage:^(UIImage *aImage) {
            image = aImage;
        }];
        NSString *imageData = [Utilities imageDataWithImage:image];
        [ServerService userEditAlbumWithSessionId:[LoginManager sharedManager].getSessionId imageData:imageData imageDelete:nil currentPosition:0 newPosition:0 success:^(NSArray *list) {
            NSDictionary *nd = list.firstObject;
            NSString *url = nd[@"image_add"];
            if (url) {
                [self.images removeObjectAtIndex:0];
                [self.images insertObject:url atIndex:0];
                [self.selectImgList removeAllObjects];
                RunAfter(.5f, ^{
                    [self.collectionView reloadData];
                });
                [SVProgressHUD showSuccessWithStatus:@"图片上传完成！"];
            }
        } failure:^(id error) {
            [SVProgressHUD showErrorWithStatus:@"图片上传失败！"];
            [self.selectImgList removeAllObjects];
        }];
        
    }else if (self.selectImgList.count > 1){
        //上传多张图片
        RunOnGlobalQueue(^{
            [ServerService initResourceWithSessionId:[LoginManager sharedManager].getSessionId dataType:@"member" dataId:self.memberId imageDataCount:(int)self.selectImgList.count videoDataCount:0 success:^(BaseService *BS) {
                if (BS.success) {
                    NSDictionary *nd = (NSDictionary *)BS.data;
                    int resId = [nd[@"res_id"] intValue];
                    if (resId > 0) {
                        __block int s = 0;
                        __block int e = 0;
                        
                        for (DDAsset *asset in self.selectImgList) {
                            NSUInteger idx = [self.selectImgList indexOfObject:asset];
                            
                            __block UIImage *image;
                            [asset previewImage:^(UIImage *theImage) {
                                image = theImage;
                            }];
                            
                            ygweakify(self);
                            [ServerService uploadResourceWithResId:resId partId:idx+1 partSize:0 resData:image success:^(id data) {
                                ygstrongify(self);
                                s++;
                                NSString *url = data[@"res_url"];
                                if (url) {
                                    [self.images replaceObjectAtIndex:[self.images indexOfObject:asset] withObject:url];
                                    RunOnMainQueue(^{
                                        [self.collectionView reloadData];
                                    });
                                }
                                if (s + e >=_selectImgList.count) {
                                    RunOnMainQueue(^{
                                        [SVProgressHUD showSuccessWithStatus:@"图片上传完成！"];
                                    });                                    
                                    [self.selectImgList removeAllObjects];
                                }
                            } failure:^(id error) {
                                e ++;
                            }];
                        }
                    }
                }
            } failure:^(id error) {
                RunOnMainQueue(^{
                    [SVProgressHUD showErrorWithStatus:@"图片上传失败！"];
                });
                [self.selectImgList removeAllObjects];
            }];
        });
    }
}

@end
