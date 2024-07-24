@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    if (gen.Fields == null) return;
    if (gen.Fields.Count() == 0) return;

    var entityNamePc = gen.EntityName?.NamingPascalCase();
    var entityNameCc = gen.EntityName?.NamingCamelCase();
}

using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Collections.Generic;

using Microsoft.AspNetCore.Mvc;


using ZhonTai.Admin.Core.Dto;
using ZhonTai.Admin.Services;
using ZhonTai.DynamicApi;
using ZhonTai.DynamicApi.Attributes;
using ZhonTai.Admin.Domain.Dict;

using @(gen.Namespace).Domain.@(entityNamePc);
using @(gen.Namespace).Services.@(entityNamePc).Dto;


namespace @(gen.Namespace).Services.@(entityNamePc);

/// <summary>
/// @(gen.BusName)服务
/// </summary>
[DynamicApi(Area = "@gen.ApiAreaName")]
public partial class @(entityNamePc)Service : BaseService, I@(entityNamePc)Service, IDynamicApi
{
    private I@(entityNamePc)Repository _@(entityNameCc)Repository => LazyGetRequiredService<I@(entityNamePc)Repository>();

    /// <summary>
    /// @(gen.BusName)服务实例化
    /// </summary>
    public @(entityNamePc)Service()
    {
    }

@if (gen.Fields.Any(a => a.EncryptTrans))
{
    @:async Task<string> DecryptString(string key, string strToDec)
    @:{
    @:    var catchKey = "@(entityNamePc)_" + key;
    @:    var existsEncKey = await Cache.ExistsAsync(catchKey);
    @:    if (!existsEncKey) throw ResultOutput.Exception("解密失败！");
    @:    var encKey = await Cache.GetAsync(catchKey);
    @:    if (String.IsNullOrWhiteSpace(encKey)){
    @:        await Cache.DelAsync(catchKey);
    @:        throw ResultOutput.Exception("解密失败！");
    @:    }
    @:    return ZhonTai.Common.Helpers.DesEncrypt.Decrypt(strToDec, encKey);
    @:}
}
@if(gen.GenAdd){
@:    /// <summary>
@:    /// 新增
@:    /// </summary>
@:    /// <param name="input"></param>
@:    /// <returns></returns>
@:    [HttpPost]
@:    public async Task<long> AddAsync(@(entityNamePc)AddInput input)
@:    {
        @if (gen.Fields.Any(a => a.EncryptTrans))
        {
        @:if (!String.IsNullOrWhiteSpace(input.EncryptKey)){
            @foreach(var field in gen.Fields.Where(w => w.EncryptTrans))
            {
            @:if (!String.IsNullOrWhiteSpace(input.@(field.ColumnName.NamingPascalCase())))
            @:    input.@(field.ColumnName.NamingPascalCase()) = await DecryptString(input.EncryptKey, input.@(field.ColumnName.NamingPascalCase()));
            }
            @:await Cache.DelAsync("@(entityNamePc)_" + input.EncryptKey);
        @:}                
        }
@:      var entity = Mapper.Map<@(entityNamePc)Entity>(input);
@:      var id = (await _@(entityNameCc)Repository.InsertAsync(entity)).Id;
@:
@:      return id;
@:    }
}
    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    [HttpGet]
    public async Task<@(entityNamePc)GetOutput> GetAsync(long id)
    {
        var output = await _@(entityNameCc)Repository.GetAsync<@(entityNamePc)GetOutput>(id);
        return output;
    }

    /// <summary>
    /// 分页查询
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    [HttpPost]
    public async Task<PageOutput<@(entityNamePc)GetPageOutput>> GetPageAsync(PageInput<@(entityNamePc)GetPageInput> input)
    {
        var filter = input.Filter;
        var list = await _@(entityNameCc)Repository.Select
            .WhereDynamicFilter(input.DynamicFilter)
        @foreach(var col in gen.Fields.Where(w=>w.WhetherQuery)){
            if(col.IsTextColumn()){
            @:.WhereIf(filter !=null && !string.IsNullOrEmpty(filter.@(col.ColumnName.NamingPascalCase())), a=>a.@(col.ColumnName.NamingPascalCase()) == filter!.@(col.ColumnName.NamingPascalCase()))
            }else if(col.IsNumColumn()){
            @:.WhereIf(filter !=null && filter.@(col.ColumnName.NamingPascalCase()) != null, a=>a.@(col.ColumnName.NamingPascalCase()) == filter!.@(col.ColumnName.NamingPascalCase()))
            }
        }
            .Count(out var total)
            .OrderBy(c => c.Id)
            .Page(input.CurrentPage, input.PageSize)
            .ToListAsync<@(entityNamePc)GetPageOutput>();
    
        @if(gen.Fields.Any(a=>!string.IsNullOrWhiteSpace(a.DictTypeCode))) {

                        var usedDicCols = gen.Fields.Where(w => !string.IsNullOrWhiteSpace(w.DictTypeCode));

        @:var dictRepo = LazyGetRequiredService<IDictRepository>();
        @:var dictList = await dictRepo.Where(w => new string[] { @(string.Concat("\"" , string.Join("\", \"", usedDicCols.Select(s=>s.DictTypeCode)), "\"")) }
        @:    .Contains(w.DictType.Code)).ToListAsync();

        @:
        @:list = list.Select(s =>
        @:{
                        foreach(var col in usedDicCols)
                        {

        @:    s.@(col.ColumnName.NamingPascalCase())DictName = dictList.FirstOrDefault(f => f.DictType.Code == "@(col.DictTypeCode)" && f.Code == @if(col.IsNumColumn())@("\"\" + ")s.@(col.ColumnName.NamingPascalCase()))?.Name;
                            
                        }
        @:
        @:   return s;
        @:}).ToList();

        }

        var data = new PageOutput<@(entityNamePc)GetPageOutput> { List = list, Total = total };
    
        return data;
    }

@if(gen.GenUpdate){
@:    /// <summary>
@:    /// 更新
@:    /// </summary>
@:    /// <param name="input"></param>
@:    /// <returns></returns>
@:    [HttpPut]
@:    public async Task UpdateAsync(@(entityNamePc)UpdateInput input)
@:    {
@:        var entity = await _@(entityNameCc)Repository.GetAsync(input.Id);
@:        if (!(entity?.Id > 0))
@:        {
@:            throw ResultOutput.Exception("@(gen.BusName)不存在！");
@:        }
        @if (gen.Fields.Any(a => a.EncryptTrans))
        {
        @:if (!String.IsNullOrWhiteSpace(input.EncryptKey)){
            @foreach(var field in gen.Fields.Where(w => w.EncryptTrans))
            {
            @:if (!String.IsNullOrWhiteSpace(input.@(field.ColumnName.NamingPascalCase())))
            @:    input.@(field.ColumnName.NamingPascalCase()) = await DecryptString(input.EncryptKey, input.@(field.ColumnName.NamingPascalCase()));
            }
            @:await Cache.DelAsync("@(entityNamePc)_" + input.EncryptKey);
        @:}                
        }
@:        Mapper.Map(input, entity);
@:        await _@(entityNameCc)Repository.UpdateAsync(entity);
@:    }
}

@if(gen.GenDelete){
@:    /// <summary>
@:    /// 删除
@:    /// </summary>
@:    /// <param name="id"></param>
@:    /// <returns></returns>
@:    [HttpDelete]
@:    public async Task DeleteAsync(long id)
@:    {
@:        await _@(entityNameCc)Repository.DeleteAsync(id);
@:    }
}

@if(gen.GenGetList){
    @:/// <summary>
    @:/// 列表查询
    @:/// </summary>
    @:/// <param name="input"></param>
    @:/// <returns></returns>
    @:[HttpPost]
    @:public async Task<IEnumerable<@(entityNamePc)GetListOutput>> GetListAsync(@(entityNamePc)GetListInput input)
    @:{
    @:    var list = await _@(entityNameCc)Repository.Select
        @foreach(var col in gen.Fields.Where(w=>w.WhetherQuery)){
            if(col.IsTextColumn()){
            @:.WhereIf(!string.IsNullOrEmpty(input.@(col.ColumnName.NamingPascalCase())), a=>a.@(col.ColumnName.NamingPascalCase()) == input.@(col.ColumnName.NamingPascalCase()))
            }else if(col.IsNumColumn()){
            @:.WhereIf(input.@(col.ColumnName.NamingPascalCase()) != null, a=>a.@(col.ColumnName.NamingPascalCase()) == input.@(col.ColumnName.NamingPascalCase()))
            }
        }
     @:       .OrderBy(a => a.Id)
     @:       .ToListAsync<@(entityNamePc)GetListOutput>();

        @if(gen.Fields.Any(a=>!string.IsNullOrWhiteSpace(a.DictTypeCode))) {

                        var usedDicCols = gen.Fields.Where(w => !string.IsNullOrWhiteSpace(w.DictTypeCode));

        @:var dictRepo = LazyGetRequiredService<IDictRepository>();
        @:var dictList = await dictRepo.Where(w => new string[] { @(string.Concat("\"" , string.Join("\", \"", usedDicCols.Select(s=>s.DictTypeCode)), "\"")) }
        @:    .Contains(w.DictType.Code)).ToListAsync();


        @:return list.Select(s =>
        @:{
                        foreach(var col in usedDicCols)
                        {

        @:    s.@(col.ColumnName.NamingPascalCase())DictName = dictList.FirstOrDefault(f => f.DictType.Code == "@(col.DictTypeCode)" && f.Code == @if(col.IsNumColumn())@("\"\" + ")s.@(col.ColumnName.NamingPascalCase()))?.Name;
                            
                        }
        @:   return s;
        @:});

        }else
        {
        @:return list;
        }
    @:}
}

@if(gen.GenBatchDelete){
    @:/// <summary>
    @:/// 批量删除
    @:/// </summary>
    @:/// <param name="ids"></param>
    @:/// <returns></returns>
    @:[HttpPut]
    @:public async Task BatchDeleteAsync(long[] ids)
    @:{
    @:    await _@(entityNameCc)Repository.DeleteAsync(d => ids.Contains(d.Id));
    @:}
}

@if(gen.GenSoftDelete){
    @:/// <summary>
    @:/// 软删除
    @:/// </summary>
    @:/// <param name="id"></param>
    @:/// <returns></returns>
    @:[HttpDelete]
    @:public async Task SoftDeleteAsync(long id)
    @:{
    @:    await _@(entityNameCc)Repository.SoftDeleteAsync(id);
    @:}
}

@if (gen.GenBatchSoftDelete)
{
    @:/// <summary>
    @:/// 批量软删除
    @:/// </summary>
    @:/// <param name="ids"></param>
    @:/// <returns></returns>
    @:[HttpPut]
    @:public async Task BatchSoftDeleteAsync(long[] ids)
    @:{
    @:    await _@(entityNameCc)Repository.SoftDeleteAsync(ids);
    @:}
}

@if (gen.Fields.Any(a=>a.EncryptTrans)){
    @:/// <summary>获取加密信息</summary>
    @:[HttpGet]
    @:[ZhonTai.Admin.Core.Attributes.NoOprationLog]
    @:public async Task<KeyValuePair<string, string>> GetEncryptInfo()
    @:{
    @:    var guid = Guid.NewGuid().ToString("N");
    @:    var key = "@(entityNamePc)_" + guid;
    @:    var encyptKey = ZhonTai.Common.Helpers.StringHelper.GenerateRandom(8);
    @:    await Cache.SetAsync(key, encyptKey, TimeSpan.FromMinutes(2));
    @:    return KeyValuePair.Create(guid, encyptKey);
    @:}
}

}
