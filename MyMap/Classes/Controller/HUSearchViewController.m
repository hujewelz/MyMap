//
//  HUSearchViewController.m
//  MyMap
//
//  Created by jewelz on 15/6/21.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUSearchViewController.h"

@interface HUSearchViewController ()

@end

@implementation HUSearchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    if (_data) {
        return _data.count;
    }
    return 0;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    cell.textLabel.text = _data[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {

    if ([_delegate respondsToSelector:@selector(didSelectRowAtIndex:withData:)]) {
        [_delegate didSelectRowAtIndex:indexPath.row withData:_data[indexPath.row]];
    }
}

- (void)reloadData {
    [self.tableView reloadData];
}

@end
