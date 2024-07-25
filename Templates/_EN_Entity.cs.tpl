@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    if (gen.Fields == null) return;
    if (gen.Fields.Count() == 0) return;

    var entityNamePc = gen.EntityName.NamingPascalCase();

    var entityClassName = entityNamePc
        .PadEndIfNot("Entity")
        .PadEndIfNotEmpty(gen.BaseEntity, ": " + gen.BaseEntity);

    var commonFields = new String[] { "id", "OwnerId", "OwnerOrgId", "IsDeleted", "TenantId"
    , "CreatedUserId","CreatedUserName","CreatedTime", "ModifiedUserId","ModifiedUserName","ModifiedTime"};
}
@("/*")
@("*".PadRight(90,'*'))
@("| This code is generated using automated code generation tool [Admin.ZhonTai.Dev].".PadRight(89,' ')+"|")
@("| Repositories of code generation tool :".PadRight(89,' ')+"|")
@("|   https://github.com/share36/Admin.Core.Dev.".PadRight(89,' ')+"|")
@("|   https://gitee.com/share36/Admin.Core.Dev.".PadRight(89,' ')+"|")
@("*".PadRight(90,'*'))

@(" generated information ".PadLeft(58,'-').PadRight(90,'-'))
 Created Time : @(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"))
 Generation Author : @(gen.AuthorName)
@("-".PadRight(90,'-'))
@("*/")

using System;
using FreeSql.DataAnnotations;
using ZhonTai.Admin.Core.Entities;
@foreach(var ns in gen.GetUsings())
{
@:using @(ns);    
}

namespace @(gen.Namespace).Domain.@(entityNamePc);

/// <summary>
/// @gen.BusName @("实体类")
/// </summary>
/// <remarks>
/// @(gen.Comment)
/// <para>Created Time : @(System.DateTime.Now.ToString("yyyy-MM-dd HH:mm:ss"))</para>
/// <para>Generation Author : @(gen.AuthorName)</para>
/// <para>Generate using automatic generation tools [ZhonTai.Admin.Dev].</para>
/// <para>Repositories of tool: https://github.com/share36/Admin.Core.Dev, https://gitee.com/share36/Admin.Core.Dev.</para>
/// </remarks>
@(gen.GetTableIndexAttributes())
public partial class @(entityClassName)
{
@if (gen.Fields != null)
{
    foreach (var col in gen.Fields)
    {
        if (col == null) continue;
        if (!String.IsNullOrWhiteSpace(gen.BaseEntity))
            if (commonFields.Any(a => a.ToLower() == col.ColumnName.ToLower()))
                continue;

        if(!col.IsIgnoreColumn())
        {

    @:/// <summary>
    @:/// @(col.Title)
    @:/// </summary>
    @:/// <remarks>@(col.Comment)</remarks>
    @:@col.FreeSqlColumnAttribute()
    @:@col.PropCs()
        }

        if (col.IsIncludeColumn())
        {
            
    @:/// <summary>
    @:/// @(col.Title) @(col.IncludeMode==0?"对象":"列表")
    @:/// </summary>
    @:/// <remarks>@(col.Comment)</remarks>
    @:@col.FreeSqlNavigateAttribute()
    @:@col.PropIncludeCs()
        
        }
    }

}
}
