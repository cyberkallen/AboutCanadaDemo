//
//  AppDelegate.m
//  AboutCanadaDemo
//
//  Created by ef on 9/04/2015.
//  Copyright (c) 2015 ef. All rights reserved.
//

#import "AppDelegate.h"
#import "RootViewController.h"
#import "ParseOperation.h"

#import <CFNetwork/CFNetwork.h>
// the http URL used for fetching About Canada data
static NSString *const AboutCanadaFeed = @"https://dl.dropboxusercontent.com/u/746330/facts.json";

@interface AppDelegate ()

@property (nonatomic, retain) NSOperationQueue *queue;
@property (nonatomic, retain) NSURLConnection *listFeedConnection;
@property (nonatomic, retain) NSMutableData *listData;

@end

@implementation AppDelegate

#pragma mark -

// -------------------------------------------------------------------------------
//	applicationDidFinishLaunching:application
// -------------------------------------------------------------------------------
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions{
    // start loading JSON data
    [self loadData];
    
    // create nav and table view controllers
    UIViewController *rootViewController =[[[RootViewController alloc]init] autorelease];
    UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:rootViewController] autorelease];
    _window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _window.rootViewController = navController;
    [_window makeKeyAndVisible];
    [_window addSubview:navController.view];
    
    return YES;
}

-(void)loadData{
    NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:AboutCanadaFeed]] ;
    _listFeedConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self]  ;
    
    // Test the validity of the connection object. The most likely reason for the connection object
    // to be nil is a malformed URL, which is a programmatic error easily detected during development
    // If the URL is more dynamic, then you should implement a more flexible validation technique, and
    // be able to both recover from errors and communicate problems to the user in an unobtrusive manner.
    //
    NSAssert(_listFeedConnection != nil, @"Failure to create URL connection.");
    
    // show in the status bar that network activity is starting
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    
}


// -------------------------------------------------------------------------------
//	handleError:error
//  Reports any error with an alert which was received from connection or loading failures.
// -------------------------------------------------------------------------------
- (void)handleError:(NSError *)error{
    NSString *errorMessage = [error localizedDescription];
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Show Top Paid Apps"
                                                        message:errorMessage
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil] ;
    [alertView show];
    [alertView release];
}

// The following are delegate methods for NSURLConnection. Similar to callback functions, this is how
// the connection object,  which is working in the background, can asynchronously communicate back to
// its delegate on the thread from which it was started - in this case, the main thread.
//
#pragma mark - NSURLConnectionDelegate

// -------------------------------------------------------------------------------
//	connection:didReceiveResponse:response
//  Called when enough data has been read to construct an NSURLResponse object.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response{
    self.listData = [NSMutableData data];    // start off with new data
}

// -------------------------------------------------------------------------------
//	connection:didReceiveData:data
//  Called with a single immutable NSData object to the delegate, representing the next
//  portion of the data loaded from the connection.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [self.listData appendData:data];  // append incoming data
}

// -------------------------------------------------------------------------------
//	connection:didFailWithError:error
//  Will be called at most once, if an error occurs during a resource load.
//  No other callbacks will be made after.
// -------------------------------------------------------------------------------
- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error{
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if (error.code == kCFURLErrorNotConnectedToInternet)
    {
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"No Connection Error"};
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
                                                         code:kCFURLErrorNotConnectedToInternet
                                                     userInfo:userInfo];
        [self handleError:noConnectionError];
    }
    else
    {
        // otherwise handle the error generically
        [self handleError:error];
    }
    
    self.listFeedConnection = nil;   // release our connection
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
}

// -------------------------------------------------------------------------------
//	connectionDidFinishLoading:connection
//  Called when all connection processing has completed successfully, before the delegate
//  is released by the connection.
// -------------------------------------------------------------------------------
- (void)connectionDidFinishLoading:(NSURLConnection *)connection{
    [_listFeedConnection release];
    _listFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    // create the queue to run our ParseOperation
    _queue = [[NSOperationQueue alloc] init];
    
    // create an ParseOperation (NSOperation subclass) to parse the JSON feed data
    // so that the UI is not blocked
    ParseOperation *parser = [[[ParseOperation alloc] initWithData:_listData] autorelease] ;
    
    parser.errorHandler = ^(NSError *parseError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self handleError:parseError];
        });
    };
    
    // Referencing parser from within its completionBlock would create a retain cycle.
    __unsafe_unretained ParseOperation *weakParser = parser;
    
    parser.completionBlock = ^(void) {
        if (weakParser.aboutRecordList) {
            // The completion block may execute on any thread.  Because operations
            // involving the UI are about to be performed, make sure they execute
            // on the main thread.
            dispatch_async(dispatch_get_main_queue(), ^{
                // The root rootViewController is the only child of the navigation
                // controller, which is the window's rootViewController.
                RootViewController *rootViewController = (RootViewController*)[(UINavigationController*)self.window.rootViewController topViewController];
                
                // set nav bar title
                rootViewController.title = weakParser.tableTitle;
                // set loaded entries to Controller
                rootViewController.entries = weakParser.aboutRecordList;
                // turn off refresh, if running
                [rootViewController.refreshControl endRefreshing];
                
                // tell our table view to reload its data, now that parsing has completed
                [rootViewController.tableView reloadData];
            });
        }
        
        // we are finished with the queue and our ParseOperation
        [_queue release];
        _queue = nil;
    };
    
    [_queue addOperation:parser]; // this will start the "ParseOperation"
    
    // ownership of listData has been transferred to the parse operation
    // and should no longer be referenced in this thread
    
    [_listData release];
    _listData = nil;
    
    NSURLCache *sharedCache = [[NSURLCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:nil];
    [NSURLCache setSharedURLCache:sharedCache];
    [sharedCache release];
}


-(void)dealloc{
    [_window release];
    [super dealloc];
}
@end
