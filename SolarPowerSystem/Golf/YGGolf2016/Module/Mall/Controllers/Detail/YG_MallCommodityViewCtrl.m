//
//  YG_MallCommodityViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/11/22.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YG_MallCommodityViewCtrl.h"
#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>

#import "WKDChatViewController.h"
#import "YGMallCommoditySpecViewCtrl.h"
#import "YGMallOrderViewCtrl.h"
#import "YGMallCommodityDetailCell.h"
#import "YGMallCommodityDetailDescView.h"
#import "YGMallCartViewCtrl.h"
#import "YGMallCommodityCommentsViewCtrl.h"
#import <PINCache/PINCache.h>
#import "SharePackage.h"

@interface YG_MallCommodityViewCtrl ()<UITableViewDelegate,UITableViewDataSource,DZNEmptyDataSetSource,DZNEmptyDataSetDelegate>

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *loadingIndicator;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet YGMallCommodityDetailDescView *webViewPanel;

@property (weak, nonatomic) IBOutlet UIView *buyPanel;
@property (weak, nonatomic) IBOutlet UIButton *serviceBtn;
@property (weak, nonatomic) IBOutlet UIButton *flashSaleBuyBtn;
@property (weak, nonatomic) IBOutlet UIButton *normalNoticeBtn;
@property (weak, nonatomic) IBOutlet UIButton *normalCartBtn;
@property (weak, nonatomic) IBOutlet UIButton *normalBuyBtn;

@property (weak, nonatomic) IBOutlet UILabel *noStockLabel;
@property (strong, nonatomic) CommodityInfoModel *cim;

@property (assign, nonatomic) BOOL loadingFlag;
@property (assign, nonatomic) BOOL emptyFlag;
@property (assign, nonatomic) BOOL cartFlag;

@property (strong, nonatomic) YGMallCommoditySpecViewCtrl *specViewCtrl;

@property (strong, nonatomic) SharePackage *share;

@end

@implementation YG_MallCommodityViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.baiduMobStatName = YGMallPage_CommodityDetail;
    [self loadData];
}

- (void)loadData
{
    [ServerService fetchMallCommodityDetail:self.cid callBack:^(CommodityInfoModel *obj) {
        if ([obj isKindOfClass:[CommodityInfoModel class]]) {
            self.cim = obj;
            self.specViewCtrl.commodity = obj;
            self.emptyFlag = NO;
            [SVProgressHUD dismiss];
        }else if ([obj isKindOfClass:[NSString class]]){
            self.emptyFlag = YES;
            [SVProgressHUD showErrorWithStatus:(NSString *)obj];
        }
        [self updateUI];
    } failure:^(id error) {
        [SVProgressHUD showErrorWithStatus:@"当前网络不可用"];
        self.emptyFlag = YES;
        [self updateUI];
    }];
}

- (void)updateUI
{
    [self.loadingIndicator stopAnimating];
    [self.tableView setHidden:NO animated:YES];
    [self updateBuyPanel];
    
    if (self.emptyFlag) {
        self.webViewPanel.hidden = YES;
        [self.tableView reloadEmptyDataSet];
    }else{
        self.webViewPanel.hidden = NO;
        ygweakify(self);
        self.webViewPanel.viewCtrl = self;
        [self.webViewPanel setUpdateCallback:^(CGFloat h) {
            ygstrongify(self);
            self.webViewPanel.height = h;
            self.tableView.tableFooterView = self.webViewPanel;
            [self.tableView reloadData];
        }];
        [self.webViewPanel configureWithCommodity:self.cim];
        [self.tableView reloadData];
    }
}

- (void)updateBuyPanel
{
    if (self.loadingFlag) {
        self.buyPanel.hidden = YES;
        return;
    }
    self.buyPanel.hidden = self.emptyFlag;
    
    BOOL noStock = self.cim.stockQuantity <= self.cim.soldQuantity;
    
    // 有抢购、抢购已开始、抢购有库存，三种条件同时满足时才显示抢购按钮。其他情况下显示购买按钮或者无货按钮
    BOOL auction = self.cim.flash_sale && [self.cim.flash_sale canAuction];
    
    if (auction) {
        
        //显示立即抢购
        self.normalBuyBtn.hidden = YES;
        self.normalCartBtn.hidden = YES;
        self.normalNoticeBtn.hidden = YES;
        self.flashSaleBuyBtn.hidden = NO;
        
    }else{
        
        if (noStock) {
            //无货
            self.normalBuyBtn.hidden = YES;
            self.normalCartBtn.hidden = YES;
            self.normalNoticeBtn.hidden = NO;
            self.flashSaleBuyBtn.hidden = YES;
            
            self.normalNoticeBtn.enabled = !self.cim.arrival_notice;
            
        }else{
            //有货
            self.normalBuyBtn.hidden = NO;
            self.normalCartBtn.hidden = NO;
            self.normalNoticeBtn.hidden = YES;
            self.flashSaleBuyBtn.hidden = YES;
        }
    }
    
    UIEdgeInsets insets = self.tableView.contentInset;
    insets.bottom = (!auction && noStock)?(48.f+24.f):48.f;
    self.tableView.contentInset = insets;
    UIEdgeInsets indicatorInsets = self.tableView.scrollIndicatorInsets;
    indicatorInsets.bottom = 48.f;
    self.tableView.scrollIndicatorInsets = indicatorInsets;
    self.noStockLabel.hidden = auction || !noStock;
}

#pragma mark - Actions

- (IBAction)shareAction:(UIButton *)item
{
    if ([LoginManager sharedManager].loginState) {
        if ([self needPerfectMemberData]) {
            return;
        }
    }
    [SVProgressHUD show];
    [[SDWebImageManager sharedManager] downloadImageWithURL:[NSURL URLWithString:self.cim.photoImage] options:SDWebImageContinueInBackground progress:NULL completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
        RunOnMainQueue(^{
            [SVProgressHUD dismiss];
            if (cacheType == SDImageCacheTypeNone || !image) {
                RunAfter(.2f, ^{
                    [self beginShare:image];
                });
            }else{
                [self beginShare:image];
            }
        });
    }];
}

- (IBAction)showCartAction:(UIButton *)item
{
    [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
        [self toCartViewCtrl];
    }];
}

- (IBAction)callService:(id)sender
{
    [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
        [self toChatViewController];
    }];
}

- (IBAction)buyAction:(UIButton *)btn
{
    if (self.cim.sellingStatus == 2) {
        [SVProgressHUD showErrorWithStatus:@"该商品已下架"];
        return;
    }
    
    if (btn == self.normalCartBtn) {
        self.cartFlag = YES;
        [self.specViewCtrl show:self.cim];
    }else if (btn == self.normalBuyBtn){
        //立即购买 在实际提交时确定是否登录
        self.cartFlag = NO;
        [self.specViewCtrl show:self.cim];
    }else if(btn == self.normalNoticeBtn){
        //设置到货提醒
        [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
            [self updateArrivalNotice];
        }];
    }else if (btn == self.flashSaleBuyBtn){
        //立即抢购 在实际提交时确定是否登录
        self.cartFlag = NO;
        [self.specViewCtrl show:self.cim];
    }
}

- (void)toChatViewController
{
    int memberId = [[GolfAppDelegate shareAppDelegate].systemParamInfo.kefuCommodity[@"memberid"] intValue];
    if (memberId > 0) {
        NSString *displayName = [GolfAppDelegate shareAppDelegate].systemParamInfo.kefuCommodity[@"display_name"];
        __weak typeof(self) weakSelf = self;
        WKDChatViewController *chatVC = [[WKDChatViewController alloc] init];
        chatVC.hidesBottomBarWhenPushed = YES;
        chatVC.title = displayName;
        chatVC.memId = memberId;
        chatVC.cim = weakSelf.cim;
        [[GolfAppDelegate shareAppDelegate].currentController.navigationController pushViewController:chatVC animated:YES];
    }
}

- (void)toCartViewCtrl
{
    NSArray *vcs = [self.navigationController viewControllers];
    YGMallCartViewCtrl *cartViewCtrl;
    for (__kindof UIViewController *vc in vcs) {
        if ([vc isKindOfClass:[YGMallCartViewCtrl class]]) {
            cartViewCtrl = vc;
            break;
        }
    }
    if (cartViewCtrl) {
        [cartViewCtrl reload];
        [self.navigationController popToViewController:cartViewCtrl animated:YES];
    }else{
        cartViewCtrl = [YGMallCartViewCtrl instanceFromStoryboard];
        [self.navigationController pushViewController:cartViewCtrl animated:YES];
    }
}

- (void)beginShare:(UIImage *)image
{
    if (!image) {
        image = [UIImage imageNamed:@"logo.png"];
    }
    NSString *url = [NSString stringWithFormat:@"%@club/commodityDetail.jsp?commodityId=%d&auctionId=%d",URL_SHARE,_cim.commodityId,_cim.auctionId];
    if (!self.share) {
        NSString *content = [NSString stringWithFormat:@"商品原价%d元，云高仅售%d元，赶快来看看吧！",self.cim.originalPrice,self.cim.sellingPrice];
        self.share = [[SharePackage alloc] initWithTitle:_cim.commodityName content:content img:image url:url];
    }
    [self.share shareInfoForView:self.view];
}

- (void)updateArrivalNotice
{
    NSString *token = [[PINCache sharedCache] objectForKey:WKDeviceTokenKey];
    if (token) {
        BOOL isAdd = !self.cim.arrival_notice;
        [SVProgressHUD show];
        [ServerService updateMallCommodityArrivalNotice:self.cim.commodityId type:0 addOpera:isAdd token:token callBack:^(id obj) {
            [SVProgressHUD showSuccessWithStatus:isAdd?@"设置成功，到货以后将会提醒您":@"已取消提醒"];
            [self loadData];
        } failure:^(id error) {
            [SVProgressHUD dismiss];
        }];
    }
}

#pragma mark - Spec
- (YGMallCommoditySpecViewCtrl *)specViewCtrl
{
    if (!_specViewCtrl) {
        ygweakify(self);
        YGMallCommoditySpecViewCtrl *vc = [YGMallCommoditySpecViewCtrl instanceFromStoryboard];
        [vc setSubmitBlock:^(CommoditySpecSKUModel *sku, NSInteger quantity) {
            ygstrongify(self);
            [self prepareBuy:sku quantity:quantity];
        }];
        [self.view addSubview:vc.view];
        [self addChildViewController:vc];
        _specViewCtrl = vc;
    }
    return _specViewCtrl;
}

- (void)prepareBuy:(CommoditySpecSKUModel *)sku quantity:(NSInteger)quantity
{
    [[LoginManager sharedManager] loginIfNeed:self doSomething:^(id data) {
        [self willBuy:sku quantity:quantity];
    }];
}

- (void)willBuy:(CommoditySpecSKUModel *)sku quantity:(NSInteger)quantity
{
    if (self.cartFlag) {
        //加入购物车
        // 新版的各字段取值
        NSString *cid = [NSString stringWithFormat:@"%d",self.cim.commodityId];
        NSString *specIds = [NSString stringWithFormat:@"%ld",(long)sku.skuId];
        NSString *quantities = [NSString stringWithFormat:@"%ld",(long)quantity];
        
        // 新版本中
        [ServerService shoppingCartMaintain:[[LoginManager sharedManager] getSessionId] operation:1 commodityIds:cid specIds:specIds quantitys:quantities success:^(NSArray *list) {
            if (list.count > 0) {
                [self didAddCommodityToCart];
            }
        } failure:^(id error) {
        }];
        YGPostBuriedPoint(YGMallPointAddToCart);
    }else{
        //直接购买
        [self.specViewCtrl dismiss];
        YGPostBuriedPoint(YGMallPointBuy);
        [self.cim skuDescTitle:sku];
        YGMallOrderModel *order = [YGMallOrderModel createOrderModelWithCommodity:self.cim sku:sku quantity:quantity];
        YGMallOrderViewCtrl *vc = [YGMallOrderViewCtrl instanceFromStoryboard];
        vc.order = order;
        [self.navigationController pushViewController:vc animated:YES];
    }
}

- (void)didAddCommodityToCart
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"NewCommodityJoinCartListNotification" object:@(_cim.commodityId)];
    [self.specViewCtrl dismiss];
    [self showAddToCartAnimation];
}

// 展示一个添加到购物车的动画
- (void)showAddToCartAnimation
{
    // 在屏幕底部中心创建一个ImageView
    UIImageView *animatedImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
    animatedImageView.center = CGPointMake(Device_Width/2, Device_Height-15.f);
    [animatedImageView sd_setImageWithURL:[NSURL URLWithString:self.cim.photoImage] placeholderImage:[UIImage imageNamed:@"cgit_s"]];
    [[UIApplication sharedApplication].keyWindow addSubview:animatedImageView];
    
    // 开始动画
    [Utilities mutablePathMoveAnimationWithStartPoint:animatedImageView.origin endPoint:CGPointMake(Device_Width-40, 25) controlPoint:CGPointMake(Device_Width/2.,64.f) view:animatedImageView duration:0.8 completion:^(BOOL finished) {
        [animatedImageView removeFromSuperview];
    }];
}

- (NSString *)identifierAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger section = indexPath.section;
    NSInteger row = indexPath.row;
    
    NSString *identifier;
    if (section == 0) {
        if (row == 0) {
            identifier = kYGMallCommodityDetailCell_Image;
        }else if (row == 1){
            identifier = kYGMallCommodityDetailCell_Name;
        }else if (row == 2){
            // 有抢购，此cell为额外信息cell，显示原价已售运费。无抢购，此cell为价格cell
            identifier = self.cim.flash_sale?kYGMallCommodityDetailCell_ExtraInfo:kYGMallCommodityDetailCell_Price;
        }else if (row == 3){
            identifier = self.cim.flash_sale?kYGMallCommodityDetailCell_FlashSale:kYGMallCommodityDetailCell_ExtraInfo;
        }else if (row == 4){
            identifier = kYGMallCommodityDetailCell_Yunbi;
        }
    }else if (section == 1){
        identifier = kYGMallCommodityDetailCell_Review;
    }else{
        identifier = kYGMallCommodityDetailCell_Notice;
    }
    return identifier;
}

#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (!self.cim || self.loadingFlag || self.emptyFlag) {
        return 0;
    }
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        BOOL showYunbi = self.cim.yunbi > 0;
        return showYunbi?5:4;
    }else if (section == 1){
        return 1;
    }else{
        return 2;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self identifierAtIndexPath:indexPath];
    YGMallCommodityDetailCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    cell.isBuyNote = indexPath.row==0;
    [cell configureWithCommodity:self.cim];
    
    ygweakify(self);
    [cell setShouldUpdateData:^{
        ygstrongify(self);
        [SVProgressHUD show];
        [self loadData];
    }];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *identifier = [self identifierAtIndexPath:indexPath];
    CGFloat h = [YGMallCommodityDetailCell cellHeightForIdentifier:identifier commodity:self.cim isBuyNote:indexPath.row==0];
    return h;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    if (section == 2) {
        return 0.f;
    }
    return 10.f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    NSString *identifier = [self identifierAtIndexPath:indexPath];
    if ([identifier isEqualToString:kYGMallCommodityDetailCell_Review]) {
        YGMallCommodityCommentsViewCtrl *vc = [YGMallCommodityCommentsViewCtrl instanceFromStoryboard];
        vc.commodityId = self.cim.commodityId;
        [self pushViewController:vc title:@"评价" hide:YES];
    }
}

#pragma mark - Empty

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView
{
    NSMutableAttributedString *text = [[NSMutableAttributedString alloc] initWithString:@"点击重新加载"];
    text.yy_font = [UIFont systemFontOfSize:12];
    text.yy_color = MainHighlightColor;
    return text;
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView
{
    return -64.f;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView
{
    return 20.f;
}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView
{
    return [UIImage imageNamed:@"img_none_wifi_gray"];
}

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView
{
    return self.emptyFlag;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view
{
    if (self.emptyFlag) {
        self.loadingFlag = YES;
        [self.loadingIndicator startAnimating];
        [self.buyPanel setHidden:YES animated:YES];
        [self loadData];
    }
}

@end
