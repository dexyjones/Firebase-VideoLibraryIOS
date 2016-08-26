//
//  AppDelegate.m
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/14/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import "AppDelegate.h"
#import "Firebase.h"
#include <sys/sysctl.h>
#import "NSBundle+CTFeedback.h"
#import "TopVideosViewController.h"

@import UIKit;

@interface AppDelegate ()

@property (strong, nonatomic,nullable) FIRUser *currentUser;
@property (strong, nonatomic,nullable) FIRDatabaseReference *activeUserRecord;
@property (strong, nonatomic,nullable) FIRDatabaseReference *myAppUserEntry;
@property (strong, nonatomic,nullable) FIRDatabaseReference *dataBaseRef;
/*keeps live track of current active users */
@property (strong, nonatomic) FIRDatabaseReference *activeUsersTable;
/*keeps live track of users all time - A data extension of the firebase user table*/
@property (strong, nonatomic) FIRDatabaseReference *appUsersTable;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
  
    //for background audio playback
    NSError *anError;
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&anError];
    //[[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&anError];
    if(anError){
        NSLog(@"Background audio error %@",anError.localizedDescription);
    }
//    NSError *error;
//    if (![[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error])
//    {
//        NSLog(@"audio session error: %@", error);
//    }

    //Initialize firebase and start firebase analytics to your console
    [FIRApp configure]; 

    /*persist database writes to disk when there is loss of network connection and persist thru app restarts*/
    [FIRDatabase database].persistenceEnabled = YES;
    
    [self setupDataBaseReferences];
    [self signInGuestUser];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}
-(void)setupDataBaseReferences{
    /* store references to key tables/nodes we'll need in the application */
    
    self.dataBaseRef = [[[FIRDatabase database] reference] init];
    FIRDatabaseReference *appRootNodeReference =[self.dataBaseRef child:@"FirebaseTV"];
    //configHomeScreenCarousel is a string
    self.activeUsersTable= [appRootNodeReference child:@"ActiveUsers"] ;
    self.appUsersTable= [appRootNodeReference child:@"AppUsers"];
}
-(void)checkUserAuthenticationState{
    if(![[FIRAuth auth] currentUser]){
        NSLog(@"Current user: %@ is INSACTIVE ",[FIRAuth auth].currentUser.uid);
        NSLog(@"Signing in guest user again");
        [self signInGuestUser];
    }
    else{
        NSLog(@"Current user: %@ is still active ",[FIRAuth auth].currentUser.uid);
        self.currentUser = [FIRAuth auth].currentUser;
        [self signInGuestUser];
        //[self takeUserOnline];
    }
}
-(void)signInGuestUser{
    [[FIRAuth auth]
     signInAnonymouslyWithCompletion:^(FIRUser *_Nullable user, NSError *_Nullable error) {
         // ...
         if(error){
             //throw signin fail
             NSLog(@"Problem while signing in %@",error.localizedDescription);
         }
         else{
             BOOL isAnonymous = user.anonymous;  // YES
             NSString *uid = user.uid;
             NSLog(@"New Anonymous user created with user id: %@",uid);
             self.currentUser = user;
             [self takeUserOnline];
         }
     }];
}

-(void)takeUserOnline{

    NSDateFormatter *dateFormatter=[[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"yyyy-MM-dd hh:mm:ss"]; // Date formater
    [dateFormatter setTimeZone:[NSTimeZone timeZoneWithName:@"CDT"]];
    NSString *dateString = [dateFormatter stringFromDate:[NSDate date]];

    NSLog(@"%@",dateString);
    UIDevice *currentDevice=[UIDevice currentDevice];
    NSString *platFormName = [self platformString];
    if(platFormName==nil){
        platFormName=@"Unknown Platform";
    }
    NSDictionary *newActiveUser = @{@"go_online_time": dateString,
                                    @"last_ping_time": [FIRServerValue timestamp],
                                    @"userID": self.currentUser.uid,
                                    @"deviceName": currentDevice.name,
                                    @"deviceType": [self platformString]};
    NSDictionary *userTableRecordUpdate = @{@"go_online_time": dateString,
                                            @"last_ping_time": dateString,
                                            @"userID": self.currentUser.uid,
                                            @"deviceName": currentDevice.name,
                                            @"deviceType": [self platformString]};
    
    self.activeUserRecord = [self.activeUsersTable  child:self.currentUser.uid];
    self.myAppUserEntry = [self.appUsersTable child:self.currentUser.uid];
    
    
    [self.myAppUserEntry updateChildValues:userTableRecordUpdate withCompletionBlock:^(NSError * _Nullable error, FIRDatabaseReference * _Nonnull ref) {
        if(error){
            NSLog(@"There is an error updating user session: %@",[error localizedDescription]);
        }
        else{
            NSLog(@"Updated user server session");
        }
    }];
    [self.activeUserRecord setValue: newActiveUser];
    [self.activeUserRecord onDisconnectRemoveValue];
    
    [self.mainVideoViewController refreshAllData];
    
  }
- (NSString *)platformString
{
    //return @"unknown";
    NSString *platform = [self platform];

    // Reading a file with platform names
    // http://theiphonewiki.com/wiki/Models
    NSBundle *bundle = [NSBundle feedbackBundle];
    NSString *filePath = [bundle pathForResource:@"PlatformNames" ofType:@"plist"];
    NSDictionary *platformNamesDic = [NSDictionary dictionaryWithContentsOfFile:filePath];

    // Changing a platform name to a human readable version
    platform = platformNamesDic[platform];
    
    return platform;
}
- (NSString *)platform
{
    int mib[2];
    size_t len;
    char *machine;
    
    mib[0] = CTL_HW;
    mib[1] = HW_MACHINE;
    sysctl(mib, 2, NULL, &len, NULL, 0);
    machine = malloc(len);
    sysctl(mib, 2, machine, &len, NULL, 0);
    
    NSString *platform = [NSString stringWithCString:machine encoding:NSASCIIStringEncoding];
    free(machine);
    return platform;
}
@end
