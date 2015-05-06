//
//  AppointmentModel
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AppointmentModel.h"

@interface AppointmentModel()

@end

@implementation AppointmentModel


-(id) initWithCompany: (NSString*)company address1:(NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip startTime:(NSString*)sTime notesDesc:(NSString*)notes agendaDesc:(NSString*)agenda contactId:(NSString*) contact nextSteps:(NSString*)steps apptId:(NSString*)appointmentId {
    if ( self = [super init] ) {
        _company = company;
        _address_1=add1;
        _address_2=add2;
        _city=city;
        _state=state;
        _zip = zip;
        _start_time=sTime;
        _notes=notes;
        _agenda=agenda;
        _contactId=contact;
        _contact_name=@"";
        _contact_phone_mobile=@"";
        _contact_phone_office=@"";
        _next_steps=steps;
        _appointment_id= appointmentId;
    }
    return self;
}

-(NSString*) getAppointmentId{
    return _appointment_id;
}

-(NSString*) getContactPhoneMobile{
    return _contact_phone_mobile;
}

-(NSString*) getContactPhoneOffice{
    return _contact_phone_office;
}
-(NSString*) getContactName{
    return _contact_name;
}

-(void) setContactName:(NSString*) name phone_mobile:(NSString*)phone_m phone_office:(NSString*)phone_o{
    _contact_name=name;
    _contact_phone_mobile=phone_m;
    _contact_phone_office=phone_o;
}

@end
