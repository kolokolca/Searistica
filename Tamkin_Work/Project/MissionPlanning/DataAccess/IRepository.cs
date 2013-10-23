using System;
using System.Collections.Generic;
using System.Linq;
using System.Linq.Expressions;
using System.Text;

namespace DataAccess
{
    public interface IRepository<TObject> where TObject : class
    {
        IQueryable<TObject> All();

        IQueryable<TObject> All(int top);

        IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate);

        IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate, int top);

        bool Contains(Expression<Func<TObject, bool>> predicate);

        TObject Find(Expression<Func<TObject, bool>> predicate);

        TObject Find(Expression<Func<TObject, bool>> predicate, string include);

        TObject Single(Expression<Func<TObject, bool>> where);

        void Create(TObject t);

        int Delete(TObject t);

        int Delete(Expression<Func<TObject, bool>> predicate);

        int Update(TObject t);

        int Count { get; }

        void Insert(TObject t);

        void Add(TObject t);

        void Remove(TObject t);

        void RemoveAll(Expression<Func<TObject, bool>> predicate);

        void Edit(TObject t);

        TReturn Max<TReturn>(Expression<Func<TObject, TReturn>> predicate, Expression<Func<TObject, bool>> clause);
        
        TReturn Max<TReturn>(Expression<Func<TObject, TReturn>> predicate);
        
        IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate, int top, string include);
        
        int CountOfEntity(Expression<Func<TObject, bool>> predicate);
        
        List<T> ExecuteCommand<T>(string sqlCommand);

        int ExecuteCommandDirectly(string sqlCommand);
    }
}
