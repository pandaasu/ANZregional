/**
 * Package : ISI VDS
 * Type    : Class
 * Name    : iSapVdsExtract
 * Author  : Steve Gregan
 * Date    : March 2010
 */
package com.isi.vds;
import java.util.*;

/**
 * This interface defines the SAP interface. All classes that process SAP
 * interfaces must implement this interface.
 */
public interface iSapVdsExtract {

   /**
    * Process the SAP to VDS extract
    * 
    * @param objParameters the hash map of interface parameters
    * @param strReplace the interface data full replacement indicator
    * @exception Exception the exception
    */
   public void process(HashMap objParameters, String strReplace) throws Exception;
   
}
