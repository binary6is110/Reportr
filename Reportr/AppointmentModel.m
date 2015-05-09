//
//  AppointmentModel
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "AppointmentModel.h"

@interface AppointmentModel()
@property (nonatomic, strong) NSString * appointment_id;
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

@property (nonatomic) CLLocationCoordinate2D location;

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

-(NSString*) agenda{
    return _agenda;
}
-(NSString*) notes{
    return _notes;
}
-(NSString*) next_steps{
    return _next_steps;
}

-(NSString*) contactId{
    return _contactId;
}
-(NSString*) start_time{
    return _start_time;
}

-(NSString*) company{
    return _company;
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

-(NSString*) getAddressAsQueryString{
   return [NSString stringWithFormat:@"%@ %@, %@, %@ %@",_address_1, _address_2, _city, _state, _zip, nil];
}

-(NSString*) address_1{
    return _address_1;
}

-(NSString*) address_2{
    return _address_2;
}

-(NSString*) city{
    return _city;
}

-(NSString*) state{
    return _state;
}

-(NSString*) zip{
    return _zip;
}

-(void) setLocation:(CLLocationCoordinate2D)location {
    _location=location;
}

-(CLLocationCoordinate2D) getLocation{
    return _location;
}


@end
