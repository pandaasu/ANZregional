using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.IO;
using SevenZip.Compression.LZMA;

namespace SevenZip
{
    public class LzmaHelper
    {

        static readonly CoderPropID[] propIDs =
        {
            CoderPropID.DictionarySize,
            CoderPropID.PosStateBits,
            CoderPropID.LitContextBits,
            CoderPropID.LitPosBits,
            CoderPropID.Algorithm,
            CoderPropID.NumFastBytes,
            CoderPropID.MatchFinder,
            CoderPropID.EndMarker
        };

        public static byte[] Compress(byte[] inputBytes)
        {
            var dictionary = 1 << 23;
            var eos = false;
            object[] properties = 
			{
				dictionary,
				2,
				3,
				0,
				2,
				128,
				"bt4",
				eos
			};

            var inStream = new MemoryStream(inputBytes);
            var outStream = new MemoryStream();
            var encoder = new Encoder();
            encoder.SetCoderProperties(propIDs, properties);
            encoder.WriteCoderProperties(outStream);
            var fileSize = inStream.Length;
            for (int i = 0; i < 8; i++)
                outStream.WriteByte((Byte)(fileSize >> (8 * i)));
            encoder.Code(inStream, outStream, -1, -1, null);
            return outStream.ToArray();
        }

        public static byte[] Decompress(byte[] inputBytes)
        {
            var newInStream = new MemoryStream(inputBytes);
            var newOutStream = new MemoryStream();
            var decoder = new Decoder();

            newInStream.Seek(0, 0);

            var properties2 = new byte[5];
            if (newInStream.Read(properties2, 0, 5) != 5)
                throw (new Exception("input .lzma is too short"));
            long outSize = 0;
            for (int i = 0; i < 8; i++)
            {
                int v = newInStream.ReadByte();
                if (v < 0)
                    throw (new Exception("Can't Read 1"));
                outSize |= ((long)(byte)v) << (8 * i);
            }
            decoder.SetDecoderProperties(properties2);

            var compressedSize = newInStream.Length - newInStream.Position;
            decoder.Code(newInStream, newOutStream, compressedSize, outSize, null);

            return newOutStream.ToArray();
        }
    }
}