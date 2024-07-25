/*
Author       : SirHQ
Create Data  : 2023-01-16
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

using ZhonTai.Admin.Domain.CodeGen;

namespace ZhonTai.Admin.Services.CodeGen.Dto;
#pragma warning disable CS1591, CS8618
/// <summary>
/// 
/// </summary>
public class CodeGenGetOutput
{

    public long Id { get; set; }
    /// <summary>
    /// 作者姓名
    /// </summary>
    public string AuthorName { get; set; }

    /// <summary>
    /// 是否移除表前缀
    /// </summary>
    public Boolean TablePrefix { get; set; } = true;

    /// <summary>
    /// 生成方式
    /// </summary>
    public string? GenerateType { get; set; }

    /// <summary>
    /// 库定位器名
    /// </summary>
    public string DbKey { get; set; }

    ///// <summary>
    ///// 数据库名(保留字段)
    ///// </summary>
    //public string? DbName { get; set; }

    /// <summary>
    /// 数据库类型
    /// </summary>
    public string? DbType { get; set; }

    /// <summary>
    /// 数据库表名
    /// </summary>
    public string TableName { get; set; }

    /// <summary>
    /// 命名空间
    /// </summary>
    public string Namespace { get; set; }

    /// <summary>
    /// 实体名称
    /// </summary>
    public string EntityName { get; set; }

    /// <summary>
    /// 业务名
    /// </summary>
    public string BusName { get; set; }

    /// <summary>
    /// Api分区名称
    /// </summary>
    public String? ApiAreaName { get; set; }
    /// <summary>
    /// 基类名称
    /// </summary>
    public String? BaseEntity { get; set; }

    /// <summary>
    /// 父菜单
    /// </summary>
    public String? MenuPid { get; set; }

    /// <summary>
    /// 菜单后缀
    /// </summary>
    public String? MenuAfterText { get; set; }

    /// <summary>
    /// 后端输出目录
    /// </summary>
    public String BackendOut { get; set; }

    /// <summary>
    /// 前端输出目录
    /// </summary>
    public String? FrontendOut { get; set; }

    /// <summary>
    /// 备注说明
    /// </summary>
    public String? Comment { get; set; }

    /// <summary>
    /// 实体导入的命令空间
    /// </summary>
    public String? Usings { get; set; }

    /// <summary>
    /// 生成Entity实体类
    /// </summary>
    public Boolean GenEntity { get; set; }
    /// <summary>
    /// 生成Repository仓储类
    /// </summary>
    public Boolean GenRepository { get; set; }
    /// <summary>
    /// 生成Service服务类
    /// </summary>
    public Boolean GenService { get; set; }

    /// <summary>
    /// 生成新增服务
    /// </summary>
    public Boolean GenAdd { get; set; } = true;
    /// <summary>
    /// 生成更新服务
    /// </summary>
    public Boolean GenUpdate { get; set; } = true;
    /// <summary>
    /// 新增删除服务
    /// </summary>
    public Boolean GenDelete { get; set; } = true;

    /// <summary>
    /// 生成列表查询服务
    /// </summary>
    public Boolean GenGetList { get; set; }
    /// <summary>
    /// 生成软删除服务
    /// </summary>
    public Boolean GenSoftDelete { get; set; }
    /// <summary>
    /// 生成批量删除服务
    /// </summary>
    public Boolean GenBatchDelete { get; set; }
    /// <summary>
    /// 生成批量软删除服务
    /// </summary>
    public Boolean GenBatchSoftDelete { get; set; }
    /// <summary>
    /// 字段列表
    /// </summary>
    public IEnumerable<CodeGenFieldGetOutput>? Fields { get; set; }
}
/// <summary>
/// 
/// </summary>
public class CodeGenUpdateInput : CodeGenGetOutput
{

}

#pragma warning restore