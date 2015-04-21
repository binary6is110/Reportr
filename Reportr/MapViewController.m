#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "MapViewController.h"
#import <Firebase/Firebase.h>
#import <GoogleMaps/GoogleMaps.h>



@implementation MapViewController {
    GMSMapView *mapView_;
    BOOL firstLocationUpdate_;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:12];
    
    mapView_ = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    mapView_.settings.myLocationButton = YES;
    
    // Listen to the myLocation property of GMSMapView.
    [mapView_ addObserver:self
               forKeyPath:@"myLocation"
                  options:NSKeyValueObservingOptionNew
                  context:NULL];
    
    self.view = mapView_;
    
    // Create a reference to a Firebase location
    Firebase *myRootRef = [[Firebase alloc] initWithUrl:@"https://reportr.firebaseio.com"];
    // Write data to Firebase
    [myRootRef setValue:@"Do you have data? You'll love Firebase."];

    // Read data and react to changes
    [myRootRef observeEventType:FEventTypeValue withBlock:^(FDataSnapshot *snapshot) {
        NSLog(@"%@ -> %@", snapshot.key, snapshot.value);
    }];
    
    // Ask for My Location data after the map has already been added to the UI.
    dispatch_async(dispatch_get_main_queue(), ^{
        mapView_.myLocationEnabled = YES;
    });
}

- (void)dealloc {
    [mapView_ removeObserver:self
                  forKeyPath:@"myLocation"
                     context:NULL];
}

#pragma mark - KVO updates
- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (!firstLocationUpdate_) {
        // If the first location update has not yet been recieved, then jump to that location.
        firstLocationUpdate_ = YES;
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
        polyline.map = mapView_;
        
        GMSCoordinateBounds *bounds= [[GMSCoordinateBounds alloc] initWithPath:path];
        GMSCameraPosition *camera = [mapView_ cameraForBounds:bounds insets:UIEdgeInsetsZero];
        mapView_.camera = camera;
        
        GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds withPadding:50.0f];
        [mapView_ moveCamera:update];
     
    }
}

@end
