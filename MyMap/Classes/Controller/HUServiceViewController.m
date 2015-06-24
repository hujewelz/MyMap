//
//  HUServiceViewController.m
//  MyMap
//
//  Created by jewelz on 15/6/22.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUServiceViewController.h"
#import "HUMapView.h"

@interface HUServiceViewController() <BMKMapViewDelegate, BMKPoiSearchDelegate>{
    BMKMapView *_mapView;
    BMKPoiSearch *_search;
}

@end

@implementation HUServiceViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[BMKMapView alloc] initWithFrame:self.view.bounds];
    self.view = _mapView;

    _mapView.delegate = self;
    
    
    _search = [[BMKPoiSearch alloc] init];
    _search.delegate = self;
    
    CLLocationCoordinate2D center =  CLLocationCoordinate2DMake([_data[@"latitude"] floatValue], [_data[@"longitude"] floatValue]);
    NSString *keyword = _data[@"keyword"];
    
    self.title = [NSString stringWithFormat:@"附近的%@", keyword];
    
    [self poiSearchNearBykeyword:keyword center:center radius:5000 pageIndex:0];
   
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [_mapView viewWillAppear];
}

- (void)viewWillDisappear:(BOOL)animated {

    [_mapView viewWillDisappear];
    _search.delegate = nil;
    _mapView.delegate = nil;
    
    [super viewWillDisappear:YES];
}

//实现PoiSearchDeleage处理回调结果
- (void)onGetPoiResult:(BMKPoiSearch*)searcher result:(BMKPoiResult*)poiResultList errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        //在此处理正常结果
        NSLog(@"%@", poiResultList.poiInfoList);
        // 清除屏幕中所有的 annotation
        NSArray* array = [NSArray arrayWithArray:_mapView.annotations];
        [_mapView removeAnnotations:array];
        
        for (int i = 0; i < poiResultList.poiInfoList.count; i++) {
            BMKPoiInfo* poi = [poiResultList.poiInfoList objectAtIndex:i];
            BMKPointAnnotation* item = [[BMKPointAnnotation alloc]init];
            item.coordinate = poi.pt;
            item.title = poi.name;
            [_mapView addAnnotation:item];
            if(i == 0)
            {
                _mapView.centerCoordinate = poi.pt;
            }
            
        }
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_KEYWORD){
        //当在设置城市未找到结果，但在其他城市找到结果时，回调建议检索城市列表
        // result.cityList;
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"抱歉，未找到结果");
    }
}

- (BMKAnnotationView *)mapView:(BMKMapView *)view viewForAnnotation:(id <BMKAnnotation>)annotation {
    static NSString *AnnotationViewID = @"AnnotationViewID";
    BMKAnnotationView* annotationView = [view dequeueReusableAnnotationViewWithIdentifier:AnnotationViewID];
    // 缓存没有命中,自己构造一个,一般首次添加 annotation 代码会运行到此处 if (annotationView == nil) {
    annotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:AnnotationViewID];
    
    ((BMKPinAnnotationView*)annotationView).pinColor = BMKPinAnnotationColorRed;
    // 设置重天上掉下的效果(annotation)
    ((BMKPinAnnotationView*)annotationView).animatesDrop = YES;
    // 设置位置
    annotationView.centerOffset = CGPointMake(0, -(annotationView.frame.size.height * 0.5));
    annotationView.annotation = annotation;
    // 单击弹出泡泡,弹出泡泡前提 annotation 必须实现 title 属性 annotationView.canShowCallout = YES;
    // 设置是否可以拖拽
    annotationView.draggable = NO;
    return annotationView;

}

- (void)showSearchResult {
   
    
}

- (void)poiSearchNearBykeyword:(NSString *)keyword center:(CLLocationCoordinate2D)center radius:(int)radius pageIndex:(int)page {
    
    BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc] init];
    option.pageIndex = page;
    option.pageCapacity = 10;
    option.radius = radius;
    option.location = center;
    option.keyword = keyword;
    
    BOOL flag = [_search poiSearchNearBy:option];
    if(flag)
    {
        NSLog(@"busline检索发送成功");
    }
    else
    {
        NSLog(@"busline检索");
        [self showAlertViewWithMesg:@"没有查到周边信息"];
    }
}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
    if (_search) {
        _search = nil;
    }
}

@end
