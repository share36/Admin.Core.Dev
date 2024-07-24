using CodeService._Extensions;
using FreeSql;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.AspNetCore.Mvc;
using Microsoft.CodeAnalysis;
using RazorEngine.Templating;
using System.Data;
using System.Diagnostics;
using System.Reflection;
using System.Text;
using ZhonTai.Admin.Core.Attributes;
using ZhonTai.Admin.Core.Configs;
using ZhonTai.Admin.Core.Dto;
using ZhonTai.Admin.Domain.Api;
using ZhonTai.Admin.Domain.CodeGen;
using ZhonTai.Admin.Domain.Permission;
using ZhonTai.Admin.Domain.PermissionApi;
using ZhonTai.Admin.Domain.View;
using ZhonTai.Admin.Services.CodeGen.Dto;
using ZhonTai.Common.Helpers;
using ZhonTai.DynamicApi;
using ZhonTai.DynamicApi.Attributes;

namespace ZhonTai.Admin.Services.CodeGen;
#pragma warning disable 8604
/// <summary>
/// 代码生成服务
/// </summary>
[DynamicApi(Area = "dev")]
#if DEBUG
[AllowAnonymous]
#endif
public partial class CodeGenService : BaseService, ICodeGenService, IDynamicApi
{
    private ICodeGenRepository _codeGenRepository => LazyGetRequiredService<ICodeGenRepository>();
    private ICodeGenFieldRepository _codeGenConfigRepository => LazyGetRequiredService<ICodeGenFieldRepository>();
    private FreeSqlCloud _cloud => LazyGetRequiredService<FreeSqlCloud>();
    private DbConfig _dbconfig => LazyGetRequiredService<DbConfig>();
    private CodeGenConfig _codeGenConfig;

    public CodeGenService()
    {
        _codeGenConfig = ConfigHelper.Get<CodeGenConfig>("codegenconfig");
    }

    /// <summary>
    /// 获取数据库列表
    /// </summary>
    /// <returns></returns>
    public async Task<BaseDataGetOutput> GetBaseDataAsync()
    {

        var dbs = new List<DatabaseGetOutput>() { };
        dbs.Add(new DatabaseGetOutput { DbKey = _dbconfig.Key, Type = _dbconfig.Type.ToString() });
        if (_dbconfig.Dbs?.Length > 0)
        {
            dbs.AddRange(_dbconfig.Dbs.Select(s => new DatabaseGetOutput { DbKey = s.Key, Type = s.Type.ToString() }));
        }

        var result = new BaseDataGetOutput
        {
            Databases = dbs
        };
        Mapper.Map(_codeGenConfig.DefaultOption, result);

        return await Task.FromResult(result);
    }
    /// <summary>
    /// 获取表列表
    /// </summary>
    /// <param name="dbkey"></param>
    /// <returns></returns>
    public async Task<IEnumerable<CodeGenGetOutput>> GetTablesAsync(string dbkey)
    {
        IFreeSql fSql = _cloud.Use(dbkey);

        var getOutput = new Func<IEnumerable<CodeGenGetOutput>>(() =>
        {
            var tables = fSql.DbFirst.GetTablesByDatabase()
                .Select(s => new CodeGenGetOutput
                {
                    TableName = s.Name,
                    Comment = s.Comment,
                    DbKey = dbkey,
                    DbType = fSql.Ado.DataType.ToString(),
                    Fields = s.Columns.Select(c => new CodeGenFieldGetOutput
                    {
                        ColumnName = c.Name,
                        Comment = c.Comment,
                        Title = c.Comment,
                        NetType = fSql.DbFirst.GetCsType(c).TrimEnd('?'),
                        DbType = c.DbTypeText,
                        IsNullable = c.IsNullable,
                        IsPrimary = c.IsPrimary,
                        Length = "" + c.MaxLength
                    }).ToList()
                }).ToList();

            return tables;
        });

        return await Task.FromResult(getOutput());
    }

    /// <summary>
    /// 获取列表
    /// </summary>
    /// <param name="dbkey"></param>
    /// <returns></returns>
    public async Task<IEnumerable<CodeGenGetOutput>> GetListAsync(string dbkey)
    {
#if DEBUG
        _cloud.Use("admindb").CodeFirst.SyncStructure(typeof(CodeGenEntity), typeof(CodeGenFieldEntity));
#endif

        var gens = await _codeGenRepository.Where(w => w.DbKey == dbkey)
            .IncludeMany<CodeGenFieldEntity>(c => c.Fields.Where(w => w.CodeGenId == c.Id),
            then => then.OrderBy(o => new { o.Position, o.Id }))
            .ToListAsync();

        var tables = gens.Select(s =>
            {
                var tab = Mapper.Map<CodeGenGetOutput>(s);
                tab.Fields = s.Fields?.Select(Mapper.Map<CodeGenFieldGetOutput>);
                return tab;
            }
        );

        return tables;
    }

    /// <summary>
    /// 查询
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public async Task<CodeGenGetOutput> GetAsync(long id)
    {
        var row = await _codeGenRepository.Select.Where(w => w.Id == id).IncludeMany(c => c.Fields.Where(w => w.CodeGenId == c.Id),
            then => then.OrderBy(o => new { o.Position, o.Id }))
             .FirstAsync();

        var result = Mapper.Map<CodeGenGetOutput>(row);
        result.Fields = row.Fields?.Select(Mapper.Map<CodeGenFieldGetOutput>);
        return result;
    }

    /// <summary>
    /// 删除
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    public async Task DeleteAsync(long id)
    {
        await _codeGenConfigRepository.DeleteCascadeByDatabaseAsync(d => d.CodeGenId == id);
        await _codeGenRepository.DeleteCascadeByDatabaseAsync(d => d.Id == id);

    }

    #region 数据类型有效性检测

    void _ThrowIfNotTypeValid(string[]? autoUsings, string typeName)
    {
        var autoType = Type.GetType(typeName);

        if (autoType == null)
        {
            if (autoUsings != null && autoUsings.Length > 0)
            {
                var autoTypes = AppDomain.CurrentDomain.GetAssemblies()
                    .SelectMany(s =>
                    autoUsings.Select(u => s.GetType(u + "." + typeName))
                    ).Where(w => w != null);

                if (!autoTypes.Any())
                {
                    autoTypes = AppDomain.CurrentDomain.GetAssemblies()
                        .Select(s => s.GetType(typeName)).Where(w => w != null);
                    if (!autoTypes.Any())
                        throw ResultOutput.Exception($"未找到类型[{typeName}]");
                }

                if (autoTypes.Count() > 1)
                {
                    throw ResultOutput.Exception($"类型[{string.Join(',', autoTypes)}]间应用不明确。");
                }
            }
            else
            {
                throw ResultOutput.Exception($"未找到类型[{typeName}]");
            }
        }
    }

    void _ThrowIfNotValid(CodeGenUpdateInput input)
    {
        if (String.IsNullOrWhiteSpace(input.ApiAreaName)) { input.ApiAreaName = "admin"; }
        if (String.IsNullOrWhiteSpace(input.Namespace)) { input.Namespace = "sirhq.app"; }
        if (String.IsNullOrWhiteSpace(input.AuthorName)) { input.AuthorName = "admin"; }
        try
        {
            if (string.IsNullOrEmpty(input.DbKey))
                throw ResultOutput.Exception("数据库选择失效，刷新页面后重试");
            var usings = input.Usings?.Split(';');
            if (input.Fields != null && input.Fields.Count() > 0)
            {
                foreach (var col in input.Fields)
                {
                    if (string.IsNullOrWhiteSpace(col.ColumnName))
                        throw ResultOutput.Exception("列名称不能为空，列名为-时不使用列名。");
                    if (!string.IsNullOrWhiteSpace(col.IncludeEntity))
                        _ThrowIfNotTypeValid(usings, col.IncludeEntity);
                }
            }
        }
        catch (Exception ex)
        {
            throw ResultOutput.Exception($"检测配置有效性异常：{ex.Message}");
        }
    }

    #endregion

    /// <summary>
    /// 更新
    /// </summary>
    /// <param name="input"></param>
    /// <returns></returns>
    [HttpPost]
    [AdminTransaction]
    public async Task UpdateAsync(CodeGenUpdateInput input)
    {
        _ThrowIfNotValid(input);

        var fsql = _cloud.Use(input.DbKey);
        input.DbType = fsql.Ado.DataType.ToString();

        // 将主键转换成唯一索引键
        if (input.BaseEntity != null)
        {
            var priFields = input.Fields?.Where(w => w.IsPrimary);
            if (priFields != null && priFields.Any())
            {
                for (var i = 0; i < priFields.Count(); i++)
                {
                    var el = priFields.ElementAt(i);
                    el.IsPrimary = false;
                    el.IsUnique = true;
                }
            }
        }

        if (input.Id > 0)//更新模式
        {
            if (input.Fields == null)
                input.Fields = new List<CodeGenFieldGetOutput>();

            var tab = await _codeGenRepository.GetAsync(input.Id);
            var cols = await _codeGenConfigRepository.Where(w => w.CodeGenId == input.Id).ToListAsync();

            Mapper.Map(input, tab);

            _codeGenRepository.Update(tab);

            //新增列
            var addCols = input.Fields.Where(w => w.Id == 0).ToList();
            foreach (var c in addCols)
            {
                var col = Mapper.Map<CodeGenFieldEntity>(c);
                col.CodeGenId = input.Id;
                _codeGenConfigRepository.Insert(col);
            }

            //更新列
            var updateCols = input.Fields.Where(w => w.Id > 0 && cols.Select(s => s.Id).Contains(w.Id)).ToList();

            foreach (var c in updateCols)
            {
                var col = cols.Where(w => w.Id == c.Id).FirstOrDefault();
                if (col == null) continue;
                Mapper.Map(c, col);
                _codeGenConfigRepository.Update(col);

            }

            //删除列
            var removeCols = cols.Where(w => w.Id > 0 && !input.Fields.Select(s => s.Id).Contains(w.Id)).ToList();
            foreach (var r in removeCols)
            {
                cols.Remove(r);
                _codeGenConfigRepository.Delete(r);
            }
        }
        else//新增模式
        {
            var genEntiry = Mapper.Map<CodeGenEntity>(input);

            await _codeGenRepository.InsertAsync(genEntiry);
            if (input.Fields != null)
            {
                var genConfigs = Mapper.Map<List<CodeGenFieldEntity>>(input.Fields);

                foreach (var f in genConfigs)
                {
                    f.CodeGenId = genEntiry.Id;
                }
                await _codeGenConfigRepository.InsertAsync(genConfigs);
            }
        }
    }

    void _RazorCompile(IRazorEngineService razor, CodeGenEntity entity, string key, string code, string outfile)
    {
        if (razor == null) return;

        //razor.Compile(new LoadedTemplateSource(code), key);
        using (var fs = new FileStream(outfile, FileMode.Create, FileAccess.Write))
        {
            using (var fw = new StreamWriter(fs, Encoding.UTF8))
            {
                try
                {
                    razor.RunCompile(new LoadedTemplateSource(code), key, fw, entity.GetType(), entity);
                }
                catch (Exception ex)
                {
                    throw new InvalidOperationException(ex.Message);
                }
            }
        }
    }

    /// <summary>
    /// 生成
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    [HttpGet]
    public async Task GenerateAsync(long id)
    {
        //CodeGenConfig _codeGenConfig = ConfigHelper.Get<CodeGenConfig>("codegenconfig");

        if (_codeGenConfig == null)
            throw ResultOutput.Exception("未加载生成配置。");
        if (_codeGenConfig.TemplateOptions == null)
            throw ResultOutput.Exception("未加载生成配置。");

        var gen = await _codeGenRepository
            .Where(w => w.Id == id)
            .IncludeMany<CodeGenFieldEntity>(c => c.Fields.Where(w => w.CodeGenId == c.Id), then => then.OrderBy(o => new { o.Position, o.Id }))
            .FirstAsync();

        if (gen == null)
            throw ResultOutput.Exception(msg: "配置数据不存在。");
        if (String.IsNullOrWhiteSpace(gen.BackendOut)/* || String.IsNullOrWhiteSpace(gen.FrontendOut)*/)
            throw ResultOutput.Exception("未指定输出目录。");

        gen.Fields = gen.Fields.OrderBy(o => o.Position).ThenBy(t => t.Id);
        try
        {
            RazorEngine.Engine.Razor = RazorEngineService.Create(new RazorEngine.Configuration.
                TemplateServiceConfiguration
            {
                EncodedStringFactory = new RazorEngine.Text.RawStringFactory()// Raw string encoding.
            });
        }
        catch (Exception ex)
        {
            RazorEngine.Engine.Razor?.Dispose();
            throw ResultOutput.Exception(msg: "初始化编译器失败：" + ex.Message);
        }

        if (String.IsNullOrWhiteSpace(gen.ApiAreaName))
            gen.ApiAreaName = "admin";

        var errors = new List<string>();

        try
        {
            var genType = gen.GetType();
            var dicProps = new Dictionary<String, String>();
            var getPropValue = new Func<String, String>((propName) =>
            {
                if (dicProps.ContainsKey(propName)) return dicProps[propName];
                var value = "" + genType.GetPropertyValue<string>(gen, propName);// "" + gen.GetType().GetProperty(propName)?.GetValue(gen);
                dicProps.Add(propName, value);
                return value;
            });

            foreach (var option in _codeGenConfig.TemplateOptions)
            {
                if (option.IsDisable) continue;
                foreach (var tpl in option.Templates)
                {
                    if (tpl.IsDisable) continue;
                    var outPath = tpl.OutTo;
                    var outFileName = tpl.Source.Substring(0, tpl.Source.LastIndexOf('.'));//去掉原扩展名

                    foreach (var repl in option.NameReplaces)//属性值替换到路径及生成的文件名
                    {
                        var propValue = getPropValue(repl.PropName);
                        if (repl.NamingConvention != null)
                            propValue = ("" + propValue).Naming(repl.NamingConvention.Value);// NameFormater.GetFormatName(propValue, repl.NamingConvention.Value);
                        outPath = outPath.Replace(repl.Flag, propValue);
                        outFileName = outFileName.Replace(repl.Flag, propValue);
                    }
                    if (!Directory.Exists(outPath))
                        Directory.CreateDirectory(outPath);

                    var codeText = System.IO.File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "Templates", tpl.Source), Encoding.UTF8);

                    try
                    {
                        outPath = Path.Combine(outPath, outFileName);
                        Trace.WriteLine($"开始编译：{tpl.Source} 到 {outPath}");

                        _RazorCompile(RazorEngine.Engine.Razor, gen, tpl.Source, codeText, outPath);
                    }
                    catch (Exception ex)
                    {
                        errors.Add($"生成【{tpl.Source}】到【{outPath}】时发生错误：{ex.Message}");
                    }
                }
            }
            if (errors.Count > 0)
                throw ResultOutput.Exception(string.Join("\n", errors));
        }
        catch (Exception ex)
        {
            throw ResultOutput.Exception(ex.Message);
        }
        finally
        {
            RazorEngine.Engine.Razor.Dispose();
        }
    }

    /// <summary>
    /// 编译
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    [HttpGet]
    public async Task CompileAsync(long id)
    {
        var gen = await _codeGenRepository
            .Where(w => w.Id == id)
            .FirstAsync();
        if (gen == null)
            throw ResultOutput.Exception(msg: "配置数据不存在。");

        var codeFiles = new[] {
            Path.Combine("Domain", gen.EntityName, $"{gen.EntityName}Entity.cs"),
            Path.Combine("Domain", gen.EntityName, $"I{gen.EntityName}Repository.cs"),
            Path.Combine("Repositories", gen.EntityName, $"{gen.EntityName}Repository.cs"),
            Path.Combine("Services", gen.EntityName, $"I{gen.EntityName}Service.cs"),
            Path.Combine("Services", gen.EntityName, $"{gen.EntityName}Service.cs")
        }.Select(s => Path.Combine(gen.BackendOut, s)).Where(w => System.IO.File.Exists(w));

        var excludes = new String[] { "", "System.Threading.AccessControl" };

        try
        {
            var assemblies = new[] { "FreeSql", "ZhonTai.Admin" }
                .Select(s => Assembly.Load(new AssemblyName(s)))
                .Concat(AppDomain.CurrentDomain.GetAssemblies());

            var refs = assemblies.SelectMany(s => s.GetReferencedAssemblies().Select(Assembly.Load));

            assemblies = assemblies.Concat(refs)
                .Where(w => w != null &&
                !string.IsNullOrWhiteSpace(w.Location) &&
                !excludes.Any(a => a == w.FullName)).Distinct();

            var rawAssembly = new Compiler(assemblies).Compile(codeFiles);

            var assembly = AppDomain.CurrentDomain.Load(rawAssembly);

            if (assembly != null)
            {
                var entity = assembly.GetType($"{gen.Namespace}.Domain.{gen.EntityName}.{gen.EntityName}Entity");
                if (entity != null)
                {
                    var fsql = _cloud.Use(gen.DbKey);
                    fsql.CodeFirst.SyncStructure(entity);
                }
            }
        }
        catch (Exception ex)
        {
            throw ResultOutput.Exception(ex.Message);
        }
    }

    #region 生成菜单及权限
    /// <summary>
    /// 生成菜单
    /// </summary>
    /// <param name="id"></param>
    /// <returns></returns>
    [HttpPut]
    [AdminTransaction]
    public async Task GenMenu(long id)
    {
        var gen = _codeGenRepository.Get(id);
        if (gen == null)
            throw ResultOutput.Exception("未找到生成配置。");

        await UpdateMenuAsync(gen, await UpdateViewAsync(gen));
    }

    async Task<Int64> UpdateViewAsync(CodeGenEntity gen)
    {
        var viewRepo = LazyGetRequiredService<IViewRepository>();
        var pView = await viewRepo.Where(w => w.Name == gen.MenuPid || w.Label == gen.MenuPid
            || w.Path == gen.MenuPid).FirstAsync();

        if (pView == null)
            throw ResultOutput.Exception("未找到父视图：" + gen.MenuPid);

        var vName = gen.ApiAreaName?.ToLower() + "/" + gen.EntityName.ToLower();
        var vLabel = gen.BusName + gen.MenuAfterText;
        var vPath = gen.ApiAreaName?.ToLower() + "/" + gen.EntityName.ToLower() + "/index";

        var genView = await viewRepo.Where(w => w.ParentId == pView.Id && w.Path == vPath).FirstAsync();

        if (genView == null)
        {
            genView = new ViewEntity
            {
                ParentId = pView.Id,
                Name = vName,
                Label = vLabel,
                Path = vPath,
            };
            await viewRepo.InsertAsync(genView);
        }

        return genView.Id;
    }

    async Task<long> UpdateMenuAsync(CodeGenEntity gen, Int64 viewId)
    {
        var apiRepo = LazyGetRequiredService<IApiRepository>();
        var apis = await apiRepo.Where(w => w.Path == gen.EntityName.NamingKebabCase())
            .IncludeMany(inc => inc.Childs)
            .FirstAsync();

        if (apis == null)
            throw ResultOutput.Exception("请先进行API同步。");

        var permRepo = LazyGetRequiredService<IPermissionRepository>();
        var pMenu = await permRepo.Where(w => w.Name == gen.MenuPid
        || w.Label == gen.MenuPid || w.Path == gen.MenuPid)
            .IncludeMany(inc => inc.Childs).
            FirstAsync();

        if (pMenu == null)
            throw ResultOutput.Exception("未找到父菜单：" + gen.MenuPid);

        String mName, mPath, mLabel = gen.BusName + gen.MenuAfterText;
        mName = mPath = gen.ApiAreaName?.ToLower() + "/" + gen.EntityName.ToLower()+"/list";
        mPath = "/" + mPath;

        var menu = await permRepo.Where(w => w.ParentId == pMenu.Id && (w.Label == mLabel || w.Path == mPath)).FirstAsync();
        if (menu == null)
        {
            menu = new PermissionEntity
            {
                Label = mLabel,
                ParentId = pMenu.Id,
                Enabled = true,
                Type = PermissionType.Menu,
                ViewId = viewId,
                Path = mPath,
                Name = mName,
                Icon = "ele-Memo",
                Sort = pMenu.Childs.Count > 0 ? pMenu.Childs.Max(m => m.Sort) + 1 : 1
            };
            await permRepo.InsertAsync(menu);
        }

        var menuPerms = await permRepo.Where(w => w.ParentId == menu.Id).ToListAsync();

        var permsToGen = gen.GetPermissionsToGen();

        var permsToRemove = menuPerms.Where(w => !permsToGen.Any(a => a.Code == w.Code));
        var permsToInsert = permsToGen.Where(w => !menuPerms.Any(a => a.Code == w.Code));

        var apiPermRelRepl = LazyGetRequiredService<IPermissionApiRepository>();

        var permsId = menuPerms.Select(s => s.Id);
        var apisId = apis.Childs.Select(s => s.Id).Append(apis.Id);

        var apisRel = await apiPermRelRepl.Where(w => permsId.Contains(w.PermissionId) && apisId.Contains(w.ApiId)).ToListAsync();

        foreach (var m in permsToRemove)
        {
            await permRepo.DeleteAsync(m);
            var apiToDel = apis.Childs.FirstOrDefault(f => f.Path == "/" + m.Code.Replace(":", "/"));
            if (apiToDel != null)
            {
                await apiPermRelRepl.DeleteAsync(apiToDel.Id);
            }
        }

        var order = 1;
        foreach (var m in permsToInsert)
        {

            var permNew = new PermissionEntity
            {
                ParentId = menu.Id,
                Label = m.Label,
                Type = PermissionType.Dot,
                Code = m.Code,
                Sort = order,
            };

            await permRepo.InsertAsync(permNew);
            order++;

            var api = apis.Childs.FirstOrDefault(f => f.Path == "/" + m.Code.Replace(":", "/"));
            if (api != null)
            {
                if (!apisRel.Any(a => a.PermissionId == permNew.Id && a.ApiId == api.Id))
                {
                    apiPermRelRepl.Insert(new PermissionApiEntity { PermissionId = permNew.Id, ApiId = api.Id });
                }
            }
        }
        return menu.Id;
    }

    #endregion
}