//
//  ApplicationModel.m
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ApplicationModel.h"

@implementation ApplicationModel

-(void)setAppointments:(NSMutableArray*)array {
    
    if (_appointments){
        [_appointments removeAllObjects];
    }
    _appointments = [NSMutableArray arrayWithArray:array];
}

-(NSMutableArray*) getAppointments {
    return _appointments;
}

-(AppointmentModel*)getAppointmentAtIndex:(NSInteger)index{
    return [_appointments objectAtIndex:index];
}

-(UIColor*) darkBlueColor{
    return [UIColor colorWithRed:(43/255.0) green:(76/255.0) blue:(160/255.0) alpha:1.0];
}
-(UIColor*) lightBlueColor{
    return [UIColor colorWithRed:(57/255.0) green:(198/255.0) blue:(244/255.0) alpha:1.0];
}

-(UIColor*) lightGreyColor{
    return [UIColor colorWithRed:(228.0/255.0) green:(231.0/255.0) blue:(231.0/255.0) alpha:0.3];
}



+(id) sharedApplicationModel{
    static ApplicationModel*applicationModel =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        applicationModel = [[self alloc] init];
    });
    return applicationModel;
}

-(id) init {
    if(self=[super init]) {
        
    }
    return self;
}

@end
