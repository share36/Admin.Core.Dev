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

public class CodeGenFieldRepository : AdminRepositoryBase<CodeGenFieldEntity>, ICodeGenFieldRepository
{
    public CodeGenFieldRepository(UnitOfWorkManagerCloud muowm) : base(muowm)
    {

    }
}