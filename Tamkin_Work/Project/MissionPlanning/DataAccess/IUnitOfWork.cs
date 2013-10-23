using System;

namespace DataAccess
{
    public interface IUnitOfWork : IDisposable
    {
        ByteknightEntitiesEx UnityDbContext { get; }
        int SaveChanges();
    }
}
