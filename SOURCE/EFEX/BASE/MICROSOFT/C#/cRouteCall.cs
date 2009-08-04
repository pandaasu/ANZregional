/// <summary>
/// Type   : Class
/// Name   : cRouteCall
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile route call
	/// </summary>
	public class cRouteCall : cDataStore {

		//
		// Class declarations
		//
      private ArrayList cobjRouteStockItems;
      private ArrayList cobjRouteDisplayItems;
      private ArrayList cobjRouteActivityItems;
      private ArrayList cobjRouteOrderItems;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
      internal cRouteCall() {
         cobjRouteStockItems = new ArrayList();
         cobjRouteDisplayItems = new ArrayList();
         cobjRouteActivityItems = new ArrayList();
         cobjRouteOrderItems = new ArrayList();
		}

      /// <summary>
      /// Adds a stock item to the route call
      /// </summary>
      /// <param name="objRouteStockItem">the item reference</param>
      public void AddStockItem(cRouteStockItem objRouteStockItem) {
         cobjRouteStockItems.Add(objRouteStockItem);
      }

      /// <summary>
      /// Adds a display item to the route call
      /// </summary>
      /// <param name="objRouteDisplayItem">the display reference</param>
      public void AddDisplayItem(cRouteDisplayItem objRouteDisplayItem) {
         cobjRouteDisplayItems.Add(objRouteDisplayItem);
      }

      /// <summary>
      /// Adds an activity item to the route call
      /// </summary>
      /// <param name="objRouteActivityItem">the activity reference</param>
      public void AddActivityItem(cRouteActivityItem objRouteActivityItem) {
         cobjRouteActivityItems.Add(objRouteActivityItem);
      }

      /// <summary>
      /// Adds a order item to the route call
      /// </summary>
      /// <param name="objRouteOrderItem">the item reference</param>
      public void AddOrderItem(cRouteOrderItem objRouteOrderItem) {
         cobjRouteOrderItems.Add(objRouteOrderItem);
      }
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL, null);
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_SEQUENCE, GetValue("RTE_CALL_SEQUENCE"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_CUSTOMER_ID, GetValue("RTE_CALL_CUSTOMER_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_CUSTOMER_CODE, GetValue("RTE_CALL_CUSTOMER_CODE"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_CUSTOMER_NAME, GetValue("RTE_CALL_CUSTOMER_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_CUSTOMER_TYPE, GetValue("RTE_CALL_CUSTOMER_TYPE"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_MARKET, GetValue("RTE_CALL_MARKET"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_STATUS, GetValue("RTE_CALL_STATUS"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_DATE, GetValue("RTE_CALL_DATE"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_STR_TIME, GetValue("RTE_CALL_STR_TIME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_END_TIME, GetValue("RTE_CALL_END_TIME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_ORDER_SEND, GetValue("RTE_CALL_ORDER_SEND"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_CALL_STOCK_DIST_COUNT, GetValue("RTE_CALL_STOCK_DIST_COUNT"));
         for (int i=0; i<cobjRouteStockItems.Count; i++) {
            ((cRouteStockItem)cobjRouteStockItems[i]).GetBinary(objMailbox);
         }
         for (int i=0; i<cobjRouteDisplayItems.Count; i++) {
            ((cRouteDisplayItem)cobjRouteDisplayItems[i]).GetBinary(objMailbox);
         }
         for (int i=0; i<cobjRouteActivityItems.Count; i++) {
            ((cRouteActivityItem)cobjRouteActivityItems[i]).GetBinary(objMailbox);
         }
         for (int i=0; i<cobjRouteOrderItems.Count; i++) {
            ((cRouteOrderItem)cobjRouteOrderItems[i]).GetBinary(objMailbox);
         }
		}

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         if (GetValue("RTE_CALL_STATUS").Equals("1")) {
            objBuffer.Append("<RTE_CALL>");
            objBuffer.Append("<RTE_CALL_CUSTOMER_ID><![CDATA[" + GetValue("RTE_CALL_CUSTOMER_ID") + "]]></RTE_CALL_CUSTOMER_ID>");
            objBuffer.Append("<RTE_CALL_DATE><![CDATA[" + GetValue("RTE_CALL_DATE") + "]]></RTE_CALL_DATE>");
            objBuffer.Append("<RTE_CALL_STR_TIME><![CDATA[" + GetValue("RTE_CALL_STR_TIME") + "]]></RTE_CALL_STR_TIME>");
            objBuffer.Append("<RTE_CALL_END_TIME><![CDATA[" + GetValue("RTE_CALL_END_TIME") + "]]></RTE_CALL_END_TIME>");
            objBuffer.Append("<RTE_CALL_STOCK_DIST_COUNT><![CDATA[" + GetValue("RTE_CALL_STOCK_DIST_COUNT") + "]]></RTE_CALL_STOCK_DIST_COUNT>");
            objBuffer.Append("<RTE_STCK_ITEMS>");
            for (int i=0; i<cobjRouteStockItems.Count; i++) {
               ((cRouteStockItem)cobjRouteStockItems[i]).GetXML(objBuffer);
            }
            objBuffer.Append("</RTE_STCK_ITEMS>");
            objBuffer.Append("<RTE_DISP_ITEMS>");
            for (int i=0; i<cobjRouteDisplayItems.Count; i++) {
               ((cRouteDisplayItem)cobjRouteDisplayItems[i]).GetXML(objBuffer);
            }
            objBuffer.Append("</RTE_DISP_ITEMS>");
            objBuffer.Append("<RTE_ACTV_ITEMS>");
            for (int i=0; i<cobjRouteActivityItems.Count; i++) {
               ((cRouteActivityItem)cobjRouteActivityItems[i]).GetXML(objBuffer);
            }
            objBuffer.Append("</RTE_ACTV_ITEMS>");
            int intOrderItems = 0;
            for (int i=0; i<cobjRouteOrderItems.Count; i++) {
               if (((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY") != null
                  && !((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY").Equals("")
                  && !((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY").Equals("0")) {
                  intOrderItems++;
               }
            }
            if (intOrderItems != 0) {
               objBuffer.Append("<RTE_ORDR>");
               objBuffer.Append("<RTE_ORDR_LINE_COUNT><![CDATA[" + intOrderItems.ToString() + "]]></RTE_ORDR_LINE_COUNT>");
               objBuffer.Append("<RTE_ORDR_SEND_WHSLR><![CDATA[" + GetValue("RTE_CALL_ORDER_SEND") + "]]></RTE_ORDR_SEND_WHSLR>");
               for (int i = 0; i < cobjRouteOrderItems.Count; i++) {
                  if (((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY") != null
                     && !((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY").Equals("")
                     && !((cRouteOrderItem)cobjRouteOrderItems[i]).GetValue("RTE_ORDR_ITEM_QTY").Equals("0")) {
                     ((cRouteOrderItem)cobjRouteOrderItems[i]).GetXML(objBuffer);
                  }
               }
               objBuffer.Append("</RTE_ORDR>");
            }
            objBuffer.Append("</RTE_CALL>");
         }
      }

	}

}