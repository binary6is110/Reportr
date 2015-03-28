//
//  DetailViewController.m
//  Reportr
//
//  Created by Kim Adams on 3/27/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "DetailViewController.h"

@interface DetailViewController ()

@end

@implementation DetailViewController

#pragma mark - Managing the detail item

- (void)setDetailItem:(id)newDetailItem {
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
            
        // Update the view.
        [self configureView];
    }
}

- (void)configureView {
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem description];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:0 longitude:0 zoom:6];
    GMSMapView * mapView = [GMSMapView mapWithFrame:CGRectZero camera:camera];
    
   // GMSMapView * mapView = [[GMSMapView alloc] initWithFrame:self.view.bounds];
    mapView.myLocationEnabled = YES;
    
    
    GMSMarker *marker = [[GMSMarker alloc] init];
    marker.position = camera.target;
    marker.snippet = @"Hello World";
    marker.appearAnimation = kGMSMarkerAnimationPop;
    marker.map = mapView;
    
    self.view = mapView;
    
  
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
