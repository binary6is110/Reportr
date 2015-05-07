//
//  ContactModel.m
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ContactModel.h"

@implementation ContactModel


-(id) initWithFirstName: (NSString*)first_name lastName:(NSString*)last_name company:(NSString*)company address1: (NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip contactId:(NSString*) contact officePhone:(NSString*)office mobilePhone:(NSString*)mobile {
    
    if ( self = [super init] ) {
        _company = company;
        _address_1=add1;
        _address_2=add2;
        _city=city;
        _state=state;
        _zip = zip;
        _first_name=first_name;
        _last_name=last_name;
        _contactId=contact;
        _contact_phone_mobile=mobile;
        _contact_phone_office=office;
    }
    return self;
}

@end
