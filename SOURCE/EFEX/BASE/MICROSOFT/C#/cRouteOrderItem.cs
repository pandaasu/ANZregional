/// <summary>
/// Type   : Class
/// Name   : cRouteOrderItem
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
	
	/// <summary>
	/// This class implements the mobile route order item
	/// </summary>
   public class cRouteOrderItem : cDataStore {

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM, null);
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_ID, GetValue("RTE_ORDR_ITEM_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_NAME, GetValue("RTE_ORDR_ITEM_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_TDU, GetValue("RTE_ORDR_ITEM_PRICE_TDU"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_MCU, GetValue("RTE_ORDR_ITEM_PRICE_MCU"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_PRICE_RSU, GetValue("RTE_ORDR_ITEM_PRICE_RSU"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_BRAND, GetValue("RTE_ORDR_ITEM_BRAND"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_PACKSIZE, GetValue("RTE_ORDR_ITEM_PACKSIZE"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_REQUIRED, GetValue("RTE_ORDR_ITEM_REQUIRED"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_UOM, GetValue("RTE_ORDR_ITEM_UOM"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_QTY, GetValue("RTE_ORDR_ITEM_QTY"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_ORDR_ITEM_VALUE, GetValue("RTE_ORDR_ITEM_VALUE"));
		}

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         objBuffer.Append("<RTE_ORDR_ITEM>");
         objBuffer.Append("<RTE_ORDR_ITEM_ID><![CDATA[" + GetValue("RTE_ORDR_ITEM_ID") + "]]></RTE_ORDR_ITEM_ID>");
         objBuffer.Append("<RTE_ORDR_ITEM_UOM><![CDATA[" + GetValue("RTE_ORDR_ITEM_UOM") + "]]></RTE_ORDR_ITEM_UOM>");
         objBuffer.Append("<RTE_ORDR_ITEM_QTY><![CDATA[" + GetValue("RTE_ORDR_ITEM_QTY") + "]]></RTE_ORDR_ITEM_QTY>");
         objBuffer.Append("<RTE_ORDR_ITEM_VALUE><![CDATA[" + GetValue("RTE_ORDR_ITEM_VALUE") + "]]></RTE_ORDR_ITEM_VALUE>");
         objBuffer.Append("</RTE_ORDR_ITEM>");
      }

	}

}