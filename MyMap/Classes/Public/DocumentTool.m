//
//  DocumentTool.m
//  HealthCare
//
//  Created by jewelz on 14-10-9.
//  Copyright (c) 2014年 yangtzeU. All rights reserved.
//

#import "DocumentTool.h"

@implementation DocumentTool

//单例模式
static DocumentTool *document = nil;
+ (id)sharedDocumentTool
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        document = [[self alloc] init];
    });
    return document;
}


-(id)init
{
    self = [super init];
    if (self) {
        _array = [NSMutableArray array];
    }
    
    return self;
    
}

//写入一条记录
- (BOOL) write:(NSDictionary *)dict ToFileWithFileName:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"%@.plist", name];
    
    //获取沙盒目录
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    _path = [document stringByAppendingPathComponent:file];
    
    if (!_path) {
        return NO;
    }
    
    //拿到目录中的数组
    _array = [NSMutableArray arrayWithContentsOfFile:_path];
    
    //[_array addObject:dict];
    //将数据插入到最前面
    [_array insertObject:dict atIndex:0];
    
    NSSet *set = [NSSet setWithArray:_array];
    [_array removeAllObjects];
   // NSMutableArray *result = [NSMutableArray arrayWithCapacity:set.count];
    for (NSDictionary *dict in set) {
        [_array addObject:dict];
    }
    
    
    //将新数据写到目录中
    BOOL su = [_array writeToFile:_path atomically:YES];
    if (!su) {
        
        NSMutableArray *array = [NSMutableArray array];
        [array insertObject:dict atIndex:0];
        [array writeToFile:_path atomically:YES];
        return YES;
    }
   
    return su;
}

-(void)removefromContentsOfFile:(NSString *)path
{
    _array = [NSMutableArray arrayWithContentsOfFile:path];
    if (_array.count) {
        
        [_array removeAllObjects];
        [_array writeToFile:path atomically:YES];
         //NSLog(@"array remove:%@",_array);
    }
    
}

//删除一条记录
- (BOOL)remove:(NSUInteger)index fromContentsOfFile:(NSString *)name
{
    NSString *file = [NSString stringWithFormat:@"%@.plist", name];
    //获取沙盒目录
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [document stringByAppendingPathComponent:file];
    
    if (!path) {
        return NO;
    }
    
    _array = [NSMutableArray arrayWithContentsOfFile:path];
    //NSLog(@"delete row :%d, _array count: %d",index, _array.count);
    if (_array.count) {
        [_array removeObjectAtIndex:index];
        [_array writeToFile:path atomically:YES];
        return YES;
    }
    
    return NO;
}

- (NSMutableArray *)openContentsOfDefaultFile
{
    return [NSMutableArray arrayWithContentsOfFile:_path];
}

- (NSMutableArray *)openContentsOfFile:(NSString *)path
{
    NSString *document = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *pathStr = [NSString stringWithFormat:@"%@.plist",path];
    NSString *realPath = [document stringByAppendingPathComponent:pathStr];
    if (!realPath) {
        NSLog(@"目录未找到");
    }
    return [NSMutableArray arrayWithContentsOfFile:realPath];
}

@end
