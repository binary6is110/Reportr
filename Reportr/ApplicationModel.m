//
//  ApplicationModel.m
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ApplicationModel.h"
@interface ApplicationModel()
@property (nonatomic) CLLocationCoordinate2D location;
@end

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


-(UIColor*) darkGreyColor{
    return [UIColor colorWithRed:(228.0/255.0) green:(231.0/255.0) blue:(231.0/255.0) alpha:0.7];
}


-(NSString*) getFormattedDate{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"yyyy-MM-dd";
    return [dateFormatter stringFromDate: date];
}


-(NSString*) getFormattedDateForPrompt{
    NSDate *date = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    dateFormatter.dateFormat = @"MMMM dd, yyyy";
    return [dateFormatter stringFromDate: date];
}

-(NSString*)formattedTime:(NSString*)time {
    
    NSArray * timeChunks = [time componentsSeparatedByString: @":"];
    int hours = (int)[timeChunks[0] integerValue];
    int minutes = (int)[timeChunks[1] integerValue];
    NSString * suffix = @"AM";
    if (hours>=12){
        suffix = @"PM";
        if(hours>12)
            hours-=12;
    }
    return [NSString stringWithFormat:@"%d:%02d %@", hours, minutes, suffix, nil];
}

-(NSString*)currentTimeAsString {
    NSDate *date = [NSDate date];
    NSDateFormatter *timeFormatter = [[NSDateFormatter alloc]init];
    timeFormatter.dateFormat = @"HH:mm";
    return [timeFormatter stringFromDate: date];
}

-(void) setStartLocation:(CLLocationCoordinate2D)location {
    _location=location;
}

-(CLLocationCoordinate2D) getStartLocation{
    return _location;
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
