/// <summary> 
/// Type   : Class
/// Name   : cRouteStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile route store
	/// </summary>
	public class cRouteStore : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjRouteCalls;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
		internal cRouteStore() {
         cobjRouteCalls = new ArrayList();
		}

      /// <summary>
      /// Adds a call to the route store
      /// </summary>
      /// <param name="objRouteCall">the route call reference</param>
      public void AddCall(cRouteCall objRouteCall) {
         cobjRouteCalls.Add(objRouteCall);
      }

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
      protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STR, null);
         for (int i=0; i<cobjRouteCalls.Count; i++) {
            ((cRouteCall)cobjRouteCalls[i]).GetBinary(objMailbox);
         }
         objMailbox.AddMessage(cMailbox.EFEX_RTE_END, null);
      }

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         objBuffer.Append("<RTE_CALLS>");
         for (int i=0; i<cobjRouteCalls.Count; i++) {
            ((cRouteCall)cobjRouteCalls[i]).GetXML(objBuffer);
         }
         objBuffer.Append("</RTE_CALLS>");
      }
		
	}

}