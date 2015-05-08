//
//  VideoButtonViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "VideoButtonViewController.h"
#import "ApplicationModel.h"
#import "AppointmentModel.h"

@interface VideoButtonViewController ()
@property (strong, nonatomic) IBOutlet UIImageView *videoImg;

@end

@implementation VideoButtonViewController
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    appModel = [ApplicationModel sharedApplicationModel];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateVideoIconWithSuccess:)
                                                 name:@"addVideoComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetVideoIconWithSuccess:)
                                                 name:@"resetVideoImage" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioIcon)
                                                 name:@"checkAudioIcon" object:nil];
}

/**-(void) updateAudioIcon
 Sets icon image to reflect video for appointment */
-(void) updateAudioIcon{
    if(appModel.appointment.hasVideo){
        [_videoImg setImage:[UIImage imageNamed:@"videoRecorded_125x122.png"]];
    }else {
        [_videoImg setImage:[UIImage imageNamed:@"video_125x122.png"]];
    }
}

/**-(void) updateVideoIconWithSuccessvid: (NSNotification *)notification
   Updates icon image to reflect video for appointment */
-(void) updateVideoIconWithSuccess: (NSNotification *)notification{
   // NSLog(@"VideoButtonViewController::updateVideoIconWithSuccess, %@",notification.object);
    [_videoImg setImage:[UIImage imageNamed:@"videoRecorded_125x122.png"]];
}

/**-(void) resetVideoIconWithSuccessvid: (NSNotification *)notification
    Reset icon image to reflect video for appointment */
-(void) resetVideoIconWithSuccess: (NSNotification *)notification{
   // NSLog(@"VideoButtonViewController::resetVideoIconWithSuccess, %@",notification.object);
    [_videoImg setImage:[UIImage imageNamed:@"video_125x122.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
