using System;
using System.Linq;

namespace DataAccess
{
    public class ByteknightEntitiesEx : ByteKnightContext
    {
        #region Query execution helper methods
        public IQueryable<TReturnType> Query<TReturnType>(Func<ByteknightEntitiesEx, IQueryable<TReturnType>> query)
        {
            return query(this);
        }
        public IQueryable<TReturnType> Query<TArg0, TReturnType>(Func<ByteknightEntitiesEx, TArg0, IQueryable<TReturnType>> query, TArg0 arg0)
        {
            return query(this, arg0);
        }

        public IQueryable<TReturnType> Query<TArg0, TArg1, TReturnType>(Func<ByteknightEntitiesEx, TArg0, TArg1, IQueryable<TReturnType>> query, TArg0 arg0, TArg1 arg1)
        {
            return query(this, arg0, arg1);
        }

        public IQueryable<TReturnType> Query<TArg0, TArg1, TArg2, TReturnType>(Func<ByteknightEntitiesEx, TArg0, TArg1, TArg2, IQueryable<TReturnType>> query, TArg0 arg0, TArg1 arg1, TArg2 arg2)
        {
            return query(this, arg0, arg1, arg2);
        }
        #endregion
    }
}
