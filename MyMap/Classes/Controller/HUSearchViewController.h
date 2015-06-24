//
//  HUSearchViewController.h
//  MyMap
//
//  Created by jewelz on 15/6/21.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol HUSearchViewdelegate <NSObject>

@optional
- (void)didSelectRowAtIndex:(NSInteger)index withData:(NSString *)data;

@end

@interface HUSearchViewController : UITableViewController

@property (strong, nonatomic) NSArray *data;
@property (weak, nonatomic) id<HUSearchViewdelegate> delegate;

- (void)reloadData;

@end
