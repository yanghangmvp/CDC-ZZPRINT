@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_ZT_PRT_TEMPLATE'
define root view entity ZC_ZT_PRT_TEMPLATE
  provider contract transactional_query
  as projection on ZR_ZT_PRT_TEMPLATE
{
  key UUID,
  TemplateName,
  ServiceDefinitionName,
  IsExternalProvidedData,
  Template,
  MimeType,
  FileName,
  XSDFile,
  XSDType,
  XSDFileName,
  Fmname,
  LocalLastChangedAt
  
}
