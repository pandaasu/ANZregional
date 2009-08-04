/// <summary>
/// Type   : Class
/// Name   : cCustomerData
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

	using System;
   using System.Text;
   using System.Collections;
	
	/// <summary>
	/// This class implements the mobile customer data
	/// </summary>
	public class cCustomerData : cDataStore {
		
      /// <summary>
      /// Deconstructs the object into messages
      /// </summary>
      /// <param name="objMailbox">the mailbox reference</param>
		protected internal void GetBinary(cMailbox objMailbox) {
         objMailbox.AddMessage(cMailbox.EFEX_CUS, null);
         objMailbox.AddMessage(cMailbox.EFEX_CUS_DATA_TYPE, GetValue("CUS_DATA_TYPE"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_DATA_ACTION, GetValue("CUS_DATA_ACTION"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_CUSTOMER_ID, GetValue("CUS_CUSTOMER_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_CODE, GetValue("CUS_CODE"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_NAME, GetValue("CUS_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_STATUS, GetValue("CUS_STATUS"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_ADDRESS, GetValue("CUS_ADDRESS"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_CONTACT_NAME, GetValue("CUS_CONTACT_NAME"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_PHONE_NUMBER, GetValue("CUS_PHONE_NUMBER"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_CUS_TYPE_ID, GetValue("CUS_CUS_TYPE_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_OUTLET_LOCATION, GetValue("CUS_OUTLET_LOCATION"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_DISTRIBUTOR_ID, GetValue("CUS_DISTRIBUTOR_ID"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_POSTCODE, GetValue("CUS_POSTCODE"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_FAX_NUMBER, GetValue("CUS_FAX_NUMBER"));
         objMailbox.AddMessage(cMailbox.EFEX_CUS_EMAIL_ADDRESS, GetValue("CUS_EMAIL_ADDRESS"));
		}

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <param name="objBuffer">the XML buffer</param>
      protected internal void GetXML(StringBuilder objBuffer) {
         if (GetValue("CUS_DATA_ACTION").Equals("*EDITED")) {
            objBuffer.Append("<CUS>");
            objBuffer.Append("<CUS_DATA_TYPE><![CDATA[" + GetValue("CUS_DATA_TYPE") + "]]></CUS_DATA_TYPE>");
            objBuffer.Append("<CUS_CUSTOMER_ID><![CDATA[" + GetValue("CUS_CUSTOMER_ID") + "]]></CUS_CUSTOMER_ID>");
            objBuffer.Append("<CUS_CODE><![CDATA[" + GetValue("CUS_CODE") + "]]></CUS_CODE>");
            objBuffer.Append("<CUS_NAME><![CDATA[" + GetValue("CUS_NAME") + "]]></CUS_NAME>");
            objBuffer.Append("<CUS_STATUS><![CDATA[" + GetValue("CUS_STATUS") + "]]></CUS_STATUS>");
            objBuffer.Append("<CUS_ADDRESS><![CDATA[" + GetValue("CUS_ADDRESS") + "]]></CUS_ADDRESS>");
            objBuffer.Append("<CUS_CONTACT_NAME><![CDATA[" + GetValue("CUS_CONTACT_NAME") + "]]></CUS_CONTACT_NAME>");
            objBuffer.Append("<CUS_PHONE_NUMBER><![CDATA[" + GetValue("CUS_PHONE_NUMBER") + "]]></CUS_PHONE_NUMBER>");
            objBuffer.Append("<CUS_CUS_TYPE_ID><![CDATA[" + GetValue("CUS_CUS_TYPE_ID") + "]]></CUS_CUS_TYPE_ID>");
            objBuffer.Append("<CUS_OUTLET_LOCATION><![CDATA[" + GetValue("CUS_OUTLET_LOCATION") + "]]></CUS_OUTLET_LOCATION>");
            objBuffer.Append("<CUS_DISTRIBUTOR_ID><![CDATA[" + GetValue("CUS_DISTRIBUTOR_ID") + "]]></CUS_DISTRIBUTOR_ID>");
            objBuffer.Append("<CUS_POSTCODE><![CDATA[" + GetValue("CUS_POSTCODE") + "]]></CUS_POSTCODE>");
            objBuffer.Append("<CUS_FAX_NUMBER><![CDATA[" + GetValue("CUS_FAX_NUMBER") + "]]></CUS_FAX_NUMBER>");
            objBuffer.Append("<CUS_EMAIL_ADDRESS><![CDATA[" + GetValue("CUS_EMAIL_ADDRESS") + "]]></CUS_EMAIL_ADDRESS>");
            objBuffer.Append("</CUS>");
         }
      }

	}

}