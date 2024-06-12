@AccessControl.authorizationCheck: #CHECK
@Metadata.allowExtensions: true
@EndUserText.label: 'Projection View for ZR_ZT_PRT_RECORD'
define root view entity ZC_ZT_PRT_RECORD
  provider contract transactional_query
  as projection on ZR_ZT_PRT_RECORD
{
  key UUID,
      TemplateUUID,
      IsExternalProvidedData,
      ExternalProvidedData,
      ProvidedKeys,
      Pdf,
      MimeType,
      FileName,
      LocalLastChangedAt,
      _Template.TemplateName,
      SendToPrintQueue,
      NumberOfCopies,
      PrintQueue,
      MimeTypeData,
      DataFileName,
      _Template : redirected to ZC_ZT_PRT_TEMPLATE

}
