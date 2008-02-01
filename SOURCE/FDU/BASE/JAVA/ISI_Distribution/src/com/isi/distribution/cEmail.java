/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cEmail
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.io.*;
import java.net.*;

/**
 * This class implements the email functionality.
 */
public class cEmail {
   
   /**
    * Sends the email.
    *
    * @param strServer the SMTP server
    * @param intPort the SMTP port
    * @param strFrom the email from address
    * @param strTo the email to address
    * @param strSubject the email subject
    * @param strBody the the email body
    * @throws Exception the exception message
    */
   public void send(String strServer, int intPort, String strFrom, String strTo, String strSubject, String strBody) throws Exception {
      
      //
      // Create a connecttion to the SMTP server
      //
      Socket objSocket = null;
      BufferedReader objInputStream = null;
      BufferedWriter objOutputStream = null;
      try {
         objSocket = new Socket(strServer, intPort);
         objInputStream = new BufferedReader(new InputStreamReader(objSocket.getInputStream()));
         objOutputStream = new BufferedWriter(new OutputStreamWriter(objSocket.getOutputStream()));
         if (objSocket != null && objOutputStream != null && objInputStream != null) {
            sendData(objOutputStream, objInputStream, null);
            sendData(objOutputStream, objInputStream, "HELO " + strServer);
            sendData(objOutputStream, objInputStream, "MAIL FROM: <" + strFrom + ">");
            sendData(objOutputStream, objInputStream, "RCPT TO: <" + strTo + ">");
            sendData(objOutputStream, objInputStream, "DATA");
            sendData(objOutputStream, "From: " + strFrom);
            sendData(objOutputStream, "To: " + strTo);
            sendData(objOutputStream, "Subject: " + strSubject);
            sendData(objOutputStream, "Content-Type: text/plain");
            sendData(objOutputStream, strBody);
            sendData(objOutputStream, objInputStream, "\r\n.");
            sendData(objOutputStream, objInputStream, "QUIT");
         }
      } catch(Exception objException) {
         throw new Exception("Email send failed - " + objException.getMessage());
      } finally {
         if (objSocket != null) {
            objSocket.close();
         }
      }
      
   }
      
   /**
    * Sends the email data.
    *
    * @param objOutputStream the socket output stream
    * @param objInputStream the socket input stream
    * @param strData the output data string
    * @throws Exception the exception message
    */
   private void sendData(BufferedWriter objOutputStream, BufferedReader objInputStream, String strData) throws Exception {
      
      //
      // Send the data when required
      //
      if (strData != null && !strData.equals("")) {
         objOutputStream.write(strData + "\r\n");
         objOutputStream.flush();
      }
      
      //
      // Receive the response
      //
      String strLine = objInputStream.readLine();

   }
   
   /**
    * Sends the email data.
    *
    * @param objOutputStream the socket output stream
    * @param strData the output data string
    * @throws Exception the exception message
    */
   private void sendData(BufferedWriter objOutputStream, String strData) throws Exception {
      
      //
      // Send the data when required
      //
      if (strData != null && !strData.equals("")) {
         objOutputStream.write(strData + "\r\n");
         objOutputStream.flush();
      }

   }

}