//
//  AlertPrompt.m
//  Prompt
//
//  Created by Jeff LaMarche on 2/26/09.

#import "AlertPrompt.h"

@implementation AlertPrompt
@synthesize textField;
@synthesize enteredText;
- (id)initWithTitle:(NSString *)title message:(NSString *)message delegate:(id)delegate cancelButtonTitle:(NSString *)cancelButtonTitle okButtonTitle:(NSString *)okayButtonTitle
{
    
    if ((self = [super initWithTitle:title message:message delegate:delegate cancelButtonTitle:cancelButtonTitle otherButtonTitles:okayButtonTitle, nil]))
    {
        UITextField *theTextField = [[UITextField alloc] initWithFrame:CGRectMake(12.0, 45.0, 260.0, 25.0)]; 
        [theTextField setBackgroundColor:[UIColor whiteColor]]; 
        theTextField.keyboardAppearance = UIKeyboardAppearanceAlert;
        theTextField.autocapitalizationType  = UITextAutocapitalizationTypeNone;
        theTextField.autocorrectionType = UITextAutocapitalizationTypeNone;
        theTextField.textAlignment = UITextAlignmentCenter;
        
        [self addSubview:theTextField];
        self.textField = theTextField;
        
        [theTextField release];
        
        //textField.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
        //CGAffineTransform translate = CGAffineTransformMakeTranslation(0.0, 130.0); 
        //[self setTransform:translate];
    }
    return self;
}
- (void)show
{
    [textField becomeFirstResponder];
    [super show];
}
- (NSString *)enteredText
{
    return textField.text;
}
- (void)dealloc
{
    [textField release];
    [super dealloc];
}
@end