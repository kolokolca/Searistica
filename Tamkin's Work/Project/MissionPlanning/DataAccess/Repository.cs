using System;
using System.Collections.Generic;
using System.Data.Objects;
using System.Linq;
using System.Linq.Expressions;
using System.Text;

namespace DataAccess
{
    public class Repository<TObject> : IRepository<TObject> where TObject : class
    {
        protected ByteknightEntitiesEx Context = null;

        public Repository(IUnitOfWork unitOfWork)
        {
            Context = unitOfWork.UnityDbContext;
        }

        protected ObjectSet<TObject> FullDataSet
        {
            get
            {
                return Context.CreateObjectSet<TObject>();
            }
        }

        #region Implementation of IRepository<TObject>

        public IQueryable<TObject> All()
        {
            return FullDataSet;
        }

        public IQueryable<TObject> All(int top)
        {
            return FullDataSet.Take(top);
        }

        public virtual IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate)
        {
            return FullDataSet.Where(predicate);
        }

        public IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate, int top)
        {
            return FullDataSet.Where(predicate).Take(top);
        }

        public IQueryable<TObject> Filter(Expression<Func<TObject, bool>> predicate, int top, string include)
        {
            return FullDataSet.Include(include).Where(predicate).Take(top);
        }

        public bool Contains(Expression<Func<TObject, bool>> predicate)
        {
            return FullDataSet.Any(predicate);
        }

        public TObject Find(Expression<Func<TObject, bool>> predicate)
        {
            return FullDataSet.FirstOrDefault(predicate);
        }

        public TObject Find(Expression<Func<TObject, bool>> predicate, string include)
        {
            return FullDataSet.Include(include).FirstOrDefault(predicate);
        }

        public void Create(TObject t)
        {
            FullDataSet.AddObject(t);
            Context.SaveChanges();
        }

        public int Delete(TObject t)
        {
            FullDataSet.DeleteObject(t);

            return Context.SaveChanges();
        }

        public int Delete(Expression<Func<TObject, bool>> predicate)
        {
            var objects = Filter(predicate);
            foreach (var obj in objects)
                FullDataSet.DeleteObject(obj);
            return Context.SaveChanges();
        }

        public int Update(TObject t)
        {
            return Context.SaveChanges();
        }

        public int Count
        {
            get { return FullDataSet.Count(); }
        }

        public int CountOfEntity(Expression<Func<TObject, bool>> predicate)
        {
            return FullDataSet.Count(predicate);
        }

        public void Insert(TObject t)
        {
            FullDataSet.AddObject(t);
        }

        public void Add(TObject t)
        {
            FullDataSet.AddObject(t);
        }

        public void Remove(TObject t)
        {
            FullDataSet.DeleteObject(t);
        }

        public TObject Single(Expression<Func<TObject, bool>> where)
        {
            return FullDataSet.SingleOrDefault<TObject>(where);
        }

        public void Edit(TObject t)
        {
            string fqen = GetEntityName();

            Context.ApplyCurrentValues(fqen, t);

            Context.SaveChanges(SaveOptions.AcceptAllChangesAfterSave);

        }

        public TReturn Max<TReturn>(Expression<Func<TObject, TReturn>> predicate, Expression<Func<TObject, bool>> clause)
        {
            if (FullDataSet.Any(clause))
            {
                return FullDataSet.Where(clause).Max(predicate);
            }
            return default(TReturn);
        }

        public TReturn Max<TReturn>(Expression<Func<TObject, TReturn>> predicate)
        {
            return FullDataSet.Max(predicate);
        }

        private string GetEntityName()
        {
            return string.Format("{0}.{1}", FullDataSet.EntitySet.EntityContainer, FullDataSet.EntitySet.Name);
        }

        public void RemoveAll(Expression<Func<TObject, bool>> predicate)
        {
            var objects = Filter(predicate);
            foreach (var obj in objects)
                FullDataSet.DeleteObject(obj);
        }

        public List<T> ExecuteCommand<T>(string sqlCommand)
        {
           return Context.ExecuteStoreQuery<T>(sqlCommand).ToList();
        }

        public int ExecuteCommandDirectly(string sqlCommand)
        {
            return Context.ExecuteStoreCommand(sqlCommand);
        }

        #endregion

    }
}
