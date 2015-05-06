//
//  AudioButtonViewController.h
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioButtonViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIImageView *micImg;
-(void) updateAudioIconWithSuccess: (NSNotification *)notification;
-(void) resetAudioIconWithSuccess: (NSNotification *)notification;
@end
