CLASS LHC_ZR_ZT_PRT_TEMPLATE DEFINITION INHERITING FROM CL_ABAP_BEHAVIOR_HANDLER.
  PRIVATE SECTION.
    METHODS:
      GET_GLOBAL_AUTHORIZATIONS FOR GLOBAL AUTHORIZATION
        IMPORTING
           REQUEST requested_authorizations FOR ZR_ZT_PRT_TEMPLATE
        RESULT result,
      " 保存记录时创建XSDFile
      createXSDFile FOR DETERMINE ON SAVE
        IMPORTING keys FOR Template~createXSDFile.
ENDCLASS.

CLASS LHC_ZR_ZT_PRT_TEMPLATE IMPLEMENTATION.
  METHOD GET_GLOBAL_AUTHORIZATIONS.
  ENDMETHOD.
*&---====================创建XSDFile 文件，提供Adobe 打印数据源文件
  METHOD createXSDFile.
    DATA : lv_error   TYPE abap_boolean,
           lv_message TYPE string.

*&---获取UI 界面实体数据内容
    READ ENTITIES OF zr_zt_prt_template IN LOCAL MODE
    ENTITY Template ALL FIELDS WITH CORRESPONDING #( keys )
    RESULT DATA(results).

*&---出来数据文件
    LOOP AT results ASSIGNING FIELD-SYMBOL(<result>).
      lv_error = abap_false.
      TRY.
          "FDP utils
          " 通过数据服务获取对应的xsd 文件
          " 获取数据服务类
          DATA(lo_fdp_util) = cl_fp_fdp_services=>get_instance( CONV zzeservicename( <result>-ServiceDefinitionName ) ).
          " 获取数据服务xsd 文件
          <result>-XSDFile = lo_fdp_util->get_xsd(  ).
          " 设置xsd 文件名
          <result>-XSDFileName = |{ <result>-ServiceDefinitionName }.xsd |.
          " 设置xsd 存储文件类型
          <result>-XSDType = 'application/xml'.
        CATCH cx_fp_fdp_error INTO DATA(lx_fdp).
          lv_message = lx_fdp->get_longtext(  ).
*              lv_message = lx_ads->get_longtext(  ).
          lv_error = abap_true.
      ENDTRY.
      " 报错消息处理
      IF lv_error = abap_true.
        APPEND VALUE #(  uuid = <result>-uuid
            %msg = new_message(
            id       = '00'
            number   = 000
            severity = if_abap_behv_message=>severity-error
            v1       = lv_message
            )
        )  TO reported-template.

      ENDIF.
*      ENDIF.
    ENDLOOP.
    " 若无错则保存数据服务xsd 文件到template 附加xsdfile 文件字段中
    IF lv_error = abap_false.
      " 更新数据实体把产生xsd 内容和对应字段更新到对应实体上
      MODIFY ENTITIES OF zr_zt_prt_template IN LOCAL MODE
          ENTITY Template UPDATE FIELDS ( XSDFileName XSDType XSDFile )
              WITH VALUE #( FOR file IN results ( %tky        = file-%tky
                                                  XSDFileName = file-XSDFileName
                                                  XSDType     = file-XSDType
                                                  XSDFile     = file-XSDFile ) ).
    ENDIF.

  ENDMETHOD.
ENDCLASS.
