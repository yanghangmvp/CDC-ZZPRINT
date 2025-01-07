CLASS zzcl_print_tool DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    TYPES:BEGIN OF ty_dd03,
            tabname(30),"结构名
            rollname(30),"字段名
            inttype(4),"类型
            intlen(6),"字段长度
            rolltext(60),"字段描述
            parent(30),"上级节点
          END OF ty_dd03.
    DATA:mt_dd03 TYPE TABLE OF ty_dd03 WITH EMPTY KEY.
    DATA:mv_struct TYPE sxco_ad_object_name.


    DATA:l_ixml TYPE REF TO if_ixml_core,
         l_doc  TYPE REF TO if_ixml_document,
         l_root TYPE REF TO if_ixml_element.
    "获取结构字段
    METHODS get_dd03
      IMPORTING
        !iv_struct TYPE sxco_ad_object_name
        !iv_parent TYPE sxco_ad_object_name DEFAULT ''.
    "设置XML节点
    METHODS set_node
      IMPORTING
        !p_data TYPE any
        !parent TYPE REF TO if_ixml_node.

    "获取结构XSD
    METHODS get_xsd
      RETURNING
        VALUE(rv_xsd) TYPE xstring.
    "获取内表XML
    METHODS get_xml
      IMPORTING
        iv_data       TYPE any
      RETURNING
        VALUE(rv_xml) TYPE xstring.

    METHODS constructor
      IMPORTING
        iv_struct TYPE sxco_ad_object_name.

    INTERFACES if_oo_adt_classrun.
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.



CLASS zzcl_print_tool IMPLEMENTATION.


  METHOD if_oo_adt_classrun~main.

*    DATA(lv_xsd) = me->get_xsd( 'ZZS_SDI001_REQ' ).
*    DATA(lv_xsd_string) = /ui2/cl_json=>raw_to_string( iv_xstring = lv_xsd ).
*
*
*    DATA ls_data TYPE zzs_sdi001_req.
**    ls_data-req-head-salesorder = '122222'.
**    APPEND VALUE #( salesorderitem = '00010'
**                    material = '234455' )   TO ls_data-req-item.
**    APPEND VALUE #( salesorderitem = '000210'
**                    material = '23445511' )   TO ls_data-req-item.
*
*    DATA(lv_xml) = me->get_xml( iv_data = ls_data  iv_struct = 'ZZS_SDI001_REQ' ).
*    DATA(lv_xml_string) = /ui2/cl_json=>raw_to_string( iv_xstring = lv_xml ).
*
*
*    TRY.
*        " 获取模板数据服务，数据
*        "打印处理
*        SELECT SINGLE *                       "#EC CI_ALL_FIELDS_NEEDED
*          FROM zzt_print_config
*         WHERE template_name = 'TEST001'
*          INTO @DATA(ls_template).
*
*
*        DATA:lv_options TYPE cl_fp_ads_util=>ty_gs_options_pdf.
*        lv_options-trace_level = 4.
*        cl_fp_ads_util=>render_pdf( EXPORTING
*                                       iv_locale     = 'en_US'
*                                       iv_xdp_layout = ls_template-template
*                                       iv_xml_data   = lv_xml
*                                       is_options    = lv_options
*                                    IMPORTING
*                                       ev_pdf        = DATA(lv_pdf) ).
*
*        DATA(lv_pdf_string) = /ui2/cl_json=>raw_to_string( iv_xstring = lv_pdf ).
*
*        UPDATE zzt_print_config SET xsd_file = @lv_pdf,
*                                    xsd_type = 'application/pdf',
*                                    xsd_file_name = '测试.PDF'
*                                WHERE template_name = 'TEST001'.
*
*      CATCH cx_fp_fdp_error INTO DATA(lx_fdp).
*        IF 1 = 1.
*        ENDIF.
*      CATCH cx_fp_ads_util INTO DATA(lx_ads).
*        IF 1 = 1.
*        ENDIF.
*    ENDTRY.

  ENDMETHOD.

  METHOD constructor.
    mv_struct = iv_struct.

    me->get_dd03( iv_struct = mv_struct ).

  ENDMETHOD.


  METHOD get_xml.

    l_ixml = cl_ixml_core=>create( ).
    l_doc = l_ixml->create_document( ).
    l_root = l_doc->create_simple_element( name = 'Form' parent = l_doc value = ''  ).

    l_root = l_doc->create_simple_element( name = CONV string( mv_struct ) parent = l_root value = ''  ).


    me->set_node( p_data = iv_data  parent = l_root ).

*  数据转换
    DATA(lo_ostream) = l_ixml->create_stream_factory( )->create_ostream_xstring( rv_xml ).
    lo_ostream->set_pretty_print( ).
    lo_ostream->set_encoding(
      l_ixml->create_encoding(
      character_set = 'utf-8'                               "#EC NOTEXT
      byte_order    = if_ixml_encoding=>co_little_endian )
    ).
    l_ixml->create_renderer(
      document = l_doc
      ostream  = lo_ostream
    )->render( ).

  ENDMETHOD.



  METHOD get_xsd.

    DATA(lo_ixml)          = cl_ixml_core=>create( ).
    DATA(lo_ixml_document) = lo_ixml->create_document( ).
    DATA lo_attribute TYPE REF TO if_ixml_element.
    DATA(lo_doc) = CAST if_ixml_node( lo_ixml_document ).

    DATA(lo_schema) = lo_ixml_document->create_element_ns( name = 'schema' ).
    lo_schema->set_attribute_ns( name = 'xfadata' prefix = 'xmlns' value = 'http://www.xfa.org/schema/xfa-data/1.0/' ).
    lo_doc->append_child( lo_schema ).

    DATA(lo_element) = lo_ixml_document->create_element_ns( name = 'element' ).
    lo_element->set_attribute_ns( name = 'name' value = 'Form' ) ##NO_TEXT.
    lo_schema->append_child( lo_element ).

    DATA(lo_element_ct) = lo_ixml_document->create_element_ns( name = 'complexType' ).
    lo_element->append_child( lo_element_ct ).

    DATA(lo_element_ct_seq) = lo_ixml_document->create_element_ns( name = 'sequence' ).
    lo_element_ct->append_child( lo_element_ct_seq ).

    DATA(lo_element_ct_seq_el) = lo_ixml_document->create_element_ns( name = 'element' ).
    lo_element_ct_seq_el->set_attribute_ns( name = 'name' value = CONV string( mv_struct ) ).
    lo_element_ct_seq_el->set_attribute_ns( name = 'type' value = CONV string( mv_struct ) ).
    lo_element_ct_seq->append_child( lo_element_ct_seq_el ).


    DATA(lt_outline)  = me->mt_dd03.
    SORT lt_outline BY tabname.
    DELETE ADJACENT DUPLICATES FROM lt_outline COMPARING tabname.

    LOOP AT lt_outline ASSIGNING FIELD-SYMBOL(<ls_outline>).
      DATA(lo_entity) = lo_ixml_document->create_element_ns( name = 'complexType' ).
      lo_entity->set_attribute_ns( name = 'name' value = CONV string( <ls_outline>-tabname ) ).
      lo_schema->append_child( lo_entity ).

      DATA(lo_sequence) = lo_ixml_document->create_element_ns( name = 'sequence' ).
      lo_entity->append_child( lo_sequence ).

      SELECT *
        FROM @me->mt_dd03 AS a
       WHERE tabname = @<ls_outline>-tabname
        INTO TABLE @DATA(lt_properties).

      LOOP AT lt_properties ASSIGNING FIELD-SYMBOL(<ls_property>) WHERE ( inttype <> 'TTYP' AND inttype <> 'STRU'  ).


        DATA(lo_prop) = lo_ixml_document->create_element_ns( name = 'element' ).
        lo_prop->set_attribute_ns( name = 'name' value = CONV string( <ls_property>-rollname ) ).
        lo_sequence->append_child( lo_prop ).

        DATA(lo_prop_anno) = lo_ixml_document->create_element_ns( name = 'annotation' ).
        lo_prop_anno->set_attribute_ns( prefix = 'xmlns' name = 'dc' value = 'http://purl.org/dc/elements/1.1/' ).
        lo_prop->append_child( lo_prop_anno ).


        DATA(lo_prop_anno_appinfo) = lo_ixml_document->create_element_ns( name = 'appinfo' ).
        lo_prop_anno_appinfo->set_attribute_ns( prefix = 'dc' name = 'title' value = CONV string( <ls_property>-rolltext ) ).
        lo_prop_anno->append_child( lo_prop_anno_appinfo ).

        DATA(lo_prop_stype) = lo_ixml_document->create_element_ns( name = 'simpleType' ).
        lo_prop->append_child( lo_prop_stype ).
        DATA(lo_prop_stype_restrict) = lo_ixml_document->create_element_ns( name = 'restriction' ).

        CASE <ls_property>-inttype.
          WHEN 'CHAR'.
            lo_prop_stype_restrict->set_attribute_ns( name = 'base' value = 'string' ).
            lo_attribute = lo_ixml_document->create_element_ns( name = 'maxLength' ).
            lo_attribute->set_attribute_ns( name = 'value' value = |{ <ls_property>-intlen }| ).
            lo_prop_stype_restrict->append_child( lo_attribute ).


          WHEN OTHERS.
            lo_prop_stype_restrict->set_attribute_ns( name = 'base' value = 'string' ).
            lo_attribute = lo_ixml_document->create_element_ns( name = 'maxLength' ).
            lo_attribute->set_attribute_ns( name = 'value' value = |{ 256 }| ).
            lo_prop_stype_restrict->append_child( lo_attribute ).

        ENDCASE.

        lo_prop_stype->append_child( lo_prop_stype_restrict ).
      ENDLOOP.

      LOOP AT lt_properties ASSIGNING <ls_property> WHERE ( inttype = 'TTYP' OR inttype = 'STRU'  ) .

        READ TABLE me->mt_dd03 INTO DATA(ls_dd03) WITH KEY parent = <ls_property>-rollname.

        DATA(lo_nav_wrap) = lo_ixml_document->create_element_ns( name = 'element' ).
        lo_nav_wrap->set_attribute_ns( name = 'name' value = CONV string( <ls_property>-rollname ) ).

        DATA(lo_nav_wrap_comp) = lo_ixml_document->create_element_ns( name = 'complexType' ).
        lo_nav_wrap->append_child( lo_nav_wrap_comp ).
        DATA(lo_nav_wrap_seq) = lo_ixml_document->create_element_ns( name = 'sequence' ).
        lo_nav_wrap_comp->append_child( lo_nav_wrap_seq ).
        DATA(lo_nav_prop) = lo_ixml_document->create_element_ns( name = 'element' ).
        lo_nav_prop->set_attribute_ns( name = 'name' value = CONV string( ls_dd03-tabname )  ).
        lo_nav_wrap_seq->append_child( lo_nav_prop ).
        lo_sequence->append_child( lo_nav_wrap ).


        lo_nav_prop->set_attribute_ns( name = 'type' value = CONV string( ls_dd03-tabname ) ).
        lo_nav_prop->set_attribute_ns( name = 'minOccurs' value = '0' ).
        lo_nav_prop->set_attribute_ns( name = 'maxOccurs' value = SWITCH string(
          <ls_property>-inttype
            WHEN 'STRU' THEN '1'
            WHEN 'TTYP' THEN 'unbounded'
          ) ).
      ENDLOOP.
    ENDLOOP.

    DATA(lo_ostream) = lo_ixml->create_stream_factory( )->create_ostream_xstring( rv_xsd ).
    lo_ostream->set_pretty_print( ).
    lo_ostream->set_encoding(
      lo_ixml->create_encoding(
      character_set = 'utf-8'                               "#EC NOTEXT
      byte_order    = if_ixml_encoding=>co_little_endian )
    ).
    lo_ixml->create_renderer(
      document = lo_ixml_document
      ostream  = lo_ostream
    )->render( ).
  ENDMETHOD.

  METHOD get_dd03.
    DATA:ls_dd03 TYPE me->ty_dd03.

    DATA(lo_structure) = xco_cp_abap_dictionary=>structure( iv_struct ).
    DATA(lt_components) = lo_structure->components->all->get( ).
    LOOP AT lt_components INTO DATA(ls_components).
      CLEAR:ls_dd03.

      ls_dd03-tabname = iv_struct.
      ls_dd03-rollname = ls_components->name.

      IF iv_parent IS INITIAL.
        ls_dd03-parent = iv_struct.
      ELSE.
        ls_dd03-parent = iv_parent.
      ENDIF.

      DATA(lr_type) = ls_components->content( )->get_type( ).

      CASE abap_true.
        WHEN lr_type->is_built_in_type( ).
          ls_dd03-inttype = lr_type->get_built_in_type( )->type.
          ls_dd03-rolltext = ls_dd03-rollname.
          ls_dd03-intlen = lr_type->get_built_in_type( )->length.
        WHEN lr_type->is_data_element( ).
          ls_dd03-rolltext = lr_type->get_data_element( )->content( )->get( )-long_field_label-text.
          ls_dd03-inttype = lr_type->get_data_element( )->content( )->get_underlying_built_in_type( )->type.
          ls_dd03-intlen = lr_type->get_data_element( )->content( )->get_underlying_built_in_type( )->length.

        WHEN lr_type->is_structure( ).
          ls_dd03-inttype = 'STRU'.
          DATA(lv_structure) = lr_type->get_structure( )->name.
          me->get_dd03( iv_struct = lv_structure iv_parent = ls_dd03-rollname  ).
        WHEN lr_type->is_table_type( ).
          ls_dd03-inttype = 'TTYP'.
          DATA(lv_table) = lr_type->get_table_type( )->content( )->get_row_type( )->get_structure( )->name.
          me->get_dd03( iv_struct = lv_table iv_parent = ls_dd03-rollname  ).
      ENDCASE.

      APPEND ls_dd03 TO me->mt_dd03.
    ENDLOOP.
  ENDMETHOD.

  METHOD set_node.
    DATA l_item      TYPE REF TO if_ixml_element.
    DATA descr_ref TYPE REF TO cl_abap_structdescr .

    descr_ref ?= cl_abap_typedescr=>describe_by_data( p_data ).
    LOOP AT descr_ref->components INTO DATA(ls_components).
      ASSIGN COMPONENT ls_components-name  OF STRUCTURE p_data TO FIELD-SYMBOL(<fs_value>).
      CASE ls_components-type_kind.
        WHEN 'v'."结构
          DATA(l_item_v) = l_doc->create_simple_element( name = CONV string( ls_components-name ) parent = parent value = ''  ).
          READ TABLE me->mt_dd03 INTO DATA(ls_dd03) WITH KEY parent = ls_components-name .
          l_item = l_doc->create_simple_element( name = CONV string( ls_dd03-tabname ) parent = l_item_v value = ''  ).

          me->set_node( p_data = <fs_value> parent = l_item ).
        WHEN 'h'."表
          DATA(l_item_h) = l_doc->create_simple_element( name = CONV string( ls_components-name ) parent = parent value = ''  ).
          LOOP AT <fs_value> ASSIGNING FIELD-SYMBOL(<fs_tab>).
            READ TABLE me->mt_dd03 INTO ls_dd03 WITH KEY parent = ls_components-name .
            l_item = l_doc->create_simple_element( name = CONV string( ls_dd03-tabname ) parent = l_item_h value = ''  ).
            me->set_node( p_data = <fs_tab> parent = l_item ).
          ENDLOOP.

        WHEN OTHERS.
          IF <fs_value> IS NOT INITIAL.
            l_item = l_doc->create_simple_element( name = CONV string( ls_components-name )
                                                  parent = parent
                                                  value = CONV string( <fs_value> )  ).
          ENDIF.
      ENDCASE.

    ENDLOOP.
  ENDMETHOD.


ENDCLASS.
