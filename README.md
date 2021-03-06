# MemoryTextField

MemoryTextField adds autocomplete functionality to your UITextFields in the simplest form. 

![readmeImg](https://raw.githubusercontent.com/AlvaroOlave/MTFPodSpecs/master/readmeImg.png)

## Installation

In your Podfile:

pod 'MemoryTextField', '~> 0.1'

## Usage

Just make your UITextField inherit from MemoryTextField and invoke the next methods in the right place:
```objective-c
- (void)setNameKey:(NSString *)key; 
```
Key used to read from the NSUserDefaults. If you don´t set this key, will be used the default key. TextFields with same key will share the same autocomplete words.

```objective-c
- (void)saveNewEntry;
```

Invoke this method when you want to save the current word. (e.g. In -(BOOL)textFieldShouldReturn:(UITextField*)textField method.)

```objective-c
- (BOOL)shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string; 
```

In your textField´s delegate, implement 

```objective-c
        - (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string;
```
    
and return the result of invoke this MemoryTextField method. 


Added support for your own persistence, in case that don´t want to use the NSUserDefaults.

## License

 MemoryTextField is available under the MIT license.
