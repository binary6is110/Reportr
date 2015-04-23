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
#import "GeocodingModel.h"

static NSString * const kFirebaseURL = @"https://reportrplatform.firebaseio.com";

@interface MapViewController ()

@property GMSMapView *mapView;
@property BOOL firstLocationUpdate;
@property MapNavigationController * mapNavController;
@property UserModel*userModel;

@property NSMutableArray* locations;
@end

@implementation MapViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:12];
    
    _mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    _mapView.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [_mapView addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    _locations= [[NSMutableArray alloc] init];
    
    self.view = _mapView;
    if(!_mapNavController){
        _mapNavController= (MapNavigationController*)self.parentViewController;
    }
    _userModel = _mapNavController.userModel;
    NSLog(@"userModel set in MapViewController, employeeId: %@",_userModel.employeeId);
  
    [self retrieveAppointmentsForUser:_mapNavController.userModel];
 
}

- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark – Firebase queries
/** -(void) retrieveAppointmentsForUser:(UserModel*)userModel
 *  retrieves appointments for user by ID.
    TODO: Filter by date & sort
 */
-(void) retrieveAppointmentsForUser:(UserModel*)userModel
{
    NSString * empId = _userModel.employeeId;
    _appointments= [ [Firebase alloc] initWithUrl: [NSString stringWithFormat:@"%@/%@", kFirebaseURL, @"appointments"]];
    [[_appointments queryOrderedByChild:@"appointment_id"] observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *snapShot) {
        FQuery *queryRef = [[_appointments queryOrderedByChild:@"employee_id"] queryEqualToValue:empId];
         [queryRef observeSingleEventOfType:FEventTypeValue withBlock:^(FDataSnapshot *querySnapshot) {
             for (FDataSnapshot* child in querySnapshot.children) {
                 NSLog(@"child.key %@, child.value %@", child.key, child.value);
                 GeocodingModel * gModel = [[GeocodingModel alloc] initWithCompany:child.value[@"company"] address1:child.value[@"address_1"] address2:child.value[@"address_2"] city:child.value[@"city"] state:child.value[@"state"] zip:child.value[@"zip"]];
                 [_locations insertObject:gModel atIndex:_locations.count];
             }
             
             // Ask for My Location data after the map has already been added to the UI.
             dispatch_async(dispatch_get_main_queue(), ^{
                 _mapView.myLocationEnabled = YES;
             });
        }];
    }];
}

-(void) geocodeAddresses
{
    
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that location.
        _firstLocationUpdate = YES;
        
        
        //CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        NSMutableArray * coords = [[NSMutableArray alloc] init];
        GMSMutablePath *path = [GMSMutablePath path];
        for (GeocodingModel * obj in _locations)
        {
            CLLocationCoordinate2D thisSpot = [self geoCodeUsingAddress: [NSString stringWithFormat:@"%@,%@,%@,%@",obj.address_1, obj.city, obj.state, obj.zip]];
            GMSMarker * marker = [GMSMarker markerWithPosition: thisSpot];
            marker.title= obj.company;
            marker.snippet = obj.address_1;
            marker.flat = YES;
            marker.infoWindowAnchor = CGPointMake(0.5, 0.5);
          //  marker.icon = [UIImage imageNamed:@"mapMarker.png"];
          //  marker.icon.alignmentRectInsets;
            marker.map = _mapView;
            obj.latitude= [NSString stringWithFormat:@"%f",thisSpot.latitude];
            obj.longitude= [NSString stringWithFormat:@"%f",thisSpot.longitude];
            [coords insertObject:obj atIndex:coords.count];
            [path addCoordinate:thisSpot];
        }

        
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.map = _mapView;
        
        GMSCoordinateBounds *bounds= [[GMSCoordinateBounds alloc] initWithPath:path];
        GMSCameraPosition *camera = [_mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
        _mapView.camera = camera;
        
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
        [_mapView moveCamera:update];
    }
}

- (CLLocationCoordinate2D) geoCodeUsingAddress:(NSString *)address
{
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

-(void) passUserModel:(UserModel*) userModel{
    NSLog(@"userModel set in MapViewController, employeeID: %@",userModel.employeeId);
    _userModel=userModel;
}

@end