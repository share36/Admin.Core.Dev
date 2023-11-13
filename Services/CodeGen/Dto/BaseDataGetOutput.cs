namespace ZhonTai.Admin.Services.CodeGen.Dto;

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

public class DatabaseGetOutput
{
    public String DbKey { get; set; }
    public String Type { get; set; }
}