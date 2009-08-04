/// <summary>
/// Type   : Class
/// Name   : cMessageData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile message data
	/// </summary>
	public class cMessageData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_MSG, null);
         objMailbox.AddMessage(cMailbox.EFEX_MSG_ID, GetValue("MSG_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_MSG_OWNER, GetValue("MSG_OWNER"));
         objMailbox.AddMessage(cMailbox.EFEX_MSG_TITLE, GetValue("MSG_TITLE"));
         objMailbox.AddMessage(cMailbox.EFEX_MSG_TEXT, GetValue("MSG_TEXT"));
         objMailbox.AddMessage(cMailbox.EFEX_MSG_STATUS, GetValue("MSG_STATUS"));
		}

	}

}