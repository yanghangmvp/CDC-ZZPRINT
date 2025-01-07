@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: '打印数据来源搜索帮助'
define view entity ZR_VH_PRINT_SOURCE
  as select from DDCDS_CUSTOMER_DOMAIN_VALUE_T( p_domain_name: 'ZZDXMLSOURCE' ) as a

{
  key a.value_low as value,
      a.text
}
