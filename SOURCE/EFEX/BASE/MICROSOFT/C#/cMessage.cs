/// <summary>
/// Type   : Class
/// Name   : cMessage
/// Author : Softstep Pty Ltd
/// Date   : July 2008
/// </summary>
namespace EfexServer {
	
   using System;
	
	/// <summary>
	/// This class defines a message
	/// </summary>
	public class cMessage {

		//
		// Class declarations
		//
		private char cchrCode;
		private string cstrData;
		
		/// <summary>
		/// Constructs a new instance
		/// </summary>
		internal cMessage(char chrCode, string strData) {
			cchrCode = chrCode;
			cstrData = strData;
			if (cstrData == null) {
				cstrData = "";
			}
		}
		
		/// <summary>
		/// Gets the mailbox message code
		/// </summary>
		/// <returns>char the mailbox message code</returns>
      internal char GetCode() {
         return cchrCode;
      }

		/// <summary>
		/// Gets the mailbox message length
      /// </summary>
		/// <returns>short the mailbox message length</returns>
      internal short GetLength() {
         return (short)cstrData.Length;
      }

		/// <summary>
		/// Gets the mailbox message data
		/// </summary>
		/// <returns>string the mailbox message data</returns>
      internal string GetData() {
         return cstrData;
      }

		/// <summary>
		/// Gets the mailbox message - code, length and data
		/// </summary>
		/// <returns>string the mailbox message data</returns>
      internal string GetMessageData() {
         return new string((cchrCode.ToString() + ((char)cstrData.Length).ToString() + cstrData).ToCharArray());
      }

   }

}