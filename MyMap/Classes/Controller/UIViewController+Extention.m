//
//  UIViewController+Extention.m
//  MyMap
//
//  Created by jewelz on 15/6/23.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "UIViewController+Extention.h"

@implementation UIViewController (Extention)

- (void)showAlertViewWithMesg:(NSString *)msg {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提醒" message:msg delegate:nil cancelButtonTitle:@"取消" otherButtonTitles:@"确定", nil];
    [alert show];
}

@end
