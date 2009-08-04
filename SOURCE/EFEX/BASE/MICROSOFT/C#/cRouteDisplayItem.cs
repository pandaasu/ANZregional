/// <summary>
/// Type   : Class
/// Name   : cRouteDisplayItem
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
	
	/// <summary>
	/// This class implements the mobile route display item
	/// </summary>
   public class cRouteDisplayItem : cDataStore {

      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_RTE_DISP_ITEM, null);
         objMailbox.AddMessage(cMailbox.EFEX_RTE_DISP_ITEM_ID, GetValue("RTE_DISP_ITEM_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_DISP_ITEM_NAME, GetValue("RTE_DISP_ITEM_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_RTE_DISP_ITEM_FLAG, GetValue("RTE_DISP_ITEM_FLAG"));
		}

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(System.Text.StringBuilder objBuffer) {
         objBuffer.Append("<RTE_DISP_ITEM>");
         objBuffer.Append("<RTE_DISP_ITEM_ID><![CDATA[" + GetValue("RTE_DISP_ITEM_ID") + "]]></RTE_DISP_ITEM_ID>");
         objBuffer.Append("<RTE_DISP_ITEM_FLAG><![CDATA[" + GetValue("RTE_DISP_ITEM_FLAG") + "]]></RTE_DISP_ITEM_FLAG>");
         objBuffer.Append("</RTE_DISP_ITEM>");
      }

	}

}