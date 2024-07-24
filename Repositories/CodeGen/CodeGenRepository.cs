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