/// <summary> 
/// Type   : Class
/// Name   : cControlStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile control store
	/// </summary>
	public class cControlStore : cDataStore {

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CTL_STR, null);
         objMailbox.AddMessage(cMailbox.EFEX_CTL, null);
         objMailbox.AddMessage(cMailbox.EFEX_CTL_USER_FIRSTNAME, GetValue("CTL_USER_FIRSTNAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_USER_LASTNAME, GetValue("CTL_USER_LASTNAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_MOBILE_DATE, GetValue("CTL_MOBILE_DATE"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_MOBILE_STATUS, GetValue("CTL_MOBILE_STATUS"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_MOBILE_LOADED_TIME, GetValue("CTL_MOBILE_LOADED_TIME"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_MOBILE_SAVED_TIME, GetValue("CTL_MOBILE_SAVED_TIME"));
         objMailbox.AddMessage(cMailbox.EFEX_CTL_END, null);
      }
		
	}

}