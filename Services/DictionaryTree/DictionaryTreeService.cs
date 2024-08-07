﻿/*
Author       : SirHQ
Create Data  : 2023-01-09
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

using MapsterMapper;
using ZhonTai.Admin.Core.Consts;
using ZhonTai.Admin.Domain.Dict;
using ZhonTai.Admin.Domain.DictType;
using ZhonTai.Admin.Services;
using ZhonTai.DynamicApi;
using ZhonTai.DynamicApi.Attributes;

namespace ZhonTai.Admin.Services.DictionaryTree;

/// <summary>
/// 字典树服务
/// </summary>
[DynamicApi(Area = "dev")]
public partial class DictionaryTreeService : BaseService, IDictionaryTreeService, IDynamicApi
{
    /// <summary>
    /// 获取字典树
    /// </summary>
    /// <param name="codes">类型编号列表</param>
    /// <returns></returns>
    public async Task<IEnumerable<Dto.DictionaryTreeOutput>> GetAsync(string? codes)
    {
        var _mapper = LazyGetRequiredService<IMapper>();

        IEnumerable<String>? typesToGet = !String.IsNullOrWhiteSpace(codes) ? codes.Split(',') : null;

        var typeRepos = LazyGetRequiredService<IDictTypeRepository>();
        var dictRepos = LazyGetRequiredService<IDictRepository>();
        var types = await typeRepos.Select
            .WhereIf(typesToGet != null && typesToGet.Count() > 0, w => typesToGet!.Contains(w.Code))
            .ToListAsync<Dto.DictionaryTreeOutput>();
        var typesId = types.Select(s => s.Id);
        var dicts = await dictRepos.Select.Where(w => typesId.Contains(w.DictTypeId)).ToListAsync();

        return types.Select(s =>
        {
            s.Childrens = dicts.Where(w => w.DictTypeId == s.Id).Select(s => _mapper.Map<Dto.DictionaryTreeOutput>(s));
            return s;
        });
    }
}
