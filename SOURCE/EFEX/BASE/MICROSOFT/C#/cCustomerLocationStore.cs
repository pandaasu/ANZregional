/// <summary> 
/// Type   : Class
/// Name   : cCustomerLocationStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile customer location store
	/// </summary>
	public class cCustomerLocationStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cCustomerLocationStore() {
         cobjItems = new ArrayList();
		}

      /// <summary>
      /// Adds an item to the data store
      /// </summary>
      /// <param name="objCustomerLocationData">the item reference</param>
      public void AddItem(cCustomerLocationData objCustomerLocationData) {
         cobjItems.Add(objCustomerLocationData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_LOCN_STR, null);
         for (int i=0; i<cobjItems.Count; i++) {
            ((cCustomerLocationData)cobjItems[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_CUS_LOCN_END, null);
      }
		
	}

}