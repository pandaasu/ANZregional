/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : iSapInterface
 * Author  : Steve Gregan
 * Date    : June 2005
 */
package com.isi.sap;
import java.util.*;

/**
 * This interface defines the SAP interface. All classes that process SAP
 * interfaces must implement this interface.
 */
public interface iSapInterface {

   /**
    * Defines the sheet
    * 
    * @param objSAPConnection the cSAP connection reference
    * @param objParameters the hash map of interface parameters
    * @param strOutputFile the interface output file
    * @exception Exception the exception
    */
   public void process(cSapConnection objSAPConnection, HashMap objParameters, String strOutputFile) throws Exception;
   
}
