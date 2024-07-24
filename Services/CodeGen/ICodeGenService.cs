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