/// <summary> 
/// Type   : Class
/// Name   : cMobileUpload
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {

   using System;
   using System.Text;
   using System.IO;
   using System.Web;
   using System.Xml;
	
	/// <summary>
   /// This class implements the mobile upload HTTP handler to intercept
   /// the request and response information from the mobile client.
   /// The following configuration entries must be included
   /// in the Web.config file.
   ///  <configuration>
   ///    <system.web>
   ///       <httpHandlers>
   ///          <add verb="*" path="MobileUpload.ashx" type="EfexServer.cMobileUpload,MarsEfexServer"/>
   ///       </httpHandlers>
   ///    </system.web>
   /// </configuration>
	/// </summary>
   public class cMobileUpload : IHttpHandler {

      //
      // Class data declarations
      //
      private cControlStore cobjControlStore;
      private cRouteStore cobjRouteStore;
      private cCustomerStore cobjCustomerStore;

      /// <summary>
      /// Overrides the IHttpHandler interface ProcessRequest method
      /// 1. Create the request data model from the request input stream
      /// 2. Return the response data model to the response output stream
      /// </summary>
      /// <param name="objHttpContext">the http context reference from the web server</param>
      public void ProcessRequest(HttpContext objHttpContext) {

         //
         // Local declarations
         //
         cMailbox objInbox = new cMailbox();
         cDatabase objDatabase = new cDatabase();
         cobjControlStore = new cControlStore();
         cobjRouteStore = new cRouteStore();
         cobjCustomerStore = new cCustomerStore();

         //
         // Exception trap
         //
         try {

            //
            // Retrieve the request input stream and build the mailbox messages
            //
            StreamReader objStreamReader = new StreamReader(objHttpContext.Request.InputStream, Encoding.UTF8);
            objInbox.PutRequest(objStreamReader.ReadToEnd());
            objStreamReader.Close();
            objStreamReader = null;

            //
            // Retrieve the request messages
            //
            string strUserName = null;
            string strPassword = null;
            cRouteCall objRouteCall = null;
            cRouteStockItem objRouteStockItem = null;
            cRouteDisplayItem objRouteDisplayItem = null;
            cRouteActivityItem objRouteActivityItem = null;
            cRouteOrderItem objRouteOrderItem = null;
            cCustomerData objCustomerData = null;
            cMessage objMessage = null;
            for (int i = 0; i < objInbox.GetMessageCount(); i++) {
               objMessage = objInbox.GetMessage(i);
               switch (objMessage.GetCode()) {
                  case cMailbox.EFEX_RQS_USERNAME: {
                     strUserName = objMessage.GetData();
                     break;
                  }
                  case cMailbox.EFEX_RQS_PASSWORD: {
                     strPassword = objMessage.GetData();
                     break;
                  }
                  //
                  case cMailbox.EFEX_RTE_CALL: {
                     objRouteCall = new cRouteCall();
                     cobjRouteStore.AddCall(objRouteCall);
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_SEQUENCE: {
                     objRouteCall.SetValue("RTE_CALL_SEQUENCE", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_CUSTOMER_ID: {
                     objRouteCall.SetValue("RTE_CALL_CUSTOMER_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_STATUS: {
                     objRouteCall.SetValue("RTE_CALL_STATUS", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_DATE: {
                     objRouteCall.SetValue("RTE_CALL_DATE", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_STR_TIME: {
                     objRouteCall.SetValue("RTE_CALL_STR_TIME", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_END_TIME: {
                     objRouteCall.SetValue("RTE_CALL_END_TIME", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_ORDER_SEND: {
                     objRouteCall.SetValue("RTE_CALL_ORDER_SEND", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_CALL_STOCK_DIST_COUNT: {
                     objRouteCall.SetValue("RTE_CALL_STOCK_DIST_COUNT", objMessage.GetData());
                     break;
                  }
                  //
                  case cMailbox.EFEX_RTE_STCK_ITEM: {
                     objRouteStockItem = new cRouteStockItem();
                     objRouteCall.AddStockItem(objRouteStockItem);
                     break;
                  }
                  case cMailbox.EFEX_RTE_STCK_ITEM_ID: {
                     objRouteStockItem.SetValue("RTE_STCK_ITEM_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_STCK_ITEM_QTY: {
                     objRouteStockItem.SetValue("RTE_STCK_ITEM_QTY", objMessage.GetData());
                     break;
                  }
                  //
                  case cMailbox.EFEX_RTE_DISP_ITEM: {
                     objRouteDisplayItem = new cRouteDisplayItem();
                     objRouteCall.AddDisplayItem(objRouteDisplayItem);
                     break;
                  }
                  case cMailbox.EFEX_RTE_DISP_ITEM_ID: {
                     objRouteDisplayItem.SetValue("RTE_DISP_ITEM_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_DISP_ITEM_FLAG: {
                     objRouteDisplayItem.SetValue("RTE_DISP_ITEM_FLAG", objMessage.GetData());
                     break;
                  }
                  //
                  case cMailbox.EFEX_RTE_ACTV_ITEM: {
                     objRouteActivityItem = new cRouteActivityItem();
                     objRouteCall.AddActivityItem(objRouteActivityItem);
                     break;
                  }
                  case cMailbox.EFEX_RTE_ACTV_ITEM_ID: {
                     objRouteActivityItem.SetValue("RTE_ACTV_ITEM_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_ACTV_ITEM_FLAG: {
                     objRouteActivityItem.SetValue("RTE_ACTV_ITEM_FLAG", objMessage.GetData());
                     break;
                  }
                  //
                  case cMailbox.EFEX_RTE_ORDR_ITEM: {
                     objRouteOrderItem = new cRouteOrderItem();
                     objRouteCall.AddOrderItem(objRouteOrderItem);
                     break;
                  }
                  case cMailbox.EFEX_RTE_ORDR_ITEM_ID: {
                     objRouteOrderItem.SetValue("RTE_ORDR_ITEM_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_ORDR_ITEM_UOM: {
                     objRouteOrderItem.SetValue("RTE_ORDR_ITEM_UOM", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_ORDR_ITEM_QTY: {
                     objRouteOrderItem.SetValue("RTE_ORDR_ITEM_QTY", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_RTE_ORDR_ITEM_VALUE: {
                     objRouteOrderItem.SetValue("RTE_ORDR_ITEM_VALUE", objMessage.GetData());
                     break;
                  }
                  //
                  case cMailbox.EFEX_CUS: {
                     objCustomerData = new cCustomerData();
                     cobjCustomerStore.AddCustomer(objCustomerData);
                     break;
                  }
                  case cMailbox.EFEX_CUS_DATA_TYPE: {
                     objCustomerData.SetValue("CUS_DATA_TYPE", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_DATA_ACTION: {
                     objCustomerData.SetValue("CUS_DATA_ACTION", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_CUSTOMER_ID: {
                     objCustomerData.SetValue("CUS_CUSTOMER_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_CODE: {
                     objCustomerData.SetValue("CUS_CODE", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_NAME: {
                     objCustomerData.SetValue("CUS_NAME", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_STATUS: {
                     objCustomerData.SetValue("CUS_STATUS", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_ADDRESS: {
                     objCustomerData.SetValue("CUS_ADDRESS", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_CONTACT_NAME: {
                     objCustomerData.SetValue("CUS_CONTACT_NAME", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_PHONE_NUMBER: {
                     objCustomerData.SetValue("CUS_PHONE_NUMBER", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_CUS_TYPE_ID: {
                     objCustomerData.SetValue("CUS_CUS_TYPE_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_OUTLET_LOCATION: {
                     objCustomerData.SetValue("CUS_OUTLET_LOCATION", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_DISTRIBUTOR_ID: {
                     objCustomerData.SetValue("CUS_DISTRIBUTOR_ID", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_POSTCODE: {
                     objCustomerData.SetValue("CUS_POSTCODE", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_FAX_NUMBER: {
                     objCustomerData.SetValue("CUS_FAX_NUMBER", objMessage.GetData());
                     break;
                  }
                  case cMailbox.EFEX_CUS_EMAIL_ADDRESS: {
                     objCustomerData.SetValue("CUS_EMAIL_ADDRESS", objMessage.GetData());
                     break;
                  }
                  default: {
                     break;
                  }
               }
            }

            //
            // Process the upload request
            //
            objDatabase.ProcessUploadRequest(strUserName, strPassword, HttpContext.Current.Server.MapPath("/private/connection.txt"), "mobile_data.put_mobile_data", GetXML());

            //
            // Return the response stream success
            //
            objHttpContext.Response.Write(cMailbox.BUFFER_OPEN + cMailbox.BUFFER_CLOSE);

         } catch (ApplicationException objException) {
            objHttpContext.Response.Write(cMailbox.BUFFER_OPEN + new string((cMailbox.EFEX_RQS_MESSAGE.ToString() + ((char)objException.Message.Length).ToString() + objException.Message).ToCharArray()) + cMailbox.BUFFER_CLOSE);
         } catch (Exception objException) {
            objHttpContext.Response.Write(cMailbox.BUFFER_OPEN + new string((cMailbox.EFEX_RQS_MESSAGE.ToString() + ((char)(objException.Message + "\n\n(Trace)\n " + objException.StackTrace).Length).ToString() + objException.Message + "\n\n(Trace)\n " + objException.StackTrace).ToCharArray()) + cMailbox.BUFFER_CLOSE);
         } finally {
            objInbox = null;
            objDatabase = null;
            cobjControlStore = null;
            cobjRouteStore = null;
            cobjCustomerStore = null;
         }

      }

      /// <summary>
      /// Overrides the IHttpHandler interface IsReusable property
      /// </summary>
      /// <return>the reusable indicator</return>
      public bool IsReusable {
         get { return true; }
      }

      /// <summary>
      /// Retrieves the XML buffer
      /// </summary>
      /// <return>the XML string</return>
      private string GetXML() {
         StringBuilder objBuffer = new StringBuilder("<?xml version='1.0' encoding='UTF-8'?>");
         try {
            objBuffer.Append("<EFEX>");
            cobjCustomerStore.GetXML(objBuffer);
            cobjRouteStore.GetXML(objBuffer);
            objBuffer.Append("</EFEX>");
            return objBuffer.ToString();
         } catch (Exception objException) {
            throw objException;
         } finally {
            objBuffer = null;
         }
      }
		
   }

}