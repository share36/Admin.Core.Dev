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