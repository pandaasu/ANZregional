/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : cSapConnection
 * Author  : Steve Gregan
 * Date    : May 2005
 */
package com.isi.sap;
import com.sap.mw.jco.*; 
import java.util.*;

/**
 * This class implements a SAP database connection.
 */
public final class cSapConnection {

   //
   // Class variables
   //
   private String cstrUserId = null;
   private String cstrPassword = null;
   private JCO.Client cobjClient = null;
   private JCO.Repository cobjRepository = null;
   private IFunctionTemplate cobjFunctionTemplate = null;
   
   /**
    * Class constructor
    * @param strSapClient the SAP connection client
    * @param strSapUserId the SAP connection user identifier
    * @param strSapPassword the SAP connection password
    * @param strSapLanguage the SAP connection language
    * @param strSapSystem the SAP connection system
    * @throws Exception message
    */
   public cSapConnection(String strSapClient,
                         String strUserId,
                         String strPassword,
                         String strLanguage,
                         String strServer,
                         String strSystem) throws Exception {
      
      //
      // Instance the SAP client and attempt the connection
      //
      cstrUserId = strUserId;
      cstrPassword = strPassword;
      try {
         cobjClient = JCO.createClient(strSapClient, strUserId, strPassword, strLanguage, strServer, strSystem);
         cobjClient.connect();
         cobjRepository = new JCO.Repository("ISI-SAP", cobjClient);
         cobjFunctionTemplate = cobjRepository.getFunctionTemplate("/MARS/BC_RFC_READ_TABLE");
      } catch(Exception objException) {
         throw new Exception("SAP CONNECTION - Client connect error  - " + objException.getMessage());
      }

   }
   
   /**
    * Gets the current user id
    * @return String the current user id
    */
   public String getUserId() {
      return cstrUserId;
   }
   
   /**
    * Gets the current password
    * @return ring the current password
    */
   public String getPassword() {
      return cstrPassword;
   }
   
   /**
    * Disconnects the SAP client connection
    * @throws Exception the exception message
    */
   public void disconnect() throws Exception {
      if (cobjClient != null) {
         cobjFunctionTemplate = null;
         cobjRepository = null;
         if (cobjClient.isAlive()) {
            cobjClient.disconnect();
         }
         cobjClient = null;
      }
   }
   
   /**
    * Executes the JCO function
    * @param objFunction the JCO function to execute
    * @throws Exception the exception message
    */
   protected void execute(JCO.Function objFunction) throws Exception {
      cobjClient.execute(objFunction);
   }
   
   /**
    * Retrieves the JCO function
    * @return JCO.Function the function template function
    * @throws Exception the exception message
    */
   protected JCO.Function getFunction() throws Exception {
      return cobjFunctionTemplate.getFunction();
   }

}