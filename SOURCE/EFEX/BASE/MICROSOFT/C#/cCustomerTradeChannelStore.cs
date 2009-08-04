/// <summary> 
/// Type   : Class
/// Name   : cCustomerTradeChannelStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile customer trade channel store
	/// </summary>
	public class cCustomerTradeChannelStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cCustomerTradeChannelStore() {
         cobjItems = new ArrayList();
		}

      /// <summary>
      /// Adds an item to the data store
      /// </summary>
      /// <param name="objCustomerTradeChannelData">the item reference</param>
      public void AddItem(cCustomerTradeChannelData objCustomerTradeChannelData) {
         cobjItems.Add(objCustomerTradeChannelData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TRADE_CHANNEL_STR, null);
         for (int i=0; i<cobjItems.Count; i++) {
            ((cCustomerTradeChannelData)cobjItems[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TRADE_CHANNEL_END, null);
      }
		
	}

}