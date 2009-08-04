/// <summary>
/// Type   : Class
/// Name   : cMailbox
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {
	
   using System;
   using System.Text;
   using System.Collections;
	
	/// <summary>
	/// This class defines a mailbox used for messaging
	/// </summary>
	public class cMailbox {
		
		//
      // Class constants
		//
      internal const string BUFFER_OPEN = "<EFEX>";
      internal const string BUFFER_CLOSE = "</EFEX>";

      //
      // Request constants
      //
      internal const char EFEX_RQS_USERNAME = (char)(101);
      internal const char EFEX_RQS_PASSWORD = (char)(102);
      internal const char EFEX_RQS_CUSTOMER_ID = (char)(103);
      internal const char EFEX_RQS_MESSAGE = (char)(199);

      //
      // Control constants
      //
      internal const char EFEX_CTL_STR = (char)(1000);
      //
      internal const char EFEX_CTL = (char)(1001);
      internal const char EFEX_CTL_USER_FIRSTNAME = (char)(1002);
      internal const char EFEX_CTL_USER_LASTNAME = (char)(1003);
      internal const char EFEX_CTL_MOBILE_DATE = (char)(1004);
      internal const char EFEX_CTL_MOBILE_STATUS = (char)(1005);
      internal const char EFEX_CTL_MOBILE_LOADED_TIME = (char)(1006);
      internal const char EFEX_CTL_MOBILE_SAVED_TIME = (char)(1007);
      //
      internal const char EFEX_CTL_END = (char)(1999);

      //
      // Route constants
      //
      internal const char EFEX_RTE_STR = (char)(2000);
      //
      internal const char EFEX_RTE_CALL = (char)(2001);
      internal const char EFEX_RTE_CALL_SEQUENCE = (char)(2002);
      internal const char EFEX_RTE_CALL_CUSTOMER_ID = (char)(2003);
      internal const char EFEX_RTE_CALL_CUSTOMER_CODE = (char)(2013);
      internal const char EFEX_RTE_CALL_CUSTOMER_NAME = (char)(2004);
      internal const char EFEX_RTE_CALL_CUSTOMER_TYPE = (char)(2005);
      internal const char EFEX_RTE_CALL_MARKET = (char)(2006);
      internal const char EFEX_RTE_CALL_STATUS = (char)(2007);
      internal const char EFEX_RTE_CALL_DATE = (char)(2008);
      internal const char EFEX_RTE_CALL_STR_TIME = (char)(2009);
      internal const char EFEX_RTE_CALL_END_TIME = (char)(2010);
      internal const char EFEX_RTE_CALL_ORDER_SEND = (char)(2011);
      internal const char EFEX_RTE_CALL_STOCK_DIST_COUNT = (char)(2012);
      //
      internal const char EFEX_RTE_STCK_ITEM = (char)(2101);
      internal const char EFEX_RTE_STCK_ITEM_ID = (char)(2102);
      internal const char EFEX_RTE_STCK_ITEM_NAME = (char)(2103);
      internal const char EFEX_RTE_STCK_ITEM_REQUIRED = (char)(2104);
      internal const char EFEX_RTE_STCK_ITEM_QTY = (char)(2105);
      //
      internal const char EFEX_RTE_ORDR_ITEM = (char)(2201);
      internal const char EFEX_RTE_ORDR_ITEM_ID = (char)(2202);
      internal const char EFEX_RTE_ORDR_ITEM_NAME = (char)(2203);
      internal const char EFEX_RTE_ORDR_ITEM_PRICE_TDU = (char)(2204);
      internal const char EFEX_RTE_ORDR_ITEM_PRICE_MCU = (char)(2205);
      internal const char EFEX_RTE_ORDR_ITEM_PRICE_RSU = (char)(2206);
      internal const char EFEX_RTE_ORDR_ITEM_BRAND = (char)(2207);
      internal const char EFEX_RTE_ORDR_ITEM_PACKSIZE = (char)(2208);
      internal const char EFEX_RTE_ORDR_ITEM_REQUIRED = (char)(2209);
      internal const char EFEX_RTE_ORDR_ITEM_UOM = (char)(2210);
      internal const char EFEX_RTE_ORDR_ITEM_QTY = (char)(2211);
      internal const char EFEX_RTE_ORDR_ITEM_VALUE = (char)(2212);
      //
      internal const char EFEX_RTE_DISP_ITEM = (char)(2301);
      internal const char EFEX_RTE_DISP_ITEM_ID = (char)(2302);
      internal const char EFEX_RTE_DISP_ITEM_NAME = (char)(2303);
      internal const char EFEX_RTE_DISP_ITEM_FLAG = (char)(2304);
      //
      internal const char EFEX_RTE_ACTV_ITEM = (char)(2401);
      internal const char EFEX_RTE_ACTV_ITEM_ID = (char)(2402);
      internal const char EFEX_RTE_ACTV_ITEM_NAME = (char)(2403);
      internal const char EFEX_RTE_ACTV_ITEM_FLAG = (char)(2404);
      //
      internal const char EFEX_RTE_END = (char)(2999);

      //
      // Customer constants
      //
      internal const char EFEX_CUS_STR = (char)(3000);
      //
      internal const char EFEX_CUS = (char)(3001);
      internal const char EFEX_CUS_DATA_TYPE = (char)(3002);
      internal const char EFEX_CUS_DATA_ACTION = (char)(3003);
      internal const char EFEX_CUS_CUSTOMER_ID = (char)(3004);
      internal const char EFEX_CUS_CODE = (char)(3016);
      internal const char EFEX_CUS_NAME = (char)(3005);
      internal const char EFEX_CUS_STATUS = (char)(3006);
      internal const char EFEX_CUS_ADDRESS = (char)(3007);
      internal const char EFEX_CUS_CONTACT_NAME = (char)(3008);
      internal const char EFEX_CUS_PHONE_NUMBER = (char)(3009);
      internal const char EFEX_CUS_CUS_TYPE_ID = (char)(3010);
      internal const char EFEX_CUS_OUTLET_LOCATION = (char)(3011);
      internal const char EFEX_CUS_DISTRIBUTOR_ID = (char)(3012);
      internal const char EFEX_CUS_POSTCODE = (char)(3013);
      internal const char EFEX_CUS_FAX_NUMBER = (char)(3014);
      internal const char EFEX_CUS_EMAIL_ADDRESS = (char)(3015);
      //
      internal const char EFEX_CUS_END = (char)(3999);

      //
      // Message constants
      //
      internal const char EFEX_MSG_STR = (char)(4000);
      //
      internal const char EFEX_MSG = (char)(4001);
      internal const char EFEX_MSG_ID = (char)(4002);
      internal const char EFEX_MSG_OWNER = (char)(4003);
      internal const char EFEX_MSG_TITLE = (char)(4004);
      internal const char EFEX_MSG_TEXT = (char)(4005);
      internal const char EFEX_MSG_STATUS = (char)(4006);
      //
      internal const char EFEX_MSG_END = (char)(4999);

      //
      // Reference product UOM constants
      //
      internal const char EFEX_UOM_STR = (char)(5000);
      internal const char EFEX_UOM = (char)(5001);
      internal const char EFEX_UOM_NAME = (char)(5002);
      internal const char EFEX_UOM_TEXT = (char)(5003);
      internal const char EFEX_UOM_END = (char)(5999);

      //
      // Reference customer location constants
      //
      internal const char EFEX_CUS_LOCN_STR = (char)(5100);
      internal const char EFEX_CUS_LOCN = (char)(5101);
      internal const char EFEX_CUS_LOCN_NAME = (char)(5102);
      internal const char EFEX_CUS_LOCN_TEXT = (char)(5103);
      internal const char EFEX_CUS_LOCN_END = (char)(5199);

      //
      // Reference customer type constants
      //
      internal const char EFEX_CUS_TYPE_STR = (char)(5200);
      internal const char EFEX_CUS_TYPE = (char)(5201);
      internal const char EFEX_CUS_TYPE_ID = (char)(5202);
      internal const char EFEX_CUS_TYPE_NAME = (char)(5203);
      internal const char EFEX_CUS_TYPE_CHANNEL_ID = (char)(5204);
      internal const char EFEX_CUS_TYPE_END = (char)(5299);

      //
      // Reference customer trade channel constants
      //
      internal const char EFEX_CUS_TRADE_CHANNEL_STR = (char)(5300);
      internal const char EFEX_CUS_TRADE_CHANNEL = (char)(5301);
      internal const char EFEX_CUS_TRADE_CHANNEL_ID = (char)(5302);
      internal const char EFEX_CUS_TRADE_CHANNEL_NAME = (char)(5303);
      internal const char EFEX_CUS_TRADE_CHANNEL_END = (char)(5399);

      //
      // Reference distributor constants
      //
      internal const char EFEX_DIS_STR = (char)(5400);
      internal const char EFEX_DIS = (char)(5401);
      internal const char EFEX_DIS_ID = (char)(5402);
      internal const char EFEX_DIS_NAME = (char)(5403);
      internal const char EFEX_DIS_END = (char)(5499);
		
		//
		// Class declarations
		//
		private ArrayList cobjMessages;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
		internal cMailbox() {
			cobjMessages = new ArrayList();
		}
		
		/// <summary>
		/// Adds a new element to the collection
		/// </summary>
		/// <param name="chrCode">the message code</param>
		/// <param name="strData">the message data</param>
		internal void AddMessage(char chrCode, string strData) {
			cMessage objMessage = new cMessage(chrCode, strData);
			cobjMessages.Add(objMessage);
		}
		
		/// <summary>
		/// Gets an existing element from the collection
		/// </summary>
		/// <returns>cMessage the requested message reference</returns>
		/// <param name="intIndex">the index of the requested message</param>
		internal cMessage GetMessage(int intIndex) {
			return (cMessage)cobjMessages[intIndex];
		}
		
		/// <summary>
		/// Gets the count of the mailbox
		/// </summary>
		/// <returns>int the mailbox message count</returns>
      internal int GetMessageCount() {
         return cobjMessages.Count;
      }

		/// <summary>
		/// Puts the mailbox request string
		/// </summary>
		/// <param name="strRequest">the mailbox request string</param>
		internal void PutRequest(string strRequest) {
			if (strRequest.Length < (BUFFER_OPEN.Length + BUFFER_CLOSE.Length)) {
				throw new Exception("(Efex Server): Message buffer is incompatable with the application");
			}
			if (!strRequest.Substring(0, BUFFER_OPEN.Length).Equals(BUFFER_OPEN)) {
				throw new Exception("(Efex Server): Message buffer open tag is incompatable with the application");
			}
			if (!strRequest.Substring(strRequest.Length - BUFFER_CLOSE.Length, BUFFER_CLOSE.Length).Equals(BUFFER_CLOSE)) {
				throw new Exception("(Efex Server): Message buffer close tag is incompatable with the application");
			}
			char chrMessageCode = (char)(0);
			short shrMessageLength = 0;
         string strMessageData = null;
			int i = BUFFER_OPEN.Length;
			while (i < (strRequest.Length - BUFFER_CLOSE.Length)) {
				chrMessageCode = (char)strRequest[i];
				i++;
				shrMessageLength = (short)strRequest[i];
				i++;
				if (shrMessageLength <= 0) {
               strMessageData = null;
				} else {
               strMessageData = strRequest.Substring(i, (int)shrMessageLength);
					i = i + shrMessageLength;
				}
            this.AddMessage(chrMessageCode, strMessageData);
			}
		}
		
		/// <summary>
		/// Gets the mailbox response string
		/// </summary>
		/// <returns>string the mailbox response string</returns>
		internal string GetResponse() {  
         StringBuilder objBuffer = new StringBuilder(BUFFER_OPEN);
         cMessage objMessage;
         for (int i=0; i<cobjMessages.Count; i++) {
            objMessage = (cMessage)cobjMessages[i];
            objBuffer.Append(objMessage.GetMessageData());
         }
         objMessage = null;
         objBuffer.Append(BUFFER_CLOSE);
         return objBuffer.ToString();
      }

	}

}