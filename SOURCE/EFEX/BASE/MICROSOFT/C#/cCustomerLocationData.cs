/// <summary>
/// Type   : Class
/// Name   : cCustomerLocationData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile customer location data
	/// </summary>
   public class cCustomerLocationData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_LOCN, null);
         objMailbox.AddMessage(cMailbox.EFEX_CUS_LOCN_NAME, GetValue("CUS_LOCN_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_LOCN_TEXT, GetValue("CUS_LOCN_TEXT"));
		}

	}

}