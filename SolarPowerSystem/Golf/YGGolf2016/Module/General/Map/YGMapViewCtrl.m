//
//  YGMapViewCtrl.m
//  Golf
//
//  Created by bo wang on 2016/12/20.
//  Copyright © 2016年 云高科技. All rights reserved.
//

#import "YGMapViewCtrl.h"
#import "ClubModel.h"
#import "YGMapAnnotation.h"
#import "YGThirdMapApp.h"
#import <MapKit/MapKit.h>

@interface YGMapViewCtrl () <MKMapViewDelegate>
@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (weak, nonatomic) IBOutlet UIButton *navigateBtn;

@property (weak, nonatomic) IBOutlet UIView *descPanel;
@property (weak, nonatomic) IBOutlet UIButton *descBtn;
@property (weak, nonatomic) IBOutlet UILabel *descLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *descBottomConstraint;

@property (strong, nonatomic) ClubModel *club;

@property (assign, nonatomic) BOOL singleClub;
@property (assign, nonatomic) BOOL descContentVisible;
@end

@implementation YGMapViewCtrl

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setupBestRegion];
    [self setupAnnotations];
    [self setupDescPanel];
    self.navigateBtn.hidden = !self.singleClub;
}

- (void)dealloc
{
    [_mapView removeFromSuperview];
    _mapView = nil;
}

- (void)setClubList:(NSArray<ClubModel *> *)clubList
{
    _clubList = clubList;
    self.singleClub = clubList.count == 1;
    self.club = [clubList firstObject];
}

#pragma mark - Region
- (void)setupBestRegion
{
    // 默认为整个中国地图
    CLLocationCoordinate2D center = CLLC2DMake(28.f, 104.f);
    MKCoordinateSpan span = MKCoordinateSpanMake(50.f, 62.f);
    MKCoordinateRegion region = MKCoordinateRegionMake(center, span);
    
    BOOL animated = NO;
    
    if (self.clubList.count > 1) {
        
        __block CLLocationCoordinate2D max = CLLC2DMake(0, 0);
        __block CLLocationCoordinate2D min = CLLC2DMake(CGFLOAT_MAX, CGFLOAT_MAX);
        CLLocationCoordinate2D mid = CLLC2DMake(0, 0);
        
        [self.clubList enumerateObjectsUsingBlock:^(ClubModel *obj, NSUInteger idx, BOOL *stop) {
            max.latitude = MAX(max.latitude, fabs(obj.latitude));
            max.longitude = MAX(max.longitude, fabs(obj.longitude));
            min.latitude = MIN(min.latitude, fabs(obj.latitude));
            min.longitude = MIN(min.longitude, fabs(obj.longitude));
        }];
        
        mid.latitude = (max.latitude + min.latitude)/2;
        mid.longitude = (max.longitude + min.longitude)/2;

        // 扩大1.5倍，使最边上的球场也能显示完全
        span.latitudeDelta = (max.latitude-min.latitude)*1.5f;
        span.longitudeDelta = (max.longitude-min.longitude)*1.5f;
        
        region.center = mid;
        region.span = span;
        
        animated = YES;
        
    }else if (self.club){
        center.latitude = fabs(self.club.latitude);
        center.longitude = fabs(self.club.longitude);
        // 单一球场时，调整地图范围为 5000米
        MKCoordinateRegion viewRegion = MKCoordinateRegionMakeWithDistance(center, 5000.f, 5000.f);
        region = [self.mapView regionThatFits:viewRegion];

        animated = NO;
    }
    
    [self.mapView setCenterCoordinate:center animated:animated];
    [self.mapView setRegion:region animated:animated];
}

- (void)setupAnnotations
{
    NSArray *annotations = [YGMapAnnotation annotations:self.clubList];
    [self.mapView removeAnnotations:self.mapView.annotations];
    [self.mapView addAnnotations:annotations];
}

- (MKAnnotationView *)annotationView:(YGMapAnnotation *)annotation
{
    static NSString *identifier = @"YGMapViewAnnotationViewIdentifier";
    MKAnnotationView *annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:identifier];
    
    if (self.singleClub) {
        annotationView.frame = CGRectMake(0, 0, 30, 30);
        annotationView.image = [UIImage imageNamed:@"pin_purple"];
    }else{
        ClubModel *club = annotation.club;
        NSString *title = [NSString stringWithFormat:@"%@¥%d",club.shortName,club.minPrice];
        annotationView.frame = CGRectMake(0, 0, 80, 14);
        annotationView.image = [UIImage imageNamed:@"blueboard"];
        
        UILabel *lblTitle = [annotationView viewWithTag:10086];
        if (!lblTitle) {
            lblTitle = [[UILabel alloc] initWithFrame:CGRectMake(0, 6, 80, 14)];
            lblTitle.textAlignment = NSTextAlignmentCenter;
            lblTitle.textColor = [UIColor whiteColor];
            lblTitle.font = [UIFont boldSystemFontOfSize:12];
            lblTitle.minimumScaleFactor = 10.f/12.f;
            [annotationView addSubview:lblTitle];
        }
        lblTitle.text = title;
    }

    UIButton *btn = (UIButton *)annotationView.rightCalloutAccessoryView;
    if (!btn || ![btn isKindOfClass:[UIButton class]]) {
        btn = [UIButton buttonWithType:UIButtonTypeInfoLight];
        [btn setImage:[UIImage imageNamed:@"push"] forState:UIControlStateNormal];
        annotationView.rightCalloutAccessoryView = btn;
    }
    annotationView.annotation = annotation;
    annotationView.canShowCallout = YES;
    return annotationView;
}

- (NSInteger)zoomLevel
{
    static CGFloat MERCATOR_RADIUS = 85445659.44705395f;
    return 21-round(log2(self.mapView.region.span.longitudeDelta * MERCATOR_RADIUS * M_PI / (180.0 * CGRectGetWidth(self.mapView.frame))));
}

#pragma mark - Desc Panel
- (void)setupDescPanel
{
    self.descLabel.text = self.club.trafficGuide;
    self.descPanel.hidden = self.club.trafficGuide.length == 0 || !self.singleClub;
    self.descContentVisible = YES;
}

- (void)setDescContentVisible:(BOOL)descContentVisible
{
    _descContentVisible = descContentVisible;
    [UIView animateWithDuration:.2f animations:^{
        self.descBtn.selected = !descContentVisible;
        self.descBottomConstraint.priority = descContentVisible?250:950;
        self.descLabel.hidden = !descContentVisible;
        [self.view layoutIfNeeded];
    }];
}

- (IBAction)descBtnAction:(UIButton *)btn
{
    self.descContentVisible = !self.descContentVisible;
}

#pragma mark - Actions
- (IBAction)goExit:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)startNavigate:(id)sender
{
    [self launchNavigate:(YGMapAnnotation *)[self.mapView.annotations firstObject]];
}

#pragma mark - MKKapViewDelegate

- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray<MKAnnotationView *> *)views
{
    if (self.clubList.count == 1) {
        [mapView selectAnnotation:[mapView.annotations firstObject] animated:YES];
    }
}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(YGMapAnnotation *)annotation
{
    return [self annotationView:annotation];
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    YGMapAnnotation *annotation = (YGMapAnnotation *)view.annotation;
    if (![annotation isKindOfClass:[YGMapAnnotation class]]) return;

    if (self.singleClub) {
        [self launchNavigate:annotation];
        [mapView selectAnnotation:view.annotation animated:NO];
    }else{
        if (self.didSelectedClub) {
            self.didSelectedClub(annotation.club);
        }
    }
}

- (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
//    NSInteger zoomLevel = [self zoomLevel];
    mapView.mapType = MKMapTypeStandard;
}

#pragma mark - Navigate
- (void)launchNavigate:(YGMapAnnotation *)annotation
{
    UIAlertController *sheet = [UIAlertController alertControllerWithTitle:@"选择地图App" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (YGThirdMapApp *app in [YGThirdMapApp defaultMapApps]) {
        if (app.installed) {
            [sheet addAction:[UIAlertAction actionWithTitle:app.name style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                [self callMapApp:app annotation:annotation];
            }]];
        }
    }
    [sheet addAction:[UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:sheet animated:YES completion:nil];
}

- (void)callMapApp:(YGThirdMapApp *)app annotation:(YGMapAnnotation *)annotation
{
    NSValue *v = [NSValue valueWithMKCoordinate:annotation.coordinate];
    NSDictionary *params = @{kYGThirdMapAppParamCoordinateKey:v,
                             kYGThirdMapAppParamAnnotationKey:annotation};
    BOOL suc = [app beginNavigate:params];
    if (!suc) {
        [SVProgressHUD showErrorWithStatus:@"启动失败"];
    }
}

@end
