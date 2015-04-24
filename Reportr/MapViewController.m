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
#import "MapNavigationController.h"
#import <GoogleMaps/GoogleMaps.h>
#import "AppointmentModel.h"
#import "MDDirectionService.h"

static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";

@interface MapViewController ()
@property MapNavigationController * mapNavController;
@property GMSMapView * mapView;
@property UserModel * userModel;
@property Firebase * appointments;
@property NSMutableArray * locations;
@property NSMutableArray * waypoints;
@property NSMutableArray * waypointStrings;
@property BOOL firstLocationUpdate;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:12];
    
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self forKeyPath:@"myLocation"  options:NSKeyValueObservingOptionNew context:NULL];
    
    _locations= [[NSMutableArray alloc] init];
    _waypointStrings = [[NSMutableArray alloc]init];
    _waypoints = [[NSMutableArray alloc]init];
    
    self.view = _mapView;
    if(!_mapNavController){
        _mapNavController= (MapNavigationController*)self.parentViewController;
    }
    _userModel = _mapNavController.userModel;
    
    [self retrieveAppointmentsForUser:_mapNavController.userModel];
    
}

- (void)dealloc {
    [_mapView removeObserver:self forKeyPath:@"myLocation" context:NULL];
}

#pragma mark – Firebase Queries
/** -(void) retrieveAppointmentsForUser:(UserModel*)userModel
 *  Retrieves appointments for user by ID & date, sorted by appointment time.
 */
-(void) retrieveAppointmentsForUser:(UserModel*)userModel
{
    NSString * empId = _userModel.employeeId;
    NSString * today = @"2015-04-30";
    
    // create drill down query to retrieve appointments for a user on a date
    _appointments= [ [Firebase alloc] initWithUrl: [NSString stringWithFormat:@"%@/%@/%@/%@", kFirebaseURL, @"appointments",empId,today]];
    [[_appointments queryOrderedByValue]  observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *querySnapshot) {
        
        
        for (FDataSnapshot* child in querySnapshot.children) {
            NSLog(@"child.key %@, child.value %@", child.key, child.value);
            AppointmentModel * gModel = [[AppointmentModel alloc] initWithCompany:child.value[@"company"] address1:child.value[@"address_1"] address2:child.value[@"address_2"]
                                                                             city:child.value[@"city"] state:child.value[@"state"] zip:child.value[@"zip"] startTime:child.value[@"start_time"]];
            [_locations insertObject:gModel atIndex:_locations.count];
        }
        // ask for my location data after the map has already been added to the ui.
        dispatch_async(dispatch_get_main_queue(), ^{
            _mapView.myLocationEnabled = YES;
        });
    }];
}

#pragma mark - Google Mapping
/** - (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
 *  Creates markers and gets directions to locations for today's appointment
 */
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that location.
        _firstLocationUpdate = YES;
        
        NSMutableArray * coords = [[NSMutableArray alloc] init];
        
        for (AppointmentModel * obj in _locations)
        {
            CLLocationCoordinate2D thisSpot = [self geoCodeUsingAddress: [NSString stringWithFormat:@"%@,%@,%@,%@",obj.address_1, obj.city, obj.state, obj.zip]];
            GMSMarker * marker = [GMSMarker markerWithPosition: thisSpot];
            [_waypoints addObject:marker];
            NSString *positionString = [[NSString alloc] initWithFormat:@"%f,%f",thisSpot.latitude,thisSpot.longitude];
            [_waypointStrings addObject:positionString];
            
            marker.title= obj.company;
            marker.snippet = obj.address_1;
            marker.flat = YES;
            marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
            marker.map = _mapView;
            obj.latitude= [NSString stringWithFormat:@"%f",thisSpot.latitude];
            obj.longitude= [NSString stringWithFormat:@"%f",thisSpot.longitude];
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
/** - (void)addDirections:(NSDictionary *)json
 *  Draws routes on map between locations
 */
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
 * Reverse lookup finds coordinates for locations by address.
 */
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

#pragma mark - Messaging
/** -(void) passUserModel:(UserModel*) userModel
 * Passes UserModel to view controller before transitioning.
 */
-(void) passUserModel:(UserModel*) userModel {
    NSLog(@"userModel set in MapViewController, employeeID: %@",userModel.employeeId);
    _userModel=userModel;
}

@end
