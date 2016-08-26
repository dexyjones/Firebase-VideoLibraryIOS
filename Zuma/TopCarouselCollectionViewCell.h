//
//  TopCarouselCollectionViewCell.h
//  Brazz
//
//  Created by Kemgadi Nwachukwu on 12/31/15.
//  Copyright © 2015 4Barzup. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CALayer+XibConfiguration.h"

@interface TopCarouselCollectionViewCell : UICollectionViewCell

@property  (nonatomic,weak) IBOutlet UIImageView * carouselImageView;
@property  (nonatomic,weak) IBOutlet UILabel * carouselItemLabel;
@property  (nonatomic,weak) IBOutlet UILabel * shortDescriptionLabel;
@property  (nonatomic,weak) IBOutlet UILabel * countryLabel;
@property  (nonatomic,weak) IBOutlet UIView * innerUIView;
@property  (nonatomic,weak) IBOutlet UIActivityIndicatorView * loadingActivityIndicator;


@property (nonatomic,strong) IBInspectable UIColor*  viewBorderColor;
@end
