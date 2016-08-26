//
//  TopVideosViewController.m
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/16/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import "TopVideosViewController.h"
#import "TopCarouselCollectionViewCell.h"
#import "UIView+RoundedCorners.h"
#import "MarketPlaceTableViewCell.h"
#import "AppDelegate.h"
#import "VideoFile.h"
#import "HCYoutubeParser.h"
#import "Menu.h"
#import "HorizontalCarouselCollectionView.h"
@import MediaPlayer;
@import AVFoundation;

@interface TopVideosViewController (){
    BOOL pageControlUsed;
    
    //Holds an array of collection views for all the menus
    NSArray *lowerLevelMenusArray;
    NSMutableArray *arrayHoldingCollectionViews;

    
    /*Will be used for Video Play */
    AVPlayerViewController *myAVPlayerViewController;
}

@property (nonatomic) int topCarouselIndex;
@property (nonatomic) int midCarouselIndex;

// [START define_database_reference]

@property (strong, nonatomic) FIRDatabaseReference *dataBaseRef;
/*This is where we'll store meta data for the videos */
@property (strong, nonatomic) FIRDatabaseReference *videosTable;
/*We'll use this to configure the home page of the app */
@property (strong, nonatomic) FIRDatabaseReference *homePageCarousel;
/*We'll use remote config to reconfigure the homescreen based on server controlled preferences */
@property (nonatomic, strong) FIRRemoteConfig *remoteConfig;
@property (nonatomic, strong) NSString *configHomeScreenCarousel;

@end

@implementation TopVideosViewController
FIRDatabaseHandle _refHandle;
NSString *const tagHomeScreenRegionConfig = @"app_default_homescreen";
- (BOOL)canBecomeFirstResponder {
    return YES;
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    


}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // [START get_remote_config_instance]
    self.remoteConfig = [FIRRemoteConfig remoteConfig];
    // [END get_remote_config_instance]
    
    // Create Remote Config Setting to enable developer mode.
    // Fetching configs from the server is normally limited to 5 requests per hour.
    // Enabling developer mode allows many more requests to be made per hour, so developers
    // can test different config values during development.
    // [START enable_dev_mode]
    FIRRemoteConfigSettings *remoteConfigSettings = [[FIRRemoteConfigSettings alloc] initWithDeveloperModeEnabled:YES];
    self.remoteConfig.configSettings = remoteConfigSettings;
    // [END enable_dev_mode]
    
    // Set default Remote Config values. In general you should have in-app defaults for all
    // values that you may configure using Remote Config later on. The idea is that you
    // use the in-app defaults and when you need to adjust those defaults, you set an updated
    // value in the App Manager console. The next time that your application fetches values
    // from the server, the new values you set in the Firebase console are cached. After you
    // activate these values, they are used in your app instead of the in-app defaults. You
    // can set default values using a plist file, as shown here, or you can set defaults
    // inline by using one of the other setDefaults methods.
    // [START set_default_values]
    [self.remoteConfig setDefaultsFromPlistFileName:@"RemoteConfigDefaults"];
    // [END set_default_values]
    
    //get default config from local if offline, or from server if online.
    [self fetchConfig];
    [self setupDataBaseReferences];
    
    //round corners of some UI elements
    for(UIView *aView in self.roundedViews){
        [aView roundCorners:self.roundedCornerRadius];
    }
    

    // continuously montior home page carousel and adjust UI accordingly.
    _refHandle = [self.homePageCarousel observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
        
        NSDictionary *homePageCarouselDict = snapshot.value;
        //NSLog(@"We've got the homePageCarouselDict table from Firebase: ");
        //NSLog(@"%@",homePageCarouselDict);
        
        //Get the menus for the carousel.
        NSMutableDictionary *homePageMenus = [homePageCarouselDict valueForKey:@"menus"];
        if([homePageMenus isKindOfClass:[NSDictionary class]]){
            
            //get Carousels menus for this homepage region and sort according to menu order
            NSArray *sortedKeys = [[homePageMenus allKeys] sortedArrayUsingSelector: @selector(compare:)];
            NSMutableArray *sortedMenuValues = [NSMutableArray array];
    
            
            for (NSString *key in sortedKeys){
                
                //create menu objects
                NSDictionary *menuDict = [homePageMenus objectForKey: key];
                
                
                
                //the menu
                if([menuDict isKindOfClass:[NSDictionary class]]){
                    Menu *aHorizontalMenu = [[Menu alloc] init];
                    //load object from dictionary
                    [aHorizontalMenu setValuesForKeysWithDictionary:menuDict];
                    //resort video items after setValuesforkeys or sometimes they might not be in order
                    [aHorizontalMenu sortVideoItemsArray];
                    [sortedMenuValues addObject: aHorizontalMenu];

                }
            }
            lowerLevelMenusArray = sortedMenuValues;
            arrayHoldingCollectionViews = [[NSMutableArray alloc] init];
            
            //refreshes the table based on the newly updated menu. The menus contain details of the collectionviews/layout style for each table cell.
            [self.tableView reloadData];
            
            
        }//end if NSDictionary valid

    }];//end observe eventtype block

    AppDelegate *appDelegate = (AppDelegate *)[UIApplication sharedApplication].delegate;
    appDelegate.mainVideoViewController = self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
-(void)loadVideoItemsForMenu:(Menu *)theMenu forCollectionView:(UICollectionView *)theCollectionView{
    
    for(VideoFile *aVideoFile in theMenu.videoItems){
        FIRDatabaseReference *videoReference = [self.videosTable child:aVideoFile.videoItemNodeName];
        
        [videoReference observeEventType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            
            //[videoReference observeSingleEventOfType:FIRDataEventTypeValue withBlock:^(FIRDataSnapshot * _Nonnull snapshot) {
            
            //we got a data reference to the videoitem
            NSDictionary *videoDictionary = snapshot.value;
            if([videoDictionary isKindOfClass:[NSDictionary class]]){
                //NSLog(@"Video data item Available for -- %@ --",aVideoFile.videoItemNodeName);
                //NSLog(@"DATA: %@",videoDictionary);
                
                //get previous image url if it exists -- we use this to check image cache later, so we don't download again.
                NSString *previousImageUrl=aVideoFile.albumCoverUrl;
                
                //load object from dictionary
                [aVideoFile setValuesForKeysWithDictionary:videoDictionary];
                aVideoFile.videoNodeLoaded=YES;
                
                
                //do image caching
                if(previousImageUrl && [aVideoFile.albumCoverUrl isEqualToString:previousImageUrl] && aVideoFile.albumImage){
                    //if the image urls are the same send and we've already downloaded the image then don't download again.
                }
                else{
                    //get the image from network.
                    //note that if there is no albumImageUrl defined in DB, this function will just error out
                    [aVideoFile getCoverImageWithCompletionBlock:^(VideoFile *theVideoFile) {
                        //image retrieval successful.
                        [theCollectionView reloadData];
                    } andErrorBlock:^(NSError *theError) {
                        //Video retrieval failed
                    }];
                }

                [theCollectionView reloadData];
            }
        } withCancelBlock:^(NSError * _Nonnull error) {
            //cannot pull video
            NSLog(@"Cannot pull Video data for item: %@ .ERROR: %@",aVideoFile.videoItemNodeName,error.localizedDescription);
            
        }];
    }//end for aVideoFile
}

-(void)setupDataBaseReferences{
    /* store references to key tables/nodes we'll need in the application */
    
    self.dataBaseRef = [[[FIRDatabase database] reference] init];
    FIRDatabaseReference *appRootNodeReference =[self.dataBaseRef child:@"FirebaseTV"];
    //configHomeScreenCarousel is a string
    self.homePageCarousel= [[appRootNodeReference child:@"homePageCarousel"] child:self.configHomeScreenCarousel];
    self.videosTable= [appRootNodeReference child:@"videos"];
}
- (void)fetchConfig {
    self.configHomeScreenCarousel = self.remoteConfig[tagHomeScreenRegionConfig].stringValue;
    
    long expirationDuration = 3600;
    // If in developer mode cacheExpiration is set to 0 so each fetch will retrieve values from
    // the server.
    if (self.remoteConfig.configSettings.isDeveloperModeEnabled) {
        expirationDuration = 0;
    }
    
    // [START fetch_config_with_callback]
    // cacheExpirationSeconds is set to cacheExpiration here, indicating that any previously
    // fetched and cached config would be considered expired because it would have been fetched
    // more than cacheExpiration seconds ago. Thus the next fetch would go to the server unless
    // throttling is in progress. The default expiration duration is 43200 (12 hours).
    [self.remoteConfig fetchWithExpirationDuration:expirationDuration completionHandler:^(FIRRemoteConfigFetchStatus status, NSError *error) {
        if (status == FIRRemoteConfigFetchStatusSuccess) {
            NSLog(@"Config fetched! ");
            [self.remoteConfig activateFetched];
            
        } else {
            NSLog(@"Config not fetched");
            NSLog(@"Error %@", error.localizedDescription);
        }
        
        self.configHomeScreenCarousel = self.remoteConfig[tagHomeScreenRegionConfig].stringValue;
        NSLog(@"HomeScreen Config is: %@",self.configHomeScreenCarousel);
    }];
    // [END fetch_config_with_callback]
}
- (NSString *) getUid {
    NSString *userAuthID=  [FIRAuth auth].currentUser.uid;
    NSLog(@"Get User AuthID is %@",userAuthID);
    return userAuthID;
}


#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    
}
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    // +1 because we have one reserved row for the top carousel, so lets not forget to account for that
    return lowerLevelMenusArray.count ;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {

    //get the menu
    Menu *theMenu = [lowerLevelMenusArray objectAtIndex:indexPath.row];
    MarketPlaceTableViewCell *carouselTableViewCell;

    if([theMenu isFeaturedMenu]){
        //special UI for featured menu
        carouselTableViewCell = (MarketPlaceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"pagedCarousel" forIndexPath:indexPath];
        self.pageControl=carouselTableViewCell.pageControl;
    }
    else{
        //general menu not featured.
        carouselTableViewCell = (MarketPlaceTableViewCell*)[tableView dequeueReusableCellWithIdentifier:@"freeFlowCategories" forIndexPath:indexPath];
    }
        HorizontalCarouselCollectionView *horizontalCarouselCollectionView =carouselTableViewCell.horizontalCollectionViewCarousel;
        if([theMenu isFeaturedMenu]){
            horizontalCarouselCollectionView.isFeaturedCarousel=YES;
        }
        horizontalCarouselCollectionView.delegate=self;
        horizontalCarouselCollectionView.dataSource=self;
        
        UICollectionViewFlowLayout *flowLayout = [[UICollectionViewFlowLayout alloc] init];
        [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];

        
        if(horizontalCarouselCollectionView.isFeaturedCarousel){
            [horizontalCarouselCollectionView setPagingEnabled:YES];
            [flowLayout setMinimumInteritemSpacing:0.0f];
            [flowLayout setMinimumLineSpacing:0.0f];
        }
        else{
            [horizontalCarouselCollectionView  setPagingEnabled:NO];
            [flowLayout setMinimumInteritemSpacing:0.0f];
            [flowLayout setMinimumLineSpacing:4.0f];
        }
        [horizontalCarouselCollectionView setCollectionViewLayout:flowLayout];
    
    //add item to array unique
    if(![arrayHoldingCollectionViews containsObject:horizontalCarouselCollectionView])
    [arrayHoldingCollectionViews addObject:horizontalCarouselCollectionView];
    
        horizontalCarouselCollectionView.carouselMenu=theMenu;
        if(theMenu.menuTitle){
            carouselTableViewCell.menuTitleLabel.text=theMenu.menuTitle;
        }
        else{
            carouselTableViewCell.menuTitleLabel.text=@"";
        }
        [self loadVideoItemsForMenu:theMenu forCollectionView:horizontalCarouselCollectionView];
        
        return carouselTableViewCell;
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    Menu *theMenu =  [lowerLevelMenusArray objectAtIndex:indexPath.row];
    if([theMenu isFeaturedMenu]){
        //use featured height
        return self.topCarouselCellHeight;
    }
    else{
        return self.portraitCarouselCellHeight;
    }
}


#pragma mark - Collection view data source

// Calculate number of sections
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView {
    return 1;
}

// Every section has to have every cell filled, as we need to add empty cells as well to correct the spacing
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    
    
    if( [collectionView isKindOfClass:[HorizontalCarouselCollectionView class] ]){
        //other carousel items
        HorizontalCarouselCollectionView *theHorizontalCarousel = (HorizontalCarouselCollectionView *)collectionView;
        if([theHorizontalCarousel isFeaturedCarousel]){
            self.pageControl.numberOfPages=theHorizontalCarousel.carouselMenu.videoItems.count;
        }
        if(theHorizontalCarousel.carouselMenu.videoItems){
            return theHorizontalCarousel.carouselMenu.videoItems.count;
        }
    }
    return 0;
}


//The user selected the item to play video
-(void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{

    if( [collectionView isKindOfClass:[HorizontalCarouselCollectionView class] ]){
        //other carousel items
        HorizontalCarouselCollectionView *theHorizontalCarousel = (HorizontalCarouselCollectionView *)collectionView;
        if(theHorizontalCarousel.carouselMenu.videoItems){
            
            VideoFile *aVideoFileItem =  [theHorizontalCarousel.carouselMenu.videoItems objectAtIndex:indexPath.row];
            [self performSegueWithIdentifier:@"playVideoSegue" sender:aVideoFileItem];
        }
    }
}


- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    

    //    if (indexPath.row % 2){
    //        //cell.backgroundColor=[UIColor blueColor];
    //        cell.carouselItemLabel.text=@"PARIS";
    //    }
    TopCarouselCollectionViewCell *cell;
    VideoFile *aVideoFileItem;

    if( [collectionView isKindOfClass:[HorizontalCarouselCollectionView class] ]){
        //other carousel items
        HorizontalCarouselCollectionView *theHorizontalCarousel = (HorizontalCarouselCollectionView *)collectionView;
        if([theHorizontalCarousel isFeaturedCarousel]){
            cell = (TopCarouselCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"customCollectionViewFeatured" forIndexPath:indexPath];
        }
        else{
            cell = (TopCarouselCollectionViewCell*)[collectionView dequeueReusableCellWithReuseIdentifier:@"videoItemCollectionViewCell" forIndexPath:indexPath];
        }

        if(theHorizontalCarousel.carouselMenu.videoItems){
            aVideoFileItem =  [theHorizontalCarousel.carouselMenu.videoItems objectAtIndex:indexPath.row];
        }
    }
    
    if(!aVideoFileItem.name){
        cell.carouselItemLabel.text = @"";
    }
    else{
        cell.carouselItemLabel.text = aVideoFileItem.name;
        cell.carouselImageView.image = [UIImage imageNamed:@"default_album_art"];
    }
    
    if(aVideoFileItem.videoFile ){
        //check if the videoFileItem is a youtube video, if it is lets use youtube api for album image instead
        if([aVideoFileItem.videoFile containsString:@"youtube"] && !aVideoFileItem.albumImage){
            [cell.loadingActivityIndicator startAnimating];
            //update videoFile object to use youtube thumbnail and play youtube video url instead.
            [self updateVideoFileForYoutubeVideo:aVideoFileItem collectionViewtoUpdateOnFinish:collectionView theIndexPath:indexPath];
        }
        //if its not youtube video, then lets load our own album image.
        else if(!aVideoFileItem.albumImage){
            cell.carouselImageView.image = [UIImage imageNamed:@"default_album_art"];
            [cell.loadingActivityIndicator startAnimating];
            //cell.carouselImageView.image=[self getArtistImageForIndex:(int)indexPath.row useRandomGenerator:NO];
            
            [aVideoFileItem getCoverImageWithCompletionBlock:^(VideoFile *theVideoFile) {
                [collectionView performBatchUpdates:^{
                    [collectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] ] ];
                } completion:^(BOOL finished) {
                    
                }];//end batch updates
                
                
            } andErrorBlock:^(NSError *theError) {
                [cell.loadingActivityIndicator stopAnimating];
            }];
            
            
        }
        else{
            //else the album image does exist, so set it to cell
            cell.carouselImageView.image=aVideoFileItem.albumImage;
            [cell.loadingActivityIndicator stopAnimating];
        }
    }

    
    return cell;
}

-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath {
    
    
    if( [collectionView isKindOfClass:[HorizontalCarouselCollectionView class] ]){
        //other carousel items
        HorizontalCarouselCollectionView *theHorizontalCarousel = (HorizontalCarouselCollectionView *)collectionView;
        if([theHorizontalCarousel isFeaturedCarousel]){
            return CGSizeMake(theHorizontalCarousel.frame.size.width,theHorizontalCarousel.frame.size.height);
        }
        else{
            float width=collectionView.frame.size.width/2.5;
            //float width = midCarouselCell.cellHeight;
            return CGSizeMake(width,collectionView.frame.size.height);
        }
    }
    return CGSizeMake(0.0,0.0);
}

-(void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator{
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    [coordinator animateAlongsideTransition:nil completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        for(UICollectionView *aCollectionView in arrayHoldingCollectionViews){
            [aCollectionView performBatchUpdates:^{
                [aCollectionView setCollectionViewLayout:aCollectionView.collectionViewLayout animated:YES];
            } completion:^(BOOL finished) {
                
            }];
        }
    }];
}
/*
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
//    [self.collectionViewTopCarousel setAlpha:0.0f];
//    [self.collectionViewMidCarousel setAlpha:0.0f];
//    [self.collectionViewTopCarousel.collectionViewLayout invalidateLayout];
//    [self.collectionViewMidCarousel.collectionViewLayout invalidateLayout];
    
    CGPoint currentOffset = [self.collectionViewTopCarousel contentOffset];
    self.topCarouselIndex = currentOffset.x / self.collectionViewTopCarousel.frame.size.width;
    
//    CGPoint currentOffset2 = [self.collectionViewMidCarousel contentOffset];
//    self.midCarouselIndex = currentOffset2.x / self.collectionViewMidCarousel.frame.size.width;
}
-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    NSIndexPath *indexPath = [NSIndexPath indexPathForItem:self.topCarouselIndex inSection:0];
    
    [self.collectionViewTopCarousel scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
    
    [UIView animateWithDuration:0.125f animations:^{
        [self.collectionViewTopCarousel setAlpha:1.0f];
    }];
    
    NSIndexPath *indexPath2 = [NSIndexPath indexPathForItem:self.midCarouselIndex inSection:0];
    
//    [self.collectionViewMidCarousel scrollToItemAtIndexPath:indexPath2 atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
//    
//    [UIView animateWithDuration:0.125f animations:^{
//        [self.collectionViewMidCarousel setAlpha:1.0f];
//    }];
}
 */
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    if([sender isKindOfClass:[HorizontalCarouselCollectionView class]]){
        HorizontalCarouselCollectionView *theCollectionViewCarousel=(HorizontalCarouselCollectionView *)sender;
        if([theCollectionViewCarousel isFeaturedCarousel]){
            //only featured carousel has the page control
            // We don't want a "feedback loop" between the UIPageControl and the scroll delegate in
            // which a scroll event generated from the user hitting the page control triggers updates from
            // the delegate method. We use a boolean to disable the delegate logic when the page control is used.
            if (pageControlUsed)
            {
                // do nothing - the scroll was initiated from the page control, not the user dragging
                return;
            }
            else{
                //shut off the automatic slide advance
                //[changeSlideTimer invalidate];
            }
            CGPoint currentOffset = [theCollectionViewCarousel contentOffset];
            self.topCarouselIndex = currentOffset.x / theCollectionViewCarousel.frame.size.width;
            
            
            self.pageControl.currentPage = self.topCarouselIndex;
            
            //self.userNameLabel.text =[ NSString stringWithFormat:@"Current page is %ld",self.pageControl.currentPage ];
            
            
            
            // A possible optimization would be to unload the views+controllers which are no longer visible
        }
    }

}

// At the begin of scroll dragging, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

// At the end of scroll animation, reset the boolean used when scrolls originate from the UIPageControl
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    pageControlUsed = NO;
}

/*
 // Override to support conditional editing of the table view.
 - (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the specified item to be editable.
 return YES;
 }
 */

/*
 // Override to support editing the table view.
 - (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
 if (editingStyle == UITableViewCellEditingStyleDelete) {
 // Delete the row from the data source
 [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
 } else if (editingStyle == UITableViewCellEditingStyleInsert) {
 // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
 }
 }
 */

/*
 // Override to support rearranging the table view.
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
 }
 */

/*
 // Override to support conditional rearranging of the table view.
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
 // Return NO if you do not want the item to be re-orderable.
 return YES;
 }
 */

/*lets have fun with Ipads picture in picture api while we are at it */

#pragma mark - AVPlayerViewControllerDelegate
-(BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController{
    return YES;
}

-(void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler{
    [self presentViewController:playerViewController animated:YES completion:nil];
    NSLog(@"restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
    
}

//optional
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerWillStartPictureInPicture");
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerDidStartPictureInPicture");
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error{
    NSLog(@"failedToStartPictureInPictureWithError");
}

- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerWillStopPictureInPicture");
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerDidStopPictureInPicture");
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"playVideoSegue"]){
        
        if([sender isKindOfClass:[VideoFile class]]){
            VideoFile *theVideoFile = (VideoFile *)sender;
            if(theVideoFile.videoFile){

                
                myAVPlayerViewController=(AVPlayerViewController *)segue.destinationViewController;
                //NSURL *videoURl = [NSURL URLWithString:theVideoFile.videoFile];
                NSURL *videoURl = [NSURL URLWithString:theVideoFile.videoFile];
                myAVPlayerViewController.player=[AVPlayer playerWithURL:videoURl];
                //myAVPlayerViewController.player.allowsExternalPlayback=NO;
                //setup album artwork for OS
                MPMediaItemArtwork *albumArtwork = [[MPMediaItemArtwork alloc] initWithImage:theVideoFile.albumImage];
                NSDictionary *nowPlayingInfo = @{MPMediaItemPropertyTitle: theVideoFile.name,
                                                 MPMediaItemPropertyArtist: @"Unknown Artist",
                                                 MPMediaItemPropertyAlbumTitle: theVideoFile.name,
                                                 MPMediaItemPropertyArtwork: albumArtwork};

                
                
                //[[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
/*
 
                if(theVideoFile.albumImage){

                //[myAVPlayerViewController.contentOverlayView setBackgroundColor:[UIColor colorWithPatternImage:theVideoFile.albumImage]];
                    [myAVPlayerViewController.contentOverlayView setBackgroundColor:[UIColor redColor]];
                
                
                    UIImageView *backGroundImageView = [[UIImageView alloc] initWithImage:theVideoFile.albumImage];
                    [myAVPlayerViewController.contentOverlayView addSubview:backGroundImageView];
                    [backGroundImageView setContentMode:UIViewContentModeScaleAspectFill];
                    [backGroundImageView setFrame:myAVPlayerViewController.view.frame];
                    [myAVPlayerViewController.contentOverlayView sendSubviewToBack:backGroundImageView];

                }
 */               
                myAVPlayerViewController.delegate=self;
                [myAVPlayerViewController.player play];
                double delayInSeconds = 2.0;
                dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
                dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                    //code to be executed on the main queue after delay
                     [[MPNowPlayingInfoCenter defaultCenter] setNowPlayingInfo:nowPlayingInfo];
                });
               
                [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
                //[self becomeFirstResponder];
                
            }
        }

        
    }

}

- (void)remoteControlReceivedWithEvent:(UIEvent *)event {
    UIEventSubtype rc = event.subtype;
    NSLog(@"got a remote event! %ld", (long)rc);
    if (rc == UIEventSubtypeRemoteControlTogglePlayPause) {
        if ([myAVPlayerViewController.player isExternalPlaybackActive])
            [myAVPlayerViewController.player pause];
        else
            [myAVPlayerViewController.player play];
    } else if (rc == UIEventSubtypeRemoteControlPlay) {
        [myAVPlayerViewController.player play];
    } else if (rc == UIEventSubtypeRemoteControlPause) {
        [myAVPlayerViewController.player pause];
    }
}


-(void)refreshAllData{
    [self.tableView reloadData];
}

/*use HCYoutube parser to get youtube video information async*/
-(void)updateVideoFileForYoutubeVideo:(VideoFile *)theVideoFile collectionViewtoUpdateOnFinish:(UICollectionView *)theCollectionView theIndexPath:(NSIndexPath *)indexPath{
    
    //lets assume if we don't have the album image then we havent retrieved the youtube video and thumbnail image yet.
    if(!theVideoFile.albumImage){
        NSURL *url= [NSURL URLWithString:theVideoFile.videoFile];
        
        //get youtube video url through third party library.
        //Note this might violate youtube's TOS, but we hear there are a lot of apps in the app store doing this
        //http://stackoverflow.com/questions/1779511/play-youtube-videos-with-mpmovieplayercontroller-instead-of-uiwebview
        //lets get thumbnail and video file url
        [HCYoutubeParser thumbnailForYoutubeURL:url thumbnailSize:YouTubeThumbnailDefaultHighQuality completeBlock:^(UIImage *youtubeThumbnailImage, NSError *error) {
            
            if (!error) {
                
                [HCYoutubeParser h264videosWithYoutubeURL:url completeBlock:^(NSDictionary *videoDictionary, NSError *error) {
                    
                    /*view this dictionary using debugger, there are other fun youtube items in  here that you can play with*/
                    NSDictionary *qualities = videoDictionary;
                    
                    NSString *urlString = nil;
                    
                    //get the best url of the youtube vid
                    if ([qualities objectForKey:@"small"] != nil) {
                        urlString = [qualities objectForKey:@"small"];
                    }
                    if ([qualities objectForKey:@"medium"] != nil) {
                        urlString = [qualities objectForKey:@"medium"];
                    }
                    if ([qualities objectForKey:@"live"] != nil) {
                        urlString = [qualities objectForKey:@"live"];
                    }
                    else {
                        NSLog(@"Couldn't find youtube video for url: %@",theVideoFile.videoFile);
                        theVideoFile.albumImage=[UIImage imageNamed:@"default_album_art"];
                    }
                    if(urlString){
                        theVideoFile.videoFile=urlString;
                        theVideoFile.albumImage=youtubeThumbnailImage;
                        [theCollectionView performBatchUpdates:^{
                            [theCollectionView reloadItemsAtIndexPaths:@[[NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section] ] ];
                        } completion:^(BOOL finished) {
                            
                        }];//end batch updates
                    }
                }];
            }
            else {
                NSLog(@"There was a general error loading youtube url: %@ Error: %@",theVideoFile, error.localizedDescription);
                
            }
        }];
    }
}

//just a random image getter
-(UIImage *)getArtistImageForIndex:(int)index useRandomGenerator:(BOOL)randomPick{
    UIImage *artistImage;
    if(randomPick){
        index=arc4random_uniform(6);
    }
    
    switch(index){
        case 0:
            //drake
            artistImage = [UIImage imageNamed:@"drakefader"];
            break;
        case 1:
            //rihanna
            artistImage = [UIImage imageNamed:@"rihanna"];
            break;
        case 2:
            //avicii
            artistImage = [UIImage imageNamed:@"avicii"];
            break;
        case 3:
            //diplo
            artistImage = [UIImage imageNamed:@"diplo"];
            break;
        case 4:
            //diplo
            artistImage = [UIImage imageNamed:@"jenniferlopez"];
            break;
        case 5:
            //diplo
            artistImage = [UIImage imageNamed:@"hanslanda"];
            break;
            
        default:
            artistImage = [UIImage imageNamed:@"drakefader"];
            break;
    }
    return artistImage;
}
@end
