

#import "YGMallCartQuantityView.h"
#import "CCAlertView.h"

@interface YGMallCartQuantityView ()

@property (nonatomic,weak) IBOutlet UIButton *jianBtn;
@property (nonatomic,weak) IBOutlet UIButton *jiaBtn;
@property (nonatomic,weak) IBOutlet UILabel *quantityLabel;

@end

@implementation YGMallCartQuantityView

- (void)setCm:(CommodityModel *)cm{
    _cm = cm;
    if (_cm) {
        [_jiaBtn setImage:[UIImage imageNamed:@"sp_jia_0"] forState:UIControlStateSelected];
        [_jiaBtn setImage:[UIImage imageNamed:@"sp_jia_1"] forState:UIControlStateNormal];
        [_jianBtn setImage:[UIImage imageNamed:@"sp_jian_0"] forState:UIControlStateSelected];
        [_jianBtn setImage:[UIImage imageNamed:@"sp_jian_1"] forState:UIControlStateNormal];
        
        [self handleData];
    }
}

- (void)handleData{
    _jianBtn.enabled = NO;
    _jianBtn.selected = YES;
    _jiaBtn.enabled = NO;
    _jiaBtn.selected = YES;
    [_quantityLabel setText:[NSString stringWithFormat:@"%d",_cm.quantity]];
    // 可以买
    if ((_cm.buyLimit>0 ? MIN(_cm.remainQuantity, _cm.buyLimit) : _cm.remainQuantity) > 0) {
        if (_cm.quantity <= 0) {
            _jianBtn.enabled = NO;
            _jianBtn.selected = YES;
            _jiaBtn.enabled = YES;
            _jiaBtn.selected = NO;
        }else if (_cm.quantity >= (_cm.buyLimit>0 ? MIN(_cm.remainQuantity, _cm.buyLimit) : _cm.remainQuantity)||
                  (_cm.buyLimit>0&&_cm.totalQuantity>=_cm.buyLimit)){
            _jianBtn.enabled = YES;
            _jianBtn.selected = NO;
            _jiaBtn.enabled = NO;
            _jiaBtn.selected = YES;
        }else{
            _jianBtn.enabled = YES;
            _jianBtn.selected = NO;
            _jiaBtn.enabled = YES;
            _jiaBtn.selected = NO;
        }
        if (_cm.buyLimit > 0 && _cm.totalQuantity >= _cm.buyLimit){
            _jiaBtn.enabled = NO;
            _jiaBtn.selected = YES;
        }
    }
}

- (IBAction)buttonTap:(UIButton *)sender{
    NSInteger tag = sender.tag;
    if (tag == 2) { // 减
        if (_isMantainQuantity) {
            if (_cm.quantity == 1) {
                CCAlertView *alert = [[CCAlertView alloc] initWithTitle:nil message:@"确定移除该商品吗?"];
                [alert addButtonWithTitle:@"确定" block:^{
                    [self maintainWithOperation:tag commodityIds:[NSString stringWithFormat:@"%tu",_cm.commodityId] specIds:[NSString stringWithFormat:@"%d",_cm.specId] quantity:@"1"];
                }];
                [alert addButtonWithTitle:@"取消" block:^{}];
                [alert show];
                return;
            }
            [self maintainWithOperation:tag commodityIds:[NSString stringWithFormat:@"%tu",_cm.commodityId] specIds:[NSString stringWithFormat:@"%d",_cm.specId] quantity:@"1"];
        }else{
            _cm.quantity --;
            _cm.totalQuantity --;
            if (_refreshBlock) {
                _refreshBlock (@(_cm.totalQuantity));
            }
            [self handleData];
        }
    }else{ // 加
        if (_cm.buyLimit>0) {
            if (_cm.totalQuantity+1 >= _cm.buyLimit) {
                [SVProgressHUD showInfoWithStatus:[NSString stringWithFormat:@"已达上限,每人限购%d件",_cm.buyLimit]];
            }else if (_cm.quantity+1 >= (_cm.buyLimit>0 ? MIN(_cm.remainQuantity, _cm.buyLimit) : _cm.remainQuantity)){
                [SVProgressHUD showInfoWithStatus:@"商品数量已达库存上限"];
            }
        }else{
            if (_cm.quantity+1 >= _cm.remainQuantity) {
                [SVProgressHUD showInfoWithStatus:@"商品数量已达库存上限"];
            }
        }
        
        if (_isMantainQuantity) {
            [self maintainWithOperation:tag commodityIds:[NSString stringWithFormat:@"%tu",_cm.commodityId] specIds:[NSString stringWithFormat:@"%d",_cm.specId] quantity:@"1"];
        }else{
            _cm.quantity ++;
            _cm.totalQuantity ++;
            if (_refreshBlock) {
                _refreshBlock (@(_cm.totalQuantity));
            }
            [self handleData];
        }
    }
}

- (void)maintainWithOperation:(NSInteger)operation commodityIds:(NSString*)commodityIds specIds:(NSString *)specIds quantity:(NSString*)quantitys{
    [ServerService shoppingCartMaintain:[[LoginManager sharedManager] getSessionId] operation:operation commodityIds:commodityIds specIds:specIds quantitys:quantitys success:^(NSArray *list) {
        if (list.count>0) {
            if (_refreshBlock) {
                _refreshBlock (nil);
            }
        }
    } failure:^(id error) {
        
    }];
}

@end
