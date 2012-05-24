
//
//  AppDelegate.h
//  SimpleDocumentPicker
//
//  Created Ignacio Romero Zurbuchen on 4/16/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import "AppDelegate.h"
#import "RootViewController.h"

@interface AppDelegate() <DBSessionDelegate>
@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize viewController = _viewController;
@synthesize session, relinkUserId;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone)
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPhone" bundle:nil];
    }
    else
    {
        self.viewController = [[ViewController alloc] initWithNibName:@"ViewController_iPad" bundle:nil];
    }
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [self startDropboxSession];
    
    return YES;
}

- (void)startDropboxSession
{
    NSString *key = [self getSettingsForObjectForKey:@"Dropbox App Key"];
    NSString *secret = [self getSettingsForObjectForKey:@"Dropbox App Secret"];
    NSString *root = @"dropbox";
    
    [self setSession:nil];
    session = [[DBSession alloc] initWithAppKey:key appSecret:secret root:root];
	session.delegate = self;
	[DBSession setSharedSession:session];
}

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
	relinkUserId = userId;
	[[[UIAlertView alloc] initWithTitle:@"Dropbox Error" message:@"An error was produced. Please try in a little while." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
}


- (id)getSettingsForObjectForKey:(NSString *)objKey
{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Cloud-Settings" ofType:@"plist"];
    NSDictionary *loadedPlist = [NSDictionary dictionaryWithContentsOfFile:path];
    return [loadedPlist objectForKey:objKey];
}

- (void)applicationWillResignActive:(UIApplication *)application
{

}

- (void)applicationDidEnterBackground:(UIApplication *)application
{

}

- (void)applicationWillEnterForeground:(UIApplication *)application
{

}

- (void)applicationDidBecomeActive:(UIApplication *)application
{

}

- (void)applicationWillTerminate:(UIApplication *)application
{

}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([[DBSession sharedSession] handleOpenURL:url])
    {
        if ([[DBSession sharedSession] isLinked])
        {
            if (self.viewController.docPickerController.servicesManager.currentService == ServiceTypeDropbox)
                [self.viewController.docPickerController.servicesManager prepareForLogin];
        }
        return YES;
    }
    
    return NO;
}


@end
