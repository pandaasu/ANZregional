/// <summary>
/// Type   : Class
/// Name   : cRouteStockItem
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
	
	/// <summary>
   /// This class implements the mobile route stock item
	/// </summary>
   public class cRouteStockItem : cDataStore {

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STCK_ITEM, null);
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STCK_ITEM_ID, GetValue("RTE_STCK_ITEM_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STCK_ITEM_NAME, GetValue("RTE_STCK_ITEM_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STCK_ITEM_REQUIRED, GetValue("RTE_STCK_ITEM_REQUIRED"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_STCK_ITEM_QTY, GetValue("RTE_STCK_ITEM_QTY"));
		}

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         objBuffer.Append("<RTE_STCK_ITEM>");
         objBuffer.Append("<RTE_STCK_ITEM_ID><![CDATA[" + GetValue("RTE_STCK_ITEM_ID") + "]]></RTE_STCK_ITEM_ID>");
         objBuffer.Append("<RTE_STCK_ITEM_QTY><![CDATA[" + GetValue("RTE_STCK_ITEM_QTY") + "]]></RTE_STCK_ITEM_QTY>");
         objBuffer.Append("</RTE_STCK_ITEM>");
      }

	}

}