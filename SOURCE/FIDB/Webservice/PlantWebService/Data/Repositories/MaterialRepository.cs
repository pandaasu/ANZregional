using System;
using System.Collections.Generic;
using System.Linq;
using System.Data;
using Oracle.ManagedDataAccess.Client;
using Oracle.ManagedDataAccess.Types;
using System.Web;
using System.Data.Common;
using PlantWebService.Models;
using PlantWebService.Classes;
using System.Text;
using PlantWebService.Interfaces.UnitOfWork;
using PlantWebService.Interfaces.Repositories;
using PlantWebService.Data.UnitOfWork;
using System.Threading.Tasks;
using System.Threading;
using System.Web.Caching;
using PlantWebService.Interfaces;

namespace PlantWebService.Data.Repositories
{
    public class MaterialRepository : BaseRepository, IMaterialRepository
    {
        private const string CacheKey = "Material";

        #region constructor

        public MaterialRepository(IDataContext dataContext)
            : base(dataContext)
        {
        }

        #endregion

        #region interface methods

        public RetrieveMaterialsResponse RetrieveMaterials(RetrieveMaterialsRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveMaterials(request);
        }

        public RetrieveMaterialBatchListResponse RetrieveMaterialBatchList(RetrieveMaterialBatchListRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveMaterialBatchList(request);
        }

        public RetrieveFactoryTransfersResponse RetrieveFactoryTransfers(RetrieveFactoryTransfersRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveFactoryTransfers(request);
        }

        #endregion

        #region static methods

        public static string CacheTime()
        {
            return ((string)HttpRuntime.Cache.Get("Hash_" + CacheKey)) ?? string.Format("{0:yyyyMMddHHmmssfff}", DateTime.Now);
        }

        #endregion

        #region classes

        private class DataAccess : PlantWebService.Data.UnitOfWork.UnitOfWork
        {
            #region constructor

            public DataAccess(IUnitOfWork unitOfWork)
                : base(unitOfWork)
            {
            }

            #endregion

            #region methods
            
            public RetrieveMaterialsResponse RetrieveMaterials(RetrieveMaterialsRequest request)
            {
                var result = new RetrieveMaterialsResponse();
                var dataset = new DataSet();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.Text;
                    this.OracleCommand.CommandText = string.Format("select * from table({0}.{1}.retrieve_materials(:par_system_key, :par_mode, :par_plant_code))", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_plant_code", OracleDbType.Varchar2).Value = request.PlantCode.ToSqlNullable();

                    this.Log();
                    this.OracleAdapter = new OracleDataAdapter(this.OracleCommand);
                    this.OracleAdapter.Fill(dataset);

                    var rowCount = 0;
                    
                    foreach (DataRow row in dataset.Tables[0].Rows)
                    {
                        if (rowCount == 0)
                        {
                            result.MaterialInformation = new MaterialInformationType();
                            result.MaterialInformation.ID = new IdentifierType() { Value = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now) };
                            result.MaterialInformation.Description = new DescriptionType[1];
                            result.MaterialInformation.Description[0] = new DescriptionType() { Value = "Material Definition" };
                            result.MaterialInformation.Location = new LocationType();
                            result.MaterialInformation.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                            result.MaterialInformation.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                            result.MaterialInformation.Location.Location = new LocationType();
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = row["plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = DateTime.Now };
                            result.MaterialInformation.MaterialDefinition = new MaterialDefinitionType[dataset.Tables[0].Rows.Count];
                        }

                        var childCodes = Tools.MakeList(row["child_material_codes"].ToString());

                        result.MaterialInformation.MaterialDefinition[rowCount] = new MaterialDefinitionType();
                        result.MaterialInformation.MaterialDefinition[rowCount].ID = new IdentifierType() { Value = row["matl_code"].ToString() };
                        result.MaterialInformation.MaterialDefinition[rowCount].Description = new DescriptionType[1];
                        result.MaterialInformation.MaterialDefinition[rowCount].Description[0] = new DescriptionType() { Value = row["matl_desc"].ToString() };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty = new MaterialDefinitionPropertyType[12 + childCodes.Count];
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[0] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PART_UOM" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = row["base_uom"].ToString() }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[1] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PART_SHELFLIFE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["shelf_life"].ToString() },
                            DataType = new DataTypeType() { Value = "integer" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "Days" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[2] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=MATERIAL_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[2].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["matl_type"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[3] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=GROSS_WEIGHT" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[3].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["gross_wght"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[4] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=NET_WEIGHT" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[4].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["net_wght"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[5] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=EAN" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[5].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["ean_code"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[6] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PLANT_ORIGINATED_MATERIAL_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[6].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["plant_orntd_matl_type"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[7] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=BATCH_MANAGED_MATERIAL" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[7].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["batch_mngmnt_rqrmnt_indctr"].ToString() == "X" ? "true" : "false" },
                            DataType = new DataTypeType() { Value = "boolean" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[8] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PROCUREMENT_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[8].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["prcrmnt_type"].ToString() == "X" ? "true" : "false" },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[9] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=SPECIAL_PROCUREMENT_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[9].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" }
                        };
                        if (row["spcl_prcrmnt_type"].ToString() != string.Empty)
                        {
                            result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[9].Value[0].ValueString = new ValueStringType() { Value = row["spcl_prcrmnt_type"].ToString() };
                        }

                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[10] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=ISSUE_STORAGE_LOCATION" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[10].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" }
                        };
                        if (row["issue_strg_locn"].ToString() != string.Empty)
                        {
                            result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[10].Value[0].ValueString = new ValueStringType() { Value = row["issue_strg_locn"].ToString() };
                        }
                        
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[11] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=ACTIVE_ON_PLANT" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[11].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = row["plant_sts"].ToString() == "99" ? "false" : "true" },
                            DataType = new DataTypeType() { Value = "boolean" }
                        };

                        for (var i = 0; i < childCodes.Count; i++)
                        {
                            result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[12 + i] = new MaterialDefinitionPropertyType()
                            {
                                ID = new IdentifierType() { Value = "PROPERTY=CHILD_MATERIAL_ID" },
                                Value = new Models.ValueType[1]
                            };
                            result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[12 + i].Value[0] = new Models.ValueType()
                            {
                                ValueString = new ValueStringType() { Value = childCodes[i] },
                                DataType = new DataTypeType() { Value = "string" }
                            };
                        }

                        rowCount++;
                    }
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public RetrieveMaterialBatchListResponse RetrieveMaterialBatchList(RetrieveMaterialBatchListRequest request)
            {
                var result = new RetrieveMaterialBatchListResponse();
                var dataset = new DataSet();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.Text;
                    this.OracleCommand.CommandText = string.Format("select * from table({0}.{1}.retrieve_material_batch(:par_system_key, :par_mode, :par_batch_code, :par_matl_code))", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_batch_code", OracleDbType.Varchar2).Value = request.BatchCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_matl_code", OracleDbType.Varchar2).Value = request.MaterialCode.ToSqlNullable();

                    this.Log();
                    this.OracleAdapter = new OracleDataAdapter(this.OracleCommand);
                    this.OracleAdapter.Fill(dataset);

                    var rowCount = 0;

                    foreach (DataRow row in dataset.Tables[0].Rows)
                    {
                        if (rowCount == 0)
                        {
                            result.MaterialInformation = new MaterialInformationType();
                            result.MaterialInformation.ID = new IdentifierType() { Value = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now) };
                            result.MaterialInformation.Description = new DescriptionType[1];
                            result.MaterialInformation.Description[0] = new DescriptionType() { Value = "Batch Update" };
                            result.MaterialInformation.Location = new LocationType();
                            result.MaterialInformation.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                            result.MaterialInformation.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                            result.MaterialInformation.Location.Location = new LocationType();
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = row["plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = DateTime.Now };
                            result.MaterialInformation.MaterialLot = new MaterialLotType[dataset.Tables[0].Rows.Count];
                        }

                        result.MaterialInformation.MaterialLot[rowCount] = new MaterialLotType();
                        result.MaterialInformation.MaterialLot[rowCount].ID = new IdentifierType() { Value = row["batch_code"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].Status = new StatusType() { Value = row["batch_qi_status"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].MaterialDefinitionID = new MaterialDefinitionIDType() { Value = row["material_code"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].Description = new DescriptionType[1];
                        result.MaterialInformation.MaterialLot[rowCount].Description[0] = new DescriptionType() { Value = row["matl_desc"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty = new MaterialLotPropertyType[2];
                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[0] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "BATCH_OLC_STATUS" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["batch_olc_status"].ToString() }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[1] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "EXPIRY_DATE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = string.Format("{0:o}", row["batch_expiry_date"]) },
                            DataType = new DataTypeType() { Value = "datetime" }
                        };

                        rowCount++;
                    }
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public RetrieveFactoryTransfersResponse RetrieveFactoryTransfers(RetrieveFactoryTransfersRequest request)
            {
                var result = new RetrieveFactoryTransfersResponse();
                var dataset = new DataSet();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.Text;
                    this.OracleCommand.CommandText = string.Format("select * from table({0}.{1}.retrieve_factory_transfers(:par_system_key, :par_mode, :par_matl_code, :par_batch_code))", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_matl_code", OracleDbType.Varchar2).Value = request.MaterialCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_batch_code", OracleDbType.Varchar2).Value = request.BatchCode.ToSqlNullable();

                    this.Log();
                    this.OracleAdapter = new OracleDataAdapter(this.OracleCommand);
                    this.OracleAdapter.Fill(dataset);

                    var rowCount = 0;

                    foreach (DataRow row in dataset.Tables[0].Rows)
                    {
                        if (rowCount == 0)
                        {
                            result.MaterialInformation = new MaterialInformationType();
                            result.MaterialInformation.ID = new IdentifierType() { Value = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now) };
                            result.MaterialInformation.Description = new DescriptionType[1];
                            result.MaterialInformation.Description[0] = new DescriptionType() { Value = "Material Staging" };
                            result.MaterialInformation.Location = new LocationType();
                            result.MaterialInformation.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                            result.MaterialInformation.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                            result.MaterialInformation.Location.Location = new LocationType();
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = row["to_plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = Tools.TryDateTime(row["transmit_date"].ToString() + row["transmit_time"].ToString(), "yyyyMMddHHmmss") ?? DateTime.Now };
                            result.MaterialInformation.MaterialLot = new MaterialLotType[dataset.Tables[0].Rows.Count];
                        }

                        result.MaterialInformation.MaterialLot[rowCount] = new MaterialLotType();
                        result.MaterialInformation.MaterialLot[rowCount].ID = new IdentifierType() { Value = row["batch_code"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].Status = new StatusType() { Value = row["disposition"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].MaterialDefinitionID = new MaterialDefinitionIDType() { Value = row["material"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].StorageLocation = new StorageLocationType() { Value = row["to_sloc"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].Description = new DescriptionType[1];
                        result.MaterialInformation.MaterialLot[rowCount].Description[0] = new DescriptionType() { Value = row["material"].ToString() };
                        result.MaterialInformation.MaterialLot[rowCount].Quantity = new QuantityValueType[1];
                        result.MaterialInformation.MaterialLot[rowCount].Quantity[0] = new QuantityValueType()
                        {
                            QuantityString = new QuantityStringType() { Value = row["quantity"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = row["uom"].ToString() }
                        };
                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty = new MaterialLotPropertyType[6];
                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[0] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SSCC_NUMBER" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["sscc_number"].ToString() }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[1] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "EXPIRY_DATE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = string.Format("{0:o}", row["batch_expiry"]) },
                            DataType = new DataTypeType() { Value = "datetime" }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[2] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "VENDOR" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[2].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["vendor"].ToString() }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[3] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "VENDOR_BATCH" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[3].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["vendor_batch_code"].ToString() }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[4] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SOURCE_PLANT" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[4].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["from_plant"].ToString() }
                        };

                        result.MaterialInformation.MaterialLot[rowCount].MaterialLotProperty[5] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SOURCE_SLOC" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[5].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = row["from_sloc"].ToString() }
                        };

                        rowCount++;
                    }
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            #endregion
        }

        #endregion
    }
}