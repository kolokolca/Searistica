using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;

namespace DataAccess
{
    public class UnitOfWork : IUnitOfWork
    {
        private readonly ByteknightEntitiesEx _context;

        public UnitOfWork()
        {
            _context = new ByteknightEntitiesEx();
        }
        public void Dispose()
        {
            _context.Dispose();
        }

        public ByteknightEntitiesEx UnityDbContext
        {
            get { return _context; }
        }

        public int SaveChanges()
        {
            return _context.SaveChanges();
        }
    }
}
