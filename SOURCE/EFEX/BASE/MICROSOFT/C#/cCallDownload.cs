/// <summary> 
/// Type   : Class
/// Name   : cCallDownload
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
   /// This class implements the mobile download HTTP handler to intercept
   /// the request and response information from the mobile client.
   /// The following configuration entries must be included
   /// in the Web.config file.
   ///  <configuration>
   ///    <system.web>
   ///       <httpHandlers>
   ///          <add verb="*" path="CallDownload.ashx" type="EfexServer.cCallDownload,MarsEfexServer"/>
   ///       </httpHandlers>
   ///    </system.web>
   /// </configuration>
	/// </summary>
   public class cCallDownload : IHttpHandler {
   
      //
      // Class data declarations
      //
      private cRouteStore cobjRouteStore;

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
         cobjRouteStore = new cRouteStore();

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
            string strCustomerId = null;
            cMessage objMessage = null;
            for (int i=0; i<objInbox.GetMessageCount(); i++) {
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
                  case cMailbox.EFEX_RQS_CUSTOMER_ID: {
                     strCustomerId = objMessage.GetData();
                     break;
                  }
                  default: {
                     break;
                  }
               }
            }

            //
            // Retrieve and load the response model
            //
            loadResponseModel(objDatabase.ProcessDownloadRequest(strUserName, strPassword, HttpContext.Current.Server.MapPath("/private/connection.txt"), "mobile_data.get_customer_call('" + strCustomerId + "')"));

            //
            // Return the response stream from the data model
            //
            objHttpContext.Response.Write(GetBinary());

         } catch (ApplicationException objException) {
            objHttpContext.Response.Write(cMailbox.BUFFER_OPEN + new string((cMailbox.EFEX_RQS_MESSAGE.ToString() + ((char)objException.Message.Length).ToString() + objException.Message).ToCharArray()) + cMailbox.BUFFER_CLOSE);
         } catch (Exception objException) {
            objHttpContext.Response.Write(cMailbox.BUFFER_OPEN + new string((cMailbox.EFEX_RQS_MESSAGE.ToString() + ((char)(objException.Message + "\n\n(Trace)\n " + objException.StackTrace).Length).ToString() + objException.Message + "\n\n(Trace)\n " + objException.StackTrace).ToCharArray()) + cMailbox.BUFFER_CLOSE);
         } finally {
            objInbox = null;
            objDatabase = null;
            cobjRouteStore = null;
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
      /// Loads the response data model from the host application
      /// </summary>
      /// <param name="strResponseStream">the host response stream</param>
      private void loadResponseModel(string strResponseStream) {
         string strElementName = null;
         cDataStore objDataStore = null;
         cRouteCall objRouteCall = null;
         cRouteStockItem objRouteStockItem = null;
         cRouteDisplayItem objRouteDisplayItem = null;
         cRouteActivityItem objRouteActivityItem = null;
         cRouteOrderItem objRouteOrderItem = null;
         XmlTextReader objXmlReader = null;
         try {
            objXmlReader = new XmlTextReader(strResponseStream, XmlNodeType.Document, null);
            while (objXmlReader.Read()) {
               if (objXmlReader.NodeType == XmlNodeType.Element) {
                  strElementName = objXmlReader.Name.ToUpper();
                  if (strElementName.Equals("RTE_CALL")) {
                     objRouteCall = new cRouteCall();
                     cobjRouteStore.AddCall(objRouteCall);
                     objDataStore = (cDataStore)objRouteCall;
                  } else if (strElementName.Equals("RTE_STCK_ITEM")) {
                     objRouteStockItem = new cRouteStockItem();
                     objRouteCall.AddStockItem(objRouteStockItem);
                     objDataStore = (cDataStore)objRouteStockItem;
                  } else if (strElementName.Equals("RTE_DISP_ITEM")) {
                     objRouteDisplayItem = new cRouteDisplayItem();
                     objRouteCall.AddDisplayItem(objRouteDisplayItem);
                     objDataStore = (cDataStore)objRouteDisplayItem;
                  } else if (strElementName.Equals("RTE_ACTV_ITEM")) {
                     objRouteActivityItem = new cRouteActivityItem();
                     objRouteCall.AddActivityItem(objRouteActivityItem);
                     objDataStore = (cDataStore)objRouteActivityItem;
                  } else if (strElementName.Equals("RTE_ORDR_ITEM")) {
                     objRouteOrderItem = new cRouteOrderItem();
                     objRouteCall.AddOrderItem(objRouteOrderItem);
                     objDataStore = (cDataStore)objRouteOrderItem;
                  }
               } else if (objXmlReader.NodeType == XmlNodeType.CDATA) {
                  if (objDataStore != null && strElementName != null) {
                     objDataStore.SetValue(strElementName, objXmlReader.Value);
                  }
               }
            }
         } finally {
            if (objXmlReader != null) {
               objXmlReader.Close();
            }
            objXmlReader = null;
            objDataStore = null;
            objRouteCall = null;
            objRouteStockItem = null;
            objRouteDisplayItem = null;
            objRouteActivityItem = null;
            objRouteOrderItem = null;
            strElementName = null;
         }
      }

      /// <summary>
      /// Gets the binary response string for the data model.
      /// 1. Deconstruct the object model into response messages
      /// 2. Return the response string from the response messages
      /// </summary>
      /// <return>the response string</return>
      private string GetBinary() {
         cMailbox objOutbox = new cMailbox();
         try {
            cobjRouteStore.GetBinary(objOutbox);
            return objOutbox.GetResponse();
         } catch (Exception objException) {
            throw objException;
         } finally {
            objOutbox = null;
         }
      }

   }

}