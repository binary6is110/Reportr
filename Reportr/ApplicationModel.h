//
//  ApplicationModel.h
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

#import "AppointmentModel.h"
#import "UserModel.h"
#import "ContactModel.h"

@interface ApplicationModel : NSObject

@property (nonatomic,retain) AppointmentModel * appointment;

@property (nonatomic,retain) NSMutableArray * appointments;
@property (nonatomic,retain) ContactModel * contact;
@property (nonatomic,retain) UserModel * user;


@property (nonatomic,retain) CLLocation * currentLocation;
@property (nonatomic,retain) AppointmentModel*userLocation;

-(void) setStartLocation:(CLLocationCoordinate2D)location;
-(CLLocationCoordinate2D) getStartLocation;


-(AppointmentModel*)getAppointmentAtIndex:(NSInteger)index;

-(UIColor*) lightBlueColor;
-(UIColor*) darkBlueColor;
-(UIColor*) lightGreyColor;
-(UIColor*) darkGreyColor;

-(NSString*) getFormattedDate;
-(NSString*) getFormattedDateForPrompt;
-(NSString*)formattedTime:(NSString*)time;
-(NSString*)currentTimeAsString;

+(id) sharedApplicationModel;
@end
