/**
 * Package : MIS eFEX
 * Type    : Class
 * Name    : cConnection
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;
import java.io.*;
import javax.microedition.io.*;
import javax.microedition.pki.*;

/**
 * This class implements the eFEX secure connection layer.
 */
public final class cConnection {
   
   //
   // Private class declarations
   //
   private cResourceBundle cobjResourceBundle;
   
   /**
    * Constructs a new instance
    */
   public cConnection(cResourceBundle objResourceBundle)  {
      cobjResourceBundle = objResourceBundle;
   }
   
   /**
    * Posts the request to the secure web site and returns the response
    *
    * @param strSecure the connection type
    * @param strUrl the request URL
    * @param strRequestStream the request string
    * @return String the response string
    * @throws Exception the exception message
    */
   public String postDataStream(String strSecure, String strUrl, String strRequestStream) throws Exception {
      
      //
      // Local variable declarations
      //
      String strResponseStream = null; 
      
      //
      // Process the request based on the URL
      //
      if (strSecure.toUpperCase().equals("*YES")) {
         strResponseStream = httpsStream(strUrl, strRequestStream);
      } else {
         strResponseStream = httpStream(strUrl, strRequestStream);
      }

      //
      // Return the response stream
      //
      return strResponseStream;
      
   }
   
   /**
    * Processes the HTTPS stream
    *
    * @param strUrl the request URL
    * @param strRequestStream the request string
    * @return String the response string
    * @throws Exception the exception message
    */
   private String httpsStream(String strUrl, String strRequestStream) throws Exception {
      
      //
      // Local variable declarations
      //
      HttpsConnection objHttpConnection = null;
      OutputStream objOutputStream = null;
      InputStream objInputStream = null;
      String strResponseStream = null;
      
      //
      // Posts the request to the secure web site
      //
      try {
         objHttpConnection = (HttpsConnection)Connector.open("https://" + strUrl, Connector.READ_WRITE, false);
         objHttpConnection.setRequestProperty("Content-Length"," " + strRequestStream.length());
         objHttpConnection.setRequestMethod(HttpConnection.POST);
         objOutputStream = objHttpConnection.openOutputStream();
         objOutputStream.write(strRequestStream.getBytes("UTF-8"));
         objOutputStream.flush();
         if (objHttpConnection.getResponseCode() == HttpConnection.HTTP_OK) {
            int intDataLength = (int)objHttpConnection.getLength();
            objInputStream = objHttpConnection.openInputStream();
            if (intDataLength == -1) {
               byte[] bytData = new byte[1500];
               int intRead = 0;
               ByteArrayOutputStream baos = new ByteArrayOutputStream();
               while ((intRead = objInputStream.read(bytData)) != -1) {
                  baos.write(bytData, 0, intRead);
               }
               strResponseStream = new String(baos.toByteArray(), "UTF-8");
            } else {
               DataInputStream objDataInputStream = new DataInputStream(objInputStream);
               byte[] bytData = new byte[intDataLength];
               objDataInputStream.readFully(bytData);
               strResponseStream = new String(bytData, "UTF-8");
            }
         } else {
            throw new Exception("(eFEX) Invalid HTTPS Response Code - " + objHttpConnection.getResponseCode());
         }
      } catch (java.io.IOException objException) {
         throw new Exception(cobjResourceBundle.getResource("CONCONNECTERROR"));
      } catch (Exception objException) {
         throw new Exception("(" + objException.getClass().getName() + ") " + objException.getMessage());
      } finally {
         if (objOutputStream != null) {
            try {
               objOutputStream.close();
               objOutputStream = null;
            } catch (Throwable objThrowable) {}
         }
         if (objInputStream != null) {
            try {
               objInputStream.close();
               objInputStream = null;
            } catch (Throwable objThrowable) {}
         }
         if (objHttpConnection != null) {
            try {
               objHttpConnection.close();
               objHttpConnection = null;
            } catch (Throwable objThrowable) {}
         }
      }
      
      //
      // Return the response stream
      //
      return strResponseStream;
      
   }
   
   /**
    * Processes the HTTP stream
    *
    * @param strUrl the request URL
    * @param strRequestStream the request string
    * @return String the response string
    * @throws Exception the exception message
    */
   private String httpStream(String strUrl, String strRequestStream) throws Exception {
      
      //
      // Local variable declarations
      //
      HttpConnection objHttpConnection = null;
      OutputStream objOutputStream = null;
      InputStream objInputStream = null;
      String strResponseStream = null;
      
      //
      // Posts the request to the secure web site
      //
      try {
         objHttpConnection = (HttpConnection)Connector.open("http://" + strUrl, Connector.READ_WRITE, false);
         objHttpConnection.setRequestProperty("Content-Length"," " + strRequestStream.length());
         objHttpConnection.setRequestMethod(HttpConnection.POST);
         objOutputStream = objHttpConnection.openOutputStream();
         objOutputStream.write(strRequestStream.getBytes("UTF-8"));
         objOutputStream.flush();     
         if (objHttpConnection.getResponseCode() == HttpConnection.HTTP_OK) {
            int intDataLength = (int)objHttpConnection.getLength();
            objInputStream = objHttpConnection.openInputStream();
            if (intDataLength == -1) {
               byte[] bytData = new byte[1500];
               int intRead = 0;
               ByteArrayOutputStream baos = new ByteArrayOutputStream();
               while ((intRead = objInputStream.read(bytData)) != -1) {
                  baos.write(bytData, 0, intRead);
               }
               strResponseStream = new String(baos.toByteArray(), "UTF-8");
            } else {
               DataInputStream objDataInputStream = new DataInputStream(objInputStream);
               byte[] bytData = new byte[intDataLength];
               objDataInputStream.readFully(bytData);
               strResponseStream = new String(bytData, "UTF-8");
            }
         } else {
            throw new Exception("(eFEX) Invalid HTTP Response Code - " + objHttpConnection.getResponseCode());
         }
      } catch (java.io.IOException objException) {
         throw new Exception(cobjResourceBundle.getResource("CONCONNECTERROR"));
      } catch (Exception objException) {
         throw new Exception("(" + objException.getClass().getName() + ") " + objException.getMessage());
      } finally {
         if (objOutputStream != null) {
            try {
               objOutputStream.close();
               objOutputStream = null;
            } catch (Throwable objThrowable) {}
         }
         if (objInputStream != null) {
            try {
               objInputStream.close();
               objInputStream = null;
            } catch (Throwable objThrowable) {}
         }
         if (objHttpConnection != null) {
            try {
               objHttpConnection.close();
               objHttpConnection = null;
            } catch (Throwable objThrowable) {}
         }
      }
      
      //
      // Return the response stream
      //
      return strResponseStream;
      
   }
   
}
