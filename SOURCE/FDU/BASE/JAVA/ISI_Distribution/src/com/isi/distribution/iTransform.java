/**
 * Package : ISI Distribution
 * Type    : Interface
 * Name    : iTransform
 * Author  : Steve Gregan
 * Date    : July 2007
 */
package com.isi.distribution;
import java.util.*;

/**
 * This interface defines the distribution data transformation interface.
 * All classes register as a tranformmust implement this interface.
 */
public interface iTransform {

   /**
    * Performs the file transformation
    * 
    * @param strInputFiles the input file array
    * @param strOutputFiles the output file array
    * @exception Exception the exception
    */
   public void transform(String[] strInputFiles, String[] strOutputFiles) throws Exception;
   
}
