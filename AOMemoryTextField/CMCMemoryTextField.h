//
//  CMCMemoryTextField.h
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CMCMemoryTextField : UITextField

- (void)setNameKey:(NSString *)key;
- (void)saveNewEntry;
- (void)filterPreviousOptionsWithTippedText:(NSString *)text;
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
