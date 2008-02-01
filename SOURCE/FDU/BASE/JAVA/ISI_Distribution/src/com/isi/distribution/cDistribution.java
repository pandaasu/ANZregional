/**
 * Package : ISI Distribution
 * Type    : Class
 * Name    : cDistribution
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;
import java.io.*;

/**
 * This class implements the distribution functionality.
 */
public class cDistribution {
   
   //
   // Instance private declarations
   //
   private String cstrText;
   private ArrayList cobjActions;

   /**
    * Constructs a new instance
    * 
    * @param strParameters the distribution parameter array
    */
   public cDistribution(String[] strParameters) {
      cstrText = strParameters[0];
      cobjActions = new ArrayList();
   }
   
   /**
    * Adds a distribution action
    *
    * @param objAction the distribution action object reference
    * @throws Exception the exception message
    */
   public void addAction(Object objAction) throws Exception {
      cobjActions.add(objAction);
   }
   
   /**
    * Processes the distribution
    *
    * @param objConfiguration the configuration reference
    * @param strDistributionPath the transfer path
    * @param strTransferPath the transfer path
    * @param strTransformPath the transform path
    * @param objPrintWriter the output file writer
    * @throws Exception the exception message
    */
   public void process(cConfiguration objConfiguration, String strDistributionPath, String strTransferPath, String strTransformPath) throws Exception {
      
      //
      // Output the log start
      //
      objConfiguration.putLogLine("--> DISTRIBUTION - " + cstrText);
      
      //
      // Refresh the transfer directory from the distribution directory
      //
      objConfiguration.refreshTransfer(strDistributionPath, strTransferPath);
      
      //
      // Process the distribution action list
      //
      for (int i=0; i<cobjActions.size(); i++) {
         objConfiguration.clearDirectory(new File(strTransformPath));
         if (cobjActions.get(i) instanceof com.isi.distribution.cTransformAction) {
            ((cTransformAction)cobjActions.get(i)).process(objConfiguration, strTransferPath, strTransformPath);
         } else if (cobjActions.get(i) instanceof com.isi.distribution.cTransferAction) {
            ((cTransferAction)cobjActions.get(i)).process(objConfiguration, strTransferPath);
         } else {
            objConfiguration.putLogLine("-----> **EXCEPTION** - Distribution action class (" + cobjActions.get(i) + ")not recognised");
            throw new Exception("Distribution exception");
         }
      }
      
   }

}