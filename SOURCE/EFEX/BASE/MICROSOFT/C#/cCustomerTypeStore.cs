/// <summary> 
/// Type   : Class
/// Name   : cCustomerTypeStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile customer type store
	/// </summary>
	public class cCustomerTypeStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cCustomerTypeStore() {
         cobjItems = new ArrayList();
		}

      /// <summary>
      /// Adds an item to the data store
      /// </summary>
      /// <param name="objCustomerTypeData">the item reference</param>
      public void AddItem(cCustomerTypeData objCustomerTypeData) {
         cobjItems.Add(objCustomerTypeData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE_STR, null);
         for (int i=0; i<cobjItems.Count; i++) {
            ((cCustomerTypeData)cobjItems[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_CUS_TYPE_END, null);
      }
		
	}

}