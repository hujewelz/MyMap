//
//  MenuView.m
//  MyMap
//
//  Created by jewelz on 15/6/20.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//


#import "MenuView.h"
@interface MenuView()

@property (weak, nonatomic) IBOutlet UISegmentedControl *segment;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *addMark;

@property (weak, nonatomic) IBOutlet UIButton *saveBtn;
@end
@implementation MenuView

+(instancetype)menuView {
    return [[[NSBundle mainBundle] loadNibNamed:@"MenuView" owner:nil options:nil] lastObject];
}

- (void)awakeFromNib {

    [self setUp];
}

- (void)setUp {
    self.backgroundColor = [[UIColor colorWithRed:60 green:60 blue:60 alpha:1] colorWithAlphaComponent:0.6];
    self.cancleBtn.layer.cornerRadius = 7;
    
    [_segment addTarget:self action:@selector(segmentAction:) forControlEvents:UIControlEventValueChanged];
    [self.cancleBtn addTarget:self action:@selector(cancleBtnClicked) forControlEvents:UIControlEventTouchUpInside];
    
    
    
}

- (void)segmentAction:(UISegmentedControl *)seg{
    if ([self.delegate respondsToSelector:@selector(menuView:selectedSegmentAtIndex:)]) {
        [self.delegate menuView:self selectedSegmentAtIndex:seg.selectedSegmentIndex];
    }
}

- (void)addTarget:(id)target action:(SEL)action {
    [self.saveBtn addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
    [self.addMark addTarget:target action:action forControlEvents:UIControlEventTouchUpInside];
}

- (void)cancleBtnClicked {
    if ([self.delegate respondsToSelector:@selector(didCancleButtonClicked)]) {
        [self.delegate didCancleButtonClicked];
    }
}

@end
