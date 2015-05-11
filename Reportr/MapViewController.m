//
//  MapViewController.m
//  Reportr
//
//  Created by Kim Adams on 4/21/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "MapViewController.h"
#import "MDDirectionService.h"
#import "InfoWindow.h"
#import "MessageModel.h"
#import "ApplicationModel.h"
#import "AppointmentModel.h"

#import "Enums.h"
#import "MapRequestModel.h"
#import "OpenInGoogleMapsController.h"

@interface MapViewController ()
@property GMSMapView * mapView;
@property NSMutableArray * locations;
@property NSMutableArray * waypoints;
@property NSMutableArray * waypointStrings;
@property BOOL firstLocationUpdate;
// OpenInGoogleMaps properties
@property(nonatomic, strong) MapRequestModel *model;
@property(nonatomic, assign) LocationGroup pendingLocationGroup;
@property(nonatomic, strong) UIActionSheet *travelModeActionSheet;
@end

static NSString * const kOpenInMapsSampleURLScheme = @"Reportr://?resume=true";

@implementation MapViewController
static MessageModel *  mModel;
static ApplicationModel * appModel;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _model = [[MapRequestModel alloc] init];
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
    /*[self pickLocationController:nil
               pickedQueryString:@"1600 Amphitheatre Parkway, Mountain View, CA 94043"
                        forGroup:kLocationGroupStart];*/
    //[self typeOfMapChanged:self.pickMapTypeSC];
    
    // And let's set our callback URL right away!
    [OpenInGoogleMapsController sharedInstance].callbackURL =
    [NSURL URLWithString:kOpenInMapsSampleURLScheme];
    
    // If the user doesn't have Google Maps installed, let's try Chrome. And if they don't
    // have Chrome installed, let's use Apple Maps. This gives us the best chance of having an
    // x-callback-url that points back to our application.
    [OpenInGoogleMapsController sharedInstance].fallbackStrategy =kGoogleMapsFallbackChromeThenAppleMaps;
    
    [self retrieveAppointmentsForUser:appModel.user];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedEditAppointmentFromMapMarker:)
                                                 name:@"shouldSegueToDetailView" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(userSelectedRouteToAppointment:)
                                                 name:@"shouldRouteToAppointment" object:nil];
}

/**-(void) userSelectedRouteToAppointment: (NSNotification *)notification */
-(void) userSelectedRouteToAppointment: (NSNotification *)notification{
    NSLog(@"MapViewController::userSelectedRouteToAppointment");
    
    if (![[OpenInGoogleMapsController sharedInstance] isGoogleMapsInstalled]) {
        NSLog(@"Google Maps not installed, but using our fallback strategy");
    }
    
    [self openDirectionsInGoogleMaps];
}

#pragma mark - OpenInMaps
- (void)openDirectionsInGoogleMaps {
   GoogleDirectionsDefinition *directionsDefinition = [[GoogleDirectionsDefinition alloc] init];
    if (self.model.startCurrentLocation) {
        directionsDefinition.startingPoint = nil;
    } else {
        GoogleDirectionsWaypoint *startingPoint = [[GoogleDirectionsWaypoint alloc] init];
        startingPoint.queryString = [[appModel userLocation] getAddressAsQueryString];
        startingPoint.location = [appModel getStartLocation];
        directionsDefinition.startingPoint = startingPoint;
    }
    if (self.model.destinationCurrentLocation) {
        directionsDefinition.destinationPoint = nil;
    } else {
        GoogleDirectionsWaypoint *destination = [[GoogleDirectionsWaypoint alloc] init];
        destination.queryString = appModel.appointment.getAddressAsQueryString;
        destination.location = appModel.appointment.getLocation;
        directionsDefinition.destinationPoint = destination;
    }
    directionsDefinition.travelMode = kGoogleMapsTravelModeDriving;
    [[OpenInGoogleMapsController sharedInstance] openDirections:directionsDefinition];
}

# pragma mark - Miscellaneous helper methods

// Our fancy new way of showing an alert!
- (void)showSimpleAlertWithTitle:(NSString *)title description:(NSString *)description {
    if (NSClassFromString(@"UIAlertController")) {
        UIAlertAction *okay =
        [UIAlertAction actionWithTitle:@"Okay" style:UIAlertActionStyleDefault handler:nil];
        UIAlertController *alert =
        [UIAlertController alertControllerWithTitle:title
                                            message:description
                                     preferredStyle:UIAlertControllerStyleAlert];
        [alert addAction:okay];
        [self presentViewController:alert animated:YES completion:nil];
    } else {
        [[[UIAlertView alloc] initWithTitle:title
                                    message:description
                                   delegate:nil
                          cancelButtonTitle:@"Okay"
                          otherButtonTitles:nil] show];
    }
}

#pragma mark – Firebase Queries
/** -(void) retrieveAppointmentsForUser:(UserModel*)userModel
 *  Retrieves appointments for user by ID & date, sorted by appointment time.
 */
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
        [appModel setStartLocation: start];

        NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",start.latitude,start.longitude];
        [_waypointStrings addObject:positionString];
        
        AppointmentModel * aM=[[AppointmentModel alloc] init];
        aM.location= start;
        appModel.userLocation=aM;
        [coords insertObject:aM atIndex:coords.count];
        
        int index =0;
        for (AppointmentModel * obj in _locations)
        {
            CLLocationCoordinate2D thisSpot = [self geoCodeUsingAddress:[NSString stringWithFormat:@"%@,%@,%@,%@",obj.address_1, obj.city, obj.state, obj.zip]];
            AppointmentModel * m= [appModel getAppointmentAtIndex:(NSInteger)index];
            m.location=thisSpot;
            
            GMSMarker * marker = [[GMSMarker alloc] init];
            marker.userData = [NSString stringWithFormat:@"%d",index++];
            marker.position = thisSpot;
            marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
            marker.flat = YES;
            marker.map = _mapView;
            [_waypoints addObject:marker];
            
            positionString = [[NSString alloc] initWithFormat:@"%f,%f",thisSpot.latitude,thisSpot.longitude];
            [_waypointStrings addObject:positionString];
            obj.location=thisSpot;
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
    view.time.text = [appModel formattedTime:thisAppt.start_time];
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
                
                //_contact_lbl.text=  [NSString stringWithFormat:@"%@ %@", contact[@"first_name"],contact[@"last_name"]];
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



@end
