//
//  MapViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//
//  Includes Code from: OpenInGoogleMapsController//
//  Copyright 2014 Google Inc. All rights reserved.
//
//  Licensed under the Apache License, Version 2.0 (the "License");
//  you may not use this file except in compliance with the License.
//  You may obtain a copy of the License at
//
//  http://www.apache.org/licenses/LICENSE-2.0
//
//  Unless required by applicable law or agreed to in writing, software
//  distributed under the License is distributed on an "AS IS" BASIS,
//  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//  See the License for the specific language governing permissions and
//  limitations under the License.
//
//  For more information on using the OpenInGoogleMapsController, please refer to the README.md
//  file included with this project, or to the Google Maps URL Scheme documentation at
//  https://developers.google.com/maps/documentation/ios/urlscheme

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "MessageModel.h"
#import "ApplicationModel.h"
#import "MapViewController.h"
#import "MapNavigationController.h"
#import "ScheduleNavigationViewController.h"
#import "AppointmentModel.h"
#import "MDDirectionService.h"
#import "InfoWindow.h"

// Constants for URL schemes and arguments defined by Google Maps
static NSString * const kGoogleMapsScheme = @"comgooglemaps://";
static NSString * const kGoogleMapsCallbackScheme = @"comgooglemaps-x-callback://";
static NSString* const kGoogleChromeOpenLink =@"googlechrome-x-callback://x-callback-url/open/?url=";
static NSString * const kGoogleMapsStringTraffic = @"traffic";
static NSString * const kGoogleMapsStringTransit = @"transit";
static NSString * const kGoogleMapsStringSatellite = @"satellite";


/*
 * Helper method that percent-escapes a string so it can safely be used in a URL. */
static NSString *encodeByAddingPercentEscapes(NSString *input) {
    NSString *encodedValue = (NSString *)CFBridgingRelease (CFURLCreateStringByAddingPercentEscapes(
                                                                                                    kCFAllocatorDefault,(CFStringRef) input, NULL,(CFStringRef) @"!*'();:@&=+$,/?%#[]",kCFStringEncodingUTF8));
    return encodedValue;
}

@interface MapViewController ()
@property GMSMapView * mapView;
@property NSMutableArray * locations;
@property NSMutableArray * waypoints;
@property NSMutableArray * waypointStrings;
@property BOOL firstLocationUpdate;
@end

/* The GoogleMapsURLSchemable protocol states that any definition can be exported into an array of URL arguments 
 * that can then be used to open Google Maps, Apple Maps, or a web page. It's through these methods that the definitions 
 * do most of the "heavy lifting" required to convert themselves into a URL that can be opened in the appropriate app.
 * The first three methods return arrays of strings that represent URL arguments in the form of "foo=bar". These can 
 * then by joined by ampersands (and prepended by a question mark) to create a full URL. */
@protocol GoogleMapsURLSchemable
@required
- (NSArray *)URLArgumentsForGoogleMaps;
- (NSArray *)URLArgumentsForAppleMaps;
- (NSArray *)URLArgumentsForWeb;
- (BOOL)anythingToSearchFor;
@end

/* GoogleMapDefinition - A definition for opening up a location in a map. */
@interface GoogleMapDefinition() <GoogleMapsURLSchemable>
@end

@implementation GoogleMapDefinition
- (instancetype)init {
    self = [super init];
    if (self) {
        _center = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (BOOL)anythingToSearchFor {
    return (CLLocationCoordinate2DIsValid(self.center) || self.queryString);
}

- (NSArray *)URLArgumentsForGoogleMaps {
    NSMutableArray *urlArguments = [NSMutableArray array];
    if (self.queryString) {
        [urlArguments addObject:
         [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
    }
    
    if (CLLocationCoordinate2DIsValid(self.center)) {
        [urlArguments addObject:[NSString stringWithFormat:@"center=%f,%f",
                                 self.center.latitude, self.center.longitude]];
    }
    if (self.zoomLevel > 0) {
        [urlArguments addObject:[NSString stringWithFormat:@"zoom=%f", self.zoomLevel]];
    }
    if (self.viewOptions) {
        NSMutableArray *viewsToShow = [NSMutableArray arrayWithCapacity:3];
        if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
            [viewsToShow addObject:kGoogleMapsStringSatellite];
        }
        if (self.viewOptions & kGoogleMapsViewOptionTraffic) {
            [viewsToShow addObject:kGoogleMapsStringTraffic];
        }
        if (self.viewOptions & kGoogleMapsViewOptionTransit) {
            [viewsToShow addObject:kGoogleMapsStringTransit];
        }
        [urlArguments addObject:
         [NSString stringWithFormat:@"views=%@", [viewsToShow componentsJoinedByString:@","]]];
    }
    return urlArguments;
}

- (NSArray *)URLArgumentsForAppleMaps {
    NSMutableArray *urlArguments = [NSMutableArray array];
    if (self.queryString) {
        [urlArguments addObject:
         [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
    }
    if (CLLocationCoordinate2DIsValid(self.center)) {
        [urlArguments addObject:[NSString stringWithFormat:@"ll=%f,%f",
                                 self.center.latitude, self.center.longitude]];
    }
    if (self.zoomLevel > 0) {
        [urlArguments addObject:[NSString stringWithFormat:@"z=%d", (int)self.zoomLevel]];
    }
    // Apple Map's "Hybrid" view is closest to what Google's "Satellite" view looks like
    if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
        [urlArguments addObject:@"t=h"];
    }
    // TODO: Figure out what URL scheme argument enables traffic information.
    
    return urlArguments;
}

- (NSArray *)URLArgumentsForWeb {
    NSMutableArray *urlArguments = [NSMutableArray array];
    if (self.queryString) {
        [urlArguments addObject:
         [NSString stringWithFormat:@"q=%@", encodeByAddingPercentEscapes(self.queryString)]];
    }
    if (CLLocationCoordinate2DIsValid(self.center)) {
        [urlArguments addObject:[NSString stringWithFormat:@"ll=%f,%f",
                                 self.center.latitude, self.center.longitude]];
    }
    if (self.zoomLevel > 0) {
        [urlArguments addObject:[NSString stringWithFormat:@"z=%d", (int)self.zoomLevel]];
    }
    if (self.viewOptions & kGoogleMapsViewOptionSatellite) {
        [urlArguments addObject:@"t=h"];
    }
    if (self.viewOptions & kGoogleMapsViewOptionTraffic) {
        [urlArguments addObject:@"layer=t"];
    }
    
    if (self.viewOptions & kGoogleMapsViewOptionTransit) {
        [urlArguments addObject:@"lci=transit_comp"];
    }
    
    return urlArguments;
}
@end

/* GoogleStreetViewDefinition - A definition for opening up a location in Street View.
 */
@interface GoogleStreetViewDefinition() <GoogleMapsURLSchemable>
@end

@implementation GoogleStreetViewDefinition
- (instancetype)init {
    self = [super init];
    if (self) {
        _center = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

- (BOOL)anythingToSearchFor {
    return CLLocationCoordinate2DIsValid(self.center);
}

- (NSArray *)URLArgumentsForGoogleMaps {
    NSMutableArray *urlArguments = [NSMutableArray array];
    [urlArguments addObject:
     [NSString stringWithFormat:@"center=%f,%f", self.center.latitude, self.center.longitude]];
    [urlArguments addObject:@"mapmode=streetview"];
    return urlArguments;
}

/* Apple Maps doesn't support Street View, but we can zoom in to the general location with
 * satellite view. That's pretty close.
 */
- (NSArray *)URLArgumentsForAppleMaps {
    NSMutableArray *urlArguments = [NSMutableArray array];
    
    
    [urlArguments addObject:
     [NSString stringWithFormat:@"ll=%f,%f", self.center.latitude, self.center.longitude]];
    [urlArguments addObject:@"z=19"];
    [urlArguments addObject:@"t=k"];
    return urlArguments;
}

/* Currently, we are unable to open a link to Street View in our mobile web browser. But we
 * can zoom in with satellite view just like we do in Apple Maps
 */
- (NSArray *)URLArgumentsForWeb {
    return [self URLArgumentsForAppleMaps];
}
@end

/*
 * GoogleDirectionsWaypoint - A point defined by either a set of coordinates or a search string.
 * Used by the GoogleDirectionsDefinition classs.
 */
@interface GoogleDirectionsWaypoint()
@end

@implementation GoogleDirectionsWaypoint
- (instancetype)init {
    self = [super init];
    if (self) {
        _location = kCLLocationCoordinate2DInvalid;
    }
    return self;
}

/* Since waypoints should contain a location or a query string (but not both),
 * these static helper methods can be quite handy. */
+ (instancetype)waypointWithLocation:(CLLocationCoordinate2D)location {
    GoogleDirectionsWaypoint *waypoint = [[GoogleDirectionsWaypoint alloc] init];
    waypoint.location = location;
    return waypoint;
}

+ (instancetype)waypointWithQuery:(NSString *)queryString {
    GoogleDirectionsWaypoint *waypoint = [[GoogleDirectionsWaypoint alloc] init];
    waypoint.queryString = queryString;
    return waypoint;
}

- (BOOL)anythingToSearchFor {
    return (CLLocationCoordinate2DIsValid(self.location) || self.queryString);
}

/* Since a waypoint could be the start address ('saddr' in the URL) or the end address ('daddr'),
 * we need to pass in the proper key when retrieving the URL argument for this waypoint. */
- (NSString *)URLArgumentUsingKey:(NSString *)key {
    if (CLLocationCoordinate2DIsValid(self.location)) {
        return [NSString stringWithFormat:@"%@=%f,%f",
                key, self.location.latitude, self.location.longitude];
    } else if (self.queryString) {
        return [NSString stringWithFormat:@"%@=%@",
                key, encodeByAddingPercentEscapes(self.queryString)];
    } else {
        return @"";
    }
}
@end

/* GoogleDirectionsWaypoint - A point defined by either a set of coordinates or a search string.
 * Used by the GoogleDirectionsDefinition classs. */
@interface GoogleDirectionsDefinition() <GoogleMapsURLSchemable>
@end

@implementation GoogleDirectionsDefinition

- (BOOL)anythingToSearchFor {
    return ([self.startingPoint anythingToSearchFor] || [self.destinationPoint anythingToSearchFor]);
}

/*Retrieving the "travel mode" argument in Google Maps. */
- (NSString *)urlArgumentValueForTravelMode {
    switch (self.travelMode) {
        case kGoogleMapsTravelModeBiking:
            return @"bicycling";
        case kGoogleMapsTravelModeDriving:
            return @"driving";
        case kGoogleMapsTravelModeTransit:
            return @"transit";
        case kGoogleMapsTravelModeWalking:
            return @"walking";
    }
    return nil;
}

/* Retrieving the "travel mode" argument for the web. */
- (NSString *)urlArgumentValueForTravelModeWeb {
    switch (self.travelMode) {
        case kGoogleMapsTravelModeBiking:
            return @"b";
        case kGoogleMapsTravelModeDriving:
            return @"c";
        case kGoogleMapsTravelModeTransit:
            return @"r";
        case kGoogleMapsTravelModeWalking:
            return @"w";
    }
    return nil;
}

/* Retrieving the start and end waypoint arguments is the same in Google Maps, Apple Maps, and the web. */
- (NSMutableArray *)waypointArguments {
    NSMutableArray *waypointArguments = [NSMutableArray array];
    if ([self.startingPoint anythingToSearchFor]) {
        [waypointArguments addObject:[self.startingPoint URLArgumentUsingKey:@"saddr"]];
    }
    if ([self.destinationPoint anythingToSearchFor]) {
        [waypointArguments addObject:[self.destinationPoint URLArgumentUsingKey:@"daddr"]];
    }
    return waypointArguments;
}

- (NSArray *)URLArgumentsForGoogleMaps {
    NSMutableArray *urlArguments = [self waypointArguments];
    
    NSString *travelMode = [self urlArgumentValueForTravelMode];
    if (travelMode) {
        [urlArguments addObject:[NSString stringWithFormat:@"directionsmode=%@", travelMode]];
    }
    return urlArguments;
}

- (NSArray *)URLArgumentsForAppleMaps {
    NSMutableArray *urlArguments = [self waypointArguments];
    
    if (self.travelMode == kGoogleMapsTravelModeDriving) {
        [urlArguments addObject:@"dirflg=d"];
    } else if (self.travelMode == kGoogleMapsTravelModeWalking) {
        [urlArguments addObject:@"dirflg=w"];
    }
    return urlArguments;
}

- (NSArray *)URLArgumentsForWeb {
    NSMutableArray *urlArguments = [self waypointArguments];
    
    NSString *travelMode = [self urlArgumentValueForTravelModeWeb];
    if (travelMode) {
        [urlArguments addObject:[NSString stringWithFormat:@"dirflg=%@", travelMode]];
    }
    return urlArguments;
}
@end

@implementation MapViewController{
      UIApplication *_sharedApplication;
}

static MessageModel *  mModel;
static ApplicationModel * appModel;

+ (MapViewController *)sharedInstance {
    static MapViewController *_sharedInstance;
    static dispatch_once_t oncePredicate;
    dispatch_once(&oncePredicate, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _sharedApplication = [UIApplication sharedApplication];
    }
    return self;
}

- (BOOL)isGoogleMapsInstalled {
    NSURL *simpleURL = [NSURL URLWithString:kGoogleMapsScheme];
    NSURL *callbackURL = [NSURL URLWithString:kGoogleMapsCallbackScheme];
    return ([_sharedApplication canOpenURL:simpleURL] ||
            [_sharedApplication canOpenURL:callbackURL]);
}


- (BOOL)fallBackToAppleMapsWithDefinition:(id<GoogleMapsURLSchemable>)definition {
    
    NSMutableString *mapURL = [@"https://maps.apple.com/" mutableCopy];
    [mapURL appendString:[NSString stringWithFormat:@"?%@",
                          [[definition URLArgumentsForAppleMaps] componentsJoinedByString:@"&"]]];
#if DEBUG
    NSLog(@"Opening up URL: %@", mapURL);
#endif
    NSURL *URLToOpen = [NSURL URLWithString:mapURL];
    
    return [_sharedApplication openURL:URLToOpen];
}


- (BOOL)fallbackToChromeFirstWithDefinition:(id<GoogleMapsURLSchemable>)definition {
    NSMutableString *mapURL = [kGoogleChromeOpenLink mutableCopy];
    
    NSString *embedURL = @"https://maps.google.com/maps/";
    NSString *urlArgumentsAsString = [NSString stringWithFormat:@"?%@",
                                      [[definition URLArgumentsForWeb] componentsJoinedByString:@"&"]];
    
    NSString *fullEmbedURL = [embedURL stringByAppendingString:urlArgumentsAsString];
    [mapURL appendString:encodeByAddingPercentEscapes(fullEmbedURL)];
#if DEBUG
    NSLog(@"Opening up URL: %@", mapURL);
    NSLog(@"Embedded URL of: %@", fullEmbedURL);
#endif
    [self appendMapURLString:mapURL withCallbackArgumentsFromURL:self.callbackURL];
    
    NSURL *URLToOpen = [NSURL URLWithString:mapURL];
    if ([_sharedApplication openURL:URLToOpen]) {
        return YES;
    } else if (self.fallbackStrategy == kGoogleMapsFallbackChromeThenAppleMaps) {
        return [self fallBackToAppleMapsWithDefinition:definition];
    } else if (self.fallbackStrategy == kGoogleMapsFallbackChromeThenSafari) {
        return [self fallbackToSafariWithDefinition:definition];
    }
    return NO;
}


- (BOOL)fallbackToSafariWithDefinition:(id<GoogleMapsURLSchemable>)definition {
    NSMutableString *mapURL = [@"https://maps.google.com/maps" mutableCopy];
    
    [mapURL appendString:[NSString stringWithFormat:@"?%@",
                          [[definition URLArgumentsForWeb] componentsJoinedByString:@"&"]]];
#if DEBUG
    NSLog(@"Opening up URL: %@", mapURL);
#endif
    NSURL *URLToOpen = [NSURL URLWithString:mapURL];
    return [_sharedApplication openURL:URLToOpen];
}


/*
 * Since the definitions themselves do most of the work required to generate the URL arguments
 * appropriate for their type of map request, the same method can be used to open up the correct
 * URL, no matter what definition gets passed in. We chose not to make this method public,
 * simply because the more explicit methods below eliminate potential confusion.
 */
- (BOOL)openInGoogleMapsWithDefinition:(id<GoogleMapsURLSchemable>)definition {
    // Did we define anything to search for in our map?
    if (![definition anythingToSearchFor]) {
        return NO;
    }
    
    // Can we open this in google maps?
    if (![self isGoogleMapsInstalled]) {
        switch (self.fallbackStrategy) {
            case kGoogleMapsFallbackNone:
                return NO;
            case kGoogleMapsFallbackAppleMaps:
                return [self fallBackToAppleMapsWithDefinition:definition];
            case kGoogleMapsFallbackChromeThenSafari:
            case kGoogleMapsFallbackChromeThenAppleMaps:
                return [self fallbackToChromeFirstWithDefinition:definition];
            case kGoogleMapsFallbackSafari:
                return [self fallbackToSafariWithDefinition:definition];
        }
    }
    
    NSMutableString *mapURL = [[self baseURLStringUsingCallback:self.callbackURL] mutableCopy];
    
    [mapURL appendString:[NSString stringWithFormat:@"?%@",
                          [[definition URLArgumentsForGoogleMaps] componentsJoinedByString:@"&"]]];
    [self appendMapURLString:mapURL withCallbackArgumentsFromURL:self.callbackURL];
#if DEBUG
    NSLog(@"Opening up URL: %@", mapURL);
#endif
    NSURL *URLToOpen = [NSURL URLWithString:mapURL];
    
    return [_sharedApplication openURL:URLToOpen];
}


- (BOOL)openMap:(GoogleMapDefinition *)definition {
    return [self openInGoogleMapsWithDefinition:definition];
}

- (BOOL)openStreetView:(GoogleStreetViewDefinition *)definition {
    return [self openInGoogleMapsWithDefinition:definition];
}

- (BOOL)openDirections:(GoogleDirectionsDefinition *)definition {
    return [self openInGoogleMapsWithDefinition:definition];
}


# pragma mark - Map URL fragment methods

/*
 * Returns the correct URL scheme (comgooglemaps vs comgooglemaps-x-callback),
 * depending on whether or not the callback URL can be opened.
 */
- (NSString *)baseURLStringUsingCallback:(NSURL *)callbackURL {
    BOOL usingCallback = callbackURL && [_sharedApplication canOpenURL:callbackURL];
    return (usingCallback) ? kGoogleMapsCallbackScheme : kGoogleMapsScheme;
}

/*
 * Add the x-success and x-source arguments to the end of an URL string, if the callback URL
 * exists and is supported by the target app.
 */
- (void)appendMapURLString:(NSMutableString *)mapURL
withCallbackArgumentsFromURL:(NSURL *)callbackURL {
    BOOL usingCallback = callbackURL && [_sharedApplication canOpenURL:callbackURL];
    if (usingCallback) {
        [mapURL appendFormat:@"&x-success=%@",
         encodeByAddingPercentEscapes([callbackURL absoluteString])];
        [mapURL appendFormat:@"&x-source=%@",
         encodeByAddingPercentEscapes([[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"])];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    mModel = [MessageModel sharedMessageModel];
    appModel = [ApplicationModel sharedApplicationModel];
    
    
    NSString *dateString = [appModel getFormattedDateForPrompt];
    self.navigationItem.prompt = dateString;
    
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:12];
    
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self forKeyPath:@"myLocation" options:NSKeyValueObservingOptionNew context:NULL];
    
    _locations= [[NSMutableArray alloc] init];
    _waypointStrings = [[NSMutableArray alloc]init];
    _waypoints = [[NSMutableArray alloc]init];
    
    self.view = _mapView;
    
    _mapView.delegate=self;
    
    [self retrieveAppointmentsForUser:appModel.user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedEditAppointmentFromMapMarker:)
                                                 name:@"shouldSegueToDetailView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRouteToAppointment:)
                                                 name:@"shouldRouteToAppointment" object:nil];
}

#pragma mark – Parse Data Pull
/** -(void) retrieveAppointmentsForUser:(UserModel*)userModel
 *  Retrieves appointments for user by ID & date, sorted by appointment time. */
-(void) retrieveAppointmentsForUser:(UserModel*)userModel
{
    NSString * empId = appModel.user.employeeId;
    NSString *dateString = [appModel getFormattedDate];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Appointments"];
    [query whereKey:@"emp_id" equalTo:empId];
    [query whereKey:@"date" equalTo:dateString];
    [query orderByAscending:@"start"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *results, NSError *error){
        
        if (!error ) {
            for(PFObject*appt in results){
                AppointmentModel * gModel = [[AppointmentModel alloc] initWithCompany:appt[@"company"] address1:appt[@"address_1"] address2:appt[@"address_2"] city:appt[@"city"] state:appt[@"state"] zip:appt[@"zip"] startTime:appt[@"start"] notesDesc:appt[@"notes"] agendaDesc:appt[@"agenda"] contactId:appt[@"contact"] nextSteps:appt[@"next_steps"] apptId:appt.objectId];
                gModel.hasAudio=(appt[@"audio_file"] == nil);
                gModel.hasVideo=(appt[@"video_file"] == nil);
                gModel.hasImage=(appt[@"image_file"] == nil);
                [_locations insertObject:gModel atIndex:_locations.count];
            }
            appModel.appointments=_locations;
            // ask for my location data after the map has already been added to the ui.
            dispatch_async(dispatch_get_main_queue(), ^{
                _mapView.myLocationEnabled = YES;
            });
        }
    }];
}

#pragma mark - Google Maps
/** - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 *  Creates markers and gets directions to locations for today's appointment
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that location.
        _firstLocationUpdate = YES;
        
        NSMutableArray * coords = [[NSMutableArray alloc] init];
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        appModel.currentLocation=location;
        CLLocationCoordinate2D start = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",start.latitude,start.longitude];
        [_waypointStrings addObject:positionString];
        
        AppointmentModel * aM=[[AppointmentModel alloc] init];
        aM.latitude= start.latitude;
        aM.longitude= start.longitude;
        [coords insertObject:aM atIndex:coords.count];
        int index =0;
        for (AppointmentModel * obj in _locations)
        {
            CLLocationCoordinate2D thisSpot = [self geoCodeUsingAddress:[NSString stringWithFormat:@"%@,%@,%@,%@",obj.address_1, obj.city, obj.state, obj.zip]];
            AppointmentModel * m= [appModel getAppointmentAtIndex:(NSInteger)index];
            m.latitude= thisSpot.latitude;
            m.longitude=thisSpot.longitude;
            
            GMSMarker * marker = [[GMSMarker alloc] init];
            marker.userData = [NSString stringWithFormat:@"%d",index++];
            marker.position = thisSpot;
            marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
            marker.flat = YES;
            marker.map = _mapView;
            [_waypoints addObject:marker];
            
            positionString = [[NSString alloc] initWithFormat:@"%f,%f",thisSpot.latitude,thisSpot.longitude];
            [_waypointStrings addObject:positionString];
            
            obj.latitude= thisSpot.latitude;
            obj.longitude= thisSpot.longitude;
            [coords insertObject:obj atIndex:coords.count];
        }
        
        if([_waypoints count]>1)
        {
            NSString *sensor = @"false";
            NSArray *parameters = [NSArray arrayWithObjects:sensor, _waypointStrings, nil];
            NSArray *keys = [NSArray arrayWithObjects:@"sensor", @"waypoints", nil];
            NSDictionary *query = [NSDictionary dictionaryWithObjects:parameters forKeys:keys];
            MDDirectionService *mds=[[MDDirectionService alloc] init];
            SEL selector = @selector(addDirections:);
            [mds setDirectionsQuery:query withSelector:selector withDelegate:self];
        }
    }
}

/** -(UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    On user selection of marker, create custom marker & update labels and set appModel.appointment to selected appointment*/
-(UIView*)mapView:(GMSMapView *)mapView markerInfoWindow:(GMSMarker *)marker{
    InfoWindow *view =  [[[NSBundle mainBundle] loadNibNamed:@"InfoWindowView" owner:self options:nil] objectAtIndex:0];
    //retrieve appointment details & update selected appointment from mapview
    AppointmentModel*thisAppt = [appModel getAppointmentAtIndex:[marker.userData integerValue]];
    appModel.appointment=thisAppt;
    view.time.text = [mModel formattedTime:thisAppt.start_time];
    view.address_1.text = thisAppt.address_1;
    view.address_1.numberOfLines=0;
    [view.address_1 sizeToFit];
    view.companyName.text = thisAppt.company;
    view.companyName.textColor=[UIColor colorWithRed:(57/255.0) green:(198/255.0) blue:(244/255.0) alpha:1.0];
    return view;
}

#pragma mark - Google Maps: Routing between points
/** - (void)addDirections:(NSDictionary *)json
 *  Draws routes on map between locations */
- (void)addDirections:(NSDictionary *)json {
    NSDictionary *routes = [json objectForKey:@"routes"][0];
    NSDictionary *route = [routes objectForKey:@"overview_polyline"];
    NSString *overview_route = [route objectForKey:@"points"];
    GMSPath *path = [GMSPath pathFromEncodedPath:overview_route];
    GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
    polyline.map = _mapView;
    
    GMSCoordinateBounds *bounds= [[GMSCoordinateBounds alloc] initWithPath:path];
    GMSCameraPosition *camera = [_mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
    _mapView.camera = camera;
    GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
    [_mapView moveCamera:update];
}

/** - (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
 * Reverse lookup finds coordinates for locations by address. */
- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address {
    double latitude = 0, longitude = 0;
    NSString *esc_addr =  [address stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSString *req = [NSString stringWithFormat:@"http://maps.google.com/maps/api/geocode/json?sensor=false&address=%@", esc_addr];
    NSString *result = [NSString stringWithContentsOfURL:[NSURL URLWithString:req] encoding:NSUTF8StringEncoding error:NULL];
    if (result) {
        NSScanner *scanner = [NSScanner scannerWithString:result];
        if ([scanner scanUpToString:@"\"lat\" :" intoString:nil] && [scanner scanString:@"\"lat\" :" intoString:nil]) {
            [scanner scanDouble:&latitude];
            if ([scanner scanUpToString:@"\"lng\" :" intoString:nil] && [scanner scanString:@"\"lng\" :" intoString:nil]) {
                [scanner scanDouble:&longitude];
            }
        }
    }
    CLLocationCoordinate2D center;
    center.latitude = latitude;
    center.longitude = longitude;
    return center;
}

#pragma mark - Google Maps: Event Handling
/**-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
    updates CLLocation reference in model*/
-(void) locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation{
//TODO: test for change in location in model
    appModel.currentLocation=newLocation;
    NSLog(@"updating location");
}

-(void)mapView:(GMSMapView *)mapView didTapInfoWindowOfMarker:(GMSMarker *)marker{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"shouldSegueToDetailView" object:nil];
}

#pragma mark - Navigation & Prep
/**-(void) userSelectedEditAppointmentFromMapMarker: (NSNotification *)notification
 Executes query before transitioning*/
-(void) userSelectedEditAppointmentFromMapMarker: (NSNotification *)notification{
    NSLog(@"MapViewController::userSelectedEditAppointmentFromMapMarker");
    [self prepareForTransition:@"showDetailViewFromMap" withSender:self];
}

/**-(void) prepareForTransition:(NSString*)segueName withSender:(id)sender
 query contact information before moving to next state*/
-(void) prepareForTransition:(NSString*)segueName withSender:(id)sender{
    if(appModel.contact.contactId!= appModel.appointment.contactId){
        PFQuery *query = [PFQuery queryWithClassName:@"Contacts"];
        [query whereKey:@"contact_id" equalTo:appModel.appointment.contactId];
        [query getFirstObjectInBackgroundWithBlock:^(PFObject *contact, NSError *error) {
            if (!error ) {
                ContactModel * contactM = [[ContactModel alloc] initWithFirstName:contact[@"first_name"] lastName:contact[@"last_name"] company:contact[@"company"] address1:contact[@"address_1"] address2:contact[@"address_1"] city:contact[@"city"] state:contact[@"state"] zip:contact[@"zip"] contactId:contact[@"contact_id"] officePhone:contact[@"phone_office"] mobilePhone:contact[@"phone_mobile"]];
                [appModel setContact:contactM];
                [self performSegueWithIdentifier:segueName sender:sender];
            }
        }];
    }
    else{
        //same contact - no need to query again, just segue
        [self performSegueWithIdentifier:segueName sender:sender];
    }
}

/** - (IBAction)showSchedule:(id)sender
 * Transition to schedule table view*/
- (IBAction)showSchedule:(id)sender {
    [self performSegueWithIdentifier:@"showSchedule" sender:sender];
}

 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 }

#pragma mark- Handoff to Google for Routing


/**-(void) userSelectedRouteToAppointment: (NSNotification *)notification */
-(void) userSelectedRouteToAppointment: (NSNotification *)notification{
    NSLog(@"MapViewController::userSelectedRouteToAppointment, %@",notification.object);
    
    /*CLLocation *location = [appModel currentLocation];
     CLLocationCoordinate2D start = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
     
     NSString *googleMapsURLString = [NSString stringWithFormat:@"http://maps.google.com/?saddr=%1.6f,%1.6f&daddr=%1.6f,%1.6f",
     start.latitude, start.longitude, [[appModel appointment] latitude], [[appModel appointment] longitude] ];
     
     
     
     [[UIApplication sharedApplication] openURL:[NSURL URLWithString:googleMapsURLString]];
     */
}


@end
