//
//  TopCarouselCollectionViewCell.m
//  Brazz
//
//  Created by Kemgadi Nwachukwu on 12/31/15.
//  Copyright © 2015 4Barzup. All rights reserved.
//

#import "TopCarouselCollectionViewCell.h"

@implementation TopCarouselCollectionViewCell

-(void)awakeFromNib{
    if(self.innerUIView)
    [self.innerUIView.layer setBorderColor:self.viewBorderColor.CGColor];
}
@end
