/// <summary> 
/// Type   : Class
/// Name   : cCustomerStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile customer store
	/// </summary>
	public class cCustomerStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjCustomers;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
		internal cCustomerStore() {
         cobjCustomers = new ArrayList();
		}

      /// <summary>
      /// Adds a customer to the customer store
      /// </summary>
      /// <param name="objCustomerData">the customer data reference</param>
      public void AddCustomer(cCustomerData objCustomerData) {
         cobjCustomers.Add(objCustomerData);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS_STR, null);
         for (int i = 0; i < cobjCustomers.Count; i++) {
            ((cCustomerData)cobjCustomers[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_CUS_END, null);
      }

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         objBuffer.Append("<CUS_LIST>");
         for (int i = 0; i < cobjCustomers.Count; i++) {
            ((cCustomerData)cobjCustomers[i]).GetXML(objBuffer);
         }
         objBuffer.Append("</CUS_LIST>");
      }
		
	}

}