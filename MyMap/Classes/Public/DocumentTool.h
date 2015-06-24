//
//  DocumentTool.h
//  HealthCare
//
//  Created by jewelz on 14-10-9.
//  Copyright (c) 2014年 yangtzeU. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DocumentTool : NSObject
{
    NSString *_path;
    NSMutableArray *_array;
}


- (BOOL) write:(NSDictionary *)dict ToFileWithFileName:(NSString *)name;
- (BOOL) remove:(NSUInteger)index fromContentsOfFile:(NSString *)path;
- (void) removefromContentsOfFile:(NSString *)path;
- (NSMutableArray *) openContentsOfDefaultFile;
- (NSMutableArray *) openContentsOfFile:(NSString *)name;

+ (id)sharedDocumentTool;

@end
