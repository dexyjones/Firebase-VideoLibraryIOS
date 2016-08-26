//
//  Menu.m
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/23/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import "Menu.h"
#import "VideoFile.h"

@implementation Menu


- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    if([key containsString:@"item"]){
        //we are guessing this is one of the video items
        if(!self.videoItems){
            self.videoItems = [[NSMutableArray alloc] init];
        }
        VideoFile *aNewVideofile=[[VideoFile alloc] init];
        //assign the reference to the node
        aNewVideofile.menuItemDescriptor=key;
        aNewVideofile.videoItemNodeName= value;
        [self.videoItems addObject:aNewVideofile];
        //note that this does not load the data yet, you still have to load the node data to populate the video information.
        //we do that in the TopVideosViewController
    }
    return;
}
-(void)sortVideoItemsArray{
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"menuItemDescriptor"
                                                 ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *sortedArray = [self.videoItems sortedArrayUsingDescriptors:sortDescriptors];
    self.videoItems = [sortedArray mutableCopy];
}

-(BOOL)isFeaturedMenu{
    return [[self.menuType lowercaseString] isEqualToString:@"featured" ];
}
@end
