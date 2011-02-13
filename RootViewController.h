#import <UIKit/UIKit.h>
#import <CoreData/CoreData.h>
#import "ChatController.h"
//@class ChatController;
// This is a test to see how version control works in xcode 4.0

@protocol RootDelegate <NSObject>
@optional
-(void)sendUpdate;
@end



@interface RootViewController : UITableViewController <NSFetchedResultsControllerDelegate>
{
	NSFetchedResultsController *fetchedResultsController;
	ChatController *chatController;
	NSString *fromUser;
	id delegate;
}
-(void)updateChat;

@property (nonatomic, assign) id <RootDelegate> delegate;
@property (nonatomic, retain)NSString *fromUser;

@end
