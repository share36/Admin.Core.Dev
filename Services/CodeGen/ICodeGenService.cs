using ZhonTai.Admin.Services.CodeGen.Dto;

namespace ZhonTai.Admin.Services.CodeGen;

/// <summary>
/// 代码生成接口
/// </summary>
public interface ICodeGenService
{
    Task<BaseDataGetOutput> GetBaseDataAsync();
    Task<IEnumerable<CodeGenGetOutput>> GetTablesAsync(String dbkey);
    Task<IEnumerable<CodeGenGetOutput>> GetListAsync(String dbkey);
    Task<CodeGenGetOutput> GetAsync(long id);
    Task UpdateAsync(CodeGenUpdateInput input);
    Task DeleteAsync(long id);
    Task GenerateAsync(long id);
    Task CompileAsync(long id);
    Task GenMenu(long id);
}