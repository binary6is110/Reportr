//
//  AudioButtonViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AudioButtonViewController.h"
#import "ApplicationModel.h"
#import "AppointmentModel.h"

@interface AudioButtonViewController ()

@end

@implementation AudioButtonViewController
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    appModel = [ApplicationModel sharedApplicationModel];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioIconWithSuccess:)
                                                 name:@"addAudioComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAudioIconWithSuccess:)
                                                 name:@"resetAudioImage" object:nil];    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioIcon)
                                                 name:@"checkAudiIcon" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**-(void) updateAudioIcon
 Sets icon image to reflect audio for appointment */
-(void) updateAudioIcon{
    if(appModel.appointment.hasAudio){
        [_micImg setImage:[UIImage imageNamed:@"micRecorded_125x122.png"]];
    }else {
        [_micImg setImage:[UIImage imageNamed:@"mic_125x122.png"]];
    }
}

/**-(void) updateAudioeIconWithSuccess: (NSNotification *)notification
 TODO: Update icon image to reflect audio for appointment */
-(void) updateAudioIconWithSuccess: (NSNotification *)notification{
    //NSLog(@"VideoButtonViewController::updateAudioIconWithSuccess, %@",notification.object);
    [_micImg setImage:[UIImage imageNamed:@"micRecorded_125x122.png"]];
}

/**-(void) resetAudioIconWithSuccess: (NSNotification *)notification
 TODO: Reset icon image to reflect audio for appointment */
-(void) resetAudioIconWithSuccess: (NSNotification *)notification{
   // NSLog(@"VideoButtonViewController::resetAudioIconWithSuccess, %@",notification.object);
    [_micImg setImage:[UIImage imageNamed:@"mic_125x122.png"]];
}

@end
