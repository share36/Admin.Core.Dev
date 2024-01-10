@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    if (gen.Fields == null) return;
    if (gen.Fields.Count() == 0) return;

    var entityNamePc = gen.EntityName.NamingPascalCase();
}
using System.ComponentModel.DataAnnotations;
using ZhonTai.Admin.Core.Dto;
using ZhonTai.Admin.Core.Entities;
@foreach (var ns in gen.GetUsings())
{
@:using @(ns);    
}
@foreach(var col in gen.Fields.Where(w=>!String.IsNullOrWhiteSpace(w.IncludeEntity))){
@:using @(gen.Namespace).Services.@(col.IncludeEntity.Replace("Entity","").NamingPascalCase()).Dto;
}
using @(gen.Namespace).Services.@(entityNamePc).Dto;

namespace @(gen.Namespace).Services.@(entityNamePc)
{
    /// <summary>
    /// @gen.BusName @("服务接口")
    /// </summary>
    /// <remarks>@(gen.Comment)</remarks>
    public partial interface I@(entityNamePc)Service
    {
       
        /// <summary>
        /// 查询
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>
        Task<@(entityNamePc)GetOutput> GetAsync(long id);

        /// <summary>
        /// 分页查询
        /// </summary>
        /// <param name="input"></param>
        /// <returns></returns>        
        Task<PageOutput<@(entityNamePc)GetPageOutput>> GetPageAsync(PageInput<@(entityNamePc)GetPageInput> input);

@if(gen.GenAdd){ 
@:        /// <summary>
@:        /// 新增
@:        /// </summary>
@:        /// <param name="input"></param>
@:        /// <returns></returns>
@:        Task<long> AddAsync(@(entityNamePc)AddInput input);
}

@if(gen.GenUpdate){
@:        /// <summary>
@:        /// 更新
@:        /// </summary>
@:        /// <param name="input"></param>
@:        /// <returns></returns>
@:        Task UpdateAsync(@(entityNamePc)UpdateInput input);
}

@if(gen.GenDelete){
@:        /// <summary>
@:        /// 删除
@:        /// </summary>
@:        /// <param name="input"></param>
@:        /// <returns></returns>
@:        Task DeleteAsync(long id);
}
    @if(gen.GenGetList){
        @:/// <summary>
        @:/// 列表查询
        @:/// </summary>
        @:/// <param name="input"></param>
        @:/// <returns></returns>
        @:Task<IEnumerable<@(entityNamePc)GetListOutput>> GetListAsync(@(entityNamePc)GetListInput input);
    }
    @if(gen.GenBatchDelete){
        @:/// <summary>
        @:/// 批量删除
        @:/// </summary>
        @:/// <param name="ids"></param>
        @:/// <returns></returns>
        @:Task BatchDeleteAsync(long[] ids);
    }
    @if(gen.GenSoftDelete){
        @:/// <summary>
        @:/// 软删除
        @:/// </summary>
        @:/// <param name="id"></param>
        @:/// <returns></returns>
        @:Task SoftDeleteAsync(long id);
    }
    @if(gen.GenBatchSoftDelete){
        @:/// <summary>
        @:/// 批量软删除
        @:/// </summary>
        @:/// <param name="ids"></param>
        @:/// <returns></returns>
        @:Task BatchSoftDeleteAsync(long[] ids);
    }
    }
}

namespace @(gen.Namespace).Services.@(entityNamePc).Dto
{
    /// <summary>@(gen.BusName)查询结果输出</summary>
    public partial class @(entityNamePc)GetOutput {
        @if (!String.IsNullOrWhiteSpace(gen.BaseEntity))
        {
        @:public long Id { get; set; }
        }
        @foreach (var col in gen.Fields)
        {

            if (!col.IsIgnoreColumn())
            {
        @:/// <summary>@(col.Title)</summary>
        @:@col.PropCs()
        if(!String.IsNullOrWhiteSpace(col.DictTypeCode)){
        @:public string? @(col.ColumnName.NamingPascalCase())DictName { get; set; }
        }
            }

            if (col.IsIncludeColumn())
            {
        @:@col.PropIncludeCs().Replace("Entity", "GetOutput")
            }
        }
    }

    /// <summary>@(gen.BusName)分页查询结果输出</summary>
    public partial class @(entityNamePc)GetPageOutput {
        @if (!String.IsNullOrWhiteSpace(gen.BaseEntity))
        {

        @:public long Id { get; set; }
        @:public DateTime CreatedTime { get; set; }
        @:public string CreatedUserName { get; set; }
        @:public string ModifiedUserName { get; set; }
        @:public DateTime? ModifiedTime { get; set; }

        }
        @foreach(var col in gen.Fields.Where(w=>w.WhetherTable))
        {

            if(!col.IsIgnoreColumn())
            {
        @:/// <summary>@(col.Title)</summary>
        @:@col.PropCs()
            }

            if (col.IsIncludeColumn())
            {
        @:@col.PropIncludeCs()
            }

            if(!string.IsNullOrWhiteSpace(col.DictTypeCode))
            {
        @:/// <summary>@(col.Title)名称</summary>
        @:public string? @(col.ColumnName.NamingPascalCase())DictName { get; set; }
            }
        }
    }

    /// <summary>@(gen.BusName)分页查询条件输入</summary>
    public partial class @(entityNamePc)GetPageInput {

        @foreach (var col in gen.Fields.Where(w=>w.WhetherQuery))
        {
            if(!col.IsIgnoreColumn())
            {
        @:/// <summary>@(col.Title)</summary>       
        @:@col.PropCs(true)
            }
        }
    }
    
@if(gen.GenAdd){
@:    /// <summary>@(gen.BusName)新增输入</summary>
@:    public partial class @(entityNamePc)AddInput {
        @foreach (var col in gen.Fields.Where(w=>w.WhetherAdd))
        {
            if (!col.IsIgnoreColumn())
            {
@:        /// <summary>@(col.Title)</summary>
                if (!col.IsNullable)
                {
@:        [Required(ErrorMessage = "@((!String.IsNullOrEmpty(col.Title)?col.Title:col.ColumnName)+"不能为空")")]
                }
@:        @col.PropCs()                                                    
             }
        }
    @if(gen.Fields.Any(a=>a.EncryptTrans)){
          @:public string? EncryptKey { get; set; }
    }
@:    }
}

@if(gen.GenUpdate){
@:    /// <summary>@(gen.BusName)更新数据输入</summary>
@:    public partial class @(entityNamePc)UpdateInput {
    @if (!String.IsNullOrWhiteSpace(gen.BaseEntity))
    {
        @:public long Id { get; set; }
    }
    @foreach (var col in gen.Fields.Where(w => w.WhetherUpdate))
    {
        if (!col.IsIgnoreColumn())
        {
        @:/// <summary>@(col.Title)</summary>
        if (!col.IsNullable)
        {
        @:[Required(ErrorMessage = "@((!String.IsNullOrEmpty(col.Title) ? col.Title : col.ColumnName) + "不能为空")")]
        }
        @:@col.PropCs()
        }
    }
    @if(gen.Fields.Any(a=>a.EncryptTrans)){
        @:public string? EncryptKey { get; set; }
    }
@:    }
}

@if(gen.GenGetList){
    @:/// <summary>@(gen.BusName)列表查询结果输出</summary>
    @:public partial class @(entityNamePc)GetListOutput {
        @if (!String.IsNullOrWhiteSpace(gen.BaseEntity))
        {
        @:public long Id { get; set; }
        @:public DateTime CreatedTime { get; set; }
        @:public string CreatedUserName { get; set; }
        @:public string ModifiedUserName { get; set; }
        @:public DateTime? ModifiedTime { get; set; }
        }
        @foreach(var col in gen.Fields.Where(w=>w.WhetherList))
        {
            if (!col.IsIgnoreColumn())
            {
        @:/// <summary>@(col.Title)</summary>
        @:@col.PropCs()
            }

            if (col.IsIncludeColumn())
            {
        @:@col.PropIncludeCs().Replace("Entity", "GetOutput")
            }

            if (!string.IsNullOrWhiteSpace(col.DictTypeCode))
            {
        @:/// <summary>@(col.Title)名称</summary>
        @:public string? @(col.ColumnName.NamingPascalCase())DictName { get; set; }
            }
        }
    @:}

    @:/// <summary>@(gen.BusName)列表查询条件输入</summary>
    @:public partial class @(entityNamePc)GetListInput : @(entityNamePc)GetPageInput {

    @:}
}

}