/// <summary>
/// Type   : Class
/// Name   : cCustomerTypeData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile customer type data
	/// </summary>
   public class cCustomerTypeData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE, null);
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE_ID, GetValue("CUS_TYPE_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE_NAME, GetValue("CUS_TYPE_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE_CHANNEL_ID, GetValue("CUS_TYPE_CHANNEL_ID"));
		}

	}

}