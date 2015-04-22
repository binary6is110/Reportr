//
//  GeocodingModel.h
//  Reportr
//
//  Created by Kim Adams on 4/22/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GeocodingModel : NSObject
-(id) initWithCompany: (NSString*)company address1:(NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip;

@property (nonatomic, strong) NSString * latitude;
@property (nonatomic, strong) NSString * longitude;
@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * address_1;
@property (nonatomic, strong) NSString * address_2;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@end
