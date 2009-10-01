#import "___PROJECTNAMEASIDENTIFIER___AppDelegate.h"

#import "RootViewController.h"

@implementation ___PROJECTNAMEASIDENTIFIER___AppDelegate

@synthesize window;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    [window addSubview:[navigationController view]];
    [window makeKeyAndVisible];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Save data if appropriate
}

#pragma mark -
#pragma mark Memory management

- (void)dealloc {
    [navigationController release];
    [window release];
    [super dealloc];
}

@end
