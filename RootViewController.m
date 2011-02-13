#import "RootViewController.h"
#import "FacebookBBrosemer.h"
#import "UIColor-Expanded.h"
#import "MutableChatDictionary.h"
#import "XMPP.h"
#import "XMPPRosterCoreDataStorage.h"
#import "XMPPUserCoreDataStorage.h"
#import "XMPPResourceCoreDataStorage.h"
#import "ChatController.h"

@implementation RootViewController
@synthesize delegate,fromUser;

- (void)viewDidLoad
{
	[super viewDidLoad];
	
	if(chatController == nil){
		chatController = [[ChatController alloc] init];
	}
	
	self.title = @"friends";
	self.navigationController.navigationBar.tintColor = [UIColor colorWithHexString:@"3B5998"];
	// Uncomment the following line to display an Edit button in the navigation bar for this view controller.
	// self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Accessors
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


- (XMPPStream *)xmppStream{
	return [FacebookBBrosemer xmppStream];
}

- (XMPPRoster *)xmppRoster
{
	return [FacebookBBrosemer xmppRoster];
}

- (XMPPRosterCoreDataStorage *)xmppRosterStorage
{
	return [FacebookBBrosemer xmppRosterStorage];
}

- (NSManagedObjectContext *)managedObjectContext
{
	return [[FacebookBBrosemer xmppRosterStorage] managedObjectContext];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSFetchedResultsController
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSFetchedResultsController *)fetchedResultsController
{
	if (fetchedResultsController == nil)
	{
		NSEntityDescription *entity = [NSEntityDescription entityForName:@"XMPPUserCoreDataStorage"
		                                          inManagedObjectContext:[self managedObjectContext]];
		
		NSSortDescriptor *sd1 = [[NSSortDescriptor alloc] initWithKey:@"sectionNum" ascending:YES];
		NSSortDescriptor *sd2 = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
		
		NSArray *sortDescriptors = [NSArray arrayWithObjects:sd1, sd2, nil];
		
		NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
		[fetchRequest setEntity:entity];
		[fetchRequest setSortDescriptors:sortDescriptors];
		[fetchRequest setFetchBatchSize:10];
		
		fetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest
		                                                               managedObjectContext:[self managedObjectContext]
		                                                                 sectionNameKeyPath:@"sectionNum"
		                                                                          cacheName:nil];
		[fetchedResultsController setDelegate:self];
		
		[sd1 release];
		[sd2 release];
		[fetchRequest release];
		
		NSError *error = nil;
		if (![fetchedResultsController performFetch:&error])
		{
			NSLog(@"Error performing fetch: %@", error);
		}
	}
	
	return fetchedResultsController;
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller
{
	[[self tableView] reloadData];
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark UITableView
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return [[[self fetchedResultsController] sections] count];
}

- (NSString *)tableView:(UITableView *)sender titleForHeaderInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
        
		int section = [sectionInfo.name intValue];
		switch (section)
		{
			case 0  : return @"Available";
			case 1  : return @"Away";
			default : return @"Offline";
		}
	}
	
	return @"";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)sectionIndex
{
	NSArray *sections = [[self fetchedResultsController] sections];
	
	if (sectionIndex < [sections count])
	{
		id <NSFetchedResultsSectionInfo> sectionInfo = [sections objectAtIndex:sectionIndex];
		return sectionInfo.numberOfObjects;
	}
	
	return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *CellIdentifier = @"Cell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if (cell == nil)
	{
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
		                               reuseIdentifier:nil] autorelease];
	}
	
	XMPPUserCoreDataStorage *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	if([user.displayName isEqualToString:fromUser]){
		cell.textColor = [UIColor colorWithHexString:@"3B5998"];
	}
	cell.textLabel.text = user.displayName;
	return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
	XMPPUserCoreDataStorage *user = [[self fetchedResultsController] objectAtIndexPath:indexPath];
	if([[FacebookBBrosemer mutableChatDictionary].chatDictionary objectForKey:user.displayName]==NULL){
		[[FacebookBBrosemer mutableChatDictionary] createChatForUser:user.displayName];
	}
	chatController.facebookChat = [[FacebookBBrosemer mutableChatDictionary].chatDictionary objectForKey:user.displayName];
	chatController.jid = user.jidStr;
	[self.navigationController pushViewController:chatController animated:YES];
	[tableView deselectRowAtIndexPath:indexPath animated:NO];
	[chatController setUpTable];
}

-(void)updateChat{
	//NSLog(@"IS THIS WORKING: %@",userName);
	//fromUser = [[NSString alloc] init];
	//fromUser = [NSString stringWithFormat:@"%@",userName];
	
	[self.tableView reloadData];
	//fromUser = nil;
	[chatController sendUpdate];
}



- (void)dealloc
{
	[super dealloc];
}

@end
