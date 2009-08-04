/// <summary>
/// Type   : Class
/// Name   : cCustomerTradeChannelData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile customer trade channel data
	/// </summary>
   public class cCustomerTradeChannelData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TRADE_CHANNEL, null);
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TRADE_CHANNEL_ID, GetValue("CUS_TRADE_CHANNEL_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TRADE_CHANNEL_NAME, GetValue("CUS_TRADE_CHANNEL_NAME"));
		}

	}

}