//
//  YGShareViewCtrl.m
//  Golf
//
//  Created by bo wang on 16/5/30.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGShareViewCtrl.h"
#import "DDShareCommon.h"
#import "DDShareUnit.h"
#import "DDShareUnitCell.h"
#import "UIImage+ImageEffects.h"

#define kMaximumItemsPerLine 3

@interface YGShareViewCtrl ()
{
    BOOL _yungaoCommunityVisible;
    void (^_yungaoCommunityCallback)(void);
}
@property (weak, nonatomic) IBOutlet UIView *container;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *containerBottomConstraint;
  
@property (weak, nonatomic) IBOutlet UIImageView *blurImageView;
@property (strong, nonatomic) UIImage *blurImage;

// note
@property (weak, nonatomic) IBOutlet UIView *notePanel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *notePanelHeightConstraint;//note隐藏时为0，显示时根据noteContainer计算高度
@property (weak, nonatomic) IBOutlet UIView *noteContainer;      //note内部算高容器
@property (weak, nonatomic) IBOutlet UILabel *noteTitleLabel;    //标题
@property (weak, nonatomic) IBOutlet UILabel *noteDescLabel;     //note描述
@property (weak, nonatomic) IBOutlet UILabel *notePromptLabel;   //底部的提示

@property (weak, nonatomic) IBOutlet UIView *noteCoinPanel;      //显示云币icon
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteCoinHeightConstraint;//coin显示时为 27 隐藏时为0
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *noteCoinTopToDescConstraint;//coin和desc的约束。需要显示desc时优先级为 960 不需要显示desc时为 900
@property (weak, nonatomic) IBOutlet UILabel *noteCoinCountLabel;//云币数量

// 分享到云高社区动态
@property (weak, nonatomic) IBOutlet UIButton *yungaoCommunityBtn;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yungaoCommunityHeightConstrant; //显示时为44 隐藏时为0
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yungaoCommunityTopConstraint;   //显示时优先级960 隐藏时优先级900

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *collectionViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UICollectionViewFlowLayout *layout;
@property (weak, nonatomic) IBOutlet UIButton *cancelBtn;
@end

@implementation YGShareViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupUI];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self setContainerHidden:NO];
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    self.collectionViewHeightConstraint.constant = self.collectionView.contentSize.height;
}

- (void)setYungaoCommunityVisible:(BOOL)yungaoCommunityVisible callback:(void (^)(void))callback
{
    _yungaoCommunityVisible = yungaoCommunityVisible;
    _yungaoCommunityCallback = [callback copy];
}

#pragma mark - UI
- (void)setBlurReferView:(__weak UIView *)view
{
    UIImage *image = [UIImage convertViewToImage:view];
    self.blurImage = [image applyBlurWithRadius:2.f tintColor:RGBColor(150, 150, 150, .2f) saturationDeltaFactor:1.f maskImage:nil];
}

- (void)setupUI
{
    [self.view layoutIfNeeded];
    self.blurImageView.image = self.blurImage;
    
    self.container.layer.shadowColor = [UIColor darkGrayColor].CGColor;
    self.container.layer.shadowRadius = 4.f;
    self.container.layer.shadowOffset = CGSizeMake(0, -1);
    self.container.layer.shadowOpacity = .4f;
    
    self.cancelBtn.layer.masksToBounds = YES;
    self.cancelBtn.layer.cornerRadius = 4.f;
    
    self.blurImageView.userInteractionEnabled = YES;
    [self.blurImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(cancel:)]];
    
    CGFloat itemWidth = self.layout.itemSize.width;
    CGFloat spacing = (Device_Width-kMaximumItemsPerLine*itemWidth)/(kMaximumItemsPerLine+1);
    UIEdgeInsets sectionInset = self.layout.sectionInset;
    sectionInset.left = (int)spacing;
    sectionInset.right = (int)spacing;
    self.layout.sectionInset = sectionInset;
    self.layout.minimumInteritemSpacing = (int)spacing;
}

- (IBAction)cancel:(id)sender
{
    [self setContainerHidden:YES];
}

- (IBAction)yungaoCommunityAction:(UIButton *)sender
{
    [self setContainerHidden:YES];
    if (_yungaoCommunityCallback) {
        _yungaoCommunityCallback();
    }
}
#pragma mark - Animation
- (void)setContainerHidden:(BOOL)hidden
{
    if (hidden) {
        [UIView animateWithDuration:.2f animations:^{
            self.containerBottomConstraint.constant = -CGRectGetHeight(self.container.frame);
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            [self dismiss];
        }];
    }else{
        BOOL noteVisible = self.noteInfo != nil;
        self.notePanel.hidden = !noteVisible;
        if (noteVisible) {
            self.noteTitleLabel.text = self.noteInfo.title;
            self.noteDescLabel.attributedText = self.noteInfo.attributedDesc;
            self.notePromptLabel.text = self.noteInfo.prompt;
            
            [self.noteDescLabel sizeToFit];
            
            BOOL coinsVisible = self.noteInfo.coins!=0;
            self.noteCoinPanel.hidden = !coinsVisible;
            self.noteCoinHeightConstraint.constant = coinsVisible?27.f:0.f;
            self.noteCoinCountLabel.text = [NSString stringWithFormat:@"x %lu",(unsigned long)self.noteInfo.coins];
            
            BOOL descVisible = self.noteInfo.attributedDesc != nil;
            self.noteDescLabel.hidden = !descVisible;
            self.noteCoinTopToDescConstraint.priority = descVisible?960:900;
            
            CGFloat noteHeight = [self.noteContainer systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height;
            self.notePanelHeightConstraint.constant = ceilf(noteHeight);
        }else{
            self.notePanelHeightConstraint.constant = 0.f;
        }
        
        self.yungaoCommunityBtn.hidden = !_yungaoCommunityVisible;
        self.yungaoCommunityHeightConstrant.constant = _yungaoCommunityVisible?44.f:0.f;
        self.yungaoCommunityTopConstraint.priority = _yungaoCommunityVisible?960:900;
        
        [UIView animateWithDuration:.4f delay:0.f usingSpringWithDamping:.8f initialSpringVelocity:1.5f options:UIViewAnimationOptionCurveEaseInOut animations:^{
            self.containerBottomConstraint.constant = 0.f;
            [self.view layoutIfNeeded];
        } completion:^(BOOL finished) {
            
        }];
    }
}

#pragma mark - UICollectionView
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.shareUnits.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDShareUnitCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:kDDShareUnitCell forIndexPath:indexPath];
    DDShareUnit *unit = self.shareUnits[indexPath.row];
    cell.imageView.image = unit.image;
    cell.titleLabel.text = unit.title;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    DDShareUnit *unit = self.shareUnits[indexPath.row];
    if (unit.callback) {
        unit.callback();
    }
    [self setContainerHidden:YES];
}

@end
