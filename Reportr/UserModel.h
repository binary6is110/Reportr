//
//  UserModel.h
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface UserModel : NSObject
-(id) initWithId:(NSString*)lId andPassword: (NSString*)pass andEmployeeId:(NSString*)eId;
@property (readonly, getter=employeeId) NSString* employeeID;
@end
