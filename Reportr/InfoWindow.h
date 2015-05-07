//
//  InfoWindow.h
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InfoWindow : UIView <UIViewControllerTransitioningDelegate>
@property (strong, nonatomic) IBOutlet UIView *backView;
@property (strong, nonatomic) IBOutlet UILabel *time;
@property (strong, nonatomic) IBOutlet UILabel *address_1;
@property (strong, nonatomic) IBOutlet UILabel *companyName;
@property (strong, nonatomic) IBOutlet UIButton *editAppointmentButton;

@end
