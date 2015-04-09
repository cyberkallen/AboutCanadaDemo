//
//  ImageDownloader.h
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import <Foundation/Foundation.h>

@class AboutObject;

@interface ImageDownloader : NSObject

@property (nonatomic, retain) AboutObject *aboutRecord;
@property (nonatomic, copy) void (^completionHandler)(void);

- (void)startDownload; //start image download
- (void)cancelDownload; //cancel download if needed

@end
