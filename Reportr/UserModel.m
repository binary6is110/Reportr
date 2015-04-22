//
//  UserModel.m
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "UserModel.h"

@interface UserModel()
@property (nonatomic, strong) NSString * loginId;
//@property (nonatomic, strong) NSString * employeeId;
@property (nonatomic, strong) NSString * password;

@end

@implementation UserModel

-(id) initWithId:(NSString*)lId andPassword: (NSString*)pass andEmployeeId:(NSString*)eId
{
    if ( self = [super init] ) {
        _loginId=lId;
        _password=pass;
        _employeeID=eId;
        
    }
    return self;    
}


@end
