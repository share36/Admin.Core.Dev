using FreeSql.Internal;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

#pragma warning disable CS1591, CS8618

namespace ZhonTai.Admin.Core.Configs
{
    public class CodeGenConfig
    {
        TemplateOption[]? _templateOptions;

        public DefaultCodegenOption? DefaultOption { get; set; }

        public TemplateOption[] TemplateOptions
        {
            get
            {
                if (_templateOptions != null) return _templateOptions; return new TemplateOption[0];
            }
            set { _templateOptions = value; }
        }
    }
    public class DefaultCodegenOption
    {
        public string AuthorName { get; set; } = "SirHQ";
        public string BackendOut { get; set; } = "";
        public string FrontendOut { get; set; } = "";

        public string Namespace { get; set; } = "";
        public string ApiAreaName { get; set; } = "";
        public string Usings { get; set; } = "";
        /// <summary>
        /// 菜单后缀
        /// </summary>
        public string MenuAfterText { get; set; } = "管理";
    }

    public class TemplateOption
    {
        public bool IsDisable { get; set; }

        TemplateItemOption[]? _templates;

        NameReplaceOption[]? _nameReplaces;

        public NameReplaceOption[] NameReplaces
        {
            get
            {
                if (_nameReplaces != null) return _nameReplaces;
                return new NameReplaceOption[0];
            }
            set { _nameReplaces = value; }
        }

        public TemplateItemOption[] Templates
        {
            get
            {
                if (_templates != null)
                    return _templates;
                return new TemplateItemOption[0];
            }
            set { _templates = value; }
        }

    }
    public class NameReplaceOption
    {
        public string Flag { get; set; } = "";
        public string PropName { get; set; } = "";
        public DynamicApi.Enums.NamingConventionEnum? NamingConvention { get; set; }
    }
    public class TemplateItemOption
    {
        public bool IsDisable { get; set; }

        public string Source { get; set; } = "";
        public string OutTo { get; set; } = "";
    }
}

#pragma warning restore