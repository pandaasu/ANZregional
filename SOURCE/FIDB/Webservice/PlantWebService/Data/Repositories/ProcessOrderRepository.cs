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
    public class ProcessOrderRepository : BaseRepository, IProcessOrderRepository
    {
        private const string CacheKey = "ProcessOrder";

        #region constructor

        public ProcessOrderRepository(IDataContext dataContext)
            : base(dataContext)
        {
        }

        #endregion

        #region interface methods

        public RetrieveProcessOrderResponse RetrieveProcessOrder(RetrieveProcessOrderRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveProcessOrder(request);
        }

        public RetrieveProcessOrderListResponse RetrieveProcessOrderList(RetrieveProcessOrderListRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveProcessOrderList(request);
        }

        public Response CreateGR(CreateGRProcessOrderRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CreateGR(request);
        }

        public Response Acknowledge(AcknowledgeProcessOrderRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.Acknowledge(request);
        }

        public Response CancelGR(CancelGRProcessOrderRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CancelGR(request);
        }

        public Response CreateConsumption(CreateConsumptionRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CreateConsumption(request);
        }

        public Response CreateStockAdjustment(CreateStockAdjustmentRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CreateStockAdjustment(request);
        }

        public Response LoadStockBalance(LoadStockBalanceRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.LoadStockBalance(request);
        }

        public Response CreateBlend(CreateBlendRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CreateBlend(request);
        }

        public Response CreateScrapMaterial(CreateScrapMaterialRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.CreateScrapMaterial(request);
        }

        public Response Start(StartProcessOrderRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.Start(request);
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

            public RetrieveProcessOrderResponse RetrieveProcessOrder(RetrieveProcessOrderRequest request)
            {
                var result = new RetrieveProcessOrderResponse();
                
                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.retrieve_process_orders", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey;
                    this.OracleCommand.Parameters.Add("par_proc_order", OracleDbType.Varchar2).Value = request.ProcessOrder;
                    this.OracleCommand.Parameters.Add("rc_out", OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleReader = this.OracleCommand.ExecuteReader();

                    if (!this.OracleReader.HasRows)
                    {
                        return result;
                    }

                    var rowCount = 0;
                    var operationList = new List<ProductionRequestType>();
                    var phaseList = new List<SegmentRequirementType>();
                    var seqList = new List<ParameterType>();
                    var operationCode = string.Empty;
                    var phaseCode = string.Empty;
                    var seqCode = string.Empty;
                    var operation = new ProductionRequestType();
                    var phase = new SegmentRequirementType();
                    var seq = new ParameterType();
                    var operationCounter = 0;

                    while (this.OracleReader.Read())
                    {
                        if (rowCount == 0)
                        {
                            result.ProductionSchedule = new ProductionScheduleType();
                            result.ProductionSchedule.ID = new IdentifierType() { Value = this.OracleReader["proc_order"].ToString() };
                            result.ProductionSchedule.Description = new DescriptionType[1];
                            result.ProductionSchedule.Description[0] = new DescriptionType() { Value = "Process Order" };
                            result.ProductionSchedule.Location = new LocationType();
                            result.ProductionSchedule.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                            result.ProductionSchedule.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                            result.ProductionSchedule.Location.Location = new LocationType();
                            result.ProductionSchedule.Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant"].ToString() };
                            result.ProductionSchedule.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            result.ProductionSchedule.PublishedDate = new PublishedDateType() { Value = Convert.ToDateTime(this.OracleReader["upd_datime"]) };
                            result.ProductionSchedule.StartTime = new StartTimeType() { Value = Convert.ToDateTime(this.OracleReader["sched_start_datime"]) };
                            result.ProductionSchedule.EndTime = new EndTimeType() { Value = Convert.ToDateTime(this.OracleReader["run_end_datime"]) };
                        }

                        if (operationCode != this.OracleReader["opertn"].ToString())
                        {
                            if (phaseList.Count > 0)
                            {
                                operation.SegmentRequirement[0].SegmentRequirement[0].SegmentRequirement = phaseList.ToArray();
                            }

                            operationCounter++;
                            operationCode = this.OracleReader["opertn"].ToString();

                            operation = new ProductionRequestType();
                            operation.ID = new IdentifierType() { Value = result.ProductionSchedule.ID.Value + "-" + operationCounter.ToString() };
                            operation.SegmentRequirement = new SegmentRequirementType[1];
                            operation.SegmentRequirement[0] = new SegmentRequirementType();
                            operation.SegmentRequirement[0].ID = new IdentifierType() { Value = this.OracleReader["resrce_code"].ToString() };
                            operation.SegmentRequirement[0].Location = new LocationType();
                            operation.SegmentRequirement[0].Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant"].ToString() };
                            operation.SegmentRequirement[0].Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            operation.SegmentRequirement[0].ProductionParameter = new ProductionParameterType[3];
                            operation.SegmentRequirement[0].ProductionParameter[0] = new ProductionParameterType();
                            operation.SegmentRequirement[0].ProductionParameter[0].Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "EIG_CONTROLRECIPE_INFO" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[0].Parameter.Parameter = new ParameterType[1];
                            operation.SegmentRequirement[0].ProductionParameter[0].Parameter.Parameter[0] = new ParameterType() {
                                ID = new IdentifierType() { Value = "EIG_RECIPE_INFO" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[0].Parameter.Parameter[0].Value = new PlantWebService.Models.ValueType[1];
                            operation.SegmentRequirement[0].ProductionParameter[0].Parameter.Parameter[0].Value[0] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = "TemplateRecipe" },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "RECIPE_TYPE" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1] = new ProductionParameterType();
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "EIG_PROCESSPARAMS" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter = new ParameterType[2];
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[0] = new ParameterType() {
                                ID = new IdentifierType() { Value = "BATCH_SIZE.Target" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[0].Value = new PlantWebService.Models.ValueType[2];
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[0].Value[0] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["batch_size_target_value"].ToString() },
                                DataType = new DataTypeType() { Value = "decimal" },
                                Key = new IdentifierType() { Value = "VALUE" },
                                UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[0].Value[1] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["batch_size_target_low"].ToString() },
                                DataType = new DataTypeType() { Value = "decimal" },
                                Key = new IdentifierType() { Value = "LOW" },
                                UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[1] = new ParameterType() {
                                ID = new IdentifierType() { Value = "SEQUENCES.Target" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[1].Value = new PlantWebService.Models.ValueType[1];
                            operation.SegmentRequirement[0].ProductionParameter[1].Parameter.Parameter[1].Value[0] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["opertn_pans"].ToString() },
                                DataType = new DataTypeType() { Value = "decimal" },
                                Key = new IdentifierType() { Value = "VALUE" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].ProductionParameter[2] = new ProductionParameterType();
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "SAP_CONTROLRECIPE_INFO" }
                            };
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter.Value = new PlantWebService.Models.ValueType[4];
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter.Value[0] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["cntl_rec_id"].ToString() },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "ID" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter.Value[1] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["recipe_text"].ToString() },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "DESCRIPTION" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter.Value[2] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["version"].ToString() },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "PRODUCTION_VERSION" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].ProductionParameter[2].Parameter.Value[3] = new PlantWebService.Models.ValueType() {
                                ValueString = new ValueStringType() { Value = string.Format("{0:o}", this.OracleReader["upd_datime"]) },
                                DataType = new DataTypeType() { Value = "DateTime" },
                                Key = new IdentifierType() { Value = "MODIFIED_DATE" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].MaterialRequirement = new MaterialRequirementType[1];
                            operation.SegmentRequirement[0].MaterialRequirement[0] = new MaterialRequirementType();
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialDefinitionID = new MaterialDefinitionIDType[1];
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialDefinitionID[0] = new MaterialDefinitionIDType() {
                                Value = this.OracleReader["code_produced"].ToString()
                            };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Description = new DescriptionType[1];
                            operation.SegmentRequirement[0].MaterialRequirement[0].Description[0] = new DescriptionType() {
                                Value = this.OracleReader["description_produced"].ToString()
                            };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location = new LocationType();
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant_produced"].ToString() };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location.Location = new LocationType();
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["strge_locn_produced"].ToString() };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "StorageZone" };
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialUse = new MaterialUseType() { Value = "Produced" };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Quantity = new QuantityValueType[1];
                            operation.SegmentRequirement[0].MaterialRequirement[0].Quantity[0] = new QuantityValueType();
                            operation.SegmentRequirement[0].MaterialRequirement[0].Quantity[0].QuantityString = new QuantityStringType() { Value = this.OracleReader["total_qty_produced"].ToString() };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Quantity[0].DataType = new DataTypeType() { Value = "decimal" };
                            operation.SegmentRequirement[0].MaterialRequirement[0].Quantity[0].UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" };
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialRequirementProperty = new MaterialRequirementPropertyType[1];
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialRequirementProperty[0] = new MaterialRequirementPropertyType() {
                                ID = new IdentifierType() { Value = "PROPERTY=PROCESSING_TYPE" },
                                Value = new Models.ValueType[1]
                            };
                            operation.SegmentRequirement[0].MaterialRequirement[0].MaterialRequirementProperty[0].Value[0] = new Models.ValueType() {
                                ValueString = new ValueStringType() { Value = "OUTPUT" },
                                DataType = new DataTypeType { Value = "string" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].SegmentRequirement = new SegmentRequirementType[1];
                            operation.SegmentRequirement[0].SegmentRequirement[0] = new SegmentRequirementType();
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProcessSegmentID = new ProcessSegmentIDType() {
                                Value = this.OracleReader["operation_name"].ToString()
                            };
                            operation.SegmentRequirement[0].SegmentRequirement[0].Location = new LocationType();
                            operation.SegmentRequirement[0].SegmentRequirement[0].Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["resrce_code"].ToString() };
                            operation.SegmentRequirement[0].SegmentRequirement[0].Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "ProductionUnit" };
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProductionParameter = new ProductionParameterType[1];
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProductionParameter[0] = new ProductionParameterType();
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProductionParameter[0].Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "OPERATION" },
                                Value = new Models.ValueType[2]
                            };
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProductionParameter[0].Parameter.Value[0] = new Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["opertn"].ToString() },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "ID" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            operation.SegmentRequirement[0].SegmentRequirement[0].ProductionParameter[0].Parameter.Value[1] = new Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["opertn_header"].ToString() },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "DESCRIPTION" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };

                            phaseList = new List<SegmentRequirementType>();
                            phaseCode = string.Empty;

                            operationList.Add(operation);
                        }

                        if (phaseCode != this.OracleReader["phase"].ToString())
                        {
                            if (seqList.Count > 0)
                            {
                                phase.ProductionParameter[0].Parameter.Parameter = seqList.ToArray();
                            }

                            phaseCode = this.OracleReader["phase"].ToString();

                            phase = new SegmentRequirementType() { ProcessSegmentID = new ProcessSegmentIDType() { Value = this.OracleReader["phase_name"].ToString() } };
                            phase.ProductionParameter = new ProductionParameterType[2];
                            phase.ProductionParameter[0] = new ProductionParameterType() { Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "RECIPE_STEP_PROCESS_PARAMETERS" } }
                            };
                            phase.ProductionParameter[1] = new ProductionParameterType() { Parameter = new ParameterType() {
                                ID = new IdentifierType() { Value = "PHASE" } }
                            };
                            phase.ProductionParameter[1].Parameter.Value = new Models.ValueType[2];
                            phase.ProductionParameter[1].Parameter.Value[0] = new Models.ValueType()
                            {
                                ValueString = new ValueStringType()
                                {
                                    Value = this.OracleReader["phase_mpi_v"].ToString()
                                },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "SRC_PHASE_ID" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            phase.ProductionParameter[1].Parameter.Value[1] = new Models.ValueType()
                            {
                                ValueString = new ValueStringType()
                                {
                                    Value = this.OracleReader["phase_mpi_m"].ToString()
                                },
                                DataType = new DataTypeType() { Value = "string" },
                                Key = new IdentifierType() { Value = "MATERIAL_PHASE_ID" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };

                            phase.MaterialRequirement = new MaterialRequirementType[1];
                            phase.MaterialRequirement[0] = new MaterialRequirementType();
                            phase.MaterialRequirement[0].MaterialDefinitionID = new MaterialDefinitionIDType[1];
                            phase.MaterialRequirement[0].MaterialDefinitionID[0] = new MaterialDefinitionIDType() { Value = this.OracleReader["code_consumed"].ToString() };
                            phase.MaterialRequirement[0].Location = new LocationType();
                            phase.MaterialRequirement[0].Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["plant"].ToString() };
                            phase.MaterialRequirement[0].Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                            phase.MaterialRequirement[0].Location.Location = new LocationType();
                            phase.MaterialRequirement[0].Location.Location.EquipmentID = new EquipmentIDType() { Value = this.OracleReader["strge_locn_consumed"].ToString() };
                            phase.MaterialRequirement[0].Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "StorageZone" };
                            phase.MaterialRequirement[0].MaterialUse = new MaterialUseType() { Value = "Consumed" };
                            phase.MaterialRequirement[0].Quantity = new QuantityValueType[1];
                            phase.MaterialRequirement[0].Quantity[0] = new QuantityValueType();
                            phase.MaterialRequirement[0].Quantity[0].QuantityString = new QuantityStringType() { Value = this.OracleReader["total_qty_consumed"].ToString() };
                            phase.MaterialRequirement[0].Quantity[0].DataType = new DataTypeType() { Value = "decimal" };
                            phase.MaterialRequirement[0].Quantity[0].UnitOfMeasure = new UnitOfMeasureType() { Value = "kg" };
                            phase.MaterialRequirement[0].MaterialRequirementProperty = new MaterialRequirementPropertyType[2];
                            phase.MaterialRequirement[0].MaterialRequirementProperty[0] = new MaterialRequirementPropertyType() {
                                ID = new IdentifierType() { Value = "PROPERTY=PROCESSING_TYPE" },
                                Value = new Models.ValueType[1]
                            };
                            phase.MaterialRequirement[0].MaterialRequirementProperty[0].Value[0] = new Models.ValueType() {
                                ValueString = new ValueStringType() { Value = "INPUT" },
                                DataType = new DataTypeType { Value = "string" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };
                            phase.MaterialRequirement[0].MaterialRequirementProperty[1] = new MaterialRequirementPropertyType() {
                                ID = new IdentifierType() { Value = "PROPERTY=BACKFLUSH" },
                                Value = new Models.ValueType[1]
                            };
                            phase.MaterialRequirement[0].MaterialRequirementProperty[1].Value[0] = new Models.ValueType() {
                                ValueString = new ValueStringType() { Value = this.OracleReader["bf_item"].ToString() == "N" ? "false" : "true" },
                                DataType = new DataTypeType { Value = "boolean" },
                                UnitOfMeasure = new UnitOfMeasureType()
                            };

                            seqList = new List<ParameterType>();
                            seqCode = string.Empty;
                            phaseList.Add(phase);
                        }

                        seq = new ParameterType();
                        seq.ID = new IdentifierType() { Value = this.OracleReader["code"].ToString() };
                        seq.Value = new Models.ValueType[1];
                        seq.Value[0] = new Models.ValueType() {
                            DataType = new DataTypeType() { Value = "string" },
                            Key = new IdentifierType() { Value = this.OracleReader["code"].ToString() }
                        };
                        if (!string.IsNullOrEmpty(this.OracleReader["value"].ToString()))
                            seq.Value[0].ValueString = new ValueStringType() { Value = this.OracleReader["value"].ToString() };
                        if (!string.IsNullOrEmpty(this.OracleReader["uom"].ToString()))
                            seq.Value[0].UnitOfMeasure = new UnitOfMeasureType() { Value = this.OracleReader["uom"].ToString() };
                            
                        seqList.Add(seq);

                        rowCount++;
                    }

                    if (seqList.Count > 0)
                    {
                        phase.ProductionParameter[0].Parameter.Parameter = seqList.ToArray();
                    }

                    if (phaseList.Count > 0)
                    {
                        operation.SegmentRequirement[0].SegmentRequirement[0].SegmentRequirement = phaseList.ToArray();
                    }

                    if (operationList.Count > 0)
                    {
                        result.ProductionSchedule.ProductionRequest = operationList.ToArray();
                        //result.ProductionSchedule.Any = new AnyType[1];
                    }
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public RetrieveProcessOrderListResponse RetrieveProcessOrderList(RetrieveProcessOrderListRequest request)
            {
                var result = new RetrieveProcessOrderListResponse();

                result.ProductionSchedule = new ProductionScheduleType();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.retrieve_control_recipes", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("rc_out", OracleDbType.RefCursor).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleReader = this.OracleCommand.ExecuteReader();

                    var processOrderCodes = new List<string>();
                    var plantCode = default(string);
                    var productionRequests = new List<ProductionRequestType>();

                    while (this.OracleReader.Read())
                    {
                        var processOrderCode = this.OracleReader["proc_order"].ToString();
                        plantCode = this.OracleReader["plant"].ToString();

                        var productionRequest = new ProductionRequestType()
                        {
                            ID = new IdentifierType() { Value = processOrderCode }
                        };
                        productionRequest.Location = new LocationType();
                        productionRequest.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                        productionRequest.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                        productionRequest.Location.Location = new LocationType();
                        productionRequest.Location.Location.EquipmentID = new EquipmentIDType() { Value = plantCode };
                        productionRequest.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                        productionRequests.Add(productionRequest);
                    }

                    result.ProductionSchedule.ID = new IdentifierType() { Value = "ProcessOrderList" };
                    result.ProductionSchedule.Description = new DescriptionType[1];
                    result.ProductionSchedule.Description[0] = new DescriptionType() { Value = "Process Order List" };
                    result.ProductionSchedule.Location = new LocationType();
                    result.ProductionSchedule.Location.EquipmentID = new EquipmentIDType() { Value = Properties.Settings.Default.SiteCode };
                    result.ProductionSchedule.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Site" };
                    result.ProductionSchedule.Location.Location = new LocationType();
                    result.ProductionSchedule.Location.Location.EquipmentID = new EquipmentIDType() { Value = plantCode ?? Properties.Settings.Default.PlantCode };
                    result.ProductionSchedule.Location.Location.EquipmentElementLevel = new EquipmentElementLevelType() { Value = "Area" };
                    result.ProductionSchedule.PublishedDate = new PublishedDateType() { Value = DateTime.Now };
                    result.ProductionSchedule.ProductionRequest = productionRequests.ToArray();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CreateGR(CreateGRProcessOrderRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null 
                    || request.ProductionPerformance.Location.Location == null 
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;

                if (request.ProductionPerformance.Description.Length == 0)
                    throw new Exception("Sender name must be provided");

                var senderName = request.ProductionPerformance.Description[0].Value;

                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;

                if (request.ProductionPerformance.ID == null)
                    throw new Exception("Process order code must be provided");

                var processOrderCode = request.ProductionPerformance.ID.Value;

                var batchStatus = string.Empty;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.Length != 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS") != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS").Value != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS").Value.Length != 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS").Value[0].ValueString != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS").Value[0].ValueString.Value != null)
                {
                    batchStatus = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "BATCH_STATUS").Value[0].ValueString.Value;
                }

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value == null)
                    throw new Exception("Use by date must be provided");

                var useByDate = Tools.TryDateTime(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                if (useByDate == null 
                    && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value)
                    && !string.Equals(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "N/A", StringComparison.InvariantCultureIgnoreCase))
                    throw new Exception("Use by date invalid format, expected: yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString.Value == null)
                    throw new Exception("SSCC must be provided");

                var palletCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null)
                    throw new Exception("Quantity must be a valid decimal value");

                var palletFull = "Y";

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "FULL_PALLET") != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "FULL_PALLET").Value != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "FULL_PALLET").Value.Length > 0
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "FULL_PALLET").Value[0].ValueString != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "FULL_PALLET").Value[0].ValueString.Value == "false")
                    palletFull = "N";

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString.Value == null)
                    throw new Exception("User ID must be provided");

                var userId = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString.Value;

                var lastGrFlag = "N";

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "LAST_PROCESS_ORDER_GOODS_RECEIPT") != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "LAST_PROCESS_ORDER_GOODS_RECEIPT").Value != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "LAST_PROCESS_ORDER_GOODS_RECEIPT").Value.Length > 0
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "LAST_PROCESS_ORDER_GOODS_RECEIPT").Value[0].ValueString != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "LAST_PROCESS_ORDER_GOODS_RECEIPT").Value[0].ValueString.Value == "true")
                    lastGrFlag = "Y";

                var palletType = default(string);

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE") != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE").Value != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE").Value.Length > 0
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE").Value[0].ValueString != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE").Value[0].ValueString.Value != null)
                    palletType = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_TYPE").Value[0].ValueString.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value[0].ValueString.Value == null)
                    throw new Exception("Start date must be provided");

                var startDate = Tools.TryDateTime(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value[0].ValueString.Value, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                if (startDate == null 
                    && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value[0].ValueString.Value)
                    && !string.Equals(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_START_DT").Value[0].ValueString.Value, "N/A", StringComparison.InvariantCultureIgnoreCase))
                    throw new Exception("Start date invalid format, expected: yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT") == null
                                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value == null
                                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value.Length == 0
                                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value[0].ValueString == null
                                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value[0].ValueString.Value == null)
                    throw new Exception("Start date must be provided");

                var endDate = Tools.TryDateTime(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value[0].ValueString.Value, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                if (endDate == null 
                    && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value[0].ValueString.Value)
                    && !string.Equals(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "PALLET_END_DT").Value[0].ValueString.Value, "N/A", StringComparison.InvariantCultureIgnoreCase))
                    throw new Exception("End date invalid format, expected: yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.create_gr_proc_order", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_xactn_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_plant_code", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sender_name", OracleDbType.Varchar2).Value = senderName;
                    this.OracleCommand.Parameters.Add("i_zpppi_batch", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_proc_order", OracleDbType.Int32).Value = processOrderCode;
                    this.OracleCommand.Parameters.Add("i_dispn_code", OracleDbType.Varchar2).Value = batchStatus;
                    this.OracleCommand.Parameters.Add("i_use_by_date", OracleDbType.Date).Value = useByDate ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_material_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_plt_code", OracleDbType.Varchar2).Value = palletCode;
                    this.OracleCommand.Parameters.Add("i_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_full_plt_flag", OracleDbType.Varchar2).Value = palletFull;
                    this.OracleCommand.Parameters.Add("i_user_id", OracleDbType.Varchar2).Value = userId;
                    this.OracleCommand.Parameters.Add("i_last_gr_flag", OracleDbType.Varchar2).Value = lastGrFlag;
                    this.OracleCommand.Parameters.Add("i_plt_type", OracleDbType.Varchar2).Value = palletType.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_start_prodn_date", OracleDbType.Date).Value = startDate ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_end_prodn_date", OracleDbType.Date).Value = endDate ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response Acknowledge(AcknowledgeProcessOrderRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.acknowledge_process_order", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_process_order", OracleDbType.Varchar2).Value = request.ProcessOrder;
                    this.OracleCommand.Parameters.Add("i_processed", OracleDbType.Varchar2).Value = request.Processed ? "Y" : "N";
                    this.OracleCommand.Parameters.Add("i_message", OracleDbType.Varchar2).Value = request.Message.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CancelGR(CancelGRProcessOrderRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Description.Length == 0)
                    throw new Exception("Sender name must be provided");

                var senderName = request.ProductionPerformance.Description[0].Value;
                
                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString.Value == null)
                    throw new Exception("SSCC must be provided");

                var palletCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "SSCC_NUMBER").Value[0].ValueString.Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID") == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString.Value == null)
                    throw new Exception("User ID must be provided");

                var userId = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].ProductionData.FirstOrDefault(x => x.ID.Value == "USER_ID").Value[0].ValueString.Value;
                
                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.cancel_gr_proc_order", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_xactn_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_sender_name", OracleDbType.Varchar2).Value = senderName;
                    this.OracleCommand.Parameters.Add("i_plt_code", OracleDbType.Varchar2).Value = palletCode;
                    this.OracleCommand.Parameters.Add("i_user_id", OracleDbType.Varchar2).Value = userId;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CreateConsumption(CreateConsumptionRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null
                    || request.ProductionPerformance.Location.Location == null
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;
                
                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;

                if (request.ProductionPerformance.ID == null)
                    throw new Exception("Process order code must be provided");

                var processOrderCode = request.ProductionPerformance.ID.Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value))
                    throw new Exception("Quantity must be a valid decimal value");

                var transactionId = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now);
                if (request.ProductionPerformance.Any.Length > 0 && request.ProductionPerformance.Any[0].Any.Length > 0)
                {
                    var anyText = request.ProductionPerformance.Any[0].Any[0].InnerText;
                    if (anyText.IndexOf("EVENT_ID=") > -1)
                        transactionId = anyText.Replace("EVENT_ID=", string.Empty);
                }

                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.create_consumption", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_trans_id", OracleDbType.Int64).Value = transactionId;
                    this.OracleCommand.Parameters.Add("i_xactn_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_plant_code", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_proc_order", OracleDbType.Int32).Value = processOrderCode;
                    this.OracleCommand.Parameters.Add("i_material_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_batch_code", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CreateStockAdjustment(CreateStockAdjustmentRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null
                    || request.ProductionPerformance.Location.Location == null
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;
                
                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;

                if (request.ProductionPerformance.ID == null)
                    throw new Exception("ProductionPerformance ID must be provided");

                var id = request.ProductionPerformance.ID.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value == null)
                    throw new Exception("Storage location must be provided");

                var storageLocationCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null)
                    throw new Exception("Quantity must be a valid decimal value");
                
                var isReversal = false;
                if (quantity.HasValue && quantity.Value < 0)
                {
                    isReversal = true;
                    quantity = -quantity;
                }

                var uom = default(string);
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value != null)
                    uom = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value;

                var batchExpiry = default(DateTime?);
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE") != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value.Length > 0
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value != null)
                {
                    batchExpiry = Tools.TryDateTime(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                    if (!batchExpiry.HasValue 
                        && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value)
                        && !string.Equals(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "N/A", StringComparison.InvariantCultureIgnoreCase))
                        throw new Exception("Expiry date invalid format, expected: yyyy-MM-ddTHH:mm:ss.ffffffzzz");
                }
                
                #endregion
                
                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.load_stock_adjustment", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_stock_adjmnt_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_cnn", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_whse_ref", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_plant_code_1", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sto_locn_code_1", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_plant_code_2", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sto_locn_code_2", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_matl_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_mvmnt_code", OracleDbType.Varchar2).Value = id;
                    this.OracleCommand.Parameters.Add("i_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_uom", OracleDbType.Varchar2).Value = uom ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_reversal", OracleDbType.Char).Value = isReversal ? 'Y' : (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stk_status_iss", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stk_status_rec", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_batch_code", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_batch_expiry", OracleDbType.Date).Value = batchExpiry ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_vndr_batch_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_vndr_batch_exp", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_batch_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_batch_exp", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_vndr_batch_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_vndr_batch_exp", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_manufctr_date", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_manufctr_date", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_matl_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_reasn_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_cost_centre", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stock_ind", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_vendor_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_po_doc_num", OracleDbType.Int32).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_po_doc_line_num", OracleDbType.Int32).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response LoadStockBalance(LoadStockBalanceRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null
                    || request.ProductionPerformance.Location.Location == null
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value == null)
                    throw new Exception("Storage location must be provided");

                var storageLocationCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null)
                    throw new Exception("Quantity must be a valid decimal value");

                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.load_stock_balance", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_stock_bal_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_plant_code", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sto_locn_code", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_matl_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_batch_code", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_stock_ind", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stock_status", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stock_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CreateBlend(CreateBlendRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null
                    || request.ProductionPerformance.Location.Location == null
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;

                if (request.ProductionPerformance.ID == null)
                    throw new Exception("ProductionPerformance ID must be provided");

                var id = request.ProductionPerformance.ID.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value == null)
                    throw new Exception("Storage location must be provided");

                var storageLocationCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null)
                    throw new Exception("Quantity must be a valid decimal value");

                var isReversal = false;
                if (quantity.HasValue && quantity.Value < 0)
                {
                    isReversal = true;
                    quantity = -quantity;
                }

                var uom = default(string);
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value != null)
                    uom = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value;

                var batchExpiry = default(DateTime?);
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE") != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value.Length > 0
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value != null)
                {
                    batchExpiry = Tools.TryDateTime(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "yyyy-MM-ddTHH:mm:ss.ffffffzzz");

                    if (!batchExpiry.HasValue
                        && !string.IsNullOrEmpty(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value)
                        && !string.Equals(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "EXPIRY_DATE").Value[0].ValueString.Value, "N/A", StringComparison.InvariantCultureIgnoreCase))
                        throw new Exception("Expiry date invalid format, expected: yyyy-MM-ddTHH:mm:ss.ffffffzzz");
                }

                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.create_blend", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_stock_adjmnt_date", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("i_cnn", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_whse_ref", OracleDbType.Varchar2).Value = id;
                    this.OracleCommand.Parameters.Add("i_plant_code_1", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sto_locn_code_1", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_plant_code_2", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_sto_locn_code_2", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_matl_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_mvmnt_code", OracleDbType.Varchar2).Value = id;
                    this.OracleCommand.Parameters.Add("i_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_uom", OracleDbType.Varchar2).Value = uom ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_reversal", OracleDbType.Char).Value = isReversal ? 'Y' : (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stk_status_iss", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stk_status_rec", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_batch_code", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_batch_expiry", OracleDbType.Date).Value = batchExpiry ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_reasn_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_cost_centre", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_stock_ind", OracleDbType.Char).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_vndr_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_po_doc_num", OracleDbType.Int32).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_po_doc_line_num", OracleDbType.Int32).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_batch_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_manufctr_date", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_batch_exp", OracleDbType.Date).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_rec_vndr_batch_code", OracleDbType.Varchar2).Value = DBNull.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response CreateScrapMaterial(CreateScrapMaterialRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");

                if (request.ProductionPerformance.PublishedDate == null)
                    throw new Exception("PublishedDate must be provided");

                var transactionDate = request.ProductionPerformance.PublishedDate.Value;

                if (request.ProductionPerformance.Location == null
                    || request.ProductionPerformance.Location.Location == null
                    || request.ProductionPerformance.Location.Location.EquipmentID == null)
                    throw new Exception("Plant code must be provided");

                var plantCode = request.ProductionPerformance.Location.Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value == null)
                    throw new Exception("Batch code must be provided");

                var batchCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialLotID[0].Value;
                
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value == null)
                    throw new Exception("Storage location must be provided");

                var storageLocationCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Location.EquipmentID.Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value == null)
                    throw new Exception("Material code must be provided");

                var materialCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialDefinitionID[0].Value;

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity.Length == 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString == null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value == null)
                    throw new Exception("Quantity must be provided");

                var quantity = Tools.TryDecimal(request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].QuantityString.Value);

                if (quantity == null)
                    throw new Exception("Quantity must be a valid decimal value");
                
                var uom = default(string);
                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure != null
                    && request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value != null)
                    uom = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].Quantity[0].UnitOfMeasure.Value;

                var reasonCode = default(string);

                if (request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.Length != 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE") != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE").Value != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE").Value.Length != 0
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE").Value[0].ValueString != null
                    || request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE").Value[0].ValueString.Value != null)
                {
                    reasonCode = request.ProductionPerformance.ProductionResponse[0].SegmentResponse[0].MaterialActual[0].MaterialActualProperty.FirstOrDefault(x => x.ID.Value == "REASON_CODE").Value[0].ValueString.Value;
                }
                
                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.create_scrap_material", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_matl_code", OracleDbType.Varchar2).Value = materialCode;
                    this.OracleCommand.Parameters.Add("i_qty", OracleDbType.Decimal).Value = quantity ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_uom", OracleDbType.Varchar2).Value = uom ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_plant_code", OracleDbType.Varchar2).Value = plantCode;
                    this.OracleCommand.Parameters.Add("i_batch_code", OracleDbType.Varchar2).Value = batchCode;
                    this.OracleCommand.Parameters.Add("i_storage_locn", OracleDbType.Varchar2).Value = storageLocationCode;
                    this.OracleCommand.Parameters.Add("i_reasn_code", OracleDbType.Varchar2).Value = reasonCode ?? (object)DBNull.Value;
                    this.OracleCommand.Parameters.Add("i_event_datime", OracleDbType.Date).Value = transactionDate;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
                }
                else
                {
                    throw new Exception("SQL Server not implemented");
                }

                return result;
            }

            public Response Start(StartProcessOrderRequest request)
            {
                var result = new Response();
                result.Result = new ServiceResultType();

                #region validation

                if (request.ProductionPerformance == null)
                    throw new Exception("ProductionPerformance data must be provided");
                
                if (request.ProductionPerformance.ID == null || request.ProductionPerformance.ID.Value == null)
                    throw new Exception("Process order code must be provided");

                if (request.ProductionPerformance.ProductionScheduleID == null || request.ProductionPerformance.ProductionScheduleID.Value == null)
                    throw new Exception("FLOC order code must be provided");

                #endregion

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.StoredProcedure;
                    this.OracleCommand.CommandText = string.Format("{0}.{1}.start_proc_order", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("i_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("i_proc_order", OracleDbType.Varchar2).Value = request.ProductionPerformance.ID.Value;
                    this.OracleCommand.Parameters.Add("i_floc_code", OracleDbType.Varchar2).Value = request.ProductionPerformance.ProductionScheduleID.Value;
                    this.OracleCommand.Parameters.Add("o_result", OracleDbType.Int32).Direction = ParameterDirection.Output;
                    this.OracleCommand.Parameters.Add("o_result_msg", OracleDbType.Varchar2, 2000).Direction = ParameterDirection.Output;
                    this.Log();
                    this.OracleCommand.ExecuteNonQuery();

                    result.Result.Message = this.OracleCommand.Parameters["o_result_msg"].Value.ToString();
                    result.Result.Result = (Result)((OracleDecimal)this.OracleCommand.Parameters["o_result"].Value).ToInt32();
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