/// <summary> 
/// Type   : Class
/// Name   : cUomStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile UOM store
	/// </summary>
	public class cUomStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cUomStore() {
         cobjItems = new ArrayList();
		}

      /// <summary>
      /// Adds an item to the data store
      /// </summary>
      /// <param name="objUomData">the item reference</param>
      public void AddItem(cUomData objUomData) {
         cobjItems.Add(objUomData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_UOM_STR, null);
         for (int i=0; i<cobjItems.Count; i++) {
            ((cUomData)cobjItems[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_UOM_END, null);
      }
		
	}

}