//
//  ParseOperation.h
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ParseOperation : NSOperation

// A block to call when an error is encountered during parsing.
@property (nonatomic, copy) void (^errorHandler)(NSError *error);

// NSArray containing record instances for each entry parsed
// from the input data.
// Only meaningful after the operation has completed.
@property (nonatomic, retain, readonly) NSArray *aboutRecordList;
@property (nonatomic, retain, readonly) NSString *tableTitle;

// The initializer for this NSOperation subclass.
- (instancetype)initWithData:(NSData *)data;

@end
