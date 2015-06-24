//
//  HUAlterView.m
//  MyMap
//
//  Created by jewelz on 15/6/23.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUAlertView.h"

#define kSWidth [UIScreen mainScreen].bounds.size.width
#define kSHeight [UIScreen mainScreen].bounds.size.height
static const CGFloat kWidth = 120;
static const CGFloat kHeight = 58;
static const CGFloat kRadiusRote = 0.08;

@interface HUAlertView ()
@property (strong, nonatomic) UILabel *alterTitle;

@end

@implementation HUAlertView
- (instancetype)initWithTitle:(NSString *)title {
    self = [self init];
    _alterTitle.text = title;
    return self;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.9];
        self.frame = CGRectMake(0, 0, kWidth, kHeight);
        self.center = CGPointMake(kSWidth/2, kSHeight/2);
        self.layer.cornerRadius = kHeight * kRadiusRote;
        
        _alterTitle = [[UILabel alloc] initWithFrame:CGRectZero];
        _alterTitle.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleHeight;
        _alterTitle.textColor = [UIColor blackColor];
        _alterTitle.font = [UIFont systemFontOfSize:13];
        _alterTitle.textAlignment = NSTextAlignmentCenter;
        
        
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    _alterTitle.frame = self.bounds;
}

- (void)show {
 
    [self addSubview:_alterTitle];
    [[[UIApplication sharedApplication].windows firstObject] addSubview:self];
    
    [UIView animateWithDuration:3 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
    
}

@end
