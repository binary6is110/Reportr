//
//  MessageModel.m
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "MessageModel.h"


@implementation MessageModel

static MessageModel * ref = nil;
static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";
static BOOL testMode = false;

-(id) init
{
    if ( self = [super init] )
    {
        if (ref==nil)
            ref = [MessageModel new];
    }
    return self;
}

+(MessageModel*) messageModel
{
    if (ref==nil)
        ref = [MessageModel new];
    return ref;
}

+(BOOL) testMode
{
    return testMode;
}

+(NSString*) firebaseURL
{
    return kFirebaseURL;
}



@end
