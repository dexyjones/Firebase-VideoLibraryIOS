//
//  UIView+RoundedCorners.h
//  Brazz
//
//  Created by Kemgadi Nwachukwu on 2/9/15.
//  Copyright (c) 2015 4Barzup. All rights reserved.
//


#import "UIView+RoundedCorners.h"

@implementation  UIView (RoundedCorners)

-(void)roundCorners:(float)radius{
    self.layer.cornerRadius= radius;
    self.clipsToBounds=YES;
}
-(void)roundCornersDefault{
    [self roundCorners:2];
}
@end
