//
//  HUSavedLocationViewController.m
//  MyMap
//
//  Created by jewelz on 15/6/23.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "HUSavedLocationViewController.h"
#import "DocumentTool.h"

static NSString *ReuseIdentifier = @"Cell";

@interface HUSavedLocationViewController()
@property (strong, nonatomic) NSMutableArray *allData;
@end

@implementation HUSavedLocationViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"收藏的地点";
    
    self.tableView.rowHeight = 60;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:ReuseIdentifier];
}


- (NSMutableArray *)allData {
    if (!_allData) {
        _allData = [[DocumentTool sharedDocumentTool] openContentsOfFile:FileName];
    }
    return _allData;
}


#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.allData.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ReuseIdentifier forIndexPath:indexPath];
    NSDictionary *dict = self.allData[indexPath.row];
   
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.textLabel.text = dict[@"address"];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [[NSNotificationCenter defaultCenter] postNotificationName:MapViewDidReloadLocationNotification object:nil userInfo:_allData[indexPath.row]];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle != UITableViewCellEditingStyleDelete)  return;
    
    [self.allData removeObjectAtIndex:indexPath.row];
    [[DocumentTool sharedDocumentTool] remove:indexPath.row fromContentsOfFile:FileName];
    [tableView reloadData];
    //[tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
}

@end
