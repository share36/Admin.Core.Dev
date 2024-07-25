@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    var entityNamePc = "" + gen.EntityName.NamingPascalCase();
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

using ZhonTai.Admin.Core.Repositories;

namespace @(gen.Namespace).Domain.@(entityNamePc);

/// <summary>
/// @gen.BusName @("仓储接口")
/// </summary>
/// <remarks>
/// @(gen.Comment)
/// <para>Created Time : @(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"))</para>
/// <para>Generation Author : @(gen.AuthorName)</para>
/// <para>Generate using automatic generation tools [ZhonTai.Admin.Dev].</para>
/// <para>Repositories of tool: https://github.com/share36/Admin.Core.Dev, https://gitee.com/share36/Admin.Core.Dev.</para>
/// </remarks>
public interface I@(entityNamePc)Repository : IRepositoryBase<@(entityNamePc)Entity>
{
}
