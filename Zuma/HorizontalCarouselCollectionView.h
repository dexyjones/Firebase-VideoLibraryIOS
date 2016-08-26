//
//  HorizontalCarouselCollectionView.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/24/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Menu.h"

@interface HorizontalCarouselCollectionView : UICollectionView

/*the menu of items in this collectionview*/
@property(strong, nonatomic) Menu *carouselMenu;
@property( nonatomic) BOOL isFeaturedCarousel;
@end
