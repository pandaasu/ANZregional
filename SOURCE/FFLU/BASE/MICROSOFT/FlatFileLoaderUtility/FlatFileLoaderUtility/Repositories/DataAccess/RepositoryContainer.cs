using System;
using System.Linq;
using FlatFileLoaderUtility.Models.Shared;
using FlatFileLoaderUtility.Models;

namespace FlatFileLoaderUtility.Repositories.DataAccess
{
    public class RepositoryContainer : IRepositoryContainer
    {
        // This is the repository container for the application. All data access goes via the repositories
        // through this container. It allows for connection sharing to the database. ie, the base DataAccess
        // class opens the connection and creates the transaction, all subsequently created DataAccess classes
        // will then inherit from the base DataAccess class and use it's connection / transaction.
        // When disposing, the base DataAccess is disposed, which closes the connection and commits (or rolls back
        // in the case of unit testing) the transaction.

        private Access mAccess;
        public Access Access 
        {
            get
            {
                return this.mAccess;
            }
            set
            {
                // Whenever the access on the controller is updated, it needs to copy that access down
                // to the DataAccess layer, so that the Username will be accessible directly from the DAL
                // when updating data.
                this.mAccess = value;
                if (this.DataAccess != null)
                    this.DataAccess.Access = value;
            }
        }
        public DataAccess DataAccess { get; set; }
        private Connection mConnection;
        public Connection Connection
        {
            get
            {
                return mConnection;
            }
            set
            {
                if (this.DataAccess == null)
                    this.DataAccess = new DataAccess(value);
                this.mConnection = value;
            }
        }
        public User User { get; set; }

        public RepositoryContainer()
        {
        }

        public void Dispose()
        {
            if (this.DataAccess != null)
                this.DataAccess.Dispose();
        }


        private IConnectionRepository mConnectionRepository = null;
        public IConnectionRepository ConnectionRepository
        {
            get
            {
                if (this.mConnectionRepository == null)
                    this.mConnectionRepository = new ConnectionRepository(this);
                return this.mConnectionRepository;
            }
        }

        private IInterfaceRepository mInterfaceRepository = null;
        public IInterfaceRepository InterfaceRepository
        {
            get
            {
                if (this.mInterfaceRepository == null)
                    this.mInterfaceRepository = new InterfaceRepository(this);
                return this.mInterfaceRepository;
            }
        }

        private IInterfaceGroupRepository mInterfaceGroupRepository = null;
        public IInterfaceGroupRepository InterfaceGroupRepository
        {
            get
            {
                if (this.mInterfaceGroupRepository == null)
                    this.mInterfaceGroupRepository = new InterfaceGroupRepository(this);
                return this.mInterfaceGroupRepository;
            }
        }

        private IInterfaceGroupJoinRepository mInterfaceGroupJoinRepository = null;
        public IInterfaceGroupJoinRepository InterfaceGroupJoinRepository
        {
            get
            {
                if (this.mInterfaceGroupJoinRepository == null)
                    this.mInterfaceGroupJoinRepository = new InterfaceGroupJoinRepository(this);
                return this.mInterfaceGroupJoinRepository;
            }
        }

        private IInterfaceOptionRepository mInterfaceOptionRepository = null;
        public IInterfaceOptionRepository InterfaceOptionRepository
        {
            get
            {
                if (this.mInterfaceOptionRepository == null)
                    this.mInterfaceOptionRepository = new InterfaceOptionRepository(this);
                return this.mInterfaceOptionRepository;
            }
        }

        private IUserRepository mUserRepository = null;
        public IUserRepository UserRepository
        {
            get
            {
                if (this.mUserRepository == null)
                    this.mUserRepository = new UserRepository(this);
                return this.mUserRepository;
            }
        }

        private IUploadRepository mUploadRepository = null;
        public IUploadRepository UploadRepository
        {
            get
            {
                if (this.mUploadRepository == null)
                    this.mUploadRepository = new UploadRepository(this);
                return this.mUploadRepository;
            }
        }

        private ILicsRepository mLicsRepository = null;
        public ILicsRepository LicsRepository
        {
            get
            {
                if (this.mLicsRepository == null)
                    this.mLicsRepository = new LicsRepository(this);
                return this.mLicsRepository;
            }
        }

        private IIcsStatusRepository mIcsStatusRepository = null;
        public IIcsStatusRepository IcsStatusRepository
        {
            get
            {
                if (this.mIcsStatusRepository == null)
                    this.mIcsStatusRepository = new IcsStatusRepository(this);
                return this.mIcsStatusRepository;
            }
        }

        private IMonitorRepository mMonitorRepository = null;
        public IMonitorRepository MonitorRepository
        {
            get
            {
                if (this.mMonitorRepository == null)
                    this.mMonitorRepository = new MonitorRepository(this);
                return this.mMonitorRepository;
            }
        }
    }
}