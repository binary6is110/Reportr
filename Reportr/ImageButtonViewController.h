//
//  ImageButtonViewController.h
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageButtonViewController : UIViewController

-(void) updateImageIconWithSuccess: (NSNotification *)notification;
-(void) resetImageIconWithSuccess: (NSNotification *)notification;
@end
