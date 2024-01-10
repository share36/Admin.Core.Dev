@using ZhonTai.Admin.Services.CodeGen;
@using ZhonTai.DynamicApi.Enums;
@{
    var gen = Model as ZhonTai.Admin.Domain.CodeGen.CodeGenEntity;
    if (gen == null) return;
    if (gen.Fields == null) return;
    if (gen.Fields.Count() == 0) return;

    var areaName = "" + gen.ApiAreaName;
    var entityName = "" + gen.EntityName;

    var areaNamePc = areaName.NamingPascalCase();
    var entityNamePc = entityName.NamingPascalCase();

    var areaNameKc = areaName.NamingKebabCase();// KebabCase(areaName);
    var entityNameKc = entityName.NamingKebabCase();// KebabCase(entityName);

    var areaNameCc = areaName.NamingCamelCase();// camelCase(areaName);
    var entityNameCc = entityName.NamingCamelCase();// camelCase(entityName);

    var at = "@";
    var apiName = entityName + "Api";

    var permissionArea = string.Concat(areaNameKc, ":", entityNameKc);

    var queryColumns = gen.Fields.Where(w => w.WhetherQuery);

    var defineUiComponentsImportPath = new Dictionary<string, string>()
    {
        //{"my-select-dictionary","@/components/my-select-window/dictionary" },
        //{"my-role","@/components/my-select-window/role" },
        //{"my-user","@/components/my-select-window/user"},
        //{"my-position","@/components/my-select-window/position" }
    };
    var uiComponentsMethodName = new Dictionary<string, string>()
    {
        //{"my-select-dictionary","onOpenDic" },
        //{"my-role","onOpenRole" },
        //{"my-user","onOpenUser" },
        //{"my-position","onOpenPosition" }
    };
    var editors = gen.Fields.Select(s => s.Editor).Distinct();
    var uiComponentsInfo = editors
        .Where(w => defineUiComponentsImportPath.Keys.Contains(w))
        .Select(s => new { ImportName = s.NamingPascalCase(), ImportPath = defineUiComponentsImportPath[s] });



    // 获取数据输入控件
    string editorName(ZhonTai.Admin.Domain.CodeGen.CodeGenFieldEntity col, out string attrs, out string innerBody)
    {
        attrs = string.Empty;
        innerBody = string.Empty;
        var editorName = col.Editor;
        if (String.IsNullOrWhiteSpace(editorName)) editorName = "el-input";
        if (!string.IsNullOrWhiteSpace(col.DictTypeCode))
        {
            editorName = "el-select";
            if( col.IsNullable)attrs += " clearable ";
            innerBody = string.Concat("<el-option v-for=", "\"item in state.dicts['", col.DictTypeCode, "']\" :key=\"item.code\" :value=\"item.code\" :label=\"item.name\" />");
        }
        else if (col.Editor == "el-select")
        {
            editorName = col.Editor;
            if (col.IsNullable) attrs += " clearable ";
            if(!String.IsNullOrWhiteSpace(col.DisplayColumn) || !String.IsNullOrWhiteSpace(col.ValueColumn))
            {
                var labels = (""+col.DisplayColumn).Split(',');
                var values = ("" + col.ValueColumn).Split(',');
                var cout = labels.Length;
                if (values.Length > cout) cout = values.Length;
                for(var i = 0; i < cout; i++)
                {
                    innerBody += string.Concat("<el-option value=\"" + (values.Length > i ? values[i] : "") + "\" label=\"" + (labels.Length > i ? labels[i] : "") + "\" />");
                }
            }
        }
        else if(col.Editor == "el-password")
        {
            editorName = "el-input";
            attrs += "type=\"password\"";
        }
        else if(col.Editor == "el-datetime-picker"){
            editorName = "el-date-picker";
            attrs +="type=\"datetime\" value-format=\"YYYY-MM-DD HH:mm:ss\"";
        }
        else if(col.Editor == "el-upload"){
            editorName = "el-upload";
            attrs += " ref=\"uploadRef" + col.ColumnName.NamingPascalCase() + "\" :auto-upload=\"false\" :action=\"uploadAction\"";
            attrs += " :headers=\"uploadHeaders\" :data=\"{fileDirectory:'',fileReName:true}\" :show-file-list=\"false\"";
            attrs += " :before-upload=\"beforUnload\"";
            attrs += " :on-success=\"onUploadSuccess\" :on-error=\"onUploadError\"";

            innerBody += "<template #trigger><el-button type=\"primary\">选择文件...</el-button></template>";
        }
        else if(defineUiComponentsImportPath.Keys.Any(a => a == col.Editor))
        {
            attrs = attrs + " class=\"input-with-select\" ";
            innerBody = "<el-button slot=\"append\" icon=\"el-icon-more\" @click=\"" + uiComponentsMethodName[col.Editor] + "('editForm','" + col.DictTypeCode + "','" + col.Title + "')\" />";
        }

        return editorName;
    }

    var dictCodes = gen.Fields.Where(w => "dict" == w.EffectType || !String.IsNullOrWhiteSpace(w.DictTypeCode)).Select(s => s.DictTypeCode);// editors.Any(a => a == "my-select-dictionary");
    var hasDict = dictCodes.Any();
    var includeFields = gen.Fields.Where(w => !String.IsNullOrWhiteSpace(w.IncludeEntity));

    var hasEncrypt = gen.Fields.Any(a => a.EncryptTrans);

    var hasUpload = gen.Fields.Any(a => a.Editor == "el-upload");

    string jsBool(Boolean exp){
        return exp ? "true" : "false";
    }
}
@{ 
    string attributes, inner;
}
<template>
  <div style="padding: 0px 8px">
    <!--查询-->
    <el-card shadow="never" :body-style="{ paddingBottom: '0' }" style="margin-top: 8px">
      <el-form inline :model="state.filterModel">
                @foreach (var col in queryColumns.Where(w=>!w.IsIgnoreColumn()))
                {
                    var editor = editorName(col, out attributes, out inner);
        @:<el-form-item>
        @:  <@(editor) @if(!attributes.Contains("clearable"))@("clearable") @(attributes) v-model="state.filterModel.@(col.ColumnName.NamingCamelCase())" placeholder="@(col.Title)" @(at)keyup.enter="onQuery" >
        if(!string.IsNullOrWhiteSpace(inner)){
        @:    @(inner)
        }
        @:  </@(editor)>
        @:</el-form-item>
                }
                @if (queryColumns.Count() > 0)
                {
        @:<el-form-item v-auth="perms.getPage">
        @:  <el-button type="primary" icon="ele-Search" @(at)click="onQuery">查询</el-button>
        @:</el-form-item>
                }
@if(gen.GenAdd){
@:        <el-form-item v-auth="perms.add">
@:          <el-button type="primary" icon="ele-Plus" @(at)click="onAdd">新增</el-button>
@:        </el-form-item>
}
        @if(gen.GenBatchDelete || gen.GenBatchSoftDelete){
        @:<el-form-item v-auths="[perms.batDelete, perms.batSoftDelete]" >
        if(gen.GenBatchSoftDelete){
        @:  <el-button v-if="auth(perms.batSoftDelete)" type="warning" :disabled="state.sels.length==0" :placement="'bottom-end'" @(at)click="onBatchSoftDelete" icon="ele-DeleteFilled">批量软删除</el-button>
        }
        if(gen.GenBatchDelete){
        @:  <el-button v-if="auth(perms.batDelete)" type="danger" :disabled="state.sels.length==0" :placement="'bottom-end'" @(at)click="onBatchDelete" icon="ele-Delete">批量删除</el-button>
        }
        @:</el-form-item>
        }
       </el-form>
     </el-card>

    <!--列表-->
    <el-card shadow="never" style="margin-top: 8px">
      <el-table size="small" v-loading="state.listLoading" :data="state.@(entityNameCc)s" row-key="id" @(at)selection-change="selsChange" >
        <template #empty>
          <el-empty :image-size="100" />
        </template>
        @if(gen.GenBatchDelete||gen.GenBatchSoftDelete){
        @:<el-table-column type="selection" width="50" />
        }
            @foreach (var col in gen.Fields.Where(w => w.WhetherTable && !w.IsIgnoreColumn()))
            {
        @:<el-table-column prop="@(col.ColumnName.NamingCamelCase())@if(!string.IsNullOrWhiteSpace(col.DictTypeCode))@("DictName")" label="@(col.Title)" show-overflow-tooltip width />
            }
        <el-table-column v-auths="[perms.update,perms.softDelete,perms.delete]" label="操作" :width="actionColWidth" fixed="right">
          <template #default="{ row }">
@if(gen.GenUpdate){
@:            <el-button v-if="auth(perms.update)" icon="ele-EditPen" size="small" text type="primary" @(at)click="onEdit(row)">编辑</el-button>
}
            @if(gen.GenSoftDelete){
            @:<el-dropdown v-if="authAll([perms.delete,perms.softDelete])" style="margin:5px 0 0 5px;">
            @:  <span><el-icon class="el-icon--right"><component :is="'ele-ArrowDown'" /></el-icon></span>
            @:  <template #dropdown>
            @:    <el-dropdown-menu>
            @:      <el-dropdown-item v-if="auth(perms.delete)" @(at)click="onDelete(row)" icon="ele-Delete">删除</el-dropdown-item>
            @:      <el-dropdown-item v-if="auth(perms.softDelete)" @(at)click="onSoftDelete(row)" icon="ele-DeleteFilled">软删除</el-dropdown-item>
            @:    </el-dropdown-menu>
            @:  </template>            
            @:</el-dropdown>
            @:<span v-else style="margin-left:5px;height:inherit">
            @:  <el-button text type="warning" v-if="auth(perms.softDelete)" style="height:inherit" @(at)click="onDelete(row)" icon="ele-DeleteFilled">软删除</el-button>
            @:  <el-button text type="danger" v-if="auth(perms.delete)" style="height:inherit" @(at)click="onDelete(row)" icon="ele-Delete">删除</el-button>
            @:</span>
            }else{
            @:<el-button text type="danger" v-if="auth(perms.delete)" @(at)click="onDelete(row)" icon="ele-Delete">删除</el-button>
            }
          </template>
        </el-table-column>
      </el-table>

      <!--分页-->
      <div class="my-flex my-flex-end" style="margin-top: 20px">
        <el-pagination ref="pager" small background :total="state.total" :page-sizes="[10, 20, 50, 100]"
           v-model:currentPage="state.pageInput.currentPage"
           v-model:page-size="state.pageInput.pageSize"
           @(at)size-change="onSizeChange" @(at)current-change="onCurrentChange"
           layout="total, sizes, prev, pager, next, jumper"/>
      </div>
    </el-card>

@if(gen.GenAdd || gen.GenUpdate){    
@:    <el-drawer direction="rtl" v-model="state.formShow" :title="state.formTitle">
@:      <el-form :model="state.formData" label-width="100" style="margin:8px;"
@:        :rules="state.editMode=='add'?addRules:updateRules" ref="dataEditor">
      @foreach(var col in gen.Fields.Where(w=>!w.IsIgnoreColumn() && ( w.WhetherAdd || w.WhetherUpdate )))
      {
        var editor = editorName(col, out attributes, out inner);
        @:<el-form-item label="@(col.Title)" prop="@(col.ColumnName.NamingCamelCase())" v-show="editItemIsShow(@jsBool(col.WhetherAdd), @jsBool(col.WhetherUpdate))">
        @:  <@(editor) @(attributes) v-model="state.formData.@(col.ColumnName.NamingCamelCase())" placeholder="@(col.Comment)" >
        if(!string.IsNullOrWhiteSpace(inner)){
        @:    @(inner)
        }
        @:  </@(editor)>
        @:</el-form-item>
      }
@:      </el-form>
@:      <template #footer>
@:        <el-card>
@:          <el-button @(at)click="state.formShow = false">取消</el-button>
          @if(!hasUpload)
          {
@:          <el-button type="primary" @(at)click="submitData(state.formData)">确定</el-button>
          }else{
@:          <el-button type="primary" @(at)click="submitUpload">确定</el-button>
          }
@:        </el-card>
@:      </template>
@:    </el-drawer>
}
  </div>
</template>

<script lang="ts" setup name="@(areaNameCc)/@(entityNameCc)">
import { ref, reactive, @if(hasUpload){@("computed, ");}onMounted, getCurrentInstance, onUnmounted, defineAsyncComponent } from 'vue'
import { FormRules } from 'element-plus'
@if(hasUpload){
@:import { useUserInfo } from '/@(at)/stores/userInfo'
@:import pinia from '/@(at)/stores/index'
@:import { storeToRefs } from 'pinia'
@:import { AxiosResponse } from 'axios'
@:import { ResultOutputFileEntity } from '/@(at)/api/admin/data-contracts'
@:import type { UploadInstance } from 'element-plus'
}
import { PageInput@(entityNamePc)GetPageInput, @(entityNamePc)GetPageInput, @(entityNamePc)GetPageOutput, @(entityNamePc)GetOutput, 
@if(gen.GenAdd){
@:	@(entityNamePc)AddInput,
}
@if(gen.GenUpdate){
@:	@(entityNamePc)UpdateInput,
}
@if(gen.GenGetList){
@:  @(entityNamePc)GetListInput, @(entityNamePc)GetListOutput,
}
@{
    if (includeFields.Any())
    {
        foreach(var incField in includeFields)
        {
            if (incField.IncludeMode == 1)
            {
@:  @(incField.IncludeEntity.Replace("Entity", ""))GetListOutput,
            }
            else
            {
@:  @(incField.IncludeEntity.Replace("Entity", ""))GetOutput,
            }
        }
    }
    if(gen.Fields.Any(a=>a.EncryptTrans)){
@:  KeyValuePairStringString,
    }
}
} from '/@(at)/api/@(areaNameKc)/data-contracts'
import { @(apiName) } from '/@(at)/api/@(areaNameKc)/@(entityNamePc)'
@if (includeFields.Any())
{
    foreach(var incField in includeFields)
    {
        var incEntityName = incField.IncludeEntity.Replace("Entity", "");
@:import { @(incEntityName)Api } from '/@(at)/api/@(areaNameKc)/@(incEntityName)'
    }
}
import eventBus from '/@(at)/utils/mitt'
import { auth, auths, authAll } from '/@(at)/utils/authFunction'

    @if (hasDict)
    {
@:import { DictonaryTreeApi, DictionaryTreeOutput } from '/@(at)/api/admin/DictionaryTree'        
    }
    @foreach (var comp in uiComponentsInfo)
    {
@:import @(comp.ImportName) from '@(comp.ImportPath)'
    }


const { proxy } = getCurrentInstance() as any
@if(hasUpload){
@:const storesUserInfo = useUserInfo(pinia)

@foreach(var field in gen.Fields.Where(w=>w.Editor=="el-upload")){
@:const uploadRef@(field.ColumnName.NamingPascalCase()) = ref<UploadInstance>()
}
}

const dataEditor = ref()

const perms = {
  get:'api:@(permissionArea):get',
  getList:'api:@(permissionArea):get-list',
  getPage:'api:@(permissionArea):get-page',
  add:'api:@(permissionArea):add',
  update:'api:@(permissionArea):update',
  delete:'api:@(permissionArea):delete',
  batDelete:'api:@(permissionArea):batch-delete',
  softDelete:'api:@(permissionArea):soft-delete',
  batSoftDelete:'api:@(permissionArea):batch-soft-delete',
}

const actionColWidth = authAll([perms.delete,perms.softDelete])?85:auths([perms.delete,perms.softDelete])?135:70;

const formRules = reactive<FormRules>({
@foreach (var f in gen.Fields.Where(w=>!w.IsIgnoreColumn() && ( w.WhetherAdd || w.WhetherUpdate ) && !w.IsNullable))
{
@:  @(f.ColumnName.NamingCamelCase()):[{ required: true, message: '@(f.Title)不能为空！', trigger: '@(f.FrontendRuleTrigger)'}],
}
})

const addRules = {
@foreach (var f in gen.Fields.Where(w=>!w.IsIgnoreColumn() && w.WhetherAdd && !w.IsNullable))
{
@:  @(f.ColumnName.NamingCamelCase()): formRules.@(f.ColumnName.NamingCamelCase()),
}
}
const updateRules = {
@foreach (var f in gen.Fields.Where(w=>!w.IsIgnoreColumn() && w.WhetherUpdate && !w.IsNullable))
{
@:  @(f.ColumnName.NamingCamelCase()): formRules.@(f.ColumnName.NamingCamelCase()),
}
}

@{
	var formDataTypes = new List<String>();
	if(gen.GenAdd)formDataTypes.Add("AddInput");
	if(gen.GenUpdate)formDataTypes.Add("UpdateInput");
	var formDataTypeStr = "Object";
	if(formDataTypes.Count>0)
		formDataTypeStr = String.Join(" | ", formDataTypes.Select(s=>entityNamePc+s));
}

const state = reactive({
  listLoading: false,
  formTitle: '',
  editMode: 'add',
  formShow: false,
  formData: {} as @(formDataTypeStr),//@(entityNamePc)AddInput | @(entityNamePc)UpdateInput,
  sels: [] as Array<@(entityNamePc)GetPageOutput>,
  filterModel: {
@foreach(var f in queryColumns.Where(w=>!w.IsIgnoreColumn())){
@:    @(f.ColumnName.NamingCamelCase()): null,
}
  } as @(entityNamePc)GetPageInput @if(gen.GenGetList)@("| " + entityNamePc+"GetListInput"),
  total:0,
  pageInput:{
    currentPage: 1,
    pageSize: 20,
  } as PageInput@(entityNamePc)GetPageInput,
  @(entityNameCc)s: [] as Array<@(entityNamePc)GetPageOutput>,
  @if(gen.GenGetList){
  @:@(entityNameCc)List: [] as Array<@(entityNamePc)GetListOutput>,
  }
    @if(hasUpload){
  @:token: storesUserInfo.getToken(),
  @:fileUploading: false,
    }
    @if (hasDict)
    {
  @://字典相关
  @:dictSelectorTitle: '字典内容选择',
  @:dictType: '',
  @:dictForm: null,
  @:dictVisible: false,
  @:dicts:{
    foreach (var d in dictCodes)
    {
    @:"@(d)": [] as DictionaryTreeOutput[],
    }
  @:}
    }
})

@if(hasUpload){
@:const uploadHeaders = computed(()=>{ return { Authorization: 'Bearer ' + state.token } })
@:const addUploadAction = computed(()=>{ return import.meta.env.VITE_API_URL + '/api/@(areaNameKc)/@(entityNameKc)/add'})
@:const updateUploadAction = computed(()=>{ return import.meta.env.VITE_API_URL + '/api/@(areaNameKc)/@(entityNameKc)/update'})
@:const uploadAction = computed(()=>{ return import.meta.env.VITE_API_URL + '/api/admin/file/upload-file'})
@://const uploadAction = ()=>{ return state.editMode=='add'?addUploadAction:updateUploadAction }
@:
@:const beforUnload=() => {
@:  //自定义上传前验证逻辑，验证不通过时 return false
  
@:  state.token = storesUserInfo.getToken()
@:  state.fileUploading = true

@:  return true
@:}
@:
@:const onUploadSuccess = (res: ResultOutputFileEntity) =>{
@:    state.fileUploading = false
@:    if (!res?.success) {
@:        if (res.msg) {
@:            proxy.$model?.msgError(res.msg)
@:        }
@:        return
@:    }
@:    // 上传成功后的处理操作
@:    state.formData.fileId=res.data?.id
@:    submitData(state.formData);
@:}
@:
@:const onUploadError = (error: any) => {
@:    state.fileUploading = false
@:    let message = ''
@:    if (error.message) {
@:        try{
@:            message = JSON.parse(error.message)?.msg
@:        } catch (err) {
@:            message = error.message || ''
@:        }
@:    }
@:    if (message) proxy.$model?.msgError(message)
@:}
@:
@:const submitUpload = () =>{
@:  dataEditor?.value?.validate(async (valid: boolean) => {
@:    if (!valid) return
@:
@foreach(var field in gen.Fields.Where(w=>w.Editor=="el-upload")){
@:   uploadRef@(field.ColumnName.NamingPascalCase()).value!.submit()
}
@:  })
@:
@:}
}

const editItemIsShow = (add: Boolean, edit: Boolean): Boolean => {
    if(add && edit)return true;
    if(add && state.editMode == 'add')return true;
    if(edit && state.editMode == 'edit')return true;
    return false;
}

onMounted(()=>{
  onQuery()
    @if (hasDict)
    {
@:  getDictsTree()
    }
})

onUnmounted(()=>{

})

@if (hasDict)
{
@://获取需要使用的字典树
@:const getDictsTree = async () => {
@:  let res = await new DictonaryTreeApi().get({codes:'@(string.Join(',', dictCodes))'})
@:  if(!res?.success)return;
@:  for(var i in res.data){
@:    let item = res.data[i]
@:    let key = item.code
@:    let values = item.childrens
@:    state.dicts[key]= values
@:  }
@:}
}

const showEditor = () => {
  state.formShow = true
  dataEditor?.value?.resetFields()
}
@if(gen.GenAdd){
@:const defaultToAdd = (): @(entityNamePc)AddInput => {
@:  return {
@foreach(var col in gen.Fields.Where(w=>!w.IsIgnoreColumn())){
@:    @(col.ColumnName.NamingCamelCase()): @(col.GetDefaultValueStringScript()),
}
@:  } as @(entityNamePc)AddInput
@:}
}

const onQuery = async () => {
  state.listLoading = true
  
  var queryParams = state.pageInput;
  queryParams.filter = state.filterModel;
  queryParams.dynamicFilter = {};

  const res = await new @(apiName)().getPage(queryParams)

  state.@(entityNameCc)s = res?.data?.list ?? []
  state.total = res?.data?.total ?? 0
  state.listLoading = false
}

const onSizeChange = (val: number) => {
  state.pageInput.pageSize = val
  onQuery()
}

const onCurrentChange = (val: number) => {
  state.pageInput.currentPage = val
  onQuery()
}

const selsChange = (vals: @(entityNamePc)GetPageOutput[]) => {
  state.sels = vals
}

const onAdd = () => {
  state.editMode = 'add'
  state.formTitle = '新增@(gen.BusName)'
@if(gen.GenAdd){
@:  state.formData = defaultToAdd()
}
  showEditor()
}

const onEdit = async (row: @(entityNamePc)GetOutput) => {
  state.editMode = 'edit'
  state.formTitle = '编辑@(gen.BusName)'
@if(gen.GenUpdate){
@:  const res = await new @(apiName)().get({id: row.id}, { loading: true})
@:  if (res?.success) {
@:    showEditor()
@:    state.formData = res.data as @(entityNamePc)UpdateInput
@:  }
}
}

const onDelete = async (row: @(entityNamePc)GetOutput) => {
  proxy.$modal?.confirmDelete(`确定要删除？`).then(async () =>{
@if(gen.GenDelete){
@:      const rst = await new @(apiName)().delete({ id: row.id }, { loading: true, showSuccessMessage: true })
@:      if(rst?.success){
@:        onQuery()
@:      }
}
    })
}

@if(gen.GenAdd){
@:const onAddPost = async (addData: @(entityNamePc)AddInput) => {
@:  const res = await new @(apiName)().add(addData, { loading: true, showSuccessMessage: true })
@:  if (res?.success) {
@:    onQuery()
@:    state.formShow = false
@:  }
@:}
}

@if(gen.GenUpdate){
@:const onUpdatePost = async (updateData: @(entityNamePc)UpdateInput) => {
@:  const res = await new @(apiName)().update(updateData, { loading: true, showSuccessMessage: true })
@:  if (res?.success) {
@:    onQuery()
@:    state.formShow = false
@:  }
@:}
}

const submitData = async (editData: @(formDataTypeStr)/*@(entityNamePc)AddInput | @(entityNamePc)UpdateInput*/) => {
  dataEditor?.value?.validate(async (valid: boolean) => {
    if (!valid) return

    @if (gen.Fields.Any(a=>a.EncryptTrans)){
    @:let encInfo = await getEncryptInfo();
    @:editData.encryptKey = encInfo.key
    @:let encrypt = proxy.$crypto
    }

    if (state.editMode == 'add') {
@if(gen.GenAdd){
    @if (gen.Fields.Any(a=>a.EncryptTrans)){
      foreach(var field in gen.Fields.Where(w=>w.EncryptTrans)){
        var colName = field.ColumnName.NamingCamelCase();
      @:if (editData.@(colName))
        @:editData.@(colName) = encrypt.encryptByDES(editData.@(colName), encInfo.value)
      }
    }
@:      onAddPost(editData as @(entityNamePc)AddInput)
}
    } else if (state.editMode == 'edit') {
@if(gen.GenUpdate){
@:      onUpdatePost(editData as @(entityNamePc)UpdateInput)
}
    }
  })
}

@if(gen.GenBatchDelete){
@:const onBatchDelete = async () => {
@:  proxy.$modal?.confirmDelete(`确定要删除选择的${state.sels.length}条记录？`).then(async () =>{
@:    const rst = await new @(apiName)().batchDelete(state.sels.map(item=>item.id) as Array<number>, { loading: true, showSuccessMessage: true })
@:    if(rst?.success){
@:      onQuery()
@:    }
@:  })
@:}
}

@if(gen.GenSoftDelete){
@:const onSoftDelete = async (row: @(entityNamePc)GetOutput) => {
@:  proxy.$modal?.confirmDelete(`确定要移入回收站？`).then(async () =>{
@:    const rst = await new @(apiName)().softDelete({ id: row.id }, { loading: true, showSuccessMessage: true })
@:    if(rst?.success){
@:      onQuery()
@:    }
@:  })
@:}
}

@if(gen.GenBatchSoftDelete){
@:const onBatchSoftDelete = async () => {
@:  proxy.$modal?.confirmDelete(`确定要将选择的${state.sels.length}条记录移入回收站？`).then(async () =>{
@:    const rst = await new @(apiName)().batchSoftDelete(state.sels.map(item=>item.id) as Array<number>, { loading: true, showSuccessMessage: true })
@:    if(rst?.success){
@:      onQuery()
@:    }
@:  })
@:}

@if(gen.Fields.Any(a=>a.EncryptTrans)){
@:const getEncryptInfo = async (): KeyValuePairStringString => {
@:  const rst  = await new @(apiName)().getEncryptInfo()
@:  if(rst?.success)return rst.data
@:  return null
@:}
}
}

</script>

<script lang="ts">
import { defineComponent } from 'vue'
export default defineComponent({
  name: '@(areaNameCc)/@(entityNameCc)'
})
</script>