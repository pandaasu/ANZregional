/// <summary>
/// Type   : Class
/// Name   : cDataStore
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {
	
   using System;
   using System.Collections;

   /// <summary>
   /// <p>
   /// This class defines the base data storage mechanism. This class
   /// must be inherited by all data store object models.
   /// </p>
   /// </summary>
	public abstract class cDataStore {

      //
      // Class declarations
      //
      private Hashtable cobjValues = new Hashtable();

      /// <summary>
      /// Sets the data store value.
      /// </summary>
      /// <param name="strKey">the key string</param>
      /// <param name="strValue">the value string</param>
      public void SetValue(string strKey, string strValue) {
         if (!cobjValues.ContainsKey(strKey.ToUpper())) {
            cobjValues.Add(strKey.ToUpper(), strValue);
         }
      }

      /// <summary>
      /// Gets the data store value.
      /// </summary>
      /// <param name="strKey">the key string</param>
      /// <return>the value string</return>
      public string GetValue(string strKey) {
         return (string)cobjValues[strKey.ToUpper()];
      }

	}

}