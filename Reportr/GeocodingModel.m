//
//  GeocodingModel.m
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "GeocodingModel.h"

@interface GeocodingModel()



@end

@implementation GeocodingModel


-(id) initWithCompany: (NSString*)company address1:(NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip
{
    if ( self = [super init] ) {
        _company = company;
        _address_1=add1;
        _address_2=add2;
        _city=city;
        _state=state;
        _zip = zip;
    }
    return self;
}
@end
