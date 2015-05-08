//
//  MessageModel.h
//  Reportr
//
//  Created by Kim Adams on 5/1/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface MessageModel : NSObject


@property (nonatomic, retain) NSString * message;

@property (nonatomic, retain, getter=getUserName) NSString * userName;
@property (nonatomic, retain, getter=getPassword) NSString * password;

@property (nonatomic, retain) NSString * appointmentId;

@property (nonatomic,retain, readonly) NSString * videoSizeExceeded;
@property (nonatomic,retain, readonly) NSString * videoWarning;


+(id) sharedMessageModel;
-(NSString*)formattedTime:(NSString*)time;
-(void) displayError:(NSString*)errorType withMessage:(NSString*)errorMessage;


@end
