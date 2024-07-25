/*
Author       : SirHQ
Create Data  : 2023-01-16
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

using ZhonTai.Admin.Services.CodeGen.Dto;

namespace ZhonTai.Admin.Services.CodeGen;

/// <summary>
/// 代码生成接口
/// </summary>
public interface ICodeGenService
{
    /// <summary>
    /// 
    /// </summary>
    /// <returns></returns>
    Task<BaseDataGetOutput> GetBaseDataAsync();
    /// <summary>
    /// 
    /// </summary>
    /// <param name="dbkey"></param>
    /// <returns></returns>
    Task<IEnumerable<CodeGenGetOutput>> GetTablesAsync(String dbkey);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="dbkey"></param>
    /// <returns></returns>
    Task<IEnumerable<CodeGenGetOutput>> GetListAsync(String dbkey);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    Task<CodeGenGetOutput> GetAsync(long id);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    Task UpdateAsync(CodeGenUpdateInput input);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    Task DeleteAsync(long id);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    Task GenerateAsync(long id);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    Task CompileAsync(long id);
    /// <summary>
    /// 
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    Task GenMenu(long id);
}