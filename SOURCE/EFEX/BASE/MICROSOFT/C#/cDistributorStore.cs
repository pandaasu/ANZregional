/// <summary> 
/// Type   : Class
/// Name   : cDistributorStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
   /// This class implements the mobile distributor store
	/// </summary>
	public class cDistributorStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cDistributorStore() {
         cobjItems = new ArrayList();
		}

      /// <summary>
      /// Adds an item to the data store
      /// </summary>
      /// <param name="objDistributorData">the item reference</param>
      public void AddItem(cDistributorData objDistributorData) {
         cobjItems.Add(objDistributorData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_DIS_STR, null);
         for (int i=0; i<cobjItems.Count; i++) {
            ((cDistributorData)cobjItems[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_DIS_END, null);
      }
		
	}

}