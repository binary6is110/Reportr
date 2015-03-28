#if !defined(__has_feature) || !__has_feature(objc_arc)
#error "This file requires ARC support."
#endif

#import "Samples.h"

// Map Demos
#import "BasicMapViewController.h"
/*
#import "SDKDemos/Samples/CustomIndoorViewController.h"
#import "SDKDemos/Samples/DoubleMapViewController.h"
#import "SDKDemos/Samples/GestureControlViewController.h"
#import "SDKDemos/Samples/IndoorMuseumNavigationViewController.h"
#import "SDKDemos/Samples/IndoorViewController.h"
#import "SDKDemos/Samples/MapTypesViewController.h"
#import "SDKDemos/Samples/MapZoomViewController.h"
#import "SDKDemos/Samples/MyLocationViewController.h"
#import "SDKDemos/Samples/TrafficMapViewController.h"
#import "SDKDemos/Samples/VisibleRegionViewController.h"

// Panorama Demos
#import "SDKDemos/Samples/FixedPanoramaViewController.h"
#import "SDKDemos/Samples/PanoramaViewController.h"

// Overlay Demos
#import "SDKDemos/Samples/AnimatedCurrentLocationViewController.h"
#import "SDKDemos/Samples/CustomMarkersViewController.h"
#import "SDKDemos/Samples/GradientPolylinesViewController.h"
#import "SDKDemos/Samples/GroundOverlayViewController.h"
#import "SDKDemos/Samples/MarkerEventsViewController.h"
#import "SDKDemos/Samples/MarkerInfoWindowViewController.h"
#import "SDKDemos/Samples/MarkerLayerViewController.h"
#import "SDKDemos/Samples/MarkersViewController.h"
#import "SDKDemos/Samples/PolygonsViewController.h"
#import "SDKDemos/Samples/PolylinesViewController.h"
#import "SDKDemos/Samples/TileLayerViewController.h"

// Camera Demos
#import "SDKDemos/Samples/CameraViewController.h"
#import "SDKDemos/Samples/FitBoundsViewController.h"
#import "SDKDemos/Samples/MapLayerViewController.h"

// Services
#import "SDKDemos/Samples/GeocoderViewController.h"
#import "SDKDemos/Samples/StructuredGeocoderViewController.h"*/

@implementation Samples

+ (NSArray *)loadSections {
  return @[ @"Map" ];
}

+ (NSArray *)loadDemos {
  NSArray *mapDemos =
  @[[self newDemo:[BasicMapViewController class]
        withTitle:@"Basic Map"
   andDescription:nil]];
  return @[mapDemos];
}

+ (NSDictionary *)newDemo:(Class) class
                withTitle:(NSString *)title
           andDescription:(NSString *)description {
  return [[NSDictionary alloc] initWithObjectsAndKeys:class, @"controller",
          title, @"title", description, @"description", nil];
}
@end
