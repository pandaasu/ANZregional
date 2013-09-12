--------------------------------------------------------------------------------
This directory contains packages that are to be compiled into Venus DDS_APP
schema.
--------------------------------------------------------------------------------

PXIPMX07_EXTRACT - Sales Data Extract that is then Passed Through to LADS for
                   on passthrough to Promax Servers.  
                   Promax PI Interface Number : 306

PXIPMX10_EXTRACT - This is both an extract and a loader packaged for the 
                   COGS Interface.  It contains a FLU loader for loading
                   the COGS prices.  Then once a week it is scheduled to 
                   extract COGS information. 
