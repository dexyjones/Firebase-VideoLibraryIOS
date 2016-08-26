//
//  CALayer+XibConfiguration.m
//  Brazz
//
//  Created by Kemgadi Nwachukwu on 1/2/16.
//  Copyright © 2016 4Barzup. All rights reserved.
//

#import "CALayer+XibConfiguration.h"

@implementation CALayer(XibConfiguration)

-(void)setBorderUIColor:(UIColor*)color
{
    self.borderColor = color.CGColor;
}

-(UIColor*)borderUIColor
{
    return [UIColor colorWithCGColor:self.borderColor];
}

@end