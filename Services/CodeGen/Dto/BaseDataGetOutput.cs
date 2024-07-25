/*
Author       : SirHQ
Create Data  : 2023-01-16
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

namespace ZhonTai.Admin.Services.CodeGen.Dto;

#pragma warning disable CS1591, CS8618

/// <summary>
/// 
/// </summary>
public class BaseDataGetOutput
{
    public IEnumerable<DatabaseGetOutput> Databases { get; set; }

    public String AuthorName { get; set; } = "SirHQ";
    public String ApiAreaName { get; set; } = "";
    public String Namespace { get; set; } = "";
    public String BackendOut { get; set; } = "";
    public String FrontendOut { get; set; } = "";
    public String Usings { get; set; } = "";
    public String MenuAfterText { get; set; } = ""; 
}
/// <summary>
/// 
/// </summary>
public class DatabaseGetOutput
{
    public String DbKey { get; set; }
    public String Type { get; set; }
}

#pragma warning restore