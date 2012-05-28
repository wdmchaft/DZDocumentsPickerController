
//
//  DZServicesManager.h
//  DZDocumentsPickerController
//
//  Created Ignacio Romero Zurbuchen on 5/4/12.
//  Copyright (c) 2011 DZen Interaktiv.
//  Licence: MIT-Licence
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"

#import <DropboxSDK/DropboxSDK.h>
#import "Cloud.h"
#import <LiveSDK/LiveConnectClient.h>

#import "DZDocument.h"
#import "DZAlertCenter.h"

typedef enum {ServiceTypeDropbox, ServiceTypeCloudApp, ServiceTypeiCloud, ServiceTypeGoogleDrive, ServiceTypeSkyDrive, ServiceTypeSugarSync,ServiceTypeBOX} ServiceType;
NSString *const ServicesTypeArr[7];

@protocol DZServicesManagerDelegate;

@interface DZServicesManager : NSObject <DBRestClientDelegate, CLAPIEngineDelegate,
                                            LiveAuthDelegate, LiveOperationDelegate,
                                            NSURLConnectionDelegate>
{
    DZAlertCenter *alrtCenter;
    AppDelegate *appDelegate;
    
    NSMutableData *loadingData;
    NSUInteger dataTotalSize;
}

@property (nonatomic, strong) id <DZServicesManagerDelegate> delegate;

@property (nonatomic, strong) NSDictionary *downloadingFileInfo;
@property (nonatomic, assign) DocumentType allowedDocuments;
@property (nonatomic, assign) ServiceType currentService;

@property (nonatomic, copy) DBRestClient *dropboxClient;
@property (nonatomic, copy) CLAPIEngine *cloudappClient;
@property (nonatomic, copy) LiveConnectClient *skydriveClient;

@property (nonatomic, strong) UIViewController *parentViewController;

- (id)initWithDelegate:(id)applicationDelegate;

- (void)prepareForLogin;
- (void)loginWithInfo:(NSDictionary *)userInfo;

- (void)loadFilesAtPath:(NSString *)filepath;
- (void)reloadAtPath:(NSString *)path;
- (void)downloadFileAtPath:(NSString *)webpath intoLocalPath:(NSString *)localpath;
- (void)cancelDownloading;
- (void)logOut;

+ (NSString *)serviceTypeToString:(ServiceType)type;
+ (NSArray *)servicesSupported;


@end


@protocol DZServicesManagerDelegate <NSObject>
@optional
- (void)servicesManager:(DZServicesManager *)manager didLoadFiles:(NSArray *)files;
- (void)servicesManager:(DZServicesManager *)manager didDownloadFile:(NSDictionary *)info;
- (void)servicesManagerDidCancelDownload:(DZServicesManager *)manager;
- (void)servicesManagerDidCancelLogin:(DZServicesManager *)manager;
- (void)servicesManagerDidLogOut:(DZServicesManager *)manager;
@end
