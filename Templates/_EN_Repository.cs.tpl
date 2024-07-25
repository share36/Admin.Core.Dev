@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    var entityNamePC = gen.EntityName.NamingPascalCase();
}
@("/*")
@("*".PadRight(90,'*'))
@("| This code is generated using automated code generation tool [Admin.ZhonTai.Dev].".PadRight(89,' ')+"|")
@("| Repositories of code generation tool :".PadRight(89,' ')+"|")
@("|   https://github.com/share36/Admin.Core.Dev.".PadRight(89,' ')+"|")
@("|   https://gitee.com/share36/Admin.Core.Dev.".PadRight(89,' ')+"|")
@("*".PadRight(90,'*'))

@(" generated information ".PadLeft(58,'-').PadRight(90,'-'))
 Created Time : @(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"))
 Generation Author : @(gen.AuthorName)
@("-".PadRight(90,'-'))
@("*/")

using @(gen.Namespace).Domain.@(entityNamePC);
using ZhonTai.Admin.Core.Db.Transaction;
using ZhonTai.Admin.Core.Repositories;

namespace @(gen.Namespace).Repositories.@(entityNamePC);

/// <summary>
/// @gen.BusName @("仓储类")
/// </summary>
/// <remarks>
/// @(gen.Comment)
/// <para>Created Time : @(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"))</para>
/// <para>Generation Author : @(gen.AuthorName)</para>
/// <para>Generate using automatic generation tools [ZhonTai.Admin.Dev].</para>
/// <para>Repositories of tool: https://github.com/share36/Admin.Core.Dev, https://gitee.com/share36/Admin.Core.Dev.</para>
/// </remarks>
public class @(entityNamePC)Repository : RepositoryBase<@(entityNamePC)Entity>, I@(entityNamePC)Repository
{
    /// <summary>
    /// @gen.BusName @("仓储类实例化")
    /// </summary>
    public @(entityNamePC)Repository(UnitOfWorkManagerCloud muowm) : base(/*"@(gen.DbKey)"*/ Consts.DbKeys.AppDb, muowm)
    {
    }
}
