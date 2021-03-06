//
//  ApptTableViewCell.m
//  Reportr
//
//  Created by Kim Adams on 5/6/15.
//  Copyright (c) 2015 Lopez Negrete Communications. All rights reserved.
//

#import "ApptTableViewCell.h"
#import "ApplicationModel.h"

@interface ApptTableViewCell()
@property (nonatomic) IBOutlet UILabel * timeLbl;
@property (nonatomic) IBOutlet UILabel * companyLbl;
@property (nonatomic) IBOutlet UILabel * agendaLbl;
@end

@implementation ApptTableViewCell


- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void) highlightCell{
    if(!_isHighlighted){
      
        [_timeLbl setFont:[UIFont boldSystemFontOfSize:18]];
        _companyLbl.textColor=[[ApplicationModel sharedApplicationModel] lightBlueColor];
        self.contentView.backgroundColor = [[ApplicationModel sharedApplicationModel] lightGreyColor];

        _isHighlighted=YES;
    }
}

-(void) resetCell{
    if(_isHighlighted){
        _companyLbl.textColor = [UIColor grayColor ];
        [_timeLbl setFont:[UIFont systemFontOfSize:18]];

         self.contentView.backgroundColor = [UIColor whiteColor];
        _isHighlighted = NO;
    }
}


-(void) setTime:(NSString *)time{
    _timeLbl.text = time;
    
}
-(void) setCompany:(NSString *)company{
    _companyLbl.text=company;
    
}
-(void) setAgenda:(NSString *)agenda{
    _agendaLbl.text=agenda;
    
}


@end
