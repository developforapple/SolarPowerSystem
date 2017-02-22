

#import "YGMallCommodityCell.h"

@implementation YGMallCommodityCell

- (void)awakeFromNib
{
    
    [super awakeFromNib];
//    CALayer *layer = [self.photoImageView layer];
//    layer.borderColor = [[Utilities R:224 G:224 B:224] CGColor];
//    layer.borderWidth = 0.5f;
    
    self.ruhsingImageView.hidden = YES;
    self.hengxianImgView.hidden = YES;
    self.photoImageView.image = [UIImage imageNamed:@"cgit_s.png"];
    self.photoImageView.hidden = YES;
    self.soldOverLabel.hidden = YES;
}

- (void)handleCellData{
    CGRect rt ;
    CGSize sz = [Utilities getSize:self.commodityNameLabel.text withFont:self.commodityNameLabel.font withWidth:self.commodityNameLabel.frame.size.width-2];
    if (sz.height>20) {
        rt = self.commodityNameLabel.frame;
        rt.size.height = 35;
        self.commodityNameLabel.frame = rt;
    }
    
    sz = [Utilities getSize:self.originalPriceLabel.text withFont:self.originalPriceLabel.font withWidth:self.originalPriceLabel.frame.size.width];
    rt = self.hengxianImgView.frame;
    rt.size.width = sz.width + 3;
    self.hengxianImgView.frame = rt;
    
    sz = [Utilities getSize:self.sellingPriceLabel.text withFont:self.sellingPriceLabel.font withWidth:self.sellingPriceLabel.frame.size.width];
    rt = self.soldOverLabel.frame;
    rt.origin.x = self.sellingPriceLabel.frame.origin.x + sz.width + 5;
    self.soldOverLabel.frame = rt;
    
    rt = self.yunbiLabel.frame;
    rt.origin.x = self.soldOverLabel.frame.origin.x;
    self.yunbiLabel.frame = rt;
    
    if (self.yunbiLabel.hidden == YES) {
        rt = self.freightLabel.frame;
        rt.origin.x = self.soldOverLabel.frame.origin.x + 5;
        self.freightLabel.frame = rt;
    }else{
        sz = [Utilities getSize:self.yunbiLabel.text withFont:self.yunbiLabel.font withWidth:self.yunbiLabel.frame.size.width];
        rt = self.freightLabel.frame;
        rt.origin.x = self.yunbiLabel.frame.origin.x + sz.width + 5;
        self.freightLabel.frame = rt;
    }
}

@end
