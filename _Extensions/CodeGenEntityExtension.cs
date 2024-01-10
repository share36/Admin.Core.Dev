using CodeService._Extensions;
using System.Reflection.Emit;
using ZhonTai.Admin.Domain.CodeGen;

/// <summary>
/// 代码生成-实体/表对象扩展方法
/// </summary>
public static class CodeGenEntityExtension
{
    /// <summary>
    /// 当对象不为null时将对象和当前对象连接
    /// </summary>
    /// <typeparam name="T"></typeparam>
    /// <param name="dst"></param>
    /// <param name="src"></param>
    /// <returns></returns>
    public static IEnumerable<T> ConcatIfNotNull<T>(this IEnumerable<T> dst, IEnumerable<T>? src)
    {
        if (src != null) dst.Concat(src);
        return dst;
    }
    /// <summary>
    /// 
    /// </summary>
    /// <param name="config"></param>
    /// <returns></returns>
    public static IEnumerable<string> GetUsings(this CodeGenEntity config)
    {
        var usings = !String.IsNullOrWhiteSpace(config.Usings) ? config.Usings.Split(';') : new string[0];

        var ns = usings
            .ConcatIfNotNull(config.Fields?
                .Where(w => !String.IsNullOrWhiteSpace(w.IncludeEntity))
                .Select(s => s.IncludeEntity?.Split('.').Last().PadEndIfNot("Entity"))
                .Select(s => "" + Type.GetType(s)?.Namespace)
                .Where(w => !String.IsNullOrWhiteSpace(w))
            )
            .ConcatIfNotNull(config.Fields?
                .Where(w => !String.IsNullOrWhiteSpace(w.IncludeEntity))
                .Select(s =>
                {
                    if (String.IsNullOrWhiteSpace(s.IncludeEntity)) return "";
                    if (s.IncludeEntity.IndexOf('.') < 1) return "";
                    var parts = s.IncludeEntity.Split('.');
                    return String.Join(".", parts.Skip(parts.Length - 1));
                })
                .Where(w => !String.IsNullOrWhiteSpace(w))
            ).Distinct().Where(w => !String.IsNullOrWhiteSpace(w));

        return ns;
    }
    /// <summary>
    /// 权限标识符
    /// </summary>
    public struct PermInfo
    {
        /// <summary>
        /// 代码
        /// </summary>
        public string Code;
        /// <summary>
        /// 标签
        /// </summary>
        public string Label;
        /// <summary>
        /// 
        /// </summary>
        /// <param name="code"></param>
        /// <param name="label"></param>
        public PermInfo(String code, String label)
        {
            Code = code;
            Label = label;
        }
    }
    /// <summary>
    /// 获取要生成的权限标识项
    /// </summary>
    /// <param name="table"></param>
    /// <param name="spillter"></param>
    /// <returns></returns>
    public static IEnumerable<PermInfo> GetPermissionsToGen(this CodeGenEntity table, String spillter = ":")
    {
        return new List<PermInfo>
        {
            new PermInfo("add","新增"),new PermInfo("get","查询"),new PermInfo("update","更新"),
            new PermInfo("delete","删除"),new PermInfo("get-page","分页查询")
        }
        .AddIf(table.GenGetList, new PermInfo("get-list", "列表查询"))
        .AddIf(table.GenBatchDelete, new PermInfo("batch-delete", "批量删除"))
        .AddIf(table.GenSoftDelete, new PermInfo("soft-delete", "软删除"))
        .AddIf(table.GenBatchSoftDelete, new PermInfo("batch-soft-delete", "批量软删除"))
        .Select(s =>
             new PermInfo(
                String.Join(spillter, "api", table.ApiAreaName?.NamingKebabCase(),
                    table.EntityName.NamingKebabCase(), s.Code), s.Label)
        );
    }
    /// <summary>
    /// 获取建表结构时的索引项
    /// </summary>
    /// <param name="config"></param>
    /// <returns></returns>
    public static String GetTableIndexAttributes(this CodeGenEntity config)
    {
        var attrs = new List<String> { { "Table(Name=\"" + config.TableName + "\")" } };

        if (config.Fields != null)
        {
            var indexFields = config.Fields.Where(w => w.IsUnique || !String.IsNullOrWhiteSpace(w.IndexMode));

            if (indexFields != null && indexFields.Count() > 0)
            {
                attrs.AddRange(indexFields.Select(w => "Index(\"Index_{TableName}_" +
                    (String.IsNullOrWhiteSpace(w.ColumnRawName) ? w.ColumnName : w.ColumnRawName)
                    + "\", \"" + w.ColumnName + (!String.IsNullOrWhiteSpace(w.IndexMode) ? " " + w.IndexMode : "") + "\", "
                    + (w.IsUnique ? "true" : "false") + ")"));
            }
        }

        return "[" + String.Join(",", attrs) + "]";
    }
}