//
//  ImageButtonViewController.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ImageButtonViewController.h"
#import "ApplicationModel.h"
#import "AppointmentModel.h"

@interface ImageButtonViewController ()
@property (strong, nonatomic) IBOutlet UIButton *buttonBackground;
@property (strong, nonatomic) IBOutlet UILabel *actionLabel;
@property (strong, nonatomic) IBOutlet UIImageView *cameraImg;
@end

@implementation ImageButtonViewController
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    appModel = [ApplicationModel sharedApplicationModel];
    [self setView];

    // Do any additional setup after loading the view.
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageIconWithSuccess:)
                                                 name:@"addImageComplete" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(resetImageIconWithSuccess:)
                                                 name:@"resetPhotoImage" object:nil];   
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateImageIcon)
                                                 name:@"checkImageIcon" object:nil];

}

-(void) setView{
    self.actionLabel.textColor = [appModel lightBlueColor];
    [[self.buttonBackground layer] setBorderWidth:1.0f];
    [[self.buttonBackground layer] setBorderColor:[appModel darkBlueColor].CGColor];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/**-(void) updateImageIcon
 Sets icon image to reflect image for appointment */
-(void) updateImageIcon{
    if(appModel.appointment.hasImage){
        [_cameraImg setImage:[UIImage imageNamed:@"cameraRecorded_125x122.png"]];
    }else {
        [_cameraImg setImage:[UIImage imageNamed:@"camera_125x122.png"]];
    }
}

/**-(void) updateImageIconWithSuccess: (NSNotification *)notification
 TODO: Update icon image to reflect image for appointment */
-(void) updateImageIconWithSuccess: (NSNotification *)notification{
    //NSLog(@"VideoButtonViewController::updateVideoIconWithSuccess, %@",notification.object);
    [_cameraImg setImage:[UIImage imageNamed:@"cameraRecorded_125x122.png"]];
}

/**-(void) resetImageIconWithSuccess: (NSNotification *)notification
 TODO: Reset icon image to reflect image for appointment */
-(void) resetImageIconWithSuccess: (NSNotification *)notification{
   // NSLog(@"VideoButtonViewController::resetVideoIconWithSuccess, %@",notification.object);
    [_cameraImg setImage:[UIImage imageNamed:@"camera_125x122.png"]];
}

@end
