//
//  ViewController.m
//  MyMap
//
//  Created by jewelz on 15/6/19.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "ViewController.h"
#import "MyLocationViewController.h"
#import "MenuView.h"
#import "HUSearchViewController.h"
#import "BMKReverseGeoCodeResult+Extention.h"
#import "DocumentTool.h"
#import "HUSavedLocationViewController.h"
#import "HUAlertView.h"

static const CGFloat kMenuGroupPadding = 2;
static const CGFloat kMenuGroupHeight = 90;
static const CGFloat kMenuGroupWidth = 35;
static const CGFloat kSearchBarWidth = 240;

@interface ViewController () <BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate, BMKSuggestionSearchDelegate, MenuViewDelegate, UISearchBarDelegate, HUSearchViewdelegate> {
    BMKLocationService *_locService;
    BMKSuggestionSearch *_suggestionSearch;
    CLLocationCoordinate2D _currentLocation, _myLocation;
    BOOL _isUpdating;
    HUSearchViewController *_searchVc;
    BMKReverseGeoCodeResult *_currentCodeResult, *_myCodeResult;
    
}
@property (strong, nonatomic) BMKMapView *mapView;
@property (strong, nonatomic) BMKGeoCodeSearch *geocodesearch;
@property (strong, nonatomic) UIView *menuButtomGroup;
@property (strong, nonatomic) MenuView *menu;
@property (weak, nonatomic) UISearchBar *searchBar;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    [self setUpNavigationBar];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    self.view = _mapView;
    _mapView.showsUserLocation = YES;
    _mapView.mapType = BMKMapTypeSatellite;
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;//设置定位的状态
    _mapView.zoomLevel = 19;
    //_mapView.compassPosition = CGPointMake(self.view.frame.size.width-40, 40);
    
     _geocodesearch = [[BMKGeoCodeSearch alloc] init];
    
    //设置定位精确度，默认：kCLLocationAccuracyBest
    [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
    //指定最小距离更新(米)，默认：kCLDistanceFilterNone
    [BMKLocationService setLocationDistanceFilter:100.f];
    
    //初始化BMKLocationService
    _locService = [[BMKLocationService alloc]init];
    
    //启动LocationService
    [_locService startUserLocationService];
    _isUpdating = YES;
    
    
}

- (void)viewDidAppear:(BOOL)animated {
    
    UIWindow *window = [[UIApplication sharedApplication].windows firstObject];
    [window addSubview:self.menuButtomGroup];
    
    [super viewDidAppear:YES];
}

- (void)viewWillAppear:(BOOL)animated
{
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
   
    
   
    
    self.navigationController.navigationBarHidden = YES;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(mapViewDidReloadLocationNotification:) name:MapViewDidReloadLocationNotification object:nil];
   
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
    if (_suggestionSearch) {
        _suggestionSearch.delegate = nil;
    }
}


#pragma mark BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    if (!_isUpdating) return;
    
    //[self showAlertViewWithMesg:@"didUpdateUserHeading"];
    
    [_mapView updateLocationData:userLocation];
    NSLog(@"didUpdateUserHeading -- latitude: %f, longitude: %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    _isUpdating = NO;
}
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    
    
   //NSString *msg = [NSString stringWithFormat:@"经度%f:, 纬度:%f", userLocation.location.coordinate.longitude,userLocation.location.coordinate.latitude];
    //[self showAlertViewWithMesg:msg];
    
    _currentLocation = userLocation.location.coordinate;
    _myLocation = userLocation.location.coordinate;
    _myCodeResult = [BMKReverseGeoCodeResult reverseGeoCodeResultWithCoordinate:_myLocation andAddress:nil];
    
    [_mapView updateLocationData:userLocation];
    
    NSLog(@"didUpdateBMKUserLocation -- latitude: %f, longitude: %f",_currentLocation.latitude, _currentLocation.longitude);
    
    if (!_isUpdating) return;
    [self reverseGeocodeWithCoordinate:_currentLocation];
    
    _isUpdating = NO;
    
}

#pragma mark bmkmapview delegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
   static NSString *AnnotationViewID = @"AnnotationJewelz";
    // 检查是否有重用的缓存
    BMKAnnotationView* annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    
    if (!annotationView) {
         if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
            annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
            ((BMKPinAnnotationView *)annotationView).pinColor = BMKPinAnnotationColorPurple;
            ((BMKPinAnnotationView *)annotationView).animatesDrop = YES;// 设置该标注点动画显示
              annotationView.annotation = annotation;
         }
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡,弹出泡泡前提 annotation 必须实现 title 属性 annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
   
    return annotationView;;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"coordinate:%f", coordinate.latitude);
    [self didShowNavigationBarAnimated];
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"%mapoi:%@", mapPoi);
    [self didShowNavigationBarAnimated];
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
 
    if (!_currentCodeResult) return;
        
    MyLocationViewController *locaVc = [[MyLocationViewController alloc] init];

    locaVc.data = @{@"latitude":@(_currentCodeResult.location.latitude),@"longitude":@(_currentCodeResult.location.longitude), @"address":_currentCodeResult.address};
     [self.navigationController pushViewController:locaVc animated:YES];

    
    [self.menuButtomGroup removeFromSuperview];
    
}

#pragma mark BMKGeoCodeSearchDelegate
#pragma mark - 正向地理编码 获取结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"正向地理编码 获取结果: %@", result.address);
    if (error == 0) {
        _currentLocation = result.location;
        
        [self reverseGeocodeWithCoordinate:_currentLocation];
        [self addPointAnnotationWithCoordinate:result.location andTitle:result.address];
        
    } else {
        [self showAlertViewWithMesg:@"无法获取位置信息"];
    }
}

#pragma mark - 反向地理编码 获取结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"反向地理编码 获取结果");
    if (error == 0) {
        if (!_myCodeResult.address) {
            _myCodeResult.address = result.address;
            _currentCodeResult = _myCodeResult;
        } else {
            _currentCodeResult = result;
        }
       //[self showAlertViewWithMesg:[NSString stringWithFormat:@"位置：%@",result.address]];
        
        //_address = result.address;
        NSLog(@"address: %@", _currentCodeResult.address);
    } else {
        [self showAlertViewWithMesg:@"无法获取位置信息"];
    }
    
}

#pragma mark - BMKSuggestionSearchDelegate
- (void)onGetSuggestionResult:(BMKSuggestionSearch *)searcher result:(BMKSuggestionResult *)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        _searchVc.data = result.keyList;
        [_searchVc reloadData];
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}

#pragma mark UISearchBarDelegate

- (void)searchBarTextDidBeginEditing:(UISearchBar *)searchBar {
    NSLog(@"searchBarTextDidBeginEditing");
    
    _searchVc = [[HUSearchViewController alloc] init];
    _searchVc.view.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, self.view.frame.size.height-64);
    _searchVc.delegate = self;
    [[[UIApplication sharedApplication].windows firstObject] addSubview:_searchVc.view];
    
    [UIView animateWithDuration:0.4 animations:^{
        _searchVc.view.frame = CGRectMake(0, 64, self.view.frame.size.width, self.view.frame.size.height-64);
        self.navigationItem.rightBarButtonItem = nil;
        
    } completion:^(BOOL finished) {
        [searchBar sizeToFit];
        [searchBar setShowsCancelButton:YES];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyBoardWillHidden:) name:UIKeyboardWillHideNotification object:nil];

}

- (void)keyBoardWillHidden:(NSNotification *)notification {
    //[_searchBar setShowsCancelButton:NO];
    if (_searchBar.text.length > 0) return;
    [self searchBarCancelButtonClicked:_searchBar];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {

    [self suggestionSearchWithCity:@"" andKeyWord:searchText];
    
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar {
    
    NSLog(@"searchBarSearchButtonClicked");
    [self geocode:searchBar.text withCity:@""];
    
    [self searchBarCancelButtonClicked:searchBar];
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar {
    NSLog(@"searchBarCancelButtonClicked");
    
    [UIView animateWithDuration:0.5 animations:^{
        [_searchVc.view removeFromSuperview];
    } completion:^(BOOL finished) {
        [_searchBar resignFirstResponder];
        _searchBar.text = @"";
        [_searchVc removeFromParentViewController];
        _searchVc = nil;
        [_searchBar setShowsCancelButton:NO];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showMyLocations)];
        [_searchBar sizeToFit];
    }];
    
}

#pragma mark - HUSearchViewdelegate 
- (void)didSelectRowAtIndex:(NSInteger)index withData:(NSString *)data{     //定位到选择的位置
    
    [self geocode:data withCity:@""];
    [self searchBarCancelButtonClicked:_searchBar];
}


#pragma mark MenuViewDelegate
- (void)menuView:(MenuView *)menuView selectedSegmentAtIndex:(NSInteger)index {
    
    _mapView.rotation = 0;
    _mapView.overlooking = 0;
    
    switch (index) {
        case 0:
             _mapView.mapType = BMKMapTypeStandard;
            break;
            
        case 1:
            _mapView.mapType = BMKMapTypeSatellite;
            break;
            
        case 2:
            _mapView.rotation = 90;
            _mapView.overlooking = -45;
            break;
            
        default:
            break;
            
    }
            
}

- (void)clickMenuButton:(UIButton *)sender {    //弹出视图按钮点击
    if (sender.tag == 1) {  //收藏地点
         NSDictionary *dict = @{@"latitude":@(_currentCodeResult.location.latitude),@"longitude":@(_currentCodeResult.location.longitude), @"address":_currentCodeResult.address};
        
        BOOL flag = [[DocumentTool sharedDocumentTool] write:dict ToFileWithFileName:FileName];
        if (flag) {
            [[[HUAlertView alloc] initWithTitle:@"添加收藏成功!"] show];
        }
    } else {    //添加大头针
        [self addPointAnnotationWithCoordinate:_currentCodeResult.location andTitle:_currentCodeResult.address];
    }
   
    
}

- (void)didCancleButtonClicked {    //关闭弹出视图

    [UIView animateWithDuration:0.4 animations:^{
        CGRect tmp = _menu.frame;
        tmp.origin.y = self.view.frame.size.height;
        _menu.frame = tmp;
    } completion:^(BOOL finished) {
        [_menu removeFromSuperview];
        //_menu = nil;
    }];
}

#pragma mark - Myself function
#pragma mark -- 正向地理编码
- (void)geocode:(NSString *)address withCity:(NSString *)city {

    BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc] init];
    option.address = address;
    option.city = city;
    BOOL flag = [_geocodesearch geoCode:option];
    
    if (flag) {
        NSLog(@"ReverseGeocode search success.");
    }
    else { 
        //启动LocationService
        //[_locService startUserLocationService];
       // _isUpdating = YES;
        [self showAlertViewWithMesg:@"没有找到您想去的位置"];
       
    }
    
}

#pragma mark -- 反向地理编码
- (void)reverseGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate {
    NSLog(@"反向地理编码");
    
    CLLocationCoordinate2D pt = coordinate;
    BMKReverseGeoCodeOption *option = [[BMKReverseGeoCodeOption alloc] init];
    option.reverseGeoPoint = pt;
    BOOL flag = [_geocodesearch reverseGeoCode:option];
    if (flag) {
        NSLog(@"ReverseGeocode search success.");
    }
    else{
        NSLog(@"ReverseGeocode search failed!");
        [self showAlertViewWithMesg:@"无法获取当前位置"];
    }

}

#pragma mark -- 建议检索
- (void)suggestionSearchWithCity:(NSString *)city andKeyWord:(NSString *)keyWord {
    _suggestionSearch = [[BMKSuggestionSearch alloc] init];
    _suggestionSearch.delegate = self;
    
    BMKSuggestionSearchOption *option = [[BMKSuggestionSearchOption alloc] init];
    option.cityname = city;
    option.keyword = keyWord;
    
    BOOL flag = [_suggestionSearch suggestionSearch:option];

    if(flag)
    {
        NSLog(@"建议检索发送成功");
    }
    else
    {
        NSLog(@"建议检索发送失败");
    }
    
    
}


#pragma mark -- 添加annotation
- (void)addPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title {
    // 清除屏幕中所有的 annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
    [_mapView removeAnnotations:array];
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coordinate;
    annotation.title = title;
    
    _mapView.centerCoordinate = coordinate;
    
    [_mapView addAnnotation:annotation];
}

- (void)didShowNavigationBarAnimated {
    
    [self didCancleButtonClicked];  //关闭弹出视图
    if (self.navigationController.navigationBarHidden) {
        [self.navigationController setNavigationBarHidden:NO animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    } else {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
    }
}


- (MenuView *)menu {
    
    if (!_menu) {
        _menu = [MenuView menuView];
        _menu.frame = CGRectMake(0, self.view.frame.size.height, self.view.frame.size.width, kViewHeight);
        _menu.delegate = self;
        [_menu addTarget:self action:@selector(clickMenuButton:)];
    }
    return _menu;
    
}

- (void)setUpNavigationBar {
    UIView *titleView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, 44)];
    //titleView.backgroundColor = [UIColor redColor];
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, kSearchBarWidth, 44)];
    searchBar.placeholder = @"输入您要搜索的位置";
    [searchBar setShowsCancelButton:NO];
    searchBar.barTintColor = [UIColor colorWithPatternImage:[self imageWithColor:[UIColor clearColor]]];
    searchBar.delegate = self;
    self.searchBar = searchBar;
    
    [titleView addSubview:searchBar];
    
    self.navigationItem.titleView = titleView;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showMyLocations)];
}

#pragma mark -- 我的收藏按钮
- (void)showMyLocations {
    
    [self.menuButtomGroup removeFromSuperview];
    
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    HUSavedLocationViewController *saveLVc = [[HUSavedLocationViewController alloc] init];
    
    [self.navigationController pushViewController:saveLVc animated:YES];

}

- (void)menuButtonClicked {

    [UIView animateWithDuration:0.4 animations:^{
        CGRect tmp = self.menu.frame;
        tmp.origin.y = self.view.frame.size.height-kViewHeight;
        self.menu.frame = tmp;
        
        [[[UIApplication sharedApplication].windows lastObject] addSubview:self.menu];
        
    } completion:^(BOOL finished) {
        //[self.menuButtom removeFromSuperview];
    }];

}

- (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

- (UIView *)menuButtomGroup {
    if (!_menuButtomGroup) {
        
        _menuButtomGroup = [[UIView alloc] initWithFrame:CGRectMake(5, self.view.frame.size.height-kMenuGroupHeight-6, kMenuGroupWidth, kMenuGroupHeight)];
        _menuButtomGroup.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.0];
        _menuButtomGroup.layer.cornerRadius = 4;
        _menuButtomGroup.layer.masksToBounds = YES;
        
        UIButton *locateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        locateBtn.frame = CGRectMake(0, 0, kMenuGroupWidth, kMenuGroupWidth);
        locateBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        locateBtn.layer.cornerRadius = kMenuGroupWidth * 0.1;
        [locateBtn setImage:[UIImage imageNamed:@"icon_locate"] forState:UIControlStateNormal];
        [locateBtn addTarget:self action:@selector(locatedAtMyLocation) forControlEvents:UIControlEventTouchUpInside];
        [_menuButtomGroup addSubview:locateBtn];
        
        UIButton *moreBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        moreBtn.frame = CGRectMake(0, locateBtn.frame.size.height+kMenuGroupPadding, kMenuGroupWidth, kMenuGroupWidth);
        moreBtn.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.7];
        moreBtn.layer.cornerRadius = kMenuGroupWidth * 0.1;
        [moreBtn setImage:[UIImage imageNamed:@"icon_more"] forState:UIControlStateNormal];
        [moreBtn addTarget:self action:@selector(menuButtonClicked) forControlEvents:UIControlEventTouchUpInside];
        [_menuButtomGroup addSubview:moreBtn];
        

    }
    
    return _menuButtomGroup;
}

#pragma mark - 定位到我的位置
- (void)locatedAtMyLocation {
    
    _mapView.centerCoordinate = _myLocation;
    BOOL equal = [self coordinate:_myLocation equalsTheOther:_currentLocation];
    
    if (!equal) {
        _currentCodeResult = _myCodeResult;
    }
    
}

- (BOOL)coordinate:(CLLocationCoordinate2D)coordinate equalsTheOther:(CLLocationCoordinate2D)theOther {
    
    NSInteger longitude = coordinate.longitude;
    NSInteger latitude = coordinate.latitude;
    
    
    return (longitude == (NSInteger)theOther.longitude) && (latitude == (NSInteger)theOther.latitude);
}

#pragma mark MapViewDidReloadLocationNotification
- (void)mapViewDidReloadLocationNotification:(NSNotification *)notification {
    NSDictionary *dict = notification.userInfo;

   [self geocode:dict[@"address"] withCity:@""];
   
}


- (void)dealloc {
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
}

@end
