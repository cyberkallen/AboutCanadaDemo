//
//  RootViewController.m
//  Test03
//
//  Created by ef on 8/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import "RootViewController.h"
#import "AboutObject.h"
#import "ImageDownloader.h"
#import "AboutCellTableViewCell.h"
#import "AppDelegate.h"

#define kCustomRowCount 7
#define kTitleLabelWidth 320
#define kDescriptionLabelWidth 230

static NSString *CellIdentifier = @"AboutCanadaTableCell";

@interface RootViewController ()
// the set of IconDownloader objects for each record
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@end

@implementation RootViewController

// -------------------------------------------------------------------------------
//	viewDidLoad
// -------------------------------------------------------------------------------
- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    UIRefreshControl *refreshControl = [[[UIRefreshControl alloc]
                                        init] autorelease];
    refreshControl.tintColor = [UIColor grayColor];
    self.refreshControl = refreshControl;
    refreshControl.attributedTitle = [[[NSAttributedString alloc] initWithString:@"Updating..." attributes:nil] autorelease];
    [refreshControl addTarget:self action:@selector(refreshTable) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view.
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    }
    
    self.title = @"Loading...";
    
    [self.tableView registerClass:[AboutCellTableViewCell class] forCellReuseIdentifier:CellIdentifier];
    // [self.tableView registerClass:[MyTableViewCell class] forCellReuseIdentifier:PlaceholderCellIdentifier];
    
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
}

// -------------------------------------------------------------------------------
//	terminateAllDownloads
// -------------------------------------------------------------------------------
- (void)terminateAllDownloads{
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
    
    [self.imageDownloadsInProgress removeAllObjects];
}

// -------------------------------------------------------------------------------
//	dealloc
//  If this view controller is going away, we need to cancel all outstanding downloads.
// -------------------------------------------------------------------------------
- (void)dealloc{
    
    // terminate all pending download connections
    [self terminateAllDownloads];
    [super dealloc];
}

// -------------------------------------------------------------------------------
//	didReceiveMemoryWarning
// -------------------------------------------------------------------------------
- (void)didReceiveMemoryWarning{
    
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    [self terminateAllDownloads];
}


#pragma mark - UITableViewDataSource

// -------------------------------------------------------------------------------
//	tableView:numberOfRowsInSection:
//  Customize the number of rows in the table view.
// -------------------------------------------------------------------------------
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSUInteger count = self.entries.count;
    
    // if there's no data yet, return enough rows to fill the screen
    if (count == 0)
    {
        return kCustomRowCount;
    }
    return count;
}

// -------------------------------------------------------------------------------
//	tableView:cellForRowAtIndexPath:
// -------------------------------------------------------------------------------
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // MyTableViewCell *cell = nil;
    AboutCellTableViewCell *cell = nil;
    
    NSUInteger nodeCount = self.entries.count;
    
    cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Leave cells empty if there's no data yet
    if (nodeCount > 0){
        
        // Set up the cell representing the record
        AboutObject *aboutRecord = (self.entries)[indexPath.row];
        
        cell.titleLabel.text = aboutRecord.aboutTitle;
        cell.descriptionLabel.text = aboutRecord.aboutDescription;
        
        // Only load cached images; defer new downloads until scrolling ends
        if (!aboutRecord.aboutImage){
            
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO){
                
                [self startIconDownload:aboutRecord forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.iconView.image = [UIImage imageNamed:@"Placeholder.png"];
        }
        else{
            cell.iconView.image = aboutRecord.aboutImage;
        }
    }
    
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSUInteger nodeCount = self.entries.count;
    
    if (!nodeCount == 0){
        AboutObject *aboutRecord = (self.entries)[indexPath.row];
        CGSize sizeforTitle = [aboutRecord.aboutTitle
                               sizeWithFont:[UIFont fontWithName:@"Georgia" size:12.0f]
                               constrainedToSize:CGSizeMake(kTitleLabelWidth, 20000.0f)];
        
        CGSize sizeforDescription = [aboutRecord.aboutDescription
                                     sizeWithFont:[UIFont fontWithName:@"Arial" size:8.0f]
                                     constrainedToSize:CGSizeMake(kDescriptionLabelWidth, 20000.0f)
                                     lineBreakMode:NSLineBreakByWordWrapping];
        
        // height must be over 55 for image to fit
        return (sizeforTitle.height + sizeforDescription.height + 30.0f) > 55  ?
        (sizeforTitle.height + sizeforDescription.height + 30.0f) : 55;
    }
    
    return [super tableView:tableView heightForRowAtIndexPath:indexPath];

}


#pragma mark - Table cell image support

// -------------------------------------------------------------------------------
//	startIconDownload:forIndexPath:
// -------------------------------------------------------------------------------
- (void)startIconDownload:(AboutObject *)aboutRecord forIndexPath:(NSIndexPath *)indexPath{
    
    ImageDownloader *imageDownloader = (self.imageDownloadsInProgress)[indexPath];
    if (imageDownloader == nil){
        
        imageDownloader = [[[ImageDownloader alloc] init]autorelease];
        imageDownloader.aboutRecord = aboutRecord;
        [imageDownloader setCompletionHandler:^{
            
            AboutCellTableViewCell *cell = (AboutCellTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            //  MyTableViewCell *cell = (MyTableViewCell*)[self.tableView cellForRowAtIndexPath:indexPath];
            
            // Display the newly loaded image
            cell.iconView.image = aboutRecord.aboutImage;
            
            // Remove the IconDownloader from the in progress list.
            // This will result in it being deallocated.
            [self.imageDownloadsInProgress removeObjectForKey:indexPath];
            
        }];
        (self.imageDownloadsInProgress)[indexPath] = imageDownloader;
        [imageDownloader startDownload];
    }
}

// -------------------------------------------------------------------------------
//	loadImagesForOnscreenRows
//  This method is used in case the user scrolled into a set of cells that don't
//  have their icons yet.
// -------------------------------------------------------------------------------
- (void)loadImagesForOnscreenRows{
    
    if (self.entries.count > 0){
        
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths){
            
            AboutObject *aboutRecord = (self.entries)[indexPath.row];
            
            if (!aboutRecord.aboutImage){
                // Avoid the app icon download if the app already has an icon
                [self startIconDownload:aboutRecord forIndexPath:indexPath];
            }
        }
    }
}

// -------------------------------------------------------------------------------
//	refreshTable
//  This method is used to call load method on delegate
// -------------------------------------------------------------------------------
-(void)refreshTable{
    
    AppDelegate *appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate loadData];
    //stop refreshing animation
    [self.refreshControl endRefreshing];

}

#pragma mark - UIScrollViewDelegate

// -------------------------------------------------------------------------------
//	scrollViewDidEndDragging:willDecelerate:
//  Load images for all onscreen rows when scrolling is finished.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate{
    
    if (!decelerate){
        [self loadImagesForOnscreenRows];
    }
}

// -------------------------------------------------------------------------------
//	scrollViewDidEndDecelerating:scrollView
//  When scrolling stops, proceed to load the app icons that are on screen.
// -------------------------------------------------------------------------------
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    
    [self loadImagesForOnscreenRows];
}


@end
