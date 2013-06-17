using System;
using System.Linq;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories
{
    public interface IRepositoryContainer : IDisposable
    {
        Access Access { get; set; }
        Connection Connection { get; set; }
        User User { get; set; }

        void Dispose();

        IConnectionRepository ConnectionRepository { get; }
        IInterfaceRepository InterfaceRepository { get; }
        IInterfaceGroupRepository InterfaceGroupRepository { get; }
        IInterfaceGroupJoinRepository InterfaceGroupJoinRepository { get; }
        IInterfaceOptionRepository InterfaceOptionRepository { get; }
        IUserRepository UserRepository { get; }
        IUploadRepository UploadRepository { get; }
        ILicsRepository LicsRepository { get; }
        IIcsStatusRepository IcsStatusRepository { get; }
        IMonitorRepository MonitorRepository { get; }
    }
}
