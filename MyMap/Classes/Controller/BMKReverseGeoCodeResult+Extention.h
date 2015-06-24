//
//  BMKReverseGeoCodeResult+Extention.h
//  MyMap
//
//  Created by jewelz on 15/6/22.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//


@interface BMKReverseGeoCodeResult (Extention)
+(BMKReverseGeoCodeResult *)reverseGeoCodeResultWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)address;
@end
