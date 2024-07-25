/*
Author       : SirHQ
Create Data  : 2023-01-16
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

using ZhonTai.Admin.Core.Db.Transaction;
using ZhonTai.Admin.Domain.CodeGen;

namespace ZhonTai.Admin.Repositories;

/// <summary>
/// 
/// </summary>
public class CodeGenRepository : AdminRepositoryBase<CodeGenEntity>, ICodeGenRepository
{
    /// <summary>
    /// 
    /// </summary>
    /// <param name="muowm"></param>
    public CodeGenRepository(UnitOfWorkManagerCloud muowm) : base(muowm)
    {

    }
}