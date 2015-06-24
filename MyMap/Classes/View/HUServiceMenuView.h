//
//  HUServiceMenuView.h
//  MyMap
//
//  Created by jewelz on 15/6/21.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, HUServiceMenyItemType) {
    HUServiceMenyItemTypeRestaurant = 0,
    HUServiceMenyItemTypeTherter,
    HUServiceMenyItemTypeKTV,
    HUServiceMenyItemTypeSuperMarket,
    
    HUServiceMenyItemTypeSchool,
    HUServiceMenyItemTypeHospital,
    HUServiceMenyItemTypeExpress,
    HUServiceMenyItemTypeOhter
    
};

@interface HUServiceMenuView : UIView

+(instancetype)serviceMenu;
- (void)addTarget:(id)target action:(SEL)action;

@end
