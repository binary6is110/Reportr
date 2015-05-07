//
//  AppointmentModel
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppointmentModel : NSObject

@property (nonatomic, strong) NSString * appointment_id;
@property (nonatomic) float latitude;
@property (nonatomic) float longitude;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * address_1;
@property (nonatomic, strong) NSString * address_2;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSString * start_time;
@property (nonatomic, strong) NSString * notes;
@property (nonatomic, strong) NSString * next_steps;
@property (nonatomic, strong) NSString * agenda;
@property (nonatomic, strong) NSString * contactId;
@property (nonatomic, strong) NSString * contact_name;
@property (nonatomic, strong) NSString * contact_phone_mobile;
@property (nonatomic, strong) NSString * contact_phone_office;

@property (nonatomic)BOOL hasImage;
@property (nonatomic)BOOL hasVideo;
@property (nonatomic)BOOL hasAudio;

-(NSString*) getContactPhoneMobile;
-(NSString*) getContactPhoneOffice;
-(NSString*) getContactName;
-(NSString*) getAppointmentId;

-(id) initWithCompany: (NSString*)company address1:(NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip startTime:(NSString*)sTime notesDesc:(NSString*)notes agendaDesc:(NSString*)agenda contactId:(NSString*) contact nextSteps:(NSString*)steps apptId:(NSString*)appointmentId;
-(void) setContactName:(NSString*) name phone_mobile:(NSString*)phone_m phone_office:(NSString*)phone_o;

@end
