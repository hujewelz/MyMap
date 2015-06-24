//
//  HUMapView.m
//  MyMap
//
//  Created by jewelz on 15/6/22.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUMapView.h"

@interface HUMapView ()<BMKMapViewDelegate, BMKLocationServiceDelegate, BMKGeoCodeSearchDelegate>
{
    BMKMapView *_mapView;
    BMKGeoCodeSearch *_geocodesearch;
    BMKLocationService *_locService;
    BOOL _isUpdating;
    NSString *_address;
}

@end

@implementation HUMapView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _mapView = [[BMKMapView alloc] initWithFrame:self.bounds];
        
        _mapView.showsUserLocation = YES;
        _mapView.mapType = BMKMapTypeSatellite;
        _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;//设置定位的状态
        _mapView.zoomLevel = 19;
        [self addSubview:_mapView];
        
        _geocodesearch = [[BMKGeoCodeSearch alloc] init]; //搜索服务
        
        //设置定位精确度，默认：kCLLocationAccuracyBest
        [BMKLocationService setLocationDesiredAccuracy:kCLLocationAccuracyNearestTenMeters];
        //指定最小距离更新(米)，默认：kCLDistanceFilterNone
        [BMKLocationService setLocationDistanceFilter:100.f];
        
        //初始化BMKLocationService
        _locService = [[BMKLocationService alloc]init];
        
      

    }
    return self;
}

- (void)viewWillAppear {
    NSLog(@"view will appear");
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    _locService.delegate = self;
    _geocodesearch.delegate = self;
}

- (void)viewWillDisappear {
     NSLog(@"view Will Disappear");
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    _locService.delegate = nil;
    _geocodesearch.delegate = nil;
}
- (void)startUserLocationService {
    //启动LocationService
    [_locService startUserLocationService];
}

#pragma mark BMKLocationServiceDelegate
//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation
{
    if (!_isUpdating) return;
    
    [_mapView updateLocationData:userLocation];
    NSLog(@"didUpdateUserHeading -- latitude: %f, longitude: %f",userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
    if ([self.delegate respondsToSelector:@selector(didUpdateUserHeading:)]) {
        [_delegate didUpdateUserHeading:userLocation];
    }
    _isUpdating = NO;
}

//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{
    NSLog(@"didUpdateBMKUserLocation");
    if (!_isUpdating) return;
    
    //[self showAlertViewWithMesg:@"didUpdateBMKUserLocation"];
    
    _currentLocation = userLocation.location.coordinate;
    _myLocation = userLocation.location.coordinate;
    
    [_mapView updateLocationData:userLocation];
    
    if ([self.delegate respondsToSelector:@selector(didUpdateBMKUserLocation:)]) {
        [_delegate didUpdateBMKUserLocation:userLocation];
    }
    
    NSLog(@"didUpdateBMKUserLocation -- latitude: %f, longitude: %f",_currentLocation.latitude, _currentLocation.longitude);
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
            
        }
    }
    
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡,弹出泡泡前提 annotation 必须实现 title 属性 annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    
    if ([self.delegate respondsToSelector:@selector(mapView:viewForAnnotation:)]) {
        [_delegate mapView:mapView viewForAnnotation:annotation];
    }
    
    return annotationView;;
}

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate {
    NSLog(@"onClickedMapBlank :%f", coordinate.latitude);
    if ([self.delegate respondsToSelector:@selector(mapView:onClickedMapBlank:)]) {
        [_delegate mapView:mapView onClickedMapBlank:coordinate];
    }
}

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi {
    NSLog(@"onClickedMapPoi:%@", mapPoi);
    if ([self.delegate respondsToSelector:@selector(mapView:onClickedMapPoi:)]) {
        [_delegate mapView:mapView onClickedMapPoi:mapPoi];
    }
}

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
     NSLog(@"didSelectAnnotationView");
    if ([self.delegate respondsToSelector:@selector(mapView:didSelectAnnotationView:)]) {
        [_delegate mapView:mapView didSelectAnnotationView:view];
    }
    
}

#pragma mark BMKGeoCodeSearchDelegate
#pragma mark - 正向地理编码 获取结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"正向地理编码 获取结果");
    if (error == 0) {
        _currentLocation = result.location;
        
        [self reverseGeocodeWithCoordinate:_currentLocation];
        [self addPointAnnotationWithCoordinate:result.location andTitle:@"新地点"];
        
    }
    
    if ([self.delegate respondsToSelector:@selector(onGetGeoCodeResult:result:errorCode:)]) {
        [_delegate onGetGeoCodeResult:searcher result:result errorCode:error];
    }
    
}

#pragma mark - 反向地理编码 获取结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error {
    NSLog(@"反向地理编码 获取结果");
    if (error == 0) {
        _address = result.address;
        NSLog(@"address: %@", _address);
        //_currentLocation
    }
    if ([self.delegate respondsToSelector:@selector(onGetReverseGeoCodeResult:result:errorCode:)]) {
        [_delegate onGetReverseGeoCodeResult:searcher result:result errorCode:error];
    }
}

#pragma mark - Myself function
#pragma mark -- 正向地理编码
- (BOOL)geocode:(NSString *)address withCity:(NSString *)city {
    
    BMKGeoCodeSearchOption *option = [[BMKGeoCodeSearchOption alloc] init];
    option.address = address;
    option.city = city;
    BOOL flag = [_geocodesearch geoCode:option];
    
    if (flag) {
        NSLog(@"ReverseGeocode search success.");
    }
    else{
        NSLog(@"没有找到您想去的位置");
    }
    
    return flag;
}

#pragma mark -- 反向地理编码
- (BOOL)reverseGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate {
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
    }
    
    return flag;
}

#pragma mark -- 添加annotation
- (void)addPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title {
    // 清除屏幕中所有的 annotation
    NSArray* array = [NSArray arrayWithArray:_mapView.annotations]; [_mapView removeAnnotations:array];
    [_mapView removeAnnotations:array];
    
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = coordinate;
    annotation.title = title;
    
    _mapView.centerCoordinate = coordinate;
    
    [_mapView addAnnotation:annotation];
}


- (void)dealloc {
    if (_geocodesearch != nil) {
        _geocodesearch = nil;
    }
    if (_locService != nil) {
        _locService = nil;
    }
    if (_mapView) {
        _mapView = nil;
    }
    
    
}


@end
