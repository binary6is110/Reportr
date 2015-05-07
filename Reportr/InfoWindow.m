//
//  InfoWindow.m
//  Reportr
//
//  Created by Kim Adams on 5/7/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "InfoWindow.h"
#import "ApplicationModel.h"

@implementation InfoWindow
static ApplicationModel * appModel;

-(id) init{
    if ( self = [super init] ) {
        appModel = [ApplicationModel sharedApplicationModel];
    }
    return self;
}

@end
