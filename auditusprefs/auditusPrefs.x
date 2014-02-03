#import <Preferences/Preferences.h>

@interface auditusPrefsListController: PSListController {
}
@end

@implementation auditusPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Auditus" target:self] retain];
	}
	return _specifiers;
}
@end

// vim:ft=objc
