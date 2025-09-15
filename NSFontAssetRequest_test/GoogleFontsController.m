//
//  GoogleFontsController.m
//  Google Fonts Viewer for GNUstep
//
//  Created for Objective-C 1.0 / GNUstep
//

#import "GoogleFontsController.h"

@implementation GoogleFontsController

- (id)init
{
    self = [super init];
    if (self) {
        fontsArray = [[NSMutableArray alloc] init];
        receivedData = [[NSMutableData alloc] init];
    }
    return self;
}

- (void)dealloc
{
#ifdef GNUSTEP
    [fontsArray release];
    [receivedData release];
    [connection release];
    [super dealloc];
#endif
}

#pragma mark - Properties (manual implementation for ObjC 1.0)
- (void) setTableView: (NSTableView *)tv
{
    fontsTableView = tv;
}

- (NSTableView *) tableView
{
    return fontsTableView;
}

- (NSMutableArray *)fontsArray
{
    return fontsArray;
}

- (void)setFontsArray:(NSMutableArray *)array
{
    if (fontsArray != array) {
#ifdef GNUSTEP
        [fontsArray release];
        fontsArray = [array retain];
#else
        fontsArray = array;
#endif
    }
}

#pragma mark - Font Loading Methods

- (void)loadFontsFromURL:(NSString *)urlString
{
    // Clear existing data
    [receivedData setLength:0];
    [fontsArray removeAllObjects];

    // Create the request
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url
                                             cachePolicy:NSURLRequestUseProtocolCachePolicy
                                         timeoutInterval:30.0];

#ifdef GNUSTEP
    // Start the connection
    if (connection) {
        [connection release];
    }
#endif
    connection = [[NSURLConnection alloc] initWithRequest: request delegate: self];

    if (!connection) {
        NSLog(@"Failed to create URL connection");
    } else {
        NSLog(@"Loading fonts from: %@", urlString);
	[connection start];
    }
}

- (void)parseFontsData:(NSData *)data
{
    NSError *error = nil;
    id jsonObject = nil;

    jsonObject = [NSJSONSerialization  JSONObjectWithData: data
						  options: 0
						    error: &error];
    if (!jsonObject)
      {
	NSLog(@"Failed to parse JSON data");
        return;
      }

    // Extract fonts from the parsed data
    if ([jsonObject isKindOfClass:[NSDictionary class]])
      {
        NSDictionary *jsonDict = (NSDictionary *)jsonObject;
        NSArray *items = [jsonDict objectForKey:@"items"];
	
        if ([items isKindOfClass:[NSArray class]])
	  {
            NSEnumerator *enumerator = [items objectEnumerator];
            NSDictionary *fontInfo;
	    
            while ((fontInfo = [enumerator nextObject]))
	      {
		if ([fontInfo isKindOfClass:[NSDictionary class]])
		  {
		    // Create a simplified font dictionary with the information we need
		    NSMutableDictionary *font = [NSMutableDictionary dictionary];
		    
		    NSString *family = [fontInfo objectForKey:@"family"];
		    NSString *category = [fontInfo objectForKey:@"category"];
                    NSArray *variants = [fontInfo objectForKey:@"variants"];
                    NSArray *subsets = [fontInfo objectForKey:@"subsets"];
		    
                    if (family) [font setObject:family forKey:@"family"];
                    if (category) [font setObject:category forKey:@"category"];
                    if (variants) [font setObject:variants forKey:@"variants"];
                    if (subsets) [font setObject:subsets forKey:@"subsets"];
		    
                    [fontsArray addObject:font];
		  }
	      }
	  }
      }

    NSLog(@"Loaded %d fonts", [fontsArray count]);

    // Reload the table view
    if (fontsTableView)
      {
        [fontsTableView reloadData];
      }
}

#pragma mark - NSURLConnection Delegate Methods

- (void)connection:(NSURLConnection *)conn didReceiveResponse:(NSURLResponse *)response
{
    [receivedData setLength:0];

    if ([response isKindOfClass:[NSHTTPURLResponse class]]) {
        NSHTTPURLResponse *httpResponse = (NSHTTPURLResponse *)response;
        NSLog(@"HTTP Response: %d", [httpResponse statusCode]);
    }
}

- (void)connection:(NSURLConnection *)conn didReceiveData:(NSData *)data
{
    [receivedData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)conn
{
    NSLog(@"Connection finished loading. Received %d bytes", [receivedData length]);
    [self parseFontsData:receivedData];
#ifdef GNUSTEP
    DESTROY(connection);
#endif
}

- (void)connection:(NSURLConnection *)conn didFailWithError:(NSError *)error
{
    NSLog(@"Connection failed with error: %@", [error localizedDescription]);
#ifdef GNUSTEP
    DESTROY(connection);
#endif
}

#pragma mark - NSTableViewDataSource Methods

- (int)numberOfRowsInTableView:(NSTableView *)tableView
{
    return [fontsArray count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(int)row
{
    if (row < 0 || row >= [fontsArray count]) {
        return nil;
    }

    NSDictionary *font = [fontsArray objectAtIndex:row];
    NSString *identifier = [tableColumn identifier];

    if ([identifier isEqualToString:@"family"]) {
        return [font objectForKey:@"family"];
    } else if ([identifier isEqualToString:@"category"]) {
        return [font objectForKey:@"category"];
    } else if ([identifier isEqualToString:@"variants"]) {
        NSArray *variants = [font objectForKey:@"variants"];
        if (variants) {
            return [variants componentsJoinedByString:@", "];
        }
        return @"";
    } else if ([identifier isEqualToString:@"subsets"]) {
        NSArray *subsets = [font objectForKey:@"subsets"];
        if (subsets) {
            return [subsets componentsJoinedByString:@", "];
        }
        return @"";
    }

    return @"";
}

#pragma mark - NSTableViewDelegate Methods

- (void)tableViewSelectionDidChange:(NSNotification *)notification
{
    int selectedRow = [fontsTableView selectedRow];

    if (selectedRow >= 0 && selectedRow < [fontsArray count]) {
        NSDictionary *selectedFont = [fontsArray objectAtIndex:selectedRow];
        NSLog(@"Selected font: %@", [selectedFont objectForKey:@"family"]);

        // You can add additional handling here, such as:
        // - Updating a preview
        // - Loading font files
        // - Displaying detailed information
    }
}

- (BOOL)tableView:(NSTableView *)tableView shouldSelectRow:(int)row
{
    // Allow all rows to be selected
    return YES;
}

@end
