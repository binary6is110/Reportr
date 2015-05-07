//
//  MessageModel.m
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "MessageModel.h"

#define kUSERNAME @"kima@lopeznegrete.com"
#define kPASSWORD @"lnc2015"

#define kVIDEO_WARNING @"Keep recording to less than 1 minute"
#define kVIDEO_SIZE_EXCEEDED @"Video is too large. Keep video around 1 minute."


@implementation MessageModel

-(NSString *)videoSizeExceeded{
    return kVIDEO_SIZE_EXCEEDED;
}

-(NSString *)videoWarning{
    return kVIDEO_WARNING;
}

-(NSString*) getPassword {
    return kPASSWORD;
}

-(NSString*) getUserName {
    return kUSERNAME;
}

+(id) sharedMessageModel{
    static MessageModel*sharedModel =nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedModel = [[self alloc] init];
    });
    return sharedModel;
}

-(id) init {
    if(self=[super init]) {
        _message = @"default value";
    }
    return self;
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



@end
