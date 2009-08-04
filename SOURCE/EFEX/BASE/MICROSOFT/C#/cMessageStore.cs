/// <summary> 
/// Type   : Class
/// Name   : cMessageStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile message store
	/// </summary>
	public class cMessageStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjMessages;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
		internal cMessageStore() {
         cobjMessages = new ArrayList();
		}

      /// <summary>
      /// Adds a message to the message store
      /// </summary>
      /// <param name="objMessageData">the message data reference</param>
      public void AddMessage(cMessageData objMessageData) {
         cobjMessages.Add(objMessageData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_MSG_STR, null);
         for (int i=0; i<cobjMessages.Count; i++) {
            ((cMessageData)cobjMessages[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_MSG_END, null);
      }
		
	}

}