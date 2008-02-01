/**
 * Package : ISI SIMULATION
 * Type    : Class
 * Name    : cEvent
 * Author  : Steve Gregan
 * Date    : January 2006
 */
package com.isi.simulation;
import java.util.*;
import java.io.*;

/**
 * This class implements the simulation event
 */
public class cEvent {

   //
   // Instance private declarations
   //
   private String cstrMode;
   private String cstrSimulationName;
   private String cstrSimulationScript;
   private String cstrSimulationPath;
   private String cstrIcsPath;
   private String cstrRemoteServer;
   private String cstrExecType;
   private String cstrExecInterface;
   private String cstrExecFile;
   private long clngExecCount;
   private String[] cobjTokens;

   /**
    * Constructs a new instance
    * 
    * @param strParameter the event parameter array
    */
   public cEvent(String[] strParameter) {
      cstrMode = strParameter[0];
      cstrSimulationName = strParameter[1];
      cstrSimulationScript = strParameter[2];
      cstrSimulationPath = strParameter[3];
      cstrIcsPath = strParameter[4];
      cstrRemoteServer = strParameter[5];
      cstrExecType = strParameter[6];
      cstrExecInterface = strParameter[7];
      cstrExecFile = strParameter[8];
      clngExecCount = Long.parseLong(strParameter[9]);
      if (cstrExecType.equals("*INBOUND")) {
         cobjTokens = new String[9];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
         cobjTokens[6] = cstrIcsPath;
         cobjTokens[7] = cstrExecInterface;
         cobjTokens[8] = cstrExecFile;
      } else if (cstrExecType.equals("*OUTBOUND")) {
         cobjTokens = new String[9];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
         cobjTokens[6] = cstrIcsPath;
         cobjTokens[7] = cstrExecInterface;
         cobjTokens[8] = cstrExecFile;
      } else if (cstrExecType.equals("*PASSTHRU")) {
         cobjTokens = new String[9];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
         cobjTokens[6] = cstrIcsPath;
         cobjTokens[7] = cstrExecInterface;
         cobjTokens[8] = cstrExecFile;
      } else if (cstrExecType.equals("*REMOTEGET")) {
         cobjTokens = new String[8];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
         cobjTokens[6] = cstrRemoteServer;
         cobjTokens[7] = cstrExecInterface;
      } else if (cstrExecType.equals("*REMOTEPUT")) {
         cobjTokens = new String[9];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
         cobjTokens[6] = cstrRemoteServer;
         cobjTokens[7] = cstrExecInterface;
         cobjTokens[8] = cstrExecFile;
      } else {
         cobjTokens = new String[6];
         cobjTokens[0] = cstrSimulationScript;
         cobjTokens[1] = "*NONE";
         cobjTokens[2] = cstrMode;
         cobjTokens[3] = cstrExecType;
         cobjTokens[4] = cstrSimulationName;
         cobjTokens[5] = cstrSimulationPath;
      }
   }
   
   /**
    * Retrieves the execution list
    * @param objExecutions the simulation execution array
    * @param lngDurationMinutes the simulation duration minutes
    * @throws Exception the exception message
    */
   public void getExecutions(ArrayList objExecutions, long lngDurationMinutes) throws Exception {
      if (clngExecCount > 0) {
         long lngInterval = (lngDurationMinutes * 60000) / clngExecCount;
         long lngDelay = lngInterval / 2;
         for (int i=1; i<=clngExecCount; i++) {
            objExecutions.add(new cExecution(cstrExecInterface, lngDelay, cobjTokens));
            lngDelay = lngDelay + lngInterval;
         }
      }
   }
 
}