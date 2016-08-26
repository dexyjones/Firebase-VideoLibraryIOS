//
//  Menu.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/23/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject

@property(strong, nonatomic) NSString *menuType;
@property(strong, nonatomic) NSString *menuTitle;
@property(strong, nonatomic) NSMutableArray  *videoItems;

-(BOOL)isFeaturedMenu;
-(void)sortVideoItemsArray;
@end
