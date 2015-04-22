//
//  UserModel.m
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "UserModel.h"

@interface UserModel()
@property (nonatomic, strong) NSString * userId;
@property (nonatomic, strong) NSString * password;

@end

@implementation UserModel

-(id) initWithId:(NSString*)uId andPassword: (NSString*)pass
{
    if ( self = [super init] ) {
        _userId=uId;
        _password=pass;
    }
    return self;
    
}


@end
