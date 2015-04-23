//
//  MDDirectionService.m
//  MapsDirections
//
//  Created by Mano Marks on 4/8/13.
//  Copyright (c) 2013 Google. All rights reserved.
//

#import "MDDirectionService.h"

@implementation MDDirectionService{
  @private
  BOOL _sensor;
  BOOL _alternatives;
  NSURL *_directionsURL;
  NSArray *_waypoints;
}

static NSString *kMDDirectionsURL = @"http://maps.googleapis.com/maps/api/directions/json?";

- (void)setDirectionsQuery:(NSDictionary *)query withSelector:(SEL)selector withDelegate:(id)delegate {
  
    NSArray *waypoints = [query objectForKey:@"waypoints"];
    NSString *sensor = [query objectForKey:@"sensor"];
    
    NSInteger waypointCount = [waypoints count];
    NSString *origin = [waypoints objectAtIndex:0];
    NSString *destination = [waypoints objectAtIndex:1];
   
    NSMutableString *url =[NSMutableString stringWithFormat:@"%@&origin=%@&destination=%@&sensor=%@",kMDDirectionsURL, origin, destination, sensor];
    
    if(waypointCount>2) {
        [url appendString:@"&waypoints=optimize:true"];
        NSInteger wpCount = waypointCount;
        for(int i=2;i<wpCount;i++){
            [url appendString: @"|"];
            [url appendString:[waypoints objectAtIndex:i]];
        }
    }
    url = (NSMutableString*)[url stringByAddingPercentEscapesUsingEncoding: NSASCIIStringEncoding];
    _directionsURL = [NSURL URLWithString:url];
  [self retrieveDirections:selector withDelegate:delegate];
}


- (void)retrieveDirections:(SEL)selector withDelegate:(id)delegate{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSData* data =
        [NSData dataWithContentsOfURL:_directionsURL];
      [self fetchedData:data withSelector:selector withDelegate:delegate];
    });
}

- (void)fetchedData:(NSData *)data withSelector:(SEL)selector withDelegate:(id)delegate{
  
  NSError* error;
  NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
  [delegate performSelector:selector withObject:json];
}

@end
