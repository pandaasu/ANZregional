/// <summary>
/// Type   : Class
/// Name   : cDistributorData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile distributor data
	/// </summary>
   public class cDistributorData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_DIS, null);
         objMailbox.AddMessage(cMailbox.EFEX_DIS_ID, GetValue("DIS_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_DIS_NAME, GetValue("DIS_NAME"));
		}

	}

}