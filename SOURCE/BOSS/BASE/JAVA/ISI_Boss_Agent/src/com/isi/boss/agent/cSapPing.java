/**
 * Package : ISI BOSS
 * Type    : Class
 * Name    : cSapPing
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss.agent;
import com.isi.boss.iAgent;
import java.util.*;
import com.sap.mw.jco.*;

/**
 * This class implements the SAP database ping agent.
 */
public final class cSapPing implements iAgent {
   
   /**
    * Implements the iAgent interface retrieve method
    */
   public String retrieve(HashMap objAttributes) throws Exception {
      String strValue = "*ON";
      String strAlert = "*NO";
      JCO.Client cobjClient = null;
      try {
         cobjClient = JCO.createClient((String)objAttributes.get("CLIENT"), (String)objAttributes.get("USER"), (String)objAttributes.get("PASSWORD"), (String)objAttributes.get("LANGUAGE"), (String)objAttributes.get("SERVER"), (String)objAttributes.get("SYSTEM"));
         cobjClient.connect();
      } catch(Exception objException) {
         strValue = "*OFF";
         strAlert = "*YES";
      } finally {
         if (cobjClient != null) {
            if (cobjClient.isAlive()) {
               cobjClient.disconnect();
            }
         }
         cobjClient = null;
      }
      return "<?xml version='1.0'?><boss_data><measure code='STATUS' parent='*TOP' type='*SWITCH' alert='" + strAlert + "'><value><![CDATA[" + strValue + "]]></value><text><![CDATA[Database State]]></text></measure></boss_data>";
   }

}