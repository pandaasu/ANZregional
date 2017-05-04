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

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.retrieve_materials", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_plant_code", OracleDbType.Varchar2).Value = request.PlantCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("rc_out", OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleReader = this.OracleCommand.ExecuteReader();

                    if (!this.OracleReader.HasRows)
                    {
                        return result;
                    }

                    var rowCount = 0;
                    var dataList = new List<MaterialDefinitionType>();
                    
                    while (this.OracleReader.Read())
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
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = DateTime.Now };
                            //result.MaterialInformation.MaterialDefinition = new MaterialDefinitionType[dataset.Tables[0].Rows.Count];
                        }

                        var childCodes = Tools.MakeList(this.OracleReader["child_material_codes"].ToString());

                        var dataItem = new MaterialDefinitionType();
                        dataItem.ID = new IdentifierType() { Value = this.OracleReader["matl_code"].ToString() };
                        dataItem.Description = new DescriptionType[1];
                        dataItem.Description[0] = new DescriptionType() { Value = this.OracleReader["matl_desc"].ToString() };
                        dataItem.MaterialDefinitionProperty = new MaterialDefinitionPropertyType[12 + childCodes.Count];
                        dataItem.MaterialDefinitionProperty[0] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PART_UOM" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = this.OracleReader["base_uom"].ToString() }
                        };

                        dataItem.MaterialDefinitionProperty[1] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PART_SHELFLIFE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["shelf_life"].ToString() },
                            DataType = new DataTypeType() { Value = "integer" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "Days" }
                        };

                        dataItem.MaterialDefinitionProperty[2] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=MATERIAL_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[2].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["matl_type"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        dataItem.MaterialDefinitionProperty[3] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=GROSS_WEIGHT" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[3].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["gross_wght"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                        };

                        dataItem.MaterialDefinitionProperty[4] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=NET_WEIGHT" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[4].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["net_wght"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                        };

                        dataItem.MaterialDefinitionProperty[5] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=EAN" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[5].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["ean_code"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        dataItem.MaterialDefinitionProperty[6] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PLANT_ORIENTED_MATERIAL_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[6].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["plant_orntd_matl_type"].ToString() },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        dataItem.MaterialDefinitionProperty[7] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=BATCH_MANAGED_MATERIAL" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[7].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["batch_mngmnt_rqrmnt_indctr"].ToString() == "X" ? "true" : "false" },
                            DataType = new DataTypeType() { Value = "boolean" }
                        };

                        dataItem.MaterialDefinitionProperty[8] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=PROCUREMENT_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[8].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["prcrmnt_type"].ToString() == "X" ? "true" : "false" },
                            DataType = new DataTypeType() { Value = "string" }
                        };

                        dataItem.MaterialDefinitionProperty[9] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=SPECIAL_PROCUREMENT_TYPE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[9].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" }
                        };
                        if (this.OracleReader["spcl_prcrmnt_type"].ToString() != string.Empty)
                        {
                            dataItem.MaterialDefinitionProperty[9].Value[0].ValueString = new ValueStringType() { Value = this.OracleReader["spcl_prcrmnt_type"].ToString() };
                        }

                        dataItem.MaterialDefinitionProperty[10] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=ISSUE_STORAGE_LOCATION" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[10].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" }
                        };
                        if (this.OracleReader["issue_strg_locn"].ToString() != string.Empty)
                        {
                            dataItem.MaterialDefinitionProperty[10].Value[0].ValueString = new ValueStringType() { Value = this.OracleReader["issue_strg_locn"].ToString() };
                        }
                        
                        dataItem.MaterialDefinitionProperty[11] = new MaterialDefinitionPropertyType()
                        {
                            ID = new IdentifierType() { Value = "PROPERTY=ACTIVE_ON_PLANT" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialDefinitionProperty[11].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = this.OracleReader["plant_sts"].ToString() == "99" ? "false" : "true" },
                            DataType = new DataTypeType() { Value = "boolean" }
                        };

                        for (var i = 0; i < childCodes.Count; i++)
                        {
                            dataItem.MaterialDefinitionProperty[12 + i] = new MaterialDefinitionPropertyType()
                            {
                                ID = new IdentifierType() { Value = "PROPERTY=CHILD_MATERIAL_ID" },
                                Value = new Models.ValueType[1]
                            };
                            dataItem.MaterialDefinitionProperty[12 + i].Value[0] = new Models.ValueType()
                            {
                                ValueString = new ValueStringType() { Value = childCodes[i] },
                                DataType = new DataTypeType() { Value = "string" }
                            };
                        }

                        rowCount++;
                        dataList.Add(dataItem);
                    }

                    result.MaterialInformation.MaterialDefinition = dataList.ToArray();
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

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.retrieve_material_batch", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_batch_code", OracleDbType.Varchar2).Value = request.BatchCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_matl_code", OracleDbType.Varchar2).Value = request.MaterialCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("rc_out", OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleReader = this.OracleCommand.ExecuteReader();

                    if (!this.OracleReader.HasRows)
                    {
                        return result;
                    }

                    var rowCount = 0;
                    var dataList = new List<MaterialLotType>();

                    while (this.OracleReader.Read())
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
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = DateTime.Now };
                            //result.MaterialInformation.MaterialLot = new MaterialLotType[dataset.Tables[0].Rows.Count];
                        }

                        var dataItem = new MaterialLotType();
                        dataItem.ID = new IdentifierType() { Value = this.OracleReader["batch_code"].ToString() };
                        dataItem.Status = new StatusType() { Value = this.OracleReader["batch_qi_status"].ToString() };
                        dataItem.MaterialDefinitionID = new MaterialDefinitionIDType() { Value = this.OracleReader["material_code"].ToString() };
                        dataItem.Description = new DescriptionType[1];
                        dataItem.Description[0] = new DescriptionType() { Value = this.OracleReader["matl_desc"].ToString() };
                        dataItem.MaterialLotProperty = new MaterialLotPropertyType[2];
                        dataItem.MaterialLotProperty[0] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "BATCH_OLC_STATUS" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialLotProperty[0].Value = new Models.ValueType[1];
                        dataItem.MaterialLotProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["batch_olc_status"].ToString() }
                        };

                        dataItem.MaterialLotProperty[1] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "EXPIRY_DATE" },
                            Value = new Models.ValueType[1]
                        };
                        dataItem.MaterialLotProperty[1].Value = new Models.ValueType[1];
                        dataItem.MaterialLotProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = string.Format("{0:o}", this.OracleReader["batch_expiry_date"]) },
                            DataType = new DataTypeType() { Value = "datetime" }
                        };

                        rowCount++;
                        dataList.Add(dataItem);
                    }

                    result.MaterialInformation.MaterialLot = dataList.ToArray();
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

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.retrieve_factory_transfers", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_matl_code", OracleDbType.Varchar2).Value = request.MaterialCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_batch_code", OracleDbType.Varchar2).Value = request.BatchCode.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("rc_out", OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleReader = this.OracleCommand.ExecuteReader();

                    if (!this.OracleReader.HasRows)
                    {
                        return result;
                    }

                    var rowCount = 0;
                    var dataList = new List<MaterialLotType>();

                    while (this.OracleReader.Read())
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
                            result.MaterialInformation.Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["to_plant"].ToString() };
                            result.MaterialInformation.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.MaterialInformation.PublishedDate = new PublishedDateType() { Value = Tools.TryDateTime(this.OracleReader["transmit_date"].ToString() + this.OracleReader["transmit_time"].ToString(), "yyyyMMddHHmmss") ?? DateTime.Now };
                            //result.MaterialInformation.MaterialLot = new MaterialLotType[dataset.Tables[0].Rows.Count];
                        }

                        var dataItem = new MaterialLotType();
                        dataItem.ID = new IdentifierType() { Value = this.OracleReader["batch_code"].ToString() };
                        dataItem.Status = new StatusType() { Value = this.OracleReader["disposition"].ToString() };
                        dataItem.MaterialDefinitionID = new MaterialDefinitionIDType() { Value = this.OracleReader["material"].ToString() };
                        dataItem.StorageLocation = new StorageLocationType() { Value = this.OracleReader["to_sloc"].ToString() };
                        dataItem.Description = new DescriptionType[1];
                        dataItem.Description[0] = new DescriptionType() { Value = this.OracleReader["material"].ToString() };
                        dataItem.Quantity = new QuantityValueType[1];
                        dataItem.Quantity[0] = new QuantityValueType()
                        {
                            QuantityString = new QuantityStringType() { Value = this.OracleReader["quantity"].ToString() },
                            DataType = new DataTypeType() { Value = "decimal" },
                            UnitOfMeasure = new UnitOfMeasureType() { Value = this.OracleReader["uom"].ToString() }
                        };
                        dataItem.MaterialLotProperty = new MaterialLotPropertyType[6];
                        dataItem.MaterialLotProperty[0] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SSCC_NUMBER" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[0].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["sscc_number"].ToString() }
                        };

                        dataItem.MaterialLotProperty[1] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "EXPIRY_DATE" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[1].Value[0] = new Models.ValueType()
                        {
                            ValueString = new ValueStringType() { Value = string.Format("{0:o}", this.OracleReader["batch_expiry"]) },
                            DataType = new DataTypeType() { Value = "datetime" }
                        };

                        dataItem.MaterialLotProperty[2] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "VENDOR" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[2].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["vendor"].ToString() }
                        };

                        dataItem.MaterialLotProperty[3] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "VENDOR_BATCH" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[3].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["vendor_batch_code"].ToString() }
                        };

                        dataItem.MaterialLotProperty[4] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SOURCE_PLANT" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[4].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["from_plant"].ToString() }
                        };

                        dataItem.MaterialLotProperty[5] = new MaterialLotPropertyType()
                        {
                            ID = new IdentifierType() { Value = "SOURCE_SLOC" },
                            Value = new Models.ValueType[1]
                        };
                        result.MaterialInformation.MaterialDefinition[rowCount].MaterialDefinitionProperty[5].Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "string" },
                            ValueString = new ValueStringType() { Value = this.OracleReader["from_sloc"].ToString() }
                        };

                        rowCount++;
                        dataList.Add(dataItem);
                    }

                    result.MaterialInformation.MaterialLot = dataList.ToArray();
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