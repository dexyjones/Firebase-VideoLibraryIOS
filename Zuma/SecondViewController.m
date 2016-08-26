//
//  SecondViewController.m
//  Zuma
//
//  Created by Kemgadi Nwachukwu on 8/14/16.
//  Copyright © 2016 4Bars Technologies. All rights reserved.
//

#import "SecondViewController.h"



@interface SecondViewController (){
    AVPlayerViewController *myAVPlayerViewController;
}

@end

@implementation SecondViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - AVPlayerViewControllerDelegate
-(BOOL)playerViewControllerShouldAutomaticallyDismissAtPictureInPictureStart:(AVPlayerViewController *)playerViewController{
    return YES;
}

-(void)playerViewController:(AVPlayerViewController *)playerViewController restoreUserInterfaceForPictureInPictureStopWithCompletionHandler:(void (^)(BOOL))completionHandler{
    [self presentViewController:playerViewController animated:YES completion:nil];
    NSLog(@"restoreUserInterfaceForPictureInPictureStopWithCompletionHandler");
    
}

//optional
- (void)playerViewControllerWillStartPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerWillStartPictureInPicture");
}

- (void)playerViewControllerDidStartPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerDidStartPictureInPicture");
}

- (void)playerViewController:(AVPlayerViewController *)playerViewController failedToStartPictureInPictureWithError:(NSError *)error{
    NSLog(@"failedToStartPictureInPictureWithError");
}

- (void)playerViewControllerWillStopPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerWillStopPictureInPicture");
}

- (void)playerViewControllerDidStopPictureInPicture:(AVPlayerViewController *)playerViewController{
    NSLog(@"playerViewControllerDidStopPictureInPicture");
}

 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
     if([[segue identifier] isEqualToString:@"moviePlayer"]){
        myAVPlayerViewController=(AVPlayerViewController *)segue.destinationViewController;
         NSURL *videoURl = [NSURL URLWithString:@"https://r6---sn-q4fl6ne7.googlevideo.com/videoplayback?lmt=1457626020398520&expire=1472253816&ratebypass=yes&ipbits=0&nh=IgpwcjAzLmRmdzA2KgkxMjcuMC4wLjE&requiressl=yes&initcwndbps=190000&mime=video/mp4&pl=44&source=youtube&sver=3&dur=221.773&mv=m&mt=1472231789&ms=au&id=o-AF8eVfcvepF0EQ2m4O9HNCizT80HMwngcmQ5V16Dpp4J&mn=sn-q4fl6ne7&sparams=dur,id,initcwndbps,ip,ipbits,itag,lmt,mime,mm,mn,ms,mv,nh,pl,ratebypass,requiressl,source,upn,expire&signature=7C9D8FA10548D0259F74ABD85D5342C2BF020BD6.6E262C1747470C17C4A2F36950B593C7D6E38681&key=yt6&ip=2600:100d:b027:c12:dc69:da74:540c:d80b&itag=18&upn=aVmO98ikuYU&mm=31&signature=18"];
         myAVPlayerViewController.player=[AVPlayer playerWithURL:videoURl];
         myAVPlayerViewController.delegate=self;
         [myAVPlayerViewController.player play];
         
     }

 }

@end
