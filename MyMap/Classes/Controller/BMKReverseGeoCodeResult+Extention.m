//
//  BMKReverseGeoCodeResult+Extention.m
//  MyMap
//
//  Created by jewelz on 15/6/22.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "BMKReverseGeoCodeResult+Extention.h"

@implementation BMKReverseGeoCodeResult (Extention)
+(BMKReverseGeoCodeResult *)reverseGeoCodeResultWithCoordinate:(CLLocationCoordinate2D)coordinate andAddress:(NSString *)address {
    BMKReverseGeoCodeResult *result = [[BMKReverseGeoCodeResult alloc] init];
    result.location = coordinate;
    result.address = address;
    return result;
}
@end
