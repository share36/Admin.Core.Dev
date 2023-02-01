namespace ZhonTai.Admin.Services.DictionaryTree
{
    public partial interface IDictionaryTreeService
    {
        Task<IEnumerable<Dto.DictionaryTreeOutput>> GetAsync(string? codes);
    }

}

namespace ZhonTai.Admin.Services.DictionaryTree.Dto
{

    public class DictionaryTreeOutput
    {
        public long Id { get; set; }
        /// <summary>
        /// 字典名称
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// 字典编码
        /// </summary>
        public string Code { get; set; }

        public IEnumerable<DictionaryTreeOutput>? Childrens { get; set; }
    }
}