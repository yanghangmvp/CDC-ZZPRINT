@EndUserText.label: 'Parameter of Print'
define abstract entity ZR_ZT_PRT_PARAM
  //with parameters parameter_name : parameter_type
{
  TemplateName           : zzetemplatename;
  IsExternalProvidedData : abap_boolean;
  ExternalProvidedData   : zzeexternaldata;
  ProvidedKeys           : zzekeys;
  SendToPrintQueue       : abap_boolean;
  PrintQueue             : abap.char( 32 );
  NumberOfCopies         : abap.int2;

}
