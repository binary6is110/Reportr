//
//  ContactModel.h
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ContactModel : NSObject

@property (nonatomic, strong) NSString * company;
@property (nonatomic, strong) NSString * address_1;
@property (nonatomic, strong) NSString * address_2;

@property (nonatomic, strong) NSString * first_name;
@property (nonatomic, strong) NSString * last_name;
@property (nonatomic, strong) NSString * city;
@property (nonatomic, strong) NSString * state;
@property (nonatomic, strong) NSString * zip;
@property (nonatomic, strong) NSString * contactId;
@property (nonatomic, strong) NSString * contact_phone_mobile;
@property (nonatomic, strong) NSString * contact_phone_office;

-(id) initWithFirstName: (NSString*)first_name lastName:(NSString*)last_name company:(NSString*)company address1: (NSString*)add1 address2: (NSString*)add2 city:(NSString*)city state:(NSString*)state zip:(NSString*)zip contactId:(NSString*) contact officePhone:(NSString*)office mobilePhone:(NSString*)mobile;

@end
