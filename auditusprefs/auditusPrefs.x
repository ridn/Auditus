#import <Preferences/Preferences.h>
#import <Social/Social.h>

@interface PSTableCell (meh)
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier;
@end
@interface AuditusLinkListCell : PSTableCell
@end
@interface twitterCell : PSTableCell
@end
//special colored Twitter cell, b/c why not??
@implementation twitterCell
- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier specifier:(PSSpecifier *)specifier {
        self = [super initWithStyle:style reuseIdentifier:reuseIdentifier specifier:specifier];
        if(self)
        {
                self.backgroundColor = [UIColor colorWithRed:0.537 green:0.824 blue:0.961 alpha:1.0];//[UIColor colorWithRed:0.537 green:0.879 blue:0.961 alpha:1.0];
        }
        return self;
}
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
		UILongPressGestureRecognizer *shareLongPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPress:)];
		UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeCustom];

		[rightButton addGestureRecognizer:shareLongPress];
		[shareLongPress release];
		[rightButton addTarget:self
		   action:@selector(tweetMe)
		                forControlEvents:UIControlEventTouchUpInside];
		[rightButton setBackgroundImage:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/auditusPrefs.bundle/share.png"] forState:UIControlStateNormal];

		rightButton.frame = CGRectMake(0.0, 0.0, 21.0, 20.0);
		UIBarButtonItem *rightBarButton =[[UIBarButtonItem alloc] initWithCustomView:rightButton];
		[[self navigationItem] setRightBarButtonItem: rightBarButton];
		[rightBarButton release];

		_specifiers = [[self loadSpecifiersFromPlistName:@"Auditus" target:self] retain];
		[[self specifierAtIndex:2] setProperty:[AuditusLinkListCell class] forKey:@"cellClass"];
		[[self specifierAtIndex:[_specifiers count]-1] setProperty:[twitterCell class] forKey:@"cellClass"];
	}
	return _specifiers;
}
-(void)setPreferenceValue:(id)value specifier:(id)specifier
{
	[super setPreferenceValue:value specifier:specifier];
        if(specifier == [self specifierAtIndex:1])
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
- (void)tweetMe
{

	NSString* initialText = @"I'm loving Auditus by @r_idn" ;
	if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
		SLComposeViewController *twitterComposer = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
		[twitterComposer addURL:[NSURL URLWithString:@"http://github.com/ridn/Auditus"]];
		[twitterComposer setInitialText:initialText];
		[twitterComposer setCompletionHandler:^(SLComposeViewControllerResult result) {
		        [self.parentController dismissModalViewControllerAnimated:YES];
		}];
		[self.parentController presentViewController:twitterComposer animated:YES completion:nil];

	}
}

- (void)longPress:(UILongPressGestureRecognizer*)gesture {

	if ( gesture.state == UIGestureRecognizerStateBegan )
	{
		NSString* texttoshare =@"Check out Auditus by @r_idn";
		NSURL *urlToShare = [NSURL URLWithString:@"http://github.com/ridn/Auditus"];

		NSArray *activityItems = [NSArray arrayWithObjects:texttoshare,urlToShare,nil];
		UIActivityViewController *activityVC = [[UIActivityViewController alloc] initWithActivityItems:activityItems applicationActivities:nil];
		[self.parentController presentViewController:activityVC animated:YES completion:nil];
	}
}


@end

// vim:ft=objc
