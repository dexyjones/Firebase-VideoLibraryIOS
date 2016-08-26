//
//  VideoFile.h
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/16/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface VideoFile : NSObject
/*completion blocks to use to notify UI/listeners when async image download is complete/failed */
typedef void (^itemImageDownloadedCompletionBlock)(VideoFile *theVideoFile);
typedef void (^itemImageDownloadedErrorBlock)(NSError *theError);

/*used for sorting if needed*/
@property(strong, nonatomic) NSString *menuItemDescriptor;
/*used to lookup the actual video node in db */
@property(strong, nonatomic) NSString *videoItemNodeName;

/*properties below that match the video properties when the node is found in db */
@property(strong, nonatomic) NSString *name;
@property(strong, nonatomic) NSString *videoFile;
@property(strong, nonatomic) NSString *albumCoverUrl;
@property(strong, nonatomic) UIImage *albumImage;

/*just a tracker to see if the video meta data has been loaded for this object*/
@property( nonatomic) BOOL videoNodeLoaded;
/*gets the cover image from the server*/
-(void)getCoverImageWithCompletionBlock:(itemImageDownloadedCompletionBlock) completionBlock andErrorBlock:(itemImageDownloadedErrorBlock)errorBlock;
@end
