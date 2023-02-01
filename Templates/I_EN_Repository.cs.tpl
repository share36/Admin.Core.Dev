@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    var entityNamePc = "" + gen.EntityName.NamingPascalCase();
}
using ZhonTai.Admin.Core.Repositories;

namespace @(gen.Namespace).Domain.@(entityNamePc)
{
    public interface I@(entityNamePc)Repository : IRepositoryBase<@(entityNamePc)Entity>
    {
    }
}
