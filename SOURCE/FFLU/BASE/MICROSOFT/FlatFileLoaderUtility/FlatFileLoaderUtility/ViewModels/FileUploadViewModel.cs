using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using System.ComponentModel.DataAnnotations;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.ViewModels
{
    public class FileUploadViewModel
    {
        public IEnumerable<SelectListItem> InterfaceGroups { get; set; }
        public IEnumerable<SelectListItem> Interfaces { get; set; }
        public Status Status { get; set; }
        public string InterfaceName { get; set; }
        public string InterfaceCode { get; set; }
        public string FileName { get; set; }
        public int LastSegment { get; set; }
        public int ReceivedStringLength { get; set; }
        public long FileSize { get; set; }
        public int SegmentBytes { get; set; }
        public int MinCompressionBytes { get; set; }
        public int MaxCompressionBytes { get; set; }
        public int StartCompressionBytes { get; set; }
        public int MaxCompressedSegmentsPerRequest { get; set; }
        public int CompressionStep { get; set; }
        
        public FileUploadViewModel()
        {
            this.InterfaceName = string.Empty;
            this.InterfaceCode = string.Empty;
            this.FileName = string.Empty;
            this.LastSegment = 0;
            this.FileSize = 0;
            this.InterfaceGroups = new List<SelectListItem>();
            this.Interfaces = new List<SelectListItem>();
            this.SegmentBytes = Properties.Settings.Default.SegmentBytes;
            this.MinCompressionBytes = Properties.Settings.Default.MinCompressionBytes;
            this.MaxCompressionBytes = Properties.Settings.Default.MaxCompressionBytes;
            this.StartCompressionBytes = Properties.Settings.Default.StartCompressionBytes;
            this.MaxCompressedSegmentsPerRequest = Properties.Settings.Default.MaxCompressedSegmentsPerRequest;
            this.CompressionStep = Properties.Settings.Default.CompressionStep;
        }
    }
}