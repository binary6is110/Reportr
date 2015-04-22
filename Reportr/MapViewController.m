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

#import "UserModel.h"
#import "MapViewController.h"
#import "MapNavigationController.h"
#import <Firebase/Firebase.h>
#import <GoogleMaps/GoogleMaps.h>


@interface MapViewController ()
   @property GMSMapView *mapView;
   @property BOOL firstLocationUpdate;
   @property MapNavigationController * mapNavController;
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
    
    self.view = _mapView;
    if(!_mapNavController)
        _mapNavController= (MapNavigationController*)self.parentViewController;
    
    
    // Create a reference to a Firebase location
  //  Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://reportr.firebaseio.com"];
    // Write data to Firebase
   // [myRootRef setValue:@"Do you have data? You'll love Firebase."];

    // Read data and react to changes
  //  [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);    }];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        _mapView.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [_mapView removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!_firstLocationUpdate) {
        // If the first location update has not yet been recieved, then jump to that location.
        _firstLocationUpdate = YES;
        CLLocation *location = [change objectForKey:NSKeyValueChangeNewKey];
        CLLocationCoordinate2D loc1 = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        CLLocationCoordinate2D loc2 = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude+.01);
        CLLocationCoordinate2D loc3 = CLLocationCoordinate2DMake(location.coordinate.latitude-.05, location.coordinate.longitude+.01);
        CLLocationCoordinate2D loc4 = CLLocationCoordinate2DMake(location.coordinate.latitude-.05, location.coordinate.longitude-.1);
        CLLocationCoordinate2D loc5 = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude-.1);
        
        GMSMutablePath *path = [GMSMutablePath path];
        [path addCoordinate:loc1];
        [path addCoordinate:loc2];
        [path addCoordinate:loc3];
        [path addCoordinate:loc4];
        [path addCoordinate:loc5];
        [path addCoordinate:loc1];
        
        GMSPolyline *polyline = [GMSPolyline polylineWithPath:path];
        polyline.map = _mapView;
        
        GMSCoordinateBounds *bounds= [[GMSCoordinateBounds alloc] initWithPath:path];
        GMSCameraPosition *camera = [_mapView cameraForBounds:bounds insets:UIEdgeInsetsZero];
        _mapView.camera = camera;
        
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
        [_mapView moveCamera:update];
     
    }
}

-(void) hi
{
    NSLog (@"hi from map view controller");
}

-(void) passModel:(UserModel*)model
{
    NSLog (@"hi in map  view");
}

@end
