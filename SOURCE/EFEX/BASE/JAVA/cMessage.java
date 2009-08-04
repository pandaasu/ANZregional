/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cMessage
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class defines a message
 */
public class cMessage {

   //
   // Class declarations
   //
   private char cchrCode;
   private String cobjData;
   
   /**
    * Constructs a new instance
    */
   public cMessage(char chrCode, String objData) {
      cchrCode = chrCode;
      cobjData = objData;
      if (cobjData == null) {
         cobjData = "";
      }
   }
   
   /**
    * Gets the mailbox message code
    * 
    * @return char the mailbox message code
    */
   public char getCode() {
      return cchrCode;
   }
   
   /**
    * Gets the mailbox message length
    * 
    * @return short the mailbox message length
    */
   public short getLength() {
      return (short)cobjData.length();
   }
   
   /**
    * Gets the mailbox message data
    * 
    * @return String the mailbox message data
    */
   public String getData() {
      return cobjData;
   }
   
   /**
    * Gets the mailbox message - code, length and data
    * 
    * @return String the mailbox message data
    */
   public String getMessageData() {
      return new String(String.valueOf(cchrCode) + String.valueOf((char)(short)cobjData.length()) + cobjData);
   }

}