/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMailbox
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.util.Vector;

/**
 * This class defines a mailbox that can be used for messaging
 */
public final class cMailbox {

   //
   // Class static variables
   //
   private static final String BUFFER_OPEN = "<EFEX>";
   private static final String BUFFER_CLOSE = "</EFEX>";
   
   //
   // Request constants
   //
   public static final char EFEX_RQS_USERNAME = 101;
   public static final char EFEX_RQS_PASSWORD = 102;
   public static final char EFEX_RQS_CUSTOMER_ID = 103;
   public static final char EFEX_RQS_MESSAGE = 199;

   //
   // Mobile constants
   //
   public static final char EFEX_MOB = 501;
   public static final char EFEX_MOB_USERNAME = 502;
   public static final char EFEX_MOB_LANGUAGE = 503;
   public static final char EFEX_MOB_SERVERURL = 504;
   public static final char EFEX_MOB_SECURE = 505;
   
   //
   // Control constants
   //
   public static final char EFEX_CTL_STR = 1000;
   //
   public static final char EFEX_CTL = 1001;
   public static final char EFEX_CTL_USER_FIRSTNAME = 1002;
   public static final char EFEX_CTL_USER_LASTNAME = 1003;
   public static final char EFEX_CTL_MOBILE_DATE = 1004;
   public static final char EFEX_CTL_MOBILE_STATUS = 1005;
   public static final char EFEX_CTL_MOBILE_LOADED_TIME = 1006;
   public static final char EFEX_CTL_MOBILE_SAVED_TIME = 1007;
   //
   public static final char EFEX_CTL_END = (char)(1999);

   //
   // Route constants
   //
   public static final char EFEX_RTE_STR = 2000;
   //
   public static final char EFEX_RTE_CALL = 2001;
   public static final char EFEX_RTE_CALL_SEQUENCE = 2002;
   public static final char EFEX_RTE_CALL_CUSTOMER_ID = 2003;
   public static final char EFEX_RTE_CALL_CUSTOMER_CODE = 2013;
   public static final char EFEX_RTE_CALL_CUSTOMER_NAME = 2004;
   public static final char EFEX_RTE_CALL_CUSTOMER_TYPE = 2005;
   public static final char EFEX_RTE_CALL_MARKET = 2006;
   public static final char EFEX_RTE_CALL_STATUS = 2007;
   public static final char EFEX_RTE_CALL_DATE = 2008;
   public static final char EFEX_RTE_CALL_STR_TIME = 2009;
   public static final char EFEX_RTE_CALL_END_TIME = 2010;
   public static final char EFEX_RTE_CALL_ORDER_SEND = 2011;
   public static final char EFEX_RTE_CALL_STOCK_DIST_COUNT = 2012;
   //
   public static final char EFEX_RTE_STCK_ITEM = 2101;
   public static final char EFEX_RTE_STCK_ITEM_ID = 2102;
   public static final char EFEX_RTE_STCK_ITEM_NAME = 2103;
   public static final char EFEX_RTE_STCK_ITEM_REQUIRED = 2104;
   public static final char EFEX_RTE_STCK_ITEM_QTY = 2105;
   //
   public static final char EFEX_RTE_ORDR_ITEM = 2201;
   public static final char EFEX_RTE_ORDR_ITEM_ID = 2202;
   public static final char EFEX_RTE_ORDR_ITEM_NAME = 2203;
   public static final char EFEX_RTE_ORDR_ITEM_PRICE_TDU = 2204;
   public static final char EFEX_RTE_ORDR_ITEM_PRICE_MCU = 2205;
   public static final char EFEX_RTE_ORDR_ITEM_PRICE_RSU = 2206;
   public static final char EFEX_RTE_ORDR_ITEM_BRAND = 2207;
   public static final char EFEX_RTE_ORDR_ITEM_PACKSIZE = 2208;
   public static final char EFEX_RTE_ORDR_ITEM_REQUIRED = 2209;
   public static final char EFEX_RTE_ORDR_ITEM_UOM = 2210;
   public static final char EFEX_RTE_ORDR_ITEM_QTY = 2211;
   public static final char EFEX_RTE_ORDR_ITEM_VALUE = 2212;
   //
   public static final char EFEX_RTE_DISP_ITEM = 2301;
   public static final char EFEX_RTE_DISP_ITEM_ID = 2302;
   public static final char EFEX_RTE_DISP_ITEM_NAME = 2303;
   public static final char EFEX_RTE_DISP_ITEM_FLAG = 2304;
   //
   public static final char EFEX_RTE_ACTV_ITEM = 2401;
   public static final char EFEX_RTE_ACTV_ITEM_ID = 2402;
   public static final char EFEX_RTE_ACTV_ITEM_NAME = 2403;
   public static final char EFEX_RTE_ACTV_ITEM_FLAG = 2404;
   //
   public static final char EFEX_RTE_END = 2999;

   //
   // Customer constants
   //
   public static final char EFEX_CUS_STR = 3000;
   //
   public static final char EFEX_CUS = 3001;
   public static final char EFEX_CUS_DATA_TYPE = 3002;
   public static final char EFEX_CUS_DATA_ACTION = 3003;
   public static final char EFEX_CUS_CUSTOMER_ID = 3004;
   public static final char EFEX_CUS_CODE = 3016;
   public static final char EFEX_CUS_NAME = 3005;
   public static final char EFEX_CUS_STATUS = 3006;
   public static final char EFEX_CUS_ADDRESS = 3007;
   public static final char EFEX_CUS_CONTACT_NAME = 3008;
   public static final char EFEX_CUS_PHONE_NUMBER = 3009;
   public static final char EFEX_CUS_CUS_TYPE_ID = 3010;
   public static final char EFEX_CUS_OUTLET_LOCATION = 3011;
   public static final char EFEX_CUS_DISTRIBUTOR_ID = 3012;
   public static final char EFEX_CUS_POSTCODE = 3013;
   public static final char EFEX_CUS_FAX_NUMBER = 3014;
   public static final char EFEX_CUS_EMAIL_ADDRESS = 3015;
   //
   public static final char EFEX_CUS_END = 3999;

   //
   // Message constants
   //
   public static final char EFEX_MSG_STR = 4000;
   //
   public static final char EFEX_MSG = 4001;
   public static final char EFEX_MSG_ID = 4002;
   public static final char EFEX_MSG_OWNER = 4003;
   public static final char EFEX_MSG_TITLE = 4004;
   public static final char EFEX_MSG_TEXT = 4005;
   public static final char EFEX_MSG_STATUS = 4006;
   //
   public static final char EFEX_MSG_END = 4999;

   //
   // Reference product UOM constants
   //
   public static final char EFEX_UOM_STR = 5000;
   public static final char EFEX_UOM = 5001;
   public static final char EFEX_UOM_NAME = 5002;
   public static final char EFEX_UOM_TEXT = 5003;
   public static final char EFEX_UOM_END = 5999;

   //
   // Reference customer location constants
   //
   public static final char EFEX_CUS_LOCN_STR = 5100;
   public static final char EFEX_CUS_LOCN = 5101;
   public static final char EFEX_CUS_LOCN_NAME = 5102;
   public static final char EFEX_CUS_LOCN_TEXT = 5103;
   public static final char EFEX_CUS_LOCN_END = 5199;

   //
   // Reference customer type constants
   //
   public static final char EFEX_CUS_TYPE_STR = 5200;
   public static final char EFEX_CUS_TYPE = 5201;
   public static final char EFEX_CUS_TYPE_ID = 5202;
   public static final char EFEX_CUS_TYPE_NAME = 5203;
   public static final char EFEX_CUS_TYPE_CHANNEL_ID = 5204;
   public static final char EFEX_CUS_TYPE_END = 5299;

   //
   // Reference customer trade channel constants
   //
   public static final char EFEX_CUS_TRADE_CHANNEL_STR = 5300;
   public static final char EFEX_CUS_TRADE_CHANNEL = 5301;
   public static final char EFEX_CUS_TRADE_CHANNEL_ID = 5302;
   public static final char EFEX_CUS_TRADE_CHANNEL_NAME = 5303;
   public static final char EFEX_CUS_TRADE_CHANNEL_END = 5399;

   //
   // Reference distributor constants
   //
   public static final char EFEX_DIS_STR = 5400;
   public static final char EFEX_DIS = 5401;
   public static final char EFEX_DIS_ID = 5402;
   public static final char EFEX_DIS_NAME = 5403;
   public static final char EFEX_DIS_END = 5499;
   
   //
   // Class declarations
   //
   private Vector cobjMessages;

   /**
    * Constructs a new instance
    */
   public cMailbox() {
      cobjMessages = new Vector();
   }

   /**
    * Adds a new element to the collection
    * 
    * @param chrType the message type
    * @param strMessage the message data
    */
   public void addMessage(char chrType, String strData) {
      cMessage objMessage = new cMessage(chrType, strData);
      cobjMessages.addElement(objMessage);
   }
   
   /**
    * Adds bulk elements to the collection
    * 
    * @param objBuffer the mailbox string buffer
    * @exception Exception the fatal message
    */
   public void addBulkMessages(String objBuffer) throws Exception {
      char chrMessageCode = 0;
      short shrMessageLength = 0;
      String strMessageData = null;
      int i = 0;
      while (i < (objBuffer.length())) {
         chrMessageCode = objBuffer.charAt(i);
         i++;
         shrMessageLength = (short)objBuffer.charAt(i);
         i++;
         if (shrMessageLength <= 0) {
            strMessageData = "";
         } else {
            strMessageData = objBuffer.substring(i, (i + shrMessageLength));
            i = i + shrMessageLength;
         }
         this.addMessage(chrMessageCode, strMessageData);
      }
   }
   
   /**
    * Gets an existing element from the collection
    * 
    * @return cMessage the requested message reference
    * @param intIndex the index of the requested message
    * @exception Exception
    */
   public cMessage getMessage(int intIndex) throws Exception {
      return (cMessage)cobjMessages.elementAt(intIndex);
   }

   /**
    * Gets the count of the mailbox
    * 
    * @return int the mailbox message count
    */
   public int getMessageCount() {
      return cobjMessages.size();
   }
   
   /**
    * Puts the mailbox string buffer
    * 
    * @param objBuffer the mailbox string buffer
    * @exception Exception the fatal message
    */
   public void putBuffer(String objBuffer) throws Exception {
      if (objBuffer.length() < (BUFFER_OPEN.length() + BUFFER_CLOSE.length())) {
         throw new Exception("(Efex Mobile) Message buffer is incompatable with the application");
      }
      if (!objBuffer.substring(0, BUFFER_OPEN.length()).equals(BUFFER_OPEN)) {
         throw new Exception("(Efex Mobile) Message buffer open tag is incompatable with the application");
      }
      if (!objBuffer.substring(objBuffer.length() - BUFFER_CLOSE.length(), objBuffer.length()).equals(BUFFER_CLOSE)) {
         throw new Exception("(Efex Mobile) Message buffer close tag is incompatable with the application");
      }
      char chrMessageCode = 0;
      short shrMessageLength = 0;
      String strMessageData = null;
      int i = BUFFER_OPEN.length();
      while (i < (objBuffer.length() - BUFFER_CLOSE.length())) {
         chrMessageCode = objBuffer.charAt(i);
         i++;
         shrMessageLength = (short)objBuffer.charAt(i);
         i++;
         if (shrMessageLength <= 0) {
            strMessageData = "";
         } else {
            strMessageData = objBuffer.substring(i, (i + shrMessageLength));
            i = i + shrMessageLength;
         }
         this.addMessage(chrMessageCode, strMessageData);
      }
   }
   
   /**
    * Gets the mailbox string buffer
    * 
    * @return StringBuffer the mailbox string buffer
    * @exception Exception the fatal message
    */
   public StringBuffer getBuffer() throws Exception {
      cMessage objMessage;
      StringBuffer objBuffer = new StringBuffer(BUFFER_OPEN);
      for (int i=0;i<cobjMessages.size();i++) {
         objMessage = this.getMessage(i);
         objBuffer.append(objMessage.getMessageData());
      }
      objBuffer.append(BUFFER_CLOSE);
      return objBuffer;
   }
   
}