//
//  ParseOperation.m
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import "ParseOperation.h"
#import "AboutObject.h"

// string contants found in the JSON feed
static NSString *kRowsStr = @"rows";
static NSString *kTitleStr = @"title";
static NSString *kDescriptionStr = @"description";
static NSString *kImageStr = @"imageHref";

@interface ParseOperation ()

@property (nonatomic, retain) NSArray *aboutRecordList;
@property (nonatomic, retain) NSString *tableTitle;
@property (nonatomic, retain) NSData *dataToParse;
@property (nonatomic, retain) NSMutableArray *workingArray;
@property (nonatomic, retain) AboutObject *workingEntry;  // the current app record or JSON entry being parsed

@end

@implementation ParseOperation

// -------------------------------------------------------------------------------
//	initWithData:
// -------------------------------------------------------------------------------
- (instancetype)initWithData:(NSData *)data{
    
    self = [super init];
    if (self != nil){
        _dataToParse = [data retain];
    }
    
    return self;
}

// -------------------------------------------------------------------------------
//	main
//  Entry point for the operation.
// -------------------------------------------------------------------------------
- (void)main{
    
    _workingArray = [[NSMutableArray alloc]init];
    
    // convert latin string to utf8
    NSString *latinStr = [[NSString alloc] initWithData:self.dataToParse encoding:NSISOLatin1StringEncoding];
    NSData *utf8Data = [latinStr dataUsingEncoding:NSUTF8StringEncoding];
    [latinStr release];
    
    // JSON to directory
    NSMutableDictionary *allData = [NSJSONSerialization
                                    JSONObjectWithData:utf8Data
                                    options:0
                                    error:nil] ;
    
    // title for nav bar
    NSString *titleString = allData[kTitleStr];
    NSArray *rows = allData[kRowsStr];
    for ( NSDictionary *rowData in rows){ // get all rows
        _workingEntry = [[AboutObject alloc]init] ;
        
        _workingEntry.aboutTitle = rowData[kTitleStr] && ![rowData[kTitleStr] isKindOfClass:[NSNull class]] ? rowData[kTitleStr] : @"";
        _workingEntry.aboutDescription = rowData[kDescriptionStr] && ![rowData[kDescriptionStr] isKindOfClass:[NSNull class]] ? rowData[kDescriptionStr] : @"";
        _workingEntry.aboutImageURLString = rowData[kImageStr] && ![rowData[kImageStr] isKindOfClass:[NSNull class]] ? rowData[kImageStr] : @"";
        
        //skip rows with empty title
        if (![_workingEntry.aboutTitle isEqualToString:@""]) {
            [_workingArray addObject:_workingEntry ];
        }
        [_workingEntry release];
        _workingEntry = nil;
    }
    
    if (![self isCancelled]){
        // Set recordList to the result of our parsing
        self.tableTitle = titleString;
        self.aboutRecordList = [NSArray arrayWithArray:_workingArray];
    }
    // clear working set
    [_workingArray release];
    _workingArray = nil;
}

@end
