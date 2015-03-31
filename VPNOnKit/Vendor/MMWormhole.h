//
// MMWormhole.h
//
// Copyright (c) 2014 Mutual Mobile (http://www.mutualmobile.com/)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

#import <Foundation/Foundation.h>

/**
 This class creates a wormhole between a containing iOS application and an extension. The wormhole
 is meant to be used to pass data or commands back and forth between the two locations. The effect
 closely resembles interprocess communication between the app and the extension, though this is not
 really the case. The wormhole does have some disadvantages, including the fact that a contract must
 be determined in advance between the app and the extension that defines the interchange format.
 
 A good way to think of the wormhole is a collection of shared mailboxes. An identifier is
 essentially a unique mailbox you can send messages to. You know where a message will be delivered
 to because of the identifier you associate with it, but not necessarily when the message will be
 picked up by the recipient. If the app or extension are in the background, they may not receive the
 message immediately. By convention, sending messages should be done from one side to another, not
 necessarily from yourself to yourself. It's also a good practice to check the contents of your
 mailbox when your app or extension wakes up, in case any messages have been left there while you
 were away.
 
 Passing a message to the wormhole can be inferred as a data transfer package or as a command. In
 both cases, the passed message is archived using NSKeyedArchiver to a .archive file named with the
 included identifier. Once passed, the contents of the written .archive file can be queried using
 the messageWithIdentifier: method. As a command, the simple existence of the message in the shared
 app group should be taken as proof of the command's invocation. The contents of the message then
 become parameters to be evaluated along with the command. Of course, to avoid confusion later, it
 may be best to clear the contents of the message after recognizing the command. The
 -clearMessageContentsForIdentifier: method is provided for this purpose.
 
 A good wormhole includes wormhole aliens who listen for message changes. This class supports
 CFNotificationCenter Darwin Notifications, which act as a bridge between the containing app and the
 extension. When a message is passed with an identifier, a notification is fired to the Darwin
 Notification Center with the given identifier. If you have indicated your interest in the message
 by using the -listenForMessageWithIdentifier:completion: method then your completion block will be
 called when this notification is received, and the contents of the message will be unarchived and
 passed as an object to the completion block.
 
 It's worth noting that as a best practice to avoid confusing issues or deadlock that messages
 should be passed one way only for a given identifier. The containing app should pass messages to
 one set of identifiers, which are only ever read or listened for by the extension, and vic versa.
 The extension should not then write messages back to the same identifier. Instead, the extension
 should use it's own set of identifiers to associate with it's messages back to the application.
 Passing messages to the same identifier from two locations should be done only at your own risk.
 */
@interface MMWormhole : NSObject

/**
 Designated Initializer. This method must be called with an application group identifier that will
 be used to contain passed messages. It is also recommended that you include a directory name for
 messages to be read and written, but this parameter is optional.
 
 @param identifier An application group identifier
 @param directory An optional directory to read/write messages
 */

- (instancetype)initWithApplicationGroupIdentifier:(NSString *)identifier
                                 optionalDirectory:(NSString *)directory NS_DESIGNATED_INITIALIZER;

/**
 This method passes a message object associated with a given identifier. This is the primary means
 of passing information through the wormhole.
 
 @warning You should avoid situations where you need to pass messages to the same identifier in
 rapid succession. If a message's contents will be changing rapidly then consider modifying your
 workflow to write bulk changes without listening on the other side of the wormhole, and then add a
 listener for a "finished changing" message to let the other side know it's safe to read the 
 contents of your message.
 
 @param messageobject The message object to be passed. 
                      This object may be nil. In this case only a notification is posted.
 @param identifier The identifier for the message
 */
- (void)passMessageObject:(id <NSCoding>)messageObject
               identifier:(NSString *)identifier;

/**
 This method returns the value of a message with a specific identifier as an object.
 
 @param identifier The identifier for the message
 */
- (id)messageWithIdentifier:(NSString *)identifier;

/**
 This method clears the contents of a specific message with a given identifier.
 
 @param identifier The identifier for the message
 */
- (void)clearMessageContentsForIdentifier:(NSString *)identifier;

/**
 This method clears the contents of your optional message directory to give you a clean state.
 
 @warning This method will delete all messages passed to your message directory. Use with care.
 */
- (void)clearAllMessageContents;

/**
 This method begins listening for notifications of changes to a message with a specific identifier.
 If notifications are observed then the given listener block will be called along with the actual
 message object.
 
 @discussion This class only supports one listener per message identifier, so calling this method
 repeatedly for the same identifier will update the listener block that will be called when a
 message is heard.
 
 @param identifier The identifier for the message
 @param listener A listener block called with the messageObject parameter when a notification
 is observed.
 */
- (void)listenForMessageWithIdentifier:(NSString *)identifier
                              listener:(void (^)(id messageObject))listener;

/**
 This method stops listening for change notifications for a given message identifier.
 
 NOTE: This method is NOT required to be called. If the wormhole is deallocated then all listeners
 will go away as well.
 
 @param identifier The identifier for the message
 */
- (void)stopListeningForMessageWithIdentifier:(NSString *)identifier;

@end
