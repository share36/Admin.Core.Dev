/*
Author       : SirHQ
Create Data  : 2023-01-09
Description  : 中台Admin代码生成扩展
Project Name : ZhonTai.Admin.Dev

github : https://github.com/share36/Admin.Core.Dev
gitee  : https://gitee.com/share36/Admin.Core.Dev
*/

namespace ZhonTai.Admin.Services.DictionaryTree
{
    /// <summary>
    /// 数据字典树服务
    /// </summary>
    public partial interface IDictionaryTreeService
    {
        /// <summary>
        /// 查询
        /// </summary>
        /// <param name="codes"></param>
        /// <returns></returns>
        Task<IEnumerable<Dto.DictionaryTreeOutput>> GetAsync(string? codes);
    }

}

namespace ZhonTai.Admin.Services.DictionaryTree.Dto
{
    /// <summary>
    /// 数据字典树输出
    /// </summary>
    public class DictionaryTreeOutput
    {
        /// <summary>
        /// 
        /// </summary>
        public long Id { get; set; }
        /// <summary>
        /// 字典名称
        /// </summary>
        public string Name { get; set; } = String.Empty;

        /// <summary>
        /// 字典编码
        /// </summary>
        public string Code { get; set; } = String.Empty;
        /// <summary>
        /// 
        /// </summary>
        public IEnumerable<DictionaryTreeOutput>? Childrens { get; set; }
    }
}