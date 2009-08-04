/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cResourceEnglish
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application resource english class. This class
 * implements the application english resources strings.
 */
public final class cResourceEnglish extends cResourceBundle {
   
   /**
    * Constructs a new instance
    */
   public cResourceEnglish() {
      
      //
      // Command resources
      //
      objResourceStore.put("CMDEXIT", "Exit");
      objResourceStore.put("CMDBACK", "Back");
      objResourceStore.put("CMDNEXT", "Next");
      objResourceStore.put("CMDSELECT", "Select");
      objResourceStore.put("CMDSEARCH", "Search");
      objResourceStore.put("CMDCREATE", "Create");
      objResourceStore.put("CMDUPDATE", "Update");
      objResourceStore.put("CMDCLEAR", "Clear");
      objResourceStore.put("CMDDELETE", "Delete");
      objResourceStore.put("CMDSAVE", "Save");
      objResourceStore.put("CMDEDIT", "Edit");
      objResourceStore.put("CMDCANCEL", "Cancel");
      objResourceStore.put("CMDACCEPT", "Accept");
      objResourceStore.put("CMDCHANNEL", "Channel");
      objResourceStore.put("CMDYES", "Yes");
      objResourceStore.put("CMDNO", "No");
      
      //
      // Constant resources
      //
      objResourceStore.put("CONACTIVE", "Active");
      objResourceStore.put("CONINACTIVE", "Inactive");
      objResourceStore.put("CONYES", "*YES");
      objResourceStore.put("CONNO", "*NO");
      objResourceStore.put("CONALL", "*ALL");
      objResourceStore.put("CONCONFIRMCANCEL", "Please confirm the cancel action?");
      objResourceStore.put("CONCONNECTERROR", "You have lost connection to the internet. Please move to a location with better mobile signal strength and try again.");
      objResourceStore.put("CONNODATA", "** END **");
      
      //
      // Mobile resources
      //
      objResourceStore.put("MOBMNUHDR", "Mars eFEX");
      objResourceStore.put("MOBMNU001", "Configuration");
      objResourceStore.put("MOBMNU002", "Mobile Download");
      objResourceStore.put("MOBMNU003", "Mobile Upload");
      objResourceStore.put("MOBMNU004", "Mobile Settings");
      objResourceStore.put("MOBMNU005", "Route Call");
      objResourceStore.put("MOBMNU006", "Customers");
      objResourceStore.put("MOBMNU007", "Messages");
      objResourceStore.put("MOBMNUM01", "Initialising application...");
      
      objResourceStore.put("MOBCFGHDR", "Configuration");
      objResourceStore.put("MOBCFG001", "User Name");
      objResourceStore.put("MOBCFG002", "Language");
      objResourceStore.put("MOBCFG003", "Server URL");
      objResourceStore.put("MOBCFG004", "Secure");
      objResourceStore.put("MOBCFGM01", "User name must be entered");
      objResourceStore.put("MOBCFGM02", "Server URL must be entered");
      
      objResourceStore.put("MOBDWNHDR", "Mobile Download");
      objResourceStore.put("MOBDWN001", "Password");
      objResourceStore.put("MOBDWN002", "**WARNING**");
      objResourceStore.put("MOBDWN003", "Existing mobile data has not been saved");
      objResourceStore.put("MOBDWN004", "Download mobile data from server?");
      objResourceStore.put("MOBDWN005", "Cancel or Accept");
      objResourceStore.put("MOBDWNM01", "Mobile is not configured - option not allowed");
      objResourceStore.put("MOBDWNM02", "Downloading mobile data...");
      objResourceStore.put("MOBDWNM03", "Downloading mobile data completed");
      
      objResourceStore.put("MOBUPLHDR", "Mobile Upload");
      objResourceStore.put("MOBUPL001", "Password");
      objResourceStore.put("MOBUPL002", "**WARNING**");
      objResourceStore.put("MOBUPL003", "Mobile data has already been uploaded");
      objResourceStore.put("MOBUPL004", "**WARNING**");
      objResourceStore.put("MOBUPL005", "Some route calls have not been made");
      objResourceStore.put("MOBUPL006", "Upload mobile data to server?");
      objResourceStore.put("MOBUPL007", "Cancel or Accept");
      objResourceStore.put("MOBUPLM01", "Mobile is not configured - option not allowed");
      objResourceStore.put("MOBUPLM02", "No mobile data on device - option not allowed");
      objResourceStore.put("MOBUPLM03", "Uploading mobile data...");
      objResourceStore.put("MOBUPLM04", "Uploading mobile data completed");

      objResourceStore.put("MOBSETHDR", "Mobile Settings");
      objResourceStore.put("MOBSET001", "Salesperson Id");
      objResourceStore.put("MOBSET002", "Salesperson Name");
      objResourceStore.put("MOBSET003", "Route Date");
      objResourceStore.put("MOBSET004", "Mobile Status");
      objResourceStore.put("MOBSET005", "Mobile Downloaded");
      objResourceStore.put("MOBSET006", "Mobile Uploaded");
      objResourceStore.put("MOBSETM01", "Mobile is not configured - option not allowed");
      objResourceStore.put("MOBSETM02", "No mobile data on device - option not allowed");
      
      //
      // Route resources
      //
      objResourceStore.put("RTELSTHDR", "Customers");
      objResourceStore.put("RTELSTM01", "No route data on device - option not allowed");
      objResourceStore.put("RTELSTM02", "No customer selected");
      objResourceStore.put("RTELSTM03", "Opening call...");
      
      objResourceStore.put("RTEDLTHDR", "Customer Delete");
      objResourceStore.put("RTEDLT001", "Customer Code");
      objResourceStore.put("RTEDLT002", "Customer Name");
      objResourceStore.put("RTEDLTM01", "Only non-route customers can be deleted");
      objResourceStore.put("RTEDLTM02", "Deleting non-route call...");
      
      objResourceStore.put("RTESCHHDR", "Customer Search");
      objResourceStore.put("RTESCH001", "Customer Code");
      objResourceStore.put("RTESCH002", "Customer Name");
      
      objResourceStore.put("RTESLTHDR", "Customer Selection");
      objResourceStore.put("RTESLTM01", "No customer selected");
      objResourceStore.put("RTESLTM02", "Customer already exists in the call list");
      objResourceStore.put("RTESLTM03", "Downloading non-route call...");
      
      objResourceStore.put("RTEDWNHDR", "Customer Download");
      objResourceStore.put("RTEDWN001", "Password");
      objResourceStore.put("RTEDWN002", "Customer");
      objResourceStore.put("RTEDWN003", "Download customer data from server?");
      objResourceStore.put("RTEDWN004", "Cancel or Accept");
      objResourceStore.put("RTEDWNM01", "Opening customer...");
      objResourceStore.put("RTEDWNM02", "No data exists for the customer");
      
      objResourceStore.put("RTEDISHDR", "Distribution");
      objResourceStore.put("RTEDIS001", "Stock");
      objResourceStore.put("RTEDIS002", "Qty");
      objResourceStore.put("RTEDIS003", "Product");
      objResourceStore.put("RTEDIS004", "** Count SKU distributed in store **");
      objResourceStore.put("RTEDIS005", "Distribution Update");
      objResourceStore.put("RTEDIS006", "Customer");
      objResourceStore.put("RTEDIS007", "Data Type");
      objResourceStore.put("RTEDIS008", "Data Count");
      objResourceStore.put("RTEDIS009", "Product");
      objResourceStore.put("RTEDIS010", "Distributed");
      objResourceStore.put("RTEDIS011", "Stock Qty");
      
      objResourceStore.put("RTEDSPHDR", "Displays");
      objResourceStore.put("RTEDSP001", "Selected");
      objResourceStore.put("RTEDSP002", "Display");
      objResourceStore.put("RTEDSP003", "Display Update");
      objResourceStore.put("RTEDSP004", "Customer");
      objResourceStore.put("RTEDSP005", "Display");
      objResourceStore.put("RTEDSP006", "Selected");
      
      objResourceStore.put("RTEACTHDR", "Activities");
      objResourceStore.put("RTEACT001", "Selected");
      objResourceStore.put("RTEACT002", "Activity");
      objResourceStore.put("RTEACT003", "Activity Update");
      objResourceStore.put("RTEACT004", "Customer");
      objResourceStore.put("RTEACT005", "Activity");
      objResourceStore.put("RTEACT006", "Selected");

      objResourceStore.put("RTEORDHDR", "Ordering");
      objResourceStore.put("RTEORD001", "Qty");
      objResourceStore.put("RTEORD002", "UOM");
      objResourceStore.put("RTEORD003", "Value");
      objResourceStore.put("RTEORD004", "Product");
      objResourceStore.put("RTEORD005", "** Order Total **");
      
      objResourceStore.put("RTEORDUPDHDR", "Order Update");
      objResourceStore.put("RTEORDUPD001", "Customer");
      objResourceStore.put("RTEORDUPD002", "Product");
      objResourceStore.put("RTEORDUPD003", "Order Qty");
      objResourceStore.put("RTEORDUPD004", "Order UOM");
      
      objResourceStore.put("RTEORDDELHDR", "Order Delete");
      objResourceStore.put("RTEORDDEL001", "Customer");
      objResourceStore.put("RTEORDDEL002", "Product");
      objResourceStore.put("RTEORDDEL003", "Order Qty");
      objResourceStore.put("RTEORDDEL004", "Order UOM");
      
      objResourceStore.put("RTEORDCLRHDR", "Order Clear");
      objResourceStore.put("RTEORDCLR001", "Customer");
      objResourceStore.put("RTEORDCLR002", "Clear all order lines");
      objResourceStore.put("RTEORDCLR003", "Cancel or Accept");
      
      objResourceStore.put("RTEORDSCHHDR", "Product Search");
      objResourceStore.put("RTEORDSCH001", "Customer");
      objResourceStore.put("RTEORDSCH002", "Brand");
      objResourceStore.put("RTEORDSCH003", "Packsize");
      
      objResourceStore.put("RTEORDSLTHDR", "Product Selection");
      objResourceStore.put("RTEORDSLTM01", "No products satisfy the search");
      objResourceStore.put("RTEORDSLTM02", "No product selected");
      
      objResourceStore.put("RTEORDSBMHDR", "Order Submit");
      objResourceStore.put("RTEORDSBM001", "Customer");
      objResourceStore.put("RTEORDSBM002", "Do you need to send this order to the Wholesaler?");
      objResourceStore.put("RTEORDSBMM01", "All order lines must have a quantity");

      objResourceStore.put("RTECOMHDR", "Call Completion");
      objResourceStore.put("RTECOM001", "Customer");
      objResourceStore.put("RTECOM002", "Do you wish to complete the call?");
      objResourceStore.put("RTECOMM01", "Closing call...");
      
      //
      // Customer resources
      //
      objResourceStore.put("CUSVAL001", "Outlet Status is mandatory");
      objResourceStore.put("CUSVAL002", "Outlet name is mandatory");
      objResourceStore.put("CUSVAL003", "Outlet address is mandatory");
      objResourceStore.put("CUSVAL004", "Contact name is mandatory");
      objResourceStore.put("CUSVAL005", "Phone number is mandatory");
      objResourceStore.put("CUSVAL006", "Outlet type is mandatory");
      objResourceStore.put("CUSVAL007", "Outlet location is mandatory");
      objResourceStore.put("CUSVAL008", "Wholesaler is mandatory");
      
      objResourceStore.put("CUSLSTHDR", "Customer Selection");
      objResourceStore.put("CUSLSTM01", "No customer data on device - option not allowed");
      objResourceStore.put("CUSLSTM02", "No customer selected");
      
      objResourceStore.put("CUSDWNHDR", "Customer Download");
      objResourceStore.put("CUSDWN001", "Password");
      objResourceStore.put("CUSDWN002", "Customer");
      objResourceStore.put("CUSDWN003", "Download customer data from server?");
      objResourceStore.put("CUSDWN004", "Cancel or Accept");
      objResourceStore.put("CUSDWNM01", "Opening customer...");
      objResourceStore.put("CUSDWNM02", "No data exists for the customer");
      
      objResourceStore.put("CUSSCHHDR", "Customer Search");
      objResourceStore.put("CUSSCH001", "Customer Code");
      objResourceStore.put("CUSSCH002", "Customer Name");
      
      objResourceStore.put("CUSCHNHDR", "Sub Channel");
      objResourceStore.put("CUSCHNM01", "No sub channel selected");
      
      objResourceStore.put("CUSCRTHDR", "Customer Create");
      objResourceStore.put("CUSCRT001", "* Outlet Name");
      objResourceStore.put("CUSCRT002", "* Address");
      objResourceStore.put("CUSCRT003", "* Contact Name");
      objResourceStore.put("CUSCRT004", "* Phone Number");
      objResourceStore.put("CUSCRT005", "* Outlet Type");
      objResourceStore.put("CUSCRT006", "* Outlet Location");
      objResourceStore.put("CUSCRT007", "* Wholesaler");
      objResourceStore.put("CUSCRT008", "Postcode");
      objResourceStore.put("CUSCRT009", "Fax Number");
      objResourceStore.put("CUSCRT010", "Email Address");
      objResourceStore.put("CUSCRT011", "*SELECT*");
      objResourceStore.put("CUSCRTM01", "Creating customer...");
      
      objResourceStore.put("CUSUPDHDR", "Customer Update");
      objResourceStore.put("CUSUPD001", "Status");
      objResourceStore.put("CUSUPD002", "* Outlet Name");
      objResourceStore.put("CUSUPD003", "* Address");
      objResourceStore.put("CUSUPD004", "* Contact Name");
      objResourceStore.put("CUSUPD005", "* Phone Number");
      objResourceStore.put("CUSUPD006", "* Outlet Type");
      objResourceStore.put("CUSUPD007", "* Outlet Location");
      objResourceStore.put("CUSUPD008", "* Wholesaler");
      objResourceStore.put("CUSUPD009", "Postcode");
      objResourceStore.put("CUSUPD010", "Fax Number");
      objResourceStore.put("CUSUPD011", "Email Address");
      objResourceStore.put("CUSUPDM01", "Updating customer...");
      
      //
      // Message resources
      //
      objResourceStore.put("MSGLSTHDR", "Message List");
      objResourceStore.put("MSGLSTM01", "No message data on device - option not allowed");
      objResourceStore.put("MSGLSTM02", "No message selected");
      objResourceStore.put("MSGLSTM03", "Opening message...");
      
      objResourceStore.put("MSGDETHDR", "Message Detail");
      objResourceStore.put("MSGDET001", "Sender");
      objResourceStore.put("MSGDET002", "Message");
      objResourceStore.put("MSGDETM01", "Closing message...");

   }

}
