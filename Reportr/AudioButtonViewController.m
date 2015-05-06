//
//  AudioButtonViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AudioButtonViewController.h"

@interface AudioButtonViewController ()

@end

@implementation AudioButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAudioIconWithSuccess:)
                                                 name:@"addAudioComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetAudioIconWithSuccess:)
                                                 name:@"resetAudioImage" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**-(void) updateAudioeIconWithSuccess: (NSNotification *)notification
 TODO: Update icon image to reflect audio for appointment */
-(void) updateAudioIconWithSuccess: (NSNotification *)notification{
    NSLog(@"VideoButtonViewController::updateAudioIconWithSuccess, %@",notification.object);
    [_micImg setImage:[UIImage imageNamed:@"micIcon_recording.png"]];
}

/**-(void) resetAudioIconWithSuccess: (NSNotification *)notification
 TODO: Reset icon image to reflect audio for appointment */
-(void) resetAudioIconWithSuccess: (NSNotification *)notification{
    NSLog(@"VideoButtonViewController::resetAudioIconWithSuccess, %@",notification.object);
    [_micImg setImage:[UIImage imageNamed:@"micIcon.png"]];
}

@end
