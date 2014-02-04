#import <Preferences/Preferences.h>
@interface PSTableCell (meh)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
@end
@interface AuditusLinkListCell : PSTableCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
@end

@implementation AuditusLinkListCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
	self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
	NSString* filePath = @"/var/mobile/Library/Preferences/com.ridan.auditus.plist";
	NSMutableDictionary* plist = [[NSMutableDictionary alloc] initWithContentsOfFile:filePath];
        BOOL isEnabled = [[plist objectForKey:@"isEnabled"]boolValue];

	if (self) {
		if(!isEnabled){
			//self.userInteractionEnabled = NO;
			self.backgroundColor = [UIColor colorWithRed:.93 green:.93 blue:.93 alpha: .9];
			[specifier setProperty:[NSNumber numberWithBool:NO] forKey:@"enabled"];
			//[[[self subviews]lastObject] setAlpha:.4];
		}else{
			//self.userInteractionEnabled = YES;
			self.backgroundColor = [UIColor whiteColor];
			[specifier setProperty:[NSNumber numberWithBool:YES] forKey:@"enabled"];
			//[[[self subviews]lastObject] setAlpha:1.0];
		}

	}

	return self;
}
@end
@interface auditusPrefsListController: PSListController {
}
@end

@implementation auditusPrefsListController
- (id)specifiers {
	if(_specifiers == nil) {
		_specifiers = [[self loadSpecifiersFromPlistName:@"Auditus" target:self] retain];
		[[self specifierAtIndex:2] setProperty:[AuditusLinkListCell class] forKey:@"cellClass"];
	}
	return _specifiers;
}
-(void)setPreferenceValue:(id)value specifier:(id)specifier
{
	[super setPreferenceValue:value specifier:specifier];
	[self reloadSpecifierAtIndex:2 animated:YES];
}
- (void)twitter
{
if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tweetbot:///user_profile/" stringByAppendingString:@"r_idn"]]];
	} else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"twitter://user?screen_name=" stringByAppendingString:@"r_idn"]]];
	} else {
		[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"https://mobile.twitter.com/" stringByAppendingString:@"r_idn"]]];
	}
}

@end

// vim:ft=objc
