/**
 * Package : ISI BOSS
 * Type    : Class
 * Name    : cServerPing
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.boss.agent;
import com.isi.boss.iAgent;
import java.util.*;

/**
 * This class implements the server ping agent.
 */
public final class cServerPing implements iAgent {
   
   /**
    * Implements the iAgent interface retrieve method
    */
   public String retrieve(HashMap objAttributes) throws Exception {
      String strValue = "*ON";
      String strAlert = "*NO";
      Process objProcess = null;
      try {
         objProcess = Runtime.getRuntime().exec("/usr/sbin/ping " + (String)objAttributes.get("SERVER") + " -n 2");
         int intReturn = objProcess.waitFor();
         if (intReturn != 0) {
            strValue = "*OFF";
            strAlert = "*YES";
         }
      } catch(Exception objException) {
         strValue = "*OFF";
         strAlert = "*YES";
      } finally {
         objProcess = null;
      }
      return "<?xml version='1.0'?><boss_data><measure code='STATUS' parent='*TOP' type='*SWITCH' alert='" + strAlert + "'><value><![CDATA[" + strValue + "]]></value><text><![CDATA[Server State]]></text></measure></boss_data>";
   }

}