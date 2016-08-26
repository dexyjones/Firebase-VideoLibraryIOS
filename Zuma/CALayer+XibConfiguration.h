//
//  CALayer+XibConfiguration.h
//  Brazz
//
//  Created by Kemgadi Nwachukwu on 1/2/16.
//  Copyright © 2016 4Barzup. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import <UIKit/UIKit.h>

@interface CALayer(XibConfiguration)

// This assigns a CGColor to borderColor.
@property(nonatomic, assign) UIColor* borderUIColor;

@end