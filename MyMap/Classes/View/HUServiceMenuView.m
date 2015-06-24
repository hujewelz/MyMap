//
//  HUServiceMenuView.m
//  MyMap
//
//  Created by jewelz on 15/6/21.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUServiceMenuView.h"
@interface HUServiceMenuView()



@end

@implementation HUServiceMenuView

+(instancetype)serviceMenu {
    return [[[NSBundle mainBundle] loadNibNamed:@"ServiceMenuView" owner:nil options:nil] lastObject];
}


- (void)addTarget:(id)target action:(SEL)action{
 
    for (int i=0; i<8; ++i) {
        UIButton *btn = (UIButton *)[self viewWithTag:i];
        [btn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    
    }
}


@end
