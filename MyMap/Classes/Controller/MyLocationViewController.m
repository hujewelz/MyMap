//
//  MyLocationViewController.m
//  MyMap
//
//  Created by jewelz on 15/6/20.
//  Copyright (c) 2015年 yangtzeu. All rights reserved.
//

#import "MyLocationViewController.h"
#import "HUServiceMenuView.h"
#import "HUServiceViewController.h"

static const CGFloat kRowHeightNormal = 60;
static const CGFloat kRowHeighter = 150;

@interface MyLocationViewController ()<BMKMapViewDelegate, UITableViewDataSource, UITableViewDelegate> {
    int rotate;
    CADisplayLink *_displsy;
}

@property (strong, nonatomic) UITableView *tableview;
@property (strong, nonatomic) BMKMapView *mapView;
@property (nonatomic) CLLocationCoordinate2D coordinate;
@property (strong, nonatomic)  HUServiceMenuView *serviceMenu;
@end

@implementation MyLocationViewController

-(void)loadView {
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = [UIScreen mainScreen].bounds.size.height;
    
    CGRect frame = CGRectMake(0, 64, width, height);
    self.tableview = [[UITableView alloc] initWithFrame:frame style:UITableViewStyleGrouped];
    
    self.view = self.tableview;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的位置";
    self.tableview.delegate = self;
    self.tableview.dataSource = self;
    self.tableview.allowsSelection = NO;
    [self.tableview registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
   
    self.coordinate = CLLocationCoordinate2DMake([_data[@"latitude"] floatValue], [_data[@"longitude"] floatValue]);
    
    _serviceMenu = [HUServiceMenuView serviceMenu];
    [_serviceMenu addTarget:self action:@selector(menuButtonclickedWithTag:)];
    
    self.mapView = [[BMKMapView alloc] initWithFrame:CGRectMake(0, 64, self.view.frame.size.width, 140)];
    _mapView.showsUserLocation = YES;
    _mapView.userTrackingMode = BMKUserTrackingModeFollowWithHeading;//设置定位的状态
    _mapView.mapType = BMKMapTypeSatellite;
    _mapView.scrollEnabled = NO;
    _mapView.zoomEnabled = NO;
    _mapView.zoomLevel = 19;
     _mapView.rotateEnabled = YES;
    
}

- (void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBarHidden = NO;
    [[UIApplication sharedApplication] setStatusBarHidden:NO];
    
    [_mapView viewWillAppear];
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
   // _locService.delegate = self;
  
    
}
- (void)viewWillDisappear:(BOOL)animated
{
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
    [_displsy invalidate];
}

#pragma mark - tableview datasource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *indentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:indentifier forIndexPath:indexPath];
    cell.textLabel.font = [UIFont systemFontOfSize:16];
    cell.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    if (indexPath.row == 0) {
        
        cell.textLabel.text = _data[@"address"];
        cell.imageView.image = [UIImage imageNamed:@"location"];
        
    }
    if (indexPath.row == 1) {
        
        [cell.contentView addSubview:[self buttonBroup]];
    }
    if (indexPath.row == 2) {
    
        [cell.contentView addSubview:_serviceMenu];
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    
    return 140;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 2) {
        return kRowHeighter;
    } else {
        return kRowHeightNormal;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) return nil;
    //添加一个PointAnnotation
    BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
    annotation.coordinate = self.coordinate;

    [_mapView addAnnotation:annotation];
    _mapView.centerCoordinate = self.coordinate;
    
    return _mapView;
}

#pragma mark - bmkmapview delegate
- (BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id <BMKAnnotation>)annotation
{
    NSLog(@"viewForAnnotation");
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        
        _displsy = [CADisplayLink displayLinkWithTarget:self selector:@selector(mapRotation)];
        [_displsy addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        _mapView.userTrackingMode = BMKUserTrackingModeNone;
        _mapView.showsUserLocation = NO;
        
        return newAnnotationView;
    }
    return nil;
}


#pragma mark - Myself function
- (UIView *)buttonBroup {
    UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, kRowHeightNormal)];
    
    UIButton *goThere = [UIButton buttonWithType:UIButtonTypeCustom];
    goThere.frame = CGRectMake(0, 0, self.view.frame.size.width/2, kRowHeightNormal);
    goThere.tag = 0;
    [goThere setTitle:@"到这儿的路线" forState:UIControlStateNormal];
    [goThere setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [goThere setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    goThere.titleLabel.font = [UIFont systemFontOfSize:14];
    [goThere addTarget:self action:@selector(groupButtonclickedWithTag:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:goThere];
    
    UIButton *fromeThere = [UIButton buttonWithType:UIButtonTypeCustom];
    fromeThere.frame = CGRectMake(CGRectGetMaxX(goThere.frame), 0, self.view.frame.size.width/2, kRowHeightNormal);
    fromeThere.tag = 1;
    [fromeThere setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    [fromeThere setTitleColor:[UIColor lightGrayColor] forState:UIControlStateHighlighted];
    [fromeThere setTitle:@"从这儿出发的路线" forState:UIControlStateNormal];
    fromeThere.titleLabel.font = [UIFont systemFontOfSize:14];
    [fromeThere addTarget:self action:@selector(groupButtonclickedWithTag:) forControlEvents:UIControlEventTouchUpInside];
    [view addSubview:fromeThere];
    
    return view;
}

- (void)groupButtonclickedWithTag:(UIButton *)sender {
    NSLog(@"clicked at :%d", sender.tag);
}

- (void)menuButtonclickedWithTag:(UIButton *)sender {
    NSString *keyWord = nil;
    switch (sender.tag) {
        case HUServiceMenyItemTypeRestaurant:
            keyWord = @"餐馆";
            break;
        case HUServiceMenyItemTypeTherter:
            keyWord = @"电影院";
            break;
        case HUServiceMenyItemTypeKTV:
            keyWord = @"KTV";
            break;
        case HUServiceMenyItemTypeSuperMarket:
            keyWord = @"超市";
            break;
        case HUServiceMenyItemTypeSchool:
            keyWord = @"学校";
            break;
        case HUServiceMenyItemTypeHospital:
            keyWord = @"医院";
            break;
        case HUServiceMenyItemTypeExpress:
            keyWord = @"快递";
            break;
        case HUServiceMenyItemTypeOhter:
            keyWord = @"车站";
            break;
            
    }
    NSLog(@"clicked at :%d", sender.tag);
    HUServiceViewController *serviceVc = [[HUServiceViewController alloc] init];
    [self.navigationController pushViewController:serviceVc animated:YES];
    //serviceVc.center = self.coordinate;
    serviceVc.data = @{@"latitude":@(_coordinate.latitude),@"longitude":@(_coordinate.longitude), @"keyword":keyWord};
    
}


- (void)mapRotation {
   // NSLog(@"rotate: %d", rotate);
    _mapView.rotation = rotate;
    
    //rotate += 1;
    //rotate %= 360;
    rotate ++;

}

- (void)dealloc {
    if (_mapView) {
        _mapView = nil;
    }
}



@end
