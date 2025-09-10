CLASS zzcl_print_data_demo DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    INTERFACES zzif_print_data.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS ZZCL_PRINT_DATA_DEMO IMPLEMENTATION.


  METHOD zzif_print_data~get_data.

    DATA:ls_data TYPE zzs_print_demo.
    ls_data-zzname = 'YANGHANG'.
    rv_xml = NEW zzcl_print_tool( 'zzs_print_demo' )->get_xml( ls_data ).
    DATA(ts1) = utclong_current( ).
    ev_pdfname =  |{ ts1 }测试.PDF|.
  ENDMETHOD.
ENDCLASS.
