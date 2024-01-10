@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    var entityNamePc = "" + gen.EntityName.NamingPascalCase();
}
using ZhonTai.Admin.Core.Repositories;

namespace @(gen.Namespace).Domain.@(entityNamePc)
{
    /// <summary>
    /// @gen.BusName @("仓储接口")
    /// </summary>
    /// <remarks>@(gen.Comment)</remarks>
    public interface I@(entityNamePc)Repository : IRepositoryBase<@(entityNamePc)Entity>
    {
    }
}
