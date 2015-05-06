//
//  ApptTableViewCell.h
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ApptTableViewCell : UITableViewCell

@property (nonatomic) BOOL isHighlighted;
-(void) setTime:(NSString *)time;
-(void) setCompany:(NSString *)company;
-(void) setAgenda:(NSString *)agenda;
-(void) resetCell;
-(void) highlightCell;
@end
