INTERFACE zzif_print_data
  PUBLIC .


  CLASS-METHODS get_data
    IMPORTING
      iv_key        TYPE any
    EXPORTING
      ev_pdfname    TYPE string
    RETURNING
      VALUE(rv_xml) TYPE xstring.

ENDINTERFACE.
