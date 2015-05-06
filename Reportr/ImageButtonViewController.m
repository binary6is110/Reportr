//
//  ImageButtonViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ImageButtonViewController.h"

@interface ImageButtonViewController ()

@end

@implementation ImageButtonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageIconWithSuccess:)
                                                 name:@"addImageComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetImageIconWithSuccess:)
                                                 name:@"resetPhotoImage" object:nil];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**-(void) updateImageIconWithSuccess: (NSNotification *)notification
 TODO: Update icon image to reflect image for appointment */
-(void) updateImageIconWithSuccess: (NSNotification *)notification{
    NSLog(@"VideoButtonViewController::updateVideoIconWithSuccess, %@",notification.object);
    [_cameraImg setImage:[UIImage imageNamed:@"cameraIcon_recording.png"]];
}

/**-(void) resetImageIconWithSuccess: (NSNotification *)notification
 TODO: Reset icon image to reflect image for appointment */
-(void) resetImageIconWithSuccess: (NSNotification *)notification{
    NSLog(@"VideoButtonViewController::resetVideoIconWithSuccess, %@",notification.object);
    [_cameraImg setImage:[UIImage imageNamed:@"cameraIcon.png"]];
}

@end
