//
//  DDAssetsViewController.m
//  QuizUp
//
//  Created by Normal on 15/12/5.
//  Copyright © 2015年 Bo Wang. All rights reserved.
//

#import "DDAssetsViewController.h"
#import "DDAssetsInclude.h"
#import "DDAssetsCameraCell.h"
#import "DDAssetsCell.h"
#import "DDAssetsGroupViewController.h"
#import "DDAssetsDetailViewController.h"
#import "DDAssetsSendView.h"
#import "DDAssetsManager.h"
#import "UIScrollView+EmptyDataSet.h"

#define kDDAssetsGroupListSegueID @"DDAssetsGroupListSegueID"
#define kDDAssetsDetailSegueID @"DDAssetsDetailSegueID"
#define kDDAssetsDetailPreviewSegueID @"DDAssetsDetailPreviewSegueID"

@interface DDAssetsPicker ()
@end

@implementation DDAssetsPicker

+ (instancetype)instanceFromStoryboard
{
    UIStoryboard *sb = [UIStoryboard storyboardWithName:@"DDAssets" bundle:[NSBundle mainBundle]];
    DDAssetsPicker *picker = [sb instantiateViewControllerWithIdentifier:NSStringFromClass([self class])];
    [picker.navigationBar setBarTintColor:RGBColor(253, 103, 78, 1)];
    picker.autoCallbackWhenSelectedEnoughAssets = YES;
    picker.maxSelectCount = 0;
    picker.displayCamera = YES;
    picker.displayRealtimePicture = NO;
    picker.allowsEditingCameraImage = NO;
    return picker;
}

@end

@interface DDAssetsViewController : UIViewController <UICollectionViewDataSource,UICollectionViewDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *flowLayout;
@property (weak, nonatomic) IBOutlet UIView *groupListContainer;
@property (weak, nonatomic) DDAssetsGroupViewController *groupListVC;
@property (weak, nonatomic) IBOutlet UILabel *titleViewGroupLabel;
@property (weak, nonatomic) IBOutlet UIImageView *titleViewGroupIndicator;
@property (weak, nonatomic) IBOutlet UIView *bottomViewContainer;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *bottomViewHeightConstraint;
@property (weak, nonatomic) IBOutlet DDAssetsSendView *assetsSendView;

@property (getter=isLoading, nonatomic) BOOL loading;
@property (strong, nonatomic) DDAssetsManager *manager;
@property (weak, nonatomic) IBOutlet UIButton *btnPreview;

@end

@implementation DDAssetsViewController

- (void)dealloc
{
    [self.assetsSendView endMonitoring:self.manager];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self _initUI];
    [self _initSource];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationItem.rightBarButtonItem setTintColor:[UIColor whiteColor]];
}

- (IBAction)exit:(id)sender
{
    [[self assetsPicker] dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)preview:(id)sender
{
    if (self.manager.selectedAssets.count > 0) {
        [self performSegueWithIdentifier:kDDAssetsDetailPreviewSegueID sender:nil];
    }
}

- (void)next
{
    NSArray *assets = [self.manager selectedAssets];
    [self finishSelectAssets:assets];
}

- (IBAction)titleViewTapped:(id)sender
{
    BOOL isDisplay = self.groupListVC.isDisplayed;
    if (isDisplay) {
        [self.groupListVC setDisplay:NO];
    }else{
        self.groupListContainer.hidden = NO;
        [self.groupListVC setDisplay:YES];
    }
    [self _updateTitleIndicator];
}

- (void)finishSelectAssets:(NSArray *)assets
{
    DDAssetsPicker *picker = [self assetsPicker];
    if (picker.didSelectedAssetsBlock) {
        picker.didSelectedAssetsBlock(picker,assets);
    }else{
        [self exit:nil];
    }
}

#pragma mark - UI
- (DDAssetsPicker *)assetsPicker
{
    return (DDAssetsPicker *)self.navigationController;
}

- (void)_initUI
{
    self.groupListContainer.hidden = YES;
    self.titleViewGroupLabel.font = [UIFont systemFontOfSize:18];
    self.titleViewGroupLabel.textColor = [UIColor whiteColor];
    self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, self.bottomViewHeightConstraint.constant, 0);
    CGFloat w = (Device_Width-2*3)/4.f - 0.1f;
    self.flowLayout.itemSize = CGSizeMake(w, w);
    
    ddweakify(self);
    [self.assetsSendView setSendAction:^{
        ddstrongify(self);
        [self next];
    }];
}

- (void)_updateTitleView
{
    self.titleViewGroupLabel.text = [self.manager.curGroup groupTitle];
    self.titleViewGroupLabel.font = [UIFont systemFontOfSize:18];
    [self _updateTitleIndicator];
}

- (void)_setupGroupListVC
{
    ddweakify(self);
    [self.groupListVC setDidDisplayedBlock:^{
        ddstrongify(self);
        [self _updateTitleIndicator];
    }];
    [self.groupListVC setDidEndDisplayedBlock:^{
        ddstrongify(self);
        self.groupListContainer.hidden = YES;
        [self _updateTitleIndicator];
    }];
    [self.groupListVC setDidSelectedGroupBlock:^(id<DDGroupProtocol> group) {
        ddstrongify(self);
        self.manager.curGroup = group;
        [self _loadAssets];
        [self _updateTitleView];
    }];
}

- (void)_updateTitleIndicator
{
    BOOL isDisplay = self.groupListVC.isDisplayed;
    if (isDisplay) {
        [UIView animateWithDuration:0.2f animations:^{
            self.titleViewGroupIndicator.transform = CGAffineTransformMakeRotation(M_PI);
        }];
    }else{
        [UIView animateWithDuration:0.2f animations:^{
            self.titleViewGroupIndicator.transform = CGAffineTransformIdentity;
        }];
    }
}

#pragma mark - Assets
- (void)_initSource
{
    DDAssetsPicker *picker = [self assetsPicker];
    self.manager = [[DDAssetsManager alloc] initWithExistAssets:picker.existAssets maxCount:picker.maxSelectCount];
    [self.assetsSendView startMonitoringSelectedAssets:self.manager];
    [self _loadGroup];
}

- (void)_loadGroup
{
    self.loading = YES;
    
    ddweakify(self);
    [DDAssetsManager loadAssetsGroupType:self.manager.curGroupType completion:^(id group, NSError *error) {
        ddstrongify(self);
        if (group) {
            self.manager.curGroup = group;
            [self _updateTitleView];
            [self _loadAssets];
        }else{
            self.loading = NO;
            [self _updateEmptyNotice];
        }
    }];
}

- (void)_loadAssets
{
    self.loading = YES;
    ddweakify(self);
    [DDAssetsManager loadAssetsWithGroup:self.manager.curGroup completion:^(NSArray *assets) {
        ddstrongify(self);
        self.loading = NO;
        
        self.manager.curAssets = assets;
        [self.collectionView reloadData];
        [self _updateEmptyNotice];
    }];
}

- (DDAsset *)_assetAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    NSInteger row = indexPath.row;
    
    if (isDisplayCamera) {
        row--;
    }
    return self.manager.curAssets[row];
}

- (void)updateAsset:(id)asset select:(BOOL)isSelect
{
    [self.manager updateAsset:asset select:isSelect];
    
    NSInteger count = self.manager.selectedAssets.count;
    self.btnPreview.enabled = count > 0;
    NSInteger maxCount = [self assetsPicker].maxSelectCount;
    if (maxCount != 0 && count == maxCount && [self assetsPicker].autoCallbackWhenSelectedEnoughAssets) {
        [self next];    //自动返回
    }
}

#pragma mark - UICollectionView delegate
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if ([self _shouldShowNotice]) {
        return 0;
    }
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    NSInteger count = self.manager.curAssets.count;
    return isDisplayCamera?(++count):count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    if (isDisplayCamera && indexPath.row == 0) {
        DDAssetsCameraCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDDAssetsCameraCell forIndexPath:indexPath];
        return cell;
    }
    
    NSString *identifier = kDDAssetsCell;
    DDAssetsCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    cell.manager = self.manager;
    
    ddweakify(self);
    [cell setShouldSelectedAsset:^BOOL(DDAsset *asset) {
        // 将要选择这个asset时，判断是否应该选择
        ddstrongify(self);
        return [self.manager canSelectMoreAsset];
    }];
    [cell setAssetSelectedChanged:^(DDAsset *theAsset, BOOL isSelected) {
        ddstrongify(self);
        [self updateAsset:theAsset select:isSelected];
    }];
    [cell setAssetWillPreviewBlock:^(DDAsset *theAsset) {
        ddstrongify(self);
        NSInteger index = [self.manager indexOfAsset:theAsset];
        [self performSegueWithIdentifier:kDDAssetsDetailSegueID sender:@(index)];
    }];
    
    if (!iOS8) {
        [self collectionView:collectionView willDisplayCell:cell forItemAtIndexPath:indexPath];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    if (isDisplayCamera && indexPath.row == 0){
        [self showCamera];
    }
}

- (void)collectionView:(UICollectionView *)collectionView willDisplayCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell isKindOfClass:[DDAssetsCell class]]) {
        [(DDAssetsCell *)cell configureWithAsset:[self _assetAtIndexPath:indexPath]];
    }
    
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    BOOL isDisplayRealtimePicture = [self assetsPicker].isDisplayRealtimePicture;
    if (isDisplayCamera &&          //显示摄像头
        isDisplayRealtimePicture && //显示实时画面
        indexPath.row == 0) {       //当前为第一个cell
        DDAssetsCameraCell *theCell = (DDAssetsCameraCell *)cell;
        theCell.visible = YES;
    }
}

- (void)collectionView:(UICollectionView *)collectionView didEndDisplayingCell:(UICollectionViewCell *)cell forItemAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
    if (isDisplayCamera && indexPath.row == 0) {
        DDAssetsCameraCell *theCell = (DDAssetsCameraCell *)cell;
        theCell.visible = NO;
    }
}

#pragma mark - Empty data Notice
- (void)_updateEmptyNotice
{
    [self.collectionView reloadEmptyDataSet];
}

- (BOOL)_shouldShowNotice
{
    if (self.isLoading) {
        return NO;
    }
    BOOL shouldDisplay = [DDAssetsManager isPermissionDenied];
    if (!shouldDisplay) {
        BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
        shouldDisplay = !isDisplayCamera && self.manager.curAssets.count==0;
    }
    return shouldDisplay;
}

#pragma mark - Empty Data

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    if ([DDAssetsManager isPermissionDenied]) {
        NSAttributedString *title = [[NSAttributedString alloc] initWithString:@"没有权限访问您的相册"
                                                attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:18],
                                                             NSForegroundColorAttributeName:[UIColor whiteColor]}];
        return title;
    }
    return nil;
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView
{
    if ([DDAssetsManager isPermissionDenied]) {
        NSString *name = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSAttributedString *title =
        [[NSAttributedString alloc] initWithString:[NSString stringWithFormat:@"\n请前往系统设置 > 隐私 > 照片\n允许“%@”访问您的相册",name]
                                        attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14],
                                                     NSForegroundColorAttributeName:[UIColor whiteColor]}];
        return title;
    }
    return nil;
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return [self _shouldShowNotice];
}

#pragma mark - Segue
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    BOOL isPreview = [segue.identifier isEqualToString:kDDAssetsDetailPreviewSegueID];
    
    if ([segue.identifier isEqualToString:kDDAssetsGroupListSegueID]) {
        self.groupListVC = segue.destinationViewController;
        [self _setupGroupListVC];
    }else if ([segue.identifier isEqualToString:kDDAssetsDetailSegueID] ||
              isPreview){
        
        DDAssetsDetailViewController *vc = segue.destinationViewController;
        vc.manager = self.manager;
        vc.onlyDisplaySelectedAssets = isPreview;
        vc.firstDisplayedIndex = [sender integerValue];
        
        ddweakify(self);
        [vc setAssetSelectedChanged:^(DDAsset *theAsset, BOOL isSelected) {
            ddstrongify(self);
            [self updateAsset:theAsset select:isSelected];
            
            NSInteger idx = [self.manager indexOfAsset:theAsset];
            if (idx != NSNotFound) {
                BOOL isDisplayCamera = [self assetsPicker].isDisplayCamera;
                if (isDisplayCamera) {
                    idx++;
                }
                NSIndexPath *indexPath = [NSIndexPath indexPathForRow:idx inSection:0];
                [self.collectionView reloadItemsAtIndexPaths:@[indexPath]];
            }
        }];
        [vc setSendAction:^{
            ddstrongify(self);
            [self next];
        }];
    }
}

#pragma mark - Camera
- (void)showCamera
{
    BOOL available = [UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera];
    if (!available) {
        [SVProgressHUD showErrorWithStatus:@"相机不可用"];
        return;
    }
    
    [UIImagePickerController yg_setIgnored:YES];
    UIImagePickerController *picker = [[UIImagePickerController alloc] init];
    picker.sourceType = UIImagePickerControllerSourceTypeCamera;
    picker.delegate = self;
    picker.allowsEditing = [self assetsPicker].allowsEditingCameraImage;
    [self presentViewController:picker animated:YES completion:nil];
}

- (void)didSelectedCameraImage:(UIImage *)image
{
    if (image) {
        YYImage *yyimage = [[YYImage alloc] initWithCGImage:image.CGImage scale:image.scale orientation:image.imageOrientation];
        DDAsset *asset = [DDAsset assetWithImage:yyimage];
        [self.manager.selectedAssets addObject:asset];
        [self next];
    }
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    [UIImagePickerController yg_setIgnored:NO];
    UIImage *image;
    if ([self assetsPicker].allowsEditingCameraImage) {
        image = info[UIImagePickerControllerEditedImage];
    }else{
        image = info[UIImagePickerControllerOriginalImage];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
    [self didSelectedCameraImage:image];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [UIImagePickerController yg_setIgnored:NO];
    [picker dismissViewControllerAnimated:YES completion:nil];
}
@end

NSString *const kDDAssetsManagerSelectedAssetsCountChangedNotification = @"DDAssetsManagerSelectedAssetsCountChangedNotification";
