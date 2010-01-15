using System;
using System.Collections.Generic;
using System.Text;
using System.Collections;

namespace ICS.LADS.DataReader
{
    public delegate void UpdateProgressDelegate(EventArgs e);

    #region StructureLine

    public class StructureLine
    {
        string _table;
        string _field;
        int _length;

        public StructureLine()
        {
            this._table = string.Empty;
            this._field = string.Empty;
            this._length = int.MinValue;
        }

        public string Table
        {
            get
            {
                return this._table;
            }
            set
            {
                this._table = value;
            }
        }

        public string Field
        {
            get
            {
                return this._field;
            }
            set
            {
                this._field = value;
            }
        }

        public int Length
        {
            get
            {
                return this._length;
            }
            set
            {
                this._length = value;
            }
        }
    }

    #endregion

    public class ResultBuilder
    {
        public event EventHandler UpdateProgress;
        public event EventHandler StructureComplete;

        private string[] _structure;
        private string[] _contents;

        private ArrayList _result;
        private ArrayList _tableList;

        public ResultBuilder(string[] structure, string[] contents)
        {
            this._structure = structure;
            this._contents = contents;

            this._result = new ArrayList();
            this._tableList = new ArrayList();
        }

        public ArrayList BuildResultList()
        {
            this.CreateStructure();
            this.TriggerStructureComplete();
            this.ProcessContents();

            return this._result;
        }

        private void CreateStructure()
        {
            LadsTable currTable = null;
            StructureLine structLine = null;

            string currTableName = string.Empty;
            int position = 0;

            foreach (string line in this._structure)
            {
                structLine = this.CreateField(line);

                if (structLine == null)
                {
                    continue;
                }

                if (currTableName == string.Empty || string.Compare(currTableName, structLine.Table) != 0)
                {
                    if (currTable != null)
                    {
                        this._tableList.Add(currTable);
                        position = 0;
                    }

                    currTableName = structLine.Table;
                    currTable = new LadsTable(currTableName);
                }

                currTable.AddField(new LadsField(structLine, position++));
                this.TriggerUpdateProgress();
            }

            this._tableList.Add(currTable);
            this._tableList.Sort();
        }

        private void ProcessContents()
        {
            LadsTable currentTable = null;
            LineResult lineResult = null;

            string contentTableType = string.Empty;
            int tableIndex = 0;
            int counter = 0;

            foreach (string line in this._contents)
            {
                contentTableType = Utilities.GetContentTableType(line);
                tableIndex = this._tableList.BinarySearch(contentTableType);

                if (tableIndex >= 0)
                {
                    currentTable = (LadsTable)this._tableList[tableIndex];
                    lineResult = this.BuildLineResult(currentTable, line, counter++);
                }
                else
                {
                    lineResult = new LineResult(LadsTable.Empty, counter++);
                    lineResult.AddResultObject(ResultObject.Empty);
                }

                this._result.Add(lineResult);
                this.TriggerUpdateProgress();
            }
        }

        private LineResult BuildLineResult(LadsTable table, string line, int counter)
        {
            LineResult result = new LineResult(table, counter);
            ResultObject fieldResult = null;           

            int currIndex = 0;
            string strValue = string.Empty;

            foreach (LadsField field in table.Fields)
            {
                fieldResult = new ResultObject();
                fieldResult.Table = table.Name;
                fieldResult.Field = field.Name;

                if (currIndex + field.Length <= line.Length)
                {
                    strValue = line.Substring(currIndex, field.Length);
                    currIndex += field.Length;
                }
                else
                {
                    strValue = "Index Out of Range";
                }
                
                fieldResult.Value = strValue;
                result.AddResultObject(fieldResult);
            }

            return result;
        }

        private StructureLine CreateField(string line)
        {
            StructureLine result = null;
            string[] splitText = null;

            splitText = Utilities.SplitText(line);

            if (splitText != null && splitText.Length == 3)
            {
                result = new StructureLine();

                result.Table = Utilities.GetStringInQuotes(splitText[0]);
                result.Field = Utilities.GetStringInQuotes(splitText[1]);
                result.Length = Utilities.GetLength(splitText[2]);
            }

            return result;
        }

        private void TriggerUpdateProgress()
        {
            if (UpdateProgress != null)
            {
                UpdateProgress(this, EventArgs.Empty);
            }
        }

        private void TriggerStructureComplete()
        {
            if (StructureComplete != null)
            {
                StructureComplete(this, EventArgs.Empty);
            }
        }
    }

    public class LadsTable : IComparable
    {
        private string _name;
        private ArrayList _fields;

        public static LadsTable Empty;

        public LadsTable(string name)
        {
            this._name = name;
            this._fields = new ArrayList();        
        }

        static LadsTable()
        {
            if (Empty == null)
            {
                Empty = new LadsTable("NA");
            }
        }

        public string Name
        {
            get
            {
                return this._name;
            }
        }

        public ArrayList Fields
        {
            get
            {
                return this._fields;
            }
        }

        public void AddField(LadsField field)
        {
            this._fields.Add(field);
        }

        #region IComparable Members

        public int CompareTo(object obj)
        {
            int result = -1;

            if (obj is LadsTable)
            {
                result = string.Compare(this._name, (obj as LadsTable).Name);
            }
            else if (obj is string)
            {
                result = string.Compare(this._name, (string)obj);
            }

            return result;
        }

        #endregion
    }

    public class LadsField : IComparable
    {
        private string _name;
        private int _length;
        private int _position;

        public LadsField(StructureLine line, int position)
        {
            this._name = line.Field;
            this._length = line.Length;
            this._position = position;
        }

        public string Name
        {
            get
            {
                return this._name;
            }
        }

        public int Length
        {
            get
            {
                return this._length;
            }
        }

        public int Position
        {
            get
            {
                return this._position;
            }
        }

        #region IComparable Members

        public int CompareTo(object obj)
        {
            int result = -1;

            if (obj is LadsField)
            {
                result = this._position.CompareTo((obj as LadsField).Position);
            }
            else if (obj is int)
            {
                result = this._position.CompareTo((int)obj);
            }

            return result;
        }

        #endregion
    }

    public class ResultObject
    {
        private string _table;
        private string _field;
        private string _value;

        public static ResultObject Empty;

        public ResultObject()
        {
            this._table = string.Empty;
            this._field = string.Empty;
            this._value = string.Empty;
        }

        static ResultObject()
        {
            if (Empty == null)
            {
                Empty = new ResultObject();
                Empty.Table = "N/A";
                Empty.Field = "Not Found";
                Empty.Value = "No Value";
            }
        }

        public string Table
        {
            get
            {
                return this._table;
            }
            set
            {
                this._table = value;
            }
        }

        public string Field
        {
            get
            {
                return this._field;
            }
            set
            {
                this._field = value;
            }
        }

        public string Value
        {
            get
            {
                return this._value;
            }
            set
            {
                this._value = value;
            }
        }

        public override string ToString()
        {
            return string.Format(@"[{0}] - {1}: {2}", this._table
                , this._field
                , this._value);
        }
    }

    public class LineResult : IComparable
    {
        private ArrayList _resultList;
        private LadsTable _table;
        private int _index;        

        public LineResult(LadsTable table, int index)
        {
            this._table = table;
            this._index = index;
            this._resultList = new ArrayList();
        }

        public LadsTable Table
        {
            get
            {
                return this._table;
            }
        }

        public int Index
        {
            get
            {
                return this._index;
            }
        }

        public void AddResultObject(ResultObject result)
        {
            this._resultList.Add(result);
        }

        public override string ToString()
        {
            StringBuilder result = new StringBuilder();

            if (this._resultList != null && this._resultList.Count > 0)
            {
                foreach (ResultObject line in this._resultList)
                {
                    result.AppendLine(line.ToString());
                }
            }

            return result.ToString();
        }

        #region IComparable Members

        public int CompareTo(object obj)
        {
            int result = -1;

            if (obj is LineResult)
            {
                result = this._index.CompareTo((obj as LineResult).Index);
            }
            else if (obj is LadsTable)
            {
                result = this._table.CompareTo((obj as LadsTable).Name);
            }
            else if (obj is int)
            {
                result = this._index.CompareTo((int)obj);
            }
            else if (obj is string)
            {
                result = string.Compare(this._table.Name, (string)obj, true);
            }

            return result;
        }

        #endregion
    }
}
