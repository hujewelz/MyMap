//
//  HUMapView.h
//  MyMap
//
//  Created by jewelz on 15/6/22.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol HUMapViewDelegate <NSObject>

//处理方向变更信息
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation;
//处理位置坐标更新
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation;

- (void)mapView:(BMKMapView *)mapView onClickedMapBlank:(CLLocationCoordinate2D)coordinate;

- (void)mapView:(BMKMapView *)mapView onClickedMapPoi:(BMKMapPoi *)mapPoi;

- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view;

/**
 *根据 anntation 生成对应的 View
 *@param mapView 地图 View *@param annotation 指定的标注 *@return 生成的标注 View
 */
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation;

//正向地理编码 获取结果
- (void)onGetGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error;

//反向地理编码 获取结果
- (void)onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error;
@end


@interface HUMapView : UIView

@property (assign, nonatomic) CLLocationCoordinate2D currentLocation;
@property (assign, nonatomic) CLLocationCoordinate2D  myLocation;
@property (weak, nonatomic) id<HUMapViewDelegate> delegate;

- (void)viewWillAppear;
- (void)viewWillDisappear;

- (void)startUserLocationService;
/**
 正向地理编码
 @param address 地址信息
 @param city 城市信息
 @returns Bool
 */
- (BOOL)geocode:(NSString *)address withCity:(NSString *)city;
/**
 反向地理编码
 @param coordinate 通过经纬度信息获得具体位置
 @returns Bool
 */
- (BOOL)reverseGeocodeWithCoordinate:(CLLocationCoordinate2D)coordinate;

/**
 添加annotation
 @param coordinate 经纬度
 @param title 标题
 */

- (void)addPointAnnotationWithCoordinate:(CLLocationCoordinate2D)coordinate andTitle:(NSString *)title;


@end
