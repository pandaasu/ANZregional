/**
 * Package : ISI SAP
 * Type    : Class
 * Name    : iSapDualInterface
 * Author  : Steve Gregan
 * Date    : February 2007
 */
package com.isi.sap;
import java.util.*;

/**
 * This interface defines the SAP dual interface. All classes that process SAP dual
 * interfaces must implement this interface.
 */
public interface iSapDualInterface {

   /**
    * Defines the sheet
    * 
    * @param objSAPConnection01 the cSAPconnection reference 01
    * @param objSAPConnection02 the cSAPconnection reference 02
    * @param objParameters the hash map of interface parameters
    * @param strOutputFile the interface output file
    * @exception Exception the exception
    */
   public void process(cSapConnection objSAPConnection01, cSapConnection objSAPConnection02, HashMap objParameters, String strOutputFile) throws Exception;
   
}
