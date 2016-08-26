//
//  TopVideosViewController.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/16/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVKit/AVKit.h>
#import <AVFoundation/AVFoundation.h>
#import "Firebase.h"
@import FirebaseAuth;
@import FirebaseDatabase;
@import FirebaseRemoteConfig;


@interface TopVideosViewController : UIViewController<UICollectionViewDataSource, UICollectionViewDelegate,UITableViewDataSource,UITableViewDelegate ,AVPlayerViewControllerDelegate>

@property (strong, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundedViews;
@property (nonatomic) IBInspectable float roundedCornerRadius;
@property (nonatomic) IBInspectable float topCarouselCellHeight;
@property (nonatomic) IBInspectable float portraitCarouselCellHeight;

- (NSString *) getUid;
-(void)refreshAllData;
@end
