//
//  VideoFile.m
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/16/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import "VideoFile.h"
@import FirebaseStorage;


@implementation VideoFile



- (void)setValue:(id)value forUndefinedKey:(NSString *)key {
    return;
}

-(void)getCoverImageWithCompletionBlock:(itemImageDownloadedCompletionBlock) completionBlock andErrorBlock:(itemImageDownloadedErrorBlock)errorBlock{
    
    
    FIRStorage *storage = [FIRStorage storage];
    // Create a storage reference from our storage service
    // This is equivalent to creating the full reference
    //    FIRStorageReference *spaceRef = [storage referenceForURL:@"gs://project-3717062505040751407.appspot.com/placeImages/beyonce_concert@2x.jpg"];
    if(!self.albumCoverUrl){
        if(errorBlock){
            errorBlock(nil);
        }
        return;
    }
    
    FIRStorageReference *imageReference;
    @try {
        
       imageReference = [storage referenceForURL:self.albumCoverUrl];
    }
    @catch (NSException *exception) {
        //Save the exception
        NSLog(@"Exception while loading firebase files, make sure the file URL's are pointing to your own firebase account");
        NSLog(@"%@",exception.description);
    }
    @finally {
        if(!imageReference){
            if(errorBlock){
                errorBlock(nil);
            }
            return;
        }
    }
    // Download in memory with a maximum allowed size of 1MB (1 * 1024 * 1024 bytes)
    [imageReference dataWithMaxSize:10 * 1024 * 1024  completion:^(NSData * _Nullable data, NSError * _Nullable error) {
        if (error != nil) {
            // Uh-oh, an error occurred!
            switch (error.code) {
                case FIRStorageErrorCodeObjectNotFound:
                    // File doesn't exist
                    break;
                    
                case FIRStorageErrorCodeUnauthorized:
                    // User doesn't have permission to access file
                    break;
                    
                case FIRStorageErrorCodeCancelled:
                    // User canceled the upload
                    break;
                    
                case FIRStorageErrorCodeUnknown:
                    // Unknown error occurred, inspect the server response
                    break;
            }
            NSLog(@"Error retrieving File for: %@ Error: %@",self.name,error.localizedDescription);
            //We'll create error block later
            if(errorBlock){
                errorBlock(error);
            }
            
        } else {
            NSLog(@"Retrieved image for %@",self.name);
             //Data for image is returned
            self.albumImage = [UIImage imageWithData:data];
            if(completionBlock){
                completionBlock(self);
            }
        }
    }];

}

@end
