//
//  CMCMemoryTextField.h
//  VideoConference
//
//  Created by Alvaro on 25/10/16.
//  Copyright © 2016 CMC. All rights reserved.
//

#import <UIKit/UIKit.h>

FOUNDATION_EXPORT double AOMemoryTextFieldVersionNumber;

FOUNDATION_EXPORT const unsigned char AOMemoryTextFieldVersionString[];

@interface AOMemoryTextField : UITextField

- (void)setNameKey:(NSString *)key;
- (void)saveNewEntry;
- (void)filterPreviousOptionsWithTippedText:(NSString *)text;
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;

@end
