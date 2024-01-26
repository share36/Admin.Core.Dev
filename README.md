
基于 Admin.Core 和 admin.ui.plus 的代码生成扩展程序

可生成完整的 Entity、Repository、Service 后台代码
可生成包含CURD操作的前端界面
可将生成的实体类结构同步到数据库
可自动添加视图、权限项

### 列属性说明
列名：实体类字段名称  当字段名为 -_> 三个的任意一个字符时，此字段名不包含在实体中（一般在外联字段时使用，只生成外联字段名）
类型：.Net数据类型
标题：字段显示名称
数据库类型：不使用FreeSql的默认类型映射时填写指定的数据库类型
数据库列名：自定义数据库列名称

列顺序：调整列的显示序号与同步数据库结构时的列顺序

列：GetList接口是否包含此字段
表：GetPage接口是否包含此字段
增：控制该字段是否为新增时的写入字段
改：控制该字段是否为更新时的写入字段
查：控制该字段是否为查询条件

字典编码：当字段的取值来源为字典时，填写字典编码，前端为el-select组件输入方式

外联实体：外联到其它实体时填写（跟外联方式配合使用），可填写完成的实体名称（含命名空间）
外联字段：外联实体的关联字段（留空时为FreeSql的默认关联）

选中文本字段：
选中值字段：

- 编辑器 为 el-select 且  不是外联字段 时，可控制 选项的显示文本与选择值，多个之间用英文,分隔，当其中一方的数量少于另一方时，其对应位的取值为空

- 前端的外联处理功能还未实现自动生成功能

父级字段：预留

### 基础配置说明

表名：同步结构时的数据库表名称
业务名：生成的服务、权限项的名称（会在内容扣加 管理 ）
Api分区：AdminCore 的 Api Area
命名空间：生成代码的 命名空间
实体名：生成的实体类名称（会自动加入 Entity 后缀）
基类：基础类型 -> EntityBase 和 租户基础类型 -> EntityTenant

父菜单：生成权限项时的父级项

命名导入：生成代码时包含的命名空间导入，多个用;分隔

服务项包含：默认包含 Add、Update、Delete、Get、GetPage，这里可自已选择是否包含（GetList，BatchDelete、SoftDelete，BatchSoftDelete）

### 如何使用
#### 后端部分
- 在 ZhonTai.Host 添加对 ZhonTai.Admin.Dev 的项目引用
- 修改 ZhonTai.Host 项目 Config\appconfig.json 配置
    - assemblyNames：`[... "ZhonTai.Admin.Dev" ]`
    - swagger节点projects增加项 `[...{"name":"代码生成","code":"dev","version":"v0.0.1","description":""}]`
- 已在开发环境对CodeGenService忽略权限,前端直接显示代码生成，不需要加到数据库视图权限中
    ``` cs
    #if DEBUG
    [AllowAnonymous]
    #endif
    public partial class CodeGenService{}
    ```
- 运行ZhonTai.Host,可获得dev模块的swagger地址：http://localhost:8000/admin/swagger/dev/swagger.json
- 
#### 前端部分
- 复制 [admin.ui.plus.dev](https://github.com/share36/admin.ui.plus.dev) 的 views 文件到前端项目
- 修改前端 /gen/gen-api.js 文件,添加代码生成器模块配置，执行`npm run gen:api`即可生成dev模块的接口模型定义的相关代码
    ``` js
    [
        {
            output: path.resolve(__dirname, '../src/api/admin'),
            url: 'http://localhost:8000/admin/swagger/admin/swagger.json',
        },
        //添加模块
        {
            output: path.resolve(__dirname, '../src/api/dev'),
            url: 'http://localhost:8000/admin/swagger/dev/swagger.json',
        }
    ]
    ```
- 修改/src/router/route.ts,将生成器节点添加到 '/example'前面即可
  ```js
  [
        {
          path: '/dev',
          name: 'dev',
          redirect: '/dev/codegen',
          meta: {
            title: '生成器',
            isLink: '',
            isHide: false,
            isKeepAlive: true,
            isAffix: false,
            isIframe: false,
            roles: ['admin'],
            icon: 'iconfont icon-zujian',
          },
          children: [
            {
              path: '/dev/codegen',
              name: '/dev/codegen',
              component: () => import('/@/views/dev/codegen/index.vue'),
              meta: {
                title: '代码生成',
                isLink: '',
                isHide: false,
                isKeepAlive: true,
                isAffix: false,
                isIframe: false,
                roles: ['admin'],
                icon: 'iconfont icon-zujian',
              },
            }]
        },
        //...{path: '/example',...}
  ]
  ```