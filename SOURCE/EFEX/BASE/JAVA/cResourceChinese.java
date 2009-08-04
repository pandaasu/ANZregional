/**
 * Package : ISI Efex
 * Type    : Class
 * Name    : cResourceChinese
 * Author  : Steve Gregan
 * Date    : June 2008
 */
package com.isi.efex;

/**
 * This class implements the Efex application resource chinese class. This class
 * implements the application chinese resources strings.
 */
public final class cResourceChinese extends cResourceBundle {
   
   /**
    * Constructs a new instance
    */
   public cResourceChinese() {
   
      //
      // Command resources
      //
      objResourceStore.put("CMDEXIT", "退出");
      objResourceStore.put("CMDBACK", "返回");
      objResourceStore.put("CMDNEXT", "下一步");
      objResourceStore.put("CMDSELECT", "选择");
      objResourceStore.put("CMDSEARCH", "查找");
      objResourceStore.put("CMDCREATE", "新建");
      objResourceStore.put("CMDUPDATE", "修改");
      objResourceStore.put("CMDCLEAR", "清除");
      objResourceStore.put("CMDDELETE", "删除");
      objResourceStore.put("CMDSAVE", "保存");
      objResourceStore.put("CMDEDIT", "编辑");
      objResourceStore.put("CMDCANCEL", "取消");
      objResourceStore.put("CMDACCEPT", "确认");
      objResourceStore.put("CMDCHANNEL", "渠道");
      objResourceStore.put("CMDYES", "是");
      objResourceStore.put("CMDNO", "否");
      
      //
      // Constant resources
      //
      objResourceStore.put("CONACTIVE", "活动");
      objResourceStore.put("CONINACTIVE", "关闭");
      objResourceStore.put("CONYES", "*是");
      objResourceStore.put("CONNO", "*否");
      objResourceStore.put("CONALL", "*全部");
      objResourceStore.put("CONCONFIRMCANCEL", "确认取消操作？");
      objResourceStore.put("CONCONNECTERROR", "您和网络的连接已断开。请检查手机信号强度，稍后再试。");
      objResourceStore.put("CONNODATA", "** 结束 **");
      
      //
      // Mobile resources
      //
      objResourceStore.put("MOBMNUHDR", "Mars eFEX");
      objResourceStore.put("MOBMNU001", "配置");
      objResourceStore.put("MOBMNU002", "下载数据");
      objResourceStore.put("MOBMNU003", "上传数据");
      objResourceStore.put("MOBMNU004", "系统信息");
      objResourceStore.put("MOBMNU005", "开始拜访");
      objResourceStore.put("MOBMNU006", "客户管理");
      objResourceStore.put("MOBMNU007", "信息");
      objResourceStore.put("MOBMNUM01", "正在初始化……");
      
      objResourceStore.put("MOBCFGHDR", "配置");
      objResourceStore.put("MOBCFG001", "用户名");
      objResourceStore.put("MOBCFG002", "语言");
      objResourceStore.put("MOBCFG003", "服务器URL地址");
      objResourceStore.put("MOBCFG004", "安全");
      objResourceStore.put("MOBCFGM01", "用户名必填");
      objResourceStore.put("MOBCFGM02", "服务器URL地址必填");

      objResourceStore.put("MOBDWNHDR", "下载");
      objResourceStore.put("MOBDWN001", "密码");
      objResourceStore.put("MOBDWN002", "**警告**");
      objResourceStore.put("MOBDWN003", "当前数据未保存");
      objResourceStore.put("MOBDWN004", "从服务器下载数据？");
      objResourceStore.put("MOBDWN005", "取消或确认");
      objResourceStore.put("MOBDWNM01", "手机未配置 – 操作失败");
      objResourceStore.put("MOBDWNM02", "操作进行中……");
      objResourceStore.put("MOBDWNM03", "数据下载完成");
      
      objResourceStore.put("MOBUPLHDR", "数据上传");
      objResourceStore.put("MOBUPL001", "密码");
      objResourceStore.put("MOBUPL002", "**警告**");
      objResourceStore.put("MOBUPL003", "数据上传成功");
      objResourceStore.put("MOBUPL004", "**警告**");
      objResourceStore.put("MOBUPL005", "拜访路线未完成");
      objResourceStore.put("MOBUPL006", "上传数据？");
      objResourceStore.put("MOBUPL007", "取消或确认");
      objResourceStore.put("MOBUPLM01", "手机未配置 – 操作失败");
      objResourceStore.put("MOBUPLM02", "无可用数据，请下载");
      objResourceStore.put("MOBUPLM03", "操作进行中……");
      objResourceStore.put("MOBUPLM04", "数据上传完成");
      
      objResourceStore.put("MOBSETHDR", "系统信息");
      objResourceStore.put("MOBSET001", "销售人员ID");
      objResourceStore.put("MOBSET002", "销售人员姓名");
      objResourceStore.put("MOBSET003", "拜访路线日期");
      objResourceStore.put("MOBSET004", "状态");
      objResourceStore.put("MOBSET005", "下载时间");
      objResourceStore.put("MOBSET006", "保存时间");
      objResourceStore.put("MOBSETM01", "手机未配置 – 操作失败");
      objResourceStore.put("MOBSETM02", "无可用数据，请下载");

      //
      // Route resources
      //
      objResourceStore.put("RTELSTHDR", "拜访列表");
      objResourceStore.put("RTELSTM01", "无可用数据，请下载");
      objResourceStore.put("RTELSTM02", "未选择任何客户");
      objResourceStore.put("RTELSTM03", "操作进行中……");
      
      objResourceStore.put("RTEDLTHDR", "取消拜访");
      objResourceStore.put("RTEDLT001", "客户代码");
      objResourceStore.put("RTEDLT002", "客户名称");
      objResourceStore.put("RTEDLTM01", "只能取消非计划拜访客户");
      objResourceStore.put("RTEDLTM02", "操作进行中……");
      
      objResourceStore.put("RTESCHHDR", "查找客户");
      objResourceStore.put("RTESCH001", "客户代码");
      objResourceStore.put("RTESCH002", "客户名称");

      objResourceStore.put("RTESLTHDR", "选择客户");
      objResourceStore.put("RTESLTM01", "未选择客户");
      objResourceStore.put("RTESLTM02", "该客户已在拜访路线中");
      objResourceStore.put("RTESLTM03", "操作进行中……");
      
      objResourceStore.put("RTEDWNHDR", "客户数据下载");
      objResourceStore.put("RTEDWN001", "密码");
      objResourceStore.put("RTEDWN002", "客户");
      objResourceStore.put("RTEDWN003", "从服务器下载客户数据");
      objResourceStore.put("RTEDWN004", "取消或确认");
      objResourceStore.put("RTEDWNM01", "操作进行中……");
      objResourceStore.put("RTEDWNM02", "客户数据不存在");
     
      objResourceStore.put("RTEDISHDR", "分销/库存");
      objResourceStore.put("RTEDIS001", "库存");
      objResourceStore.put("RTEDIS002", "数量");
      objResourceStore.put("RTEDIS003", "产品名称");
      objResourceStore.put("RTEDIS004", "**总分销产品数**");
      objResourceStore.put("RTEDIS005", "分销状态修改");
      objResourceStore.put("RTEDIS006", "客户");
      objResourceStore.put("RTEDIS007", "数据类型");
      objResourceStore.put("RTEDIS008", "总分销产品数");
      objResourceStore.put("RTEDIS009", "产品名称");
      objResourceStore.put("RTEDIS010", "是否分销");
      objResourceStore.put("RTEDIS011", "库存数量");

      objResourceStore.put("RTEDSPHDR", "陈列");
      objResourceStore.put("RTEDSP001", "状态");
      objResourceStore.put("RTEDSP002", "陈列");
      objResourceStore.put("RTEDSP003", "陈列状态修改");
      objResourceStore.put("RTEDSP004", "客户");
      objResourceStore.put("RTEDSP005", "陈列");
      objResourceStore.put("RTEDSP006", "状态");

      objResourceStore.put("RTEACTHDR", "活动");
      objResourceStore.put("RTEACT001", "状态");
      objResourceStore.put("RTEACT002", "活动");
      objResourceStore.put("RTEACT003", "活动状态修改");
      objResourceStore.put("RTEACT004", "客户");
      objResourceStore.put("RTEACT005", "活动");
      objResourceStore.put("RTEACT006", "状态");

      objResourceStore.put("RTEORDHDR", "订单管理");
      objResourceStore.put("RTEORD001", "数量");
      objResourceStore.put("RTEORD002", "单位");
      objResourceStore.put("RTEORD003", "金额");
      objResourceStore.put("RTEORD004", "产品名称");
      objResourceStore.put("RTEORD005", "**总金额**");
      
      objResourceStore.put("RTEORDUPDHDR", "订单修改");
      objResourceStore.put("RTEORDUPD001", "客户");
      objResourceStore.put("RTEORDUPD002", "产品名称");
      objResourceStore.put("RTEORDUPD003", "数量");
      objResourceStore.put("RTEORDUPD004", "单位");
      
      objResourceStore.put("RTEORDDELHDR", "删除订单");
      objResourceStore.put("RTEORDDEL001", "客户");
      objResourceStore.put("RTEORDDEL002", "产品名称");
      objResourceStore.put("RTEORDDEL003", "数量");
      objResourceStore.put("RTEORDDEL004", "单位");
      
      objResourceStore.put("RTEORDCLRHDR", "订单清空");
      objResourceStore.put("RTEORDCLR001", "客户");
      objResourceStore.put("RTEORDCLR002", "清空所有订单项");
      objResourceStore.put("RTEORDCLR003", "取消或确认");

      objResourceStore.put("RTEORDSCHHDR", "产品查找");
      objResourceStore.put("RTEORDSCH001", "客户");
      objResourceStore.put("RTEORDSCH002", "品牌");
      objResourceStore.put("RTEORDSCH003", "包装规格");
      
      objResourceStore.put("RTEORDSLTHDR", "产品选择");
      objResourceStore.put("RTEORDSLTM01", "产品未找到");
      objResourceStore.put("RTEORDSLTM02", "未选择任何产品");

      objResourceStore.put("RTEORDSBMHDR", "订单提交");
      objResourceStore.put("RTEORDSBM001", "客户");
      objResourceStore.put("RTEORDSBM002", "传输给分销商？");
      objResourceStore.put("RTEORDSBMM01", "订单数量不能为空");
      
      objResourceStore.put("RTECOMHDR", "结束拜访");
      objResourceStore.put("RTECOM001", "客户");
      objResourceStore.put("RTECOM002", "是否确认完成？");
      objResourceStore.put("RTECOMM01", "操作进行中……");
      
      //
      // Customer resources
      //
      objResourceStore.put("CUSVAL001", "客户状态必填");
      objResourceStore.put("CUSVAL002", "客户名称必填");
      objResourceStore.put("CUSVAL003", "客户地址必填");
      objResourceStore.put("CUSVAL004", "联系人必填");
      objResourceStore.put("CUSVAL005", "电话号码必填");
      objResourceStore.put("CUSVAL006", "客户类型必填");
      objResourceStore.put("CUSVAL007", "客户位置必填");
      objResourceStore.put("CUSVAL008", "分销商信息必填");

      objResourceStore.put("CUSLSTHDR", "客户列表");
      objResourceStore.put("CUSLSTM01", "无可用数据，请下载");
      objResourceStore.put("CUSLSTM02", "未选择任何客户");
      
      objResourceStore.put("CUSDWNHDR", "客户数据下载");
      objResourceStore.put("CUSDWN001", "密码");
      objResourceStore.put("CUSDWN002", "客户");
      objResourceStore.put("CUSDWN003", "从服务器下载客户数据？");
      objResourceStore.put("CUSDWN004", "取消或确认");
      objResourceStore.put("CUSDWNM01", "操作进行中……");
      objResourceStore.put("CUSDWNM02", "客户数据不存在");
      
      objResourceStore.put("CUSSCHHDR", "查找客户");
      objResourceStore.put("CUSSCH001", "客户代码");
      objResourceStore.put("CUSSCH002", "客户名称");
      
      objResourceStore.put("CUSCHNHDR", "渠道");
      objResourceStore.put("CUSCHNM01", "渠道选项为空");

      objResourceStore.put("CUSCRTHDR", "创建客户");
      objResourceStore.put("CUSCRT001", "* 名称");
      objResourceStore.put("CUSCRT002", "* 地址");
      objResourceStore.put("CUSCRT003", "* 联系人姓名");
      objResourceStore.put("CUSCRT004", "* 电话");
      objResourceStore.put("CUSCRT005", "* 类型");
      objResourceStore.put("CUSCRT006", "* 位置");
      objResourceStore.put("CUSCRT007", "* 分销商");
      objResourceStore.put("CUSCRT008", "邮编");
      objResourceStore.put("CUSCRT009", "传真");
      objResourceStore.put("CUSCRT010", "Email");
      objResourceStore.put("CUSCRT011", "选择");
      objResourceStore.put("CUSCRTM01", "操作进行中……");
      
      objResourceStore.put("CUSUPDHDR", "客户信息修改");
      objResourceStore.put("CUSUPD001", "状态");
      objResourceStore.put("CUSUPD002", "* 名称");
      objResourceStore.put("CUSUPD003", "* 地址");
      objResourceStore.put("CUSUPD004", "* 联系人姓名");
      objResourceStore.put("CUSUPD005", "* 电话");
      objResourceStore.put("CUSUPD006", "* 类型");
      objResourceStore.put("CUSUPD007", "* 位置");
      objResourceStore.put("CUSUPD008", "* 分销商信息");
      objResourceStore.put("CUSUPD009", "邮编");
      objResourceStore.put("CUSUPD010", "传真");
      objResourceStore.put("CUSUPD011", "Email");
      objResourceStore.put("CUSUPDM01", "操作进行中……");
      
      //
      // Message resources
      //
      objResourceStore.put("MSGLSTHDR", "信息列表");
      objResourceStore.put("MSGLSTM01", "无信息 – 选项不可用");
      objResourceStore.put("MSGLSTM02", "未选择任何信息");
      objResourceStore.put("MSGLSTM03", "操作进行中……");

      objResourceStore.put("MSGDETHDR", "信息详情");
      objResourceStore.put("MSGDET001", "发送人");
      objResourceStore.put("MSGDET002", "信息");
      objResourceStore.put("MSGDETM01", "操作进行中……");
   
   }
   
}
