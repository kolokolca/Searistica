using System.Data.Objects.DataClasses;
using DataAccess;

namespace Business
{
    public static class RepositoryContainer
    {
        public static IRepository<TObject> GetRepository<TObject>(IUnitOfWork unitOfWork) where TObject : EntityObject
        {
            return new Repository<TObject>(unitOfWork);
        }
    }
}
