//
//  AppointmentModel
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GoogleMaps/GoogleMaps.h>

@interface AppointmentModel : NSObject

@property (nonatomic)BOOL hasImage;
@property (nonatomic)BOOL hasVideo;
@property (nonatomic)BOOL hasAudio;

-(NSString*) getContactPhoneMobile;
-(NSString*) getContactPhoneOffice;
-(NSString*) getContactName;
-(NSString*) getAppointmentId;
-(NSString*) getAddressAsQueryString;

-(void) setLocation:(CLLocationCoordinate2D)location;
-(CLLocationCoordinate2D) getLocation;

-(NSString*) notes;
-(NSString*) next_steps;
-(NSString*) agenda;
-(NSString*) start_time;
-(NSString*) company;
-(NSString*) contactId;
-(NSString*) address_1;
-(NSString*) address_2;
-(NSString*) city;
-(NSString*) state;
-(NSString*) zip;


-(id) initWithCompany: (NSString*)company address1:(NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip startTime:(NSString*)sTime notesDesc:(NSString*)notes agendaDesc:(NSString*)agenda contactId:(NSString*) contact nextSteps:(NSString*)steps apptId:(NSString*)appointmentId;
-(void) setContactName:(NSString*) name phone_mobile:(NSString*)phone_m phone_office:(NSString*)phone_o;
@end
