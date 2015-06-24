//
//  MenuView.h
//  MyMap
//
//  Created by jewelz on 15/6/20.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import <UIKit/UIKit.h>

static const CGFloat kViewHeight = 156;
@class MenuView;
@protocol MenuViewDelegate <NSObject>

- (void)didCancleButtonClicked;
- (void)menuView:(MenuView *)menuView selectedSegmentAtIndex:(NSInteger)index;

@end

@interface MenuView : UIView
@property (weak, nonatomic) id<MenuViewDelegate> delegate;
+ (instancetype)menuView;
- (void)addTarget:(id)target action:(SEL)action;
@end
