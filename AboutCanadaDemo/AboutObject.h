//
//  AboutObject.h
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


// object for remote JSON record
@interface AboutObject : NSObject

@property (nonatomic, retain) NSString *aboutTitle;
@property (nonatomic, retain) UIImage *aboutImage;
@property (nonatomic, retain) NSString *aboutImageURLString;
@property (nonatomic, retain) NSString *aboutDescription;

@end
