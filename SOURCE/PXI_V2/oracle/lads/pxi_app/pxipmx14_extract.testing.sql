-- Query to show the available demand forecasts.
select * from pxi_demand_header

-- Query to show the pxi baseline table data.
select * from pxi_baseline where has_account = 'Y'

-- Query to show the mars week information skewed to the correct weeks.
select * from table(pxipmx14_extract.pt_mars_weeks);

-- Create a configuration email report that 
begin
  pxipmx14_extract.email_config_error_report(1);
end;

--  Update the baseline table.
begin
  pxipmx14_extract.update_baseline(3);
end;

-- Validate Promax Account and Sku Information.
begin
  pxipmx14_extract.validate_promax_account_skus('0196');
  commit;
end;

-- Query to Show the Baseline Errors.
select * from table(pxipmx14_extract.pt_baseline_error_report('0196'));

-- Create a baseline email report that 
begin
  pxipmx14_extract.email_baseline_error_report('0196');
end;

-- Query to create the capped extract data.
select * from table (pxipmx14_extract.pt_baseline('0196')); 

-- Query to show the extract data
select * from table(pxipmx14_extract.pt_baseline_extract('0196'));

-- Create an extract to Promax.
begin
  pxipmx14_extract.create_extract('0196');
end; 

-- Perform a full test.
begin
  pxipmx14_extract.execute(1);
end;

select * from pxi_moe_attributes

select * from pxi_baseline

delete from pxi_baseline

commit
