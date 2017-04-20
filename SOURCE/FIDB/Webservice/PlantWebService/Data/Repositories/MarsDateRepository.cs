﻿using System;
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
    public class MarsDateRepository : BaseRepository, IMarsDateRepository
    {
        private const string CacheKey = "MarsDate";

        #region constructor

        public MarsDateRepository(IDataContext dataContext)
            : base(dataContext)
        {
        }

        #endregion

        #region interface methods

        public RetrieveMarsCalendarResponse RetrieveMarsCalendar(RetrieveMarsCalendarRequest request)
        {
            using (var dal = new DataAccess(this.DataContext.UnitOfWork))
                return dal.RetrieveMarsCalendar(request);
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
            
            public RetrieveMarsCalendarResponse RetrieveMarsCalendar(RetrieveMarsCalendarRequest request)
            {
                var result = new RetrieveMarsCalendarResponse();
                var dataset = new DataSet();

                if (Properties.Settings.Default.UseOracle)
                {
                    this.OracleCommand = new OracleCommand();
                    this.OracleCommand.Connection = this.OracleConnection;
                    this.OracleCommand.Transaction = this.OracleTransaction;
                    this.OracleCommand.CommandType = CommandType.Text;
                    this.OracleCommand.CommandText = string.Format("select * from table({0}.{1}.retrieve_mars_date(:par_mode, :par_system_key, :par_cal_dte, :par_hist_yrs))", Properties.Settings.Default.OracleAppSchema, Properties.Settings.Default.OracleAppPackage);
                    this.OracleCommand.Parameters.Add("par_system_key", OracleDbType.Varchar2).Value = request.SystemKey.ToSqlNullable();
                    this.OracleCommand.Parameters.Add("par_mode", OracleDbType.Int32).Value = (int)request.Mode;
                    this.OracleCommand.Parameters.Add("par_cal_dte", OracleDbType.Date).Value = request.Date.ToSqlNullable<DateTime>();
                    this.OracleCommand.Parameters.Add("par_hist_yrs", OracleDbType.Int32).Value = request.HistoryYears;

                    this.Log();
                    this.OracleAdapter = new OracleDataAdapter(this.OracleCommand);
                    this.OracleAdapter.Fill(dataset);

                    var rowCount = 0;
                    
                    foreach (DataRow row in dataset.Tables[0].Rows)
                    {
                        if (rowCount == 0)
                        {
                            result.ProductionSchedule = new ProductionScheduleType();
                            result.ProductionSchedule.ID = new IdentifierType() { Value = string.Format("{0:yyyyMMddHHmmss}", DateTime.Now) };
                            result.ProductionSchedule.Description = new DescriptionType[1];
                            result.ProductionSchedule.Description[0] = new DescriptionType() { Value = "Mars Date" };
                            result.ProductionSchedule.ProductionRequest = new ProductionRequestType[1];
                            result.ProductionSchedule.ProductionRequest[0] = new ProductionRequestType();
                            result.ProductionSchedule.ProductionRequest[0].SegmentRequirement = new SegmentRequirementType[1];
                            result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0] = new SegmentRequirementType();
                            result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter = new ProductionParameterType[dataset.Tables[0].Rows.Count];
                        }

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount] = new ProductionParameterType();
                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter = new ParameterType();
                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.ID = new IdentifierType() { Value = "MarsDateData" };
                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value = new Models.ValueType[16];

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[0] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "datetime" },
                            Key = new IdentifierType() { Value = "CalendarDate" },
                            ValueString = new ValueStringType() { Value = string.Format("{0:o}", Convert.ToDateTime(row["calendar_date"])) }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[1] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "Year" },
                            ValueString = new ValueStringType() { Value = row["year_num"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[2] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "Month" },
                            ValueString = new ValueStringType() { Value = row["month_num"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[3] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "PeriodNumber" },
                            ValueString = new ValueStringType() { Value = row["period_num"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[4] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MonthDayNumber" },
                            ValueString = new ValueStringType() { Value = row["month_day_num"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[5] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "PeriodDayNumber" },
                            ValueString = new ValueStringType() { Value = row["period_day_num"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[6] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "JulianDate" },
                            ValueString = new ValueStringType() { Value = row["julian_date"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[7] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MarsPeriod" },
                            ValueString = new ValueStringType() { Value = row["mars_period"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[8] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "YearToDayDate" },
                            ValueString = new ValueStringType() { Value = row["yyyymmdd_date"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[9] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "YearToQuarterDate" },
                            ValueString = new ValueStringType() { Value = row["yyyyqq_date"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[10] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MarsYearToQuarterDate" },
                            ValueString = new ValueStringType() { Value = row["mars_yyyyqq_date"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[11] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MarsWeek" },
                            ValueString = new ValueStringType() { Value = row["mars_week"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[12] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MarsYearPeriodDay" },
                            ValueString = new ValueStringType() { Value = row["mars_yyyyppdd"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[13] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "MarsYear" },
                            ValueString = new ValueStringType() { Value = row["mars_year"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[14] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "WmcDate" },
                            ValueString = new ValueStringType() { Value = row["mwc_date"].ToString() }
                        };

                        result.ProductionSchedule.ProductionRequest[0].SegmentRequirement[0].ProductionParameter[rowCount].Parameter.Value[15] = new Models.ValueType()
                        {
                            DataType = new DataTypeType() { Value = "integer" },
                            Key = new IdentifierType() { Value = "PeriodBusinessDayNumber" },
                            ValueString = new ValueStringType() { Value = row["period_bus_day_num"].ToString() }
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