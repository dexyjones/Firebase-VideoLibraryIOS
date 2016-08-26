//
//  MarketPlaceTableViewCell.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 1/4/16.
//  Copyright © 2016 4Barzup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"
#import "HorizontalCarouselCollectionView.h"

@interface MarketPlaceTableViewCell : UITableViewCell
@property  (nonatomic,weak) IBOutlet UILabel * menuTitleLabel;
@property (strong, nonatomic) Menu *assignedMenu;
@property (weak, nonatomic) IBOutlet HorizontalCarouselCollectionView *horizontalCollectionViewCarousel;

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *roundedViews;
@property (nonatomic) IBInspectable float roundedCornerRadius;


@end
