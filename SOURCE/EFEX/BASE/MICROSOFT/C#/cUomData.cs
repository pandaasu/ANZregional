/// <summary>
/// Type   : Class
/// Name   : cUomData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile UOM data
	/// </summary>
	public class cUomData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_UOM, null);
         objMailbox.AddMessage(cMailbox.EFEX_UOM_NAME, GetValue("UOM_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_UOM_TEXT, GetValue("UOM_TEXT"));
		}

	}

}