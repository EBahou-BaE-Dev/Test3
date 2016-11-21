CREATE OR REPLACE PACKAGE BODY FCUBEUSER.pcpks_pcdprmnt_Main AS
  /*-----------------------------------------------------------------------------------------------------
  **
  ** File Name  : PCPKS_PCDPRMNT_MAIN.SQL
  **
  ** Module     : Local Payments
  **
  ** This source is part of the Oracle FLEXCUBE Software System and is copyrighted by Oracle Financial Services Software Limited.
  **
  **
  ** All rights reserved. No part of this work may be reproduced, stored in a retrieval system,
  ** adopted or transmitted in any form or by any means, electronic, mechanical, photographic,
  ** graphic, optic recording or otherwise, translated in any language or computer language,
  ** without the prior written permission of Oracle Financial Services Software Limited.
  **
  ** Oracle Financial Services Software Limited.
  ** 10-11, SDF I, SEEPZ, Andheri (East),
  ** Mumbai - 400 096.
  ** India
  ** Copyright ? 2008 - 2009 Oracle Financial Services Software Limited. All rights reserved.
  -------------------------------------------------------------------------------------------------------
  CHANGE HISTORY

  SFR Number         :
  Changed By         :
  Change Description :

  -------------------------------------------------------------------------------------------------------
  */


g_Original_Action    VARCHAR2(100);
g_Action_Code    VARCHAR2(100);
g_Function_Id    VARCHAR2(50) := 'PCDPRMNT';
g_Ui_Name        VARCHAR2(50) := 'PCDPRMNT';
g_addl_info			 Cspks_Req_Handler.Ty_Addl_Info;
g_Key_Id                  VARCHAR2(32767);
g_pcdprmnt         pcpks_pcdprmnt_Main.ty_pcdprmnt;
--Skip Handler Variables
g_Skip_Sys       BOOLEAN := FALSE;
g_Skip_Kernel    BOOLEAN := FALSE;
g_Skip_Cluster   BOOLEAN := FALSE;
g_Skip_Custom    BOOLEAN := FALSE;
g_Skip_Master    BOOLEAN := FALSE;
PROCEDURE dbg(p_msg VARCHAR2)  IS
l_msg     VARCHAR2(32767);
BEGIN
l_msg := 'pcpks_pcdprmnt_Main ==>'||p_msg;
debug.pr_debug('PC' ,l_msg);
END dbg;

PROCEDURE pr_log_error(p_source VARCHAR2,p_err_code VARCHAR2, p_err_params VARCHAR2) IS
l_Fid    VARCHAR2(32767) := 'PCDPRMNT';
BEGIN
Cspks_Req_Utils.pr_log_error(p_source,l_Fid,p_err_code,p_err_params);
END pr_log_error;
PROCEDURE Pr_Skip_Handler(p_Stage in VARCHAR2) IS
BEGIN
NULL;
END Pr_Skip_Handler;
PROCEDURE Pr_Set_Skip_Sys IS
BEGIN
g_Skip_Sys := TRUE;
END Pr_Set_Skip_Sys;
PROCEDURE Pr_Set_Activate_Sys IS
BEGIN
g_Skip_Sys := FALSE;
END Pr_Set_Activate_Sys;
PROCEDURE Pr_Set_Skip_Kernel IS
BEGIN
g_Skip_Kernel := TRUE;
END Pr_Set_Skip_Kernel;
PROCEDURE Pr_Set_Activate_Kernel IS
BEGIN
g_Skip_Kernel := FALSE;
END Pr_Set_Activate_Kernel;
PROCEDURE Pr_Set_Skip_Cluster IS
BEGIN
g_Skip_Cluster := TRUE;
END Pr_Set_Skip_Cluster;
PROCEDURE Pr_Set_Activate_Cluster IS
BEGIN
g_Skip_Cluster := FALSE;
END Pr_Set_Activate_Cluster;
PROCEDURE Pr_Set_Skip_Master IS
BEGIN
g_Skip_Master := TRUE;
END Pr_Set_Skip_Master;
PROCEDURE Pr_Set_Activate_Master IS
BEGIN
g_Skip_Master := FALSE;
END Pr_Set_Activate_Master;
FUNCTION  Fn_Skip_Sys RETURN BOOLEAN IS
BEGIN
RETURN G_Skip_Sys;
END  Fn_Skip_Sys;
FUNCTION  Fn_Skip_Kernel RETURN BOOLEAN IS
BEGIN
IF Cspks_Req_Handler.g_Release_Type = Cspks_Req_Handler.p_Kernel THEN
RETURN FALSE;
ELSE
RETURN G_Skip_Kernel;
END IF;
END  Fn_Skip_Kernel;
FUNCTION  Fn_Skip_Cluster RETURN BOOLEAN IS
BEGIN
IF Cspks_Req_Handler.g_Release_Type =Cspks_Req_Handler.p_Kernel THEN
RETURN TRUE;
ELSIF Cspks_Req_Handler.g_Release_Type =Cspks_Req_Handler.p_Cluster THEN
RETURN FALSE;
ELSE
RETURN G_Skip_Cluster;
END IF;
END  Fn_Skip_Cluster;
FUNCTION  Fn_Skip_Custom RETURN BOOLEAN IS
BEGIN
IF Cspks_Req_Handler.g_Release_Type IN(Cspks_Req_Handler.p_Kernel,Cspks_Req_Handler.P_Cluster) THEN
RETURN TRUE;
ELSIF Cspks_Req_Handler.g_Release_Type =Cspks_Req_Handler.p_Custom THEN
RETURN FALSE;
ELSE
RETURN G_Skip_Custom;
END IF;
END  Fn_Skip_Custom;
FUNCTION  Fn_Skip_Master RETURN BOOLEAN IS
BEGIN
RETURN G_Skip_Sys;
END  Fn_Skip_Master;
FUNCTION Fn_Sys_Build_Fc_Type (
p_addl_info       IN Cspks_Req_Handler.Ty_Addl_Info,
p_pcdprmnt       IN   OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_Pk_counter        NUMBER :=1;
l_count             NUMBER;
l_parent_rec        NUMBER :=0;
l_Key               VARCHAR2(255);
l_Pkey              VARCHAR2(32767);
l_PVal              VARCHAR2(32767);
l_val               VARCHAR2(32767);
l_tag               VARCHAR2(100);
l_Node              VARCHAR2(100);
l_key_vals          VARCHAR2(32767);
l_key_Tags          VARCHAR2(32767);
l_rec_rcvd          BOOLEAN := FALSE;
l_calling_function VARCHAR2(50) := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_Master_Parsed     BOOLEAN := FALSE;
l_dsn_rec_cnt_3    NUMBER;
l_bnd_cntr_3    NUMBER;
l_dsn_rec_cnt_4    NUMBER;
l_bnd_cntr_4    NUMBER;
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_Dmy_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_Dmy_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_Dmy_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_Dmy_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN

dbg('In Fn_Sys_Build_Fc_Type..');

l_Node := Cspks_Req_Global.Fn_GetNode;
WHILE (l_Node <> 'EOPL')
LOOP
--dbg('Node Name  :'||l_Node);
IF l_Node = 'BLK_PRODUCT_DETAILS' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.PRODUCT_DESCRIPTION := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.PRODUCT_SLOGAN := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_START_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.PRODUCT_START_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
l_Val       := Cspks_Req_Global.Fn_GetVal;
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_END_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.PRODUCT_END_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
p_pcdprmnt.prmnt_cstms_product.PRODUCT_REMARKS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.NORMAL_RATE_VARIANCE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.MAXIMUM_RATE_VARIANCE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.MODULE := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RFD_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_BRN := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_CCY := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.NETWORK_ID := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_MODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUTOFF_HR := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUTOFF_MIN := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PRIORITY := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUST_ENT_DAY_PRECUTOF := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUST_ENT_VAL_DAY_PRECUTOF := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CPTY_ENT_DAY_PRECUTOF := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CPTY_ENT_VAL_DAY_PRECUTOF := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DISPATCH := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DISPATCH_DAY_PRECUTOF := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PRE_COT_RESPONSE_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MAX_INT_AMT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MAX_SPLIT_COUNT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_BEFORE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_BEFORE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.BACK_VALUE_LIMIT_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.FUTURE_VALUE_LIMIT_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_AFTER := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_AFTER := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.EX_RATE_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REDISPATCH_COUNT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REDISPATCH_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RECALL_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_WAIVER := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.DISP_FILE_NAME := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.NO_OF_REC := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CLG_CCY := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CCY_CAL := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PYMT_REJT_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.EARLY_COLL_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.FIRST_COLL_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RECUR_COLL_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.FIRST_COLL_DISP_DAYS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.CLEARING_MODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PRODUCT_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.PRODUCT_TYPE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.MAKER_ID := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.MAKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.MAKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
p_pcdprmnt.prmnt_cstms_product.CHECKER_ID := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.CHECKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.CHECKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
p_pcdprmnt.prmnt_cstms_product.MOD_NO := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.RECORD_STAT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.AUTH_STAT := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_cstms_product.ONCE_AUTH := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_product_preference.product_code := p_pcdprmnt.prmnt_cstms_product.product_code;
ELSIF l_Node = 'BLK_PRODUCT_BANKS' THEN
l_Dsn_rec_cnt_3 :=  p_pcdprmnt.prmnt_pctms_product_banks.count +1 ;
p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).PRODUCT_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).BANKCODE := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).product_code := p_pcdprmnt.prmnt_cstms_product.product_code;
ELSIF l_Node = 'BLK_PRODUCT_ACCROLE' THEN
l_Dsn_rec_cnt_4 :=  p_pcdprmnt.prmnt_pctms_product_accrole.count +1 ;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).PRODUCT_CODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).BANKCODE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ACCOUNTING_ROLE := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).STATUS := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ROLE_TYPE := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ACCOUNTING_HEAD := Cspks_Req_Global.Fn_GetVal;
l_Val       := Cspks_Req_Global.Fn_GetVal;
l_Parent_Rec := p_pcdprmnt.prmnt_pctms_product_banks.count;
IF l_Parent_Rec > 0 THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_dsn_rec_cnt_4).product_code := p_pcdprmnt.prmnt_pctms_product_banks(l_Parent_Rec).product_code;
p_pcdprmnt.prmnt_pctms_product_accrole(l_dsn_rec_cnt_4).bankcode := p_pcdprmnt.prmnt_pctms_product_banks(l_Parent_Rec).bankcode;
END IF;
ELSIF l_Node = 'BLK_PRODUCT_EVENTS' THEN
l_cscacadd := l_Dmy_CSCACADD;
l_key_vals :='PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Cspks_CSCACADD_Main.Fn_Build_Fc_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Cspks_CSCACADD_Main.Fn_Build_Fc_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_cscacadd,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACADD_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_cscacadd := l_cscacadd;

ELSIF l_Node = 'BLK_ROLE_TO_HEAD_MAPPING' THEN
l_cscacrhm := l_Dmy_CSCACRHM;
l_key_vals :='PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Cspks_CSCACRHM_Main.Fn_Build_Fc_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Cspks_CSCACRHM_Main.Fn_Build_Fc_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_cscacrhm,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACRHM_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_cscacrhm := l_cscacrhm;

ELSIF l_Node = 'BLK_PRODUCT_MIS_DETAILS' THEN
l_micprmnt := l_Dmy_MICPRMNT;
l_key_vals :='PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Mipks_MICPRMNT_Main.Fn_Build_Fc_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Mipks_MICPRMNT_Main.Fn_Build_Fc_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_micprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Mipks_MICPRMNT_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_micprmnt := l_micprmnt;

--ELSIF l_Node = 'PCPRODUCT_MASTER' THEN
ELSIF l_Node IN ('PCPRODUCT_MASTER','BLK_PC_PRODUCT_CHARGES') THEN
l_pccexpr := l_Dmy_PCCEXPR;
l_key_vals :='PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Pcpks_PCCEXPR_Main.Fn_Build_Fc_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Pcpks_PCCEXPR_Main.Fn_Build_Fc_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_pccexpr,
p_err_code,
p_err_params)  THEN
dbg('Failed in Pcpks_PCCEXPR_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_pccexpr := l_pccexpr;

END IF;
l_Node := Cspks_Req_Global.Fn_GetNode;
END LOOP;

p_pcdprmnt.addl_info := p_addl_info;
dbg('Returning from Fn_Sys_Build_Fc_Type ');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Sys_Build_Fc_Type ');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Build_Fc_Type;
FUNCTION Fn_Build_Fc_Type (
p_addl_info       IN Cspks_Req_Handler.Ty_Addl_Info,
p_pcdprmnt       IN   OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';

BEGIN

dbg('In Fn_Build_Fc_Type..');

dbg('Calling Fn_Sys_Build_Fc_Type..');
IF NOT Fn_Sys_Build_Fc_Type(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Sys_Build_Fc_Type..');
RETURN FALSE;
END IF;
Pr_Skip_Handler('POSTTYPE');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Custom.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Cluster.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_KERNEL THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Kernel.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
dbg('Returning from fn_check_mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.fn_check_mandatory ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Build_Fc_Type;
FUNCTION Fn_Sys_Build_Ws_Type (
p_addl_info       IN Cspks_Req_Handler.Ty_Addl_Info,
p_pcdprmnt       IN   OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_Pk_counter        NUMBER :=1;
l_count             NUMBER;
l_parent_rec        NUMBER :=0;
l_Key               VARCHAR2(255);
l_Pkey              VARCHAR2(32767);
l_PVal              VARCHAR2(32767);
l_val               VARCHAR2(32767);
l_tag               VARCHAR2(100);
l_rec_rcvd          BOOLEAN := FALSE;
l_Xsd_Node          VARCHAR2(100);
l_key_vals          VARCHAR2(32767);
l_key_Tags          VARCHAR2(32767);
l_dbt_Tracker       Cspks_Req_Handler.ty_tb_record_data;
l_calling_function VARCHAR2(50) := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_Master_Parsed     BOOLEAN := FALSE;
l_dsn_rec_cnt_3    NUMBER;
l_dsn_rec_cnt_4    NUMBER;
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_Dmy_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_Dmy_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_Dmy_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_Dmy_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN

dbg('In Fn_Sys_Build_Ws_Type..');

l_Xsd_Node := Cspks_Req_Global.Fn_GetNode;
WHILE (l_Xsd_Node <> 'EOPL')
LOOP
--dbg('Node Name  :'||l_Xsd_Node);
IF l_xsd_node IN ('Product-Details-IO','Product-Details-PK','Product-Details-Full') THEN
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
WHILE (l_Key <> 'EOPL')
LOOP
--dbg('Key/Value   :'||l_Key ||':'||l_Val);
IF l_key = 'PRDCD' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE := l_Val;
ELSIF l_key = 'PRDDESC' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_DESCRIPTION := l_Val;
ELSIF l_key = 'PRDTYP' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE := l_Val;
ELSIF l_key = 'PRDSLG' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_SLOGAN := l_Val;
ELSIF l_key = 'PRDGRP' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP := l_Val;
ELSIF l_key = 'PRDSTRTDT' THEN
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_START_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.PRODUCT_START_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
ELSIF l_key = 'PRDENDDT' THEN
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_END_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.PRODUCT_END_DATE := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
ELSIF l_key = 'PRDRMRKS' THEN
p_pcdprmnt.prmnt_cstms_product.PRODUCT_REMARKS := l_Val;
ELSIF l_key = 'NRMLRTVARI' THEN
p_pcdprmnt.prmnt_cstms_product.NORMAL_RATE_VARIANCE := l_Val;
ELSIF l_key = 'MAXRTVARI' THEN
p_pcdprmnt.prmnt_cstms_product.MAXIMUM_RATE_VARIANCE := l_Val;
ELSIF l_key = 'RTCODEPRFERD' THEN
p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED := l_Val;
ELSIF l_key = 'RATETYPPREF' THEN
p_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED := l_Val;
ELSIF l_key = 'COLLTP' THEN
p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE := l_Val;
ELSIF l_key = 'REDTP' THEN
p_pcdprmnt.prmnt_product_preference.RFD_TYPE := l_Val;
ELSIF l_key = 'TRANSTYPE' THEN
p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE := l_Val;
ELSIF l_key = 'CLGVOSTROBRN' THEN
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_BRN := l_Val;
ELSIF l_key = 'CLGVOSTROACC' THEN
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC := l_Val;
ELSIF l_key = 'CLGVOSTROCCY' THEN
p_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_CCY := l_Val;
ELSIF l_key = 'NETWRKID' THEN
p_pcdprmnt.prmnt_product_preference.NETWORK_ID := l_Val;
ELSIF l_key = 'MINDIVIAMT' THEN
p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT := l_Val;
ELSIF l_key = 'MINTXNAMT' THEN
p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT := l_Val;
ELSIF l_key = 'CHRGMODE' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_MODE := l_Val;
ELSIF l_key = 'INVCSPLTREQ' THEN
p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD := l_Val;
ELSIF l_key = 'MAXTXNAMT' THEN
p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT := l_Val;
ELSIF l_key = 'HOUR' THEN
p_pcdprmnt.prmnt_product_preference.CUTOFF_HR := l_Val;
ELSIF l_key = 'MINUTE' THEN
p_pcdprmnt.prmnt_product_preference.CUTOFF_MIN := l_Val;
ELSIF l_key = 'PRIORITY' THEN
p_pcdprmnt.prmnt_product_preference.PRIORITY := l_Val;
ELSIF l_key = 'CUSTENTDAYPRECUTOF' THEN
p_pcdprmnt.prmnt_product_preference.CUST_ENT_DAY_PRECUTOF := l_Val;
ELSIF l_key = 'CUSTENTVALDAYPRECUTOF' THEN
p_pcdprmnt.prmnt_product_preference.CUST_ENT_VAL_DAY_PRECUTOF := l_Val;
ELSIF l_key = 'CPTYENTDAYPRECUTOF' THEN
p_pcdprmnt.prmnt_product_preference.CPTY_ENT_DAY_PRECUTOF := l_Val;
ELSIF l_key = 'CPTYENTVALDAYPRECUTOF' THEN
p_pcdprmnt.prmnt_product_preference.CPTY_ENT_VAL_DAY_PRECUTOF := l_Val;
ELSIF l_key = 'OVEROVERDRFT' THEN
p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT := l_Val;
ELSIF l_key = 'DISPACC' THEN
p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING := l_Val;
ELSIF l_key = 'REFERLREQD' THEN
p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED := l_Val;
ELSIF l_key = 'DISP' THEN
p_pcdprmnt.prmnt_product_preference.DISPATCH := l_Val;
ELSIF l_key = 'AUTODISPATCH' THEN
p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH := l_Val;
ELSIF l_key = 'OUTPMTWRKFLW' THEN
p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW := l_Val;
ELSIF l_key = 'DISPMEDIA' THEN
p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA := l_Val;
ELSIF l_key = 'DISPDAYRECUTOF' THEN
p_pcdprmnt.prmnt_product_preference.DISPATCH_DAY_PRECUTOF := l_Val;
ELSIF l_key = 'AUT_RESP' THEN
p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE := l_Val;
ELSIF l_key = 'ASCII' THEN
p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD := l_Val;
ELSIF l_key = 'COL_STA_REQ' THEN
p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD := l_Val;
ELSIF l_key = 'RESPADVCREQD' THEN
p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD := l_Val;
ELSIF l_key = 'PRECOTRESPDAYS' THEN
p_pcdprmnt.prmnt_product_preference.PRE_COT_RESPONSE_DAYS := l_Val;
ELSIF l_key = 'RESPADVCEBASIS' THEN
p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS := l_Val;
ELSIF l_key = 'MAXINTAMT' THEN
p_pcdprmnt.prmnt_product_preference.MAX_INT_AMT := l_Val;
ELSIF l_key = 'MAXSPLTCOUNT' THEN
p_pcdprmnt.prmnt_product_preference.MAX_SPLIT_COUNT := l_Val;
ELSIF l_key = 'REJACTYPEBEFR' THEN
p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE := l_Val;
ELSIF l_key = 'LMTBRN' THEN
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_BEFORE := l_Val;
ELSIF l_key = 'ATMACC' THEN
p_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS := l_Val;
ELSIF l_key = 'REJPMNTCCYBEFORE' THEN
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_BEFORE := l_Val;
ELSIF l_key = 'BCKVALLMTDAYS' THEN
p_pcdprmnt.prmnt_product_preference.BACK_VALUE_LIMIT_DAYS := l_Val;
ELSIF l_key = 'FUTUREVLLMTDAYS' THEN
p_pcdprmnt.prmnt_product_preference.FUTURE_VALUE_LIMIT_DAYS := l_Val;
ELSIF l_key = 'MOVEBVTACTIVDT' THEN
p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE := l_Val;
ELSIF l_key = 'DFLTACTIVDT' THEN
p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE := l_Val;
ELSIF l_key = 'PROCSREJAFTRRESPDAYS' THEN
p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS := l_Val;
ELSIF l_key = 'REJVERIFYFUNDS' THEN
p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS := l_Val;
ELSIF l_key = 'REJACTYPEAFTR' THEN
p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER := l_Val;
ELSIF l_key = 'ACCBRN' THEN
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_AFTER := l_Val;
ELSIF l_key = 'ACCOUNT_NUMBER' THEN
p_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS := l_Val;
ELSIF l_key = 'REJPMNCCYAFTER' THEN
p_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_AFTER := l_Val;
ELSIF l_key = 'ALLOWPOSTCOTTXN' THEN
p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN := l_Val;
ELSIF l_key = 'AUTOEXCHRATEREQD' THEN
p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD := l_Val;
ELSIF l_key = 'EXRATECD' THEN
p_pcdprmnt.prmnt_product_preference.EX_RATE_CODE := l_Val;
ELSIF l_key = 'EXRATETP' THEN
p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE := l_Val;
ELSIF l_key = 'REDISPATCH_REQD' THEN
p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD := l_Val;
ELSIF l_key = 'AUTOREDISP' THEN
p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH := l_Val;
ELSIF l_key = 'REDISPATCH_COUNT' THEN
p_pcdprmnt.prmnt_product_preference.REDISPATCH_COUNT := l_Val;
ELSIF l_key = 'REDISPATCH_DAYS' THEN
p_pcdprmnt.prmnt_product_preference.REDISPATCH_DAYS := l_Val;
ELSIF l_key = 'RECALLDAYS' THEN
p_pcdprmnt.prmnt_product_preference.RECALL_DAYS := l_Val;
ELSIF l_key = 'RECALLDAYSBASIS' THEN
p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS := l_Val;
ELSIF l_key = 'AGREEIDREQD' THEN
p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD := l_Val;
ELSIF l_key = 'CREDITOR_ID_REQD' THEN
p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD := l_Val;
ELSIF l_key = 'CHARGE_WAIVER' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_WAIVER := l_Val;
ELSIF l_key = 'ALLOWTHIRDPRTYCHG' THEN
p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG := l_Val;
ELSIF l_key = 'CHRGCUSTSTATCS' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS := l_Val;
ELSIF l_key = 'CHRGACSTATCS' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS := l_Val;
ELSIF l_key = 'COLLVLUMSTATCS' THEN
p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS := l_Val;
ELSIF l_key = 'CUSTENTCONSOLREQD' THEN
p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD := l_Val;
ELSIF l_key = 'CUSTENTCONSOLLMT' THEN
p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT := l_Val;
ELSIF l_key = 'DISPFILENAME' THEN
p_pcdprmnt.prmnt_product_preference.DISP_FILE_NAME := l_Val;
ELSIF l_key = 'NOOFREC' THEN
p_pcdprmnt.prmnt_product_preference.NO_OF_REC := l_Val;
ELSIF l_key = 'REVSETLEGL' THEN
p_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL := l_Val;
ELSIF l_key = 'RESPDAYSBASIS' THEN
p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS := l_Val;
ELSIF l_key = 'CLGCCY' THEN
p_pcdprmnt.prmnt_product_preference.CLG_CCY := l_Val;
ELSIF l_key = 'CHRGCAT' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY := l_Val;
ELSIF l_key = 'CCYCAL' THEN
p_pcdprmnt.prmnt_product_preference.CCY_CAL := l_Val;
ELSIF l_key = 'PYMTREJTDAYS' THEN
p_pcdprmnt.prmnt_product_preference.PYMT_REJT_DAYS := l_Val;
ELSIF l_key = 'SERVLEVELCODE' THEN
p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE := l_Val;
ELSIF l_key = 'CHRGBEARER' THEN
p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER := l_Val;
ELSIF l_key = 'EARLYCOLLDAYS' THEN
p_pcdprmnt.prmnt_product_preference.EARLY_COLL_DAYS := l_Val;
ELSIF l_key = 'FIRSTCOLLDAYS' THEN
p_pcdprmnt.prmnt_product_preference.FIRST_COLL_DAYS := l_Val;
ELSIF l_key = 'RECURCOLLDAYS' THEN
p_pcdprmnt.prmnt_product_preference.RECUR_COLL_DAYS := l_Val;
ELSIF l_key = 'FIRSTCOLLDISPDAYS' THEN
p_pcdprmnt.prmnt_product_preference.FIRST_COLL_DISP_DAYS := l_Val;
ELSIF l_key = 'RECALLDTBASIS' THEN
p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS := l_Val;
ELSIF l_key = 'PAYMNTTP' THEN
p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE := l_Val;
ELSIF l_key = 'CLGMODE' THEN
p_pcdprmnt.prmnt_product_preference.CLEARING_MODE := l_Val;
ELSIF l_key = 'MAKER' THEN
p_pcdprmnt.prmnt_cstms_product.MAKER_ID := l_Val;
ELSIF l_key = 'MAKERSTAMP' THEN
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.MAKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.MAKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
ELSIF l_key = 'CHECKER' THEN
p_pcdprmnt.prmnt_cstms_product.CHECKER_ID := l_Val;
ELSIF l_key = 'CHECKERSTAMP' THEN
IF Length(l_val) > Length(Cspks_Req_Handler.g_date_format) THEN
p_pcdprmnt.prmnt_cstms_product.CHECKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_time_format);
ELSE
p_pcdprmnt.prmnt_cstms_product.CHECKER_DT_STAMP := TO_DATE(l_val,Cspks_Req_Handler.g_date_format);
END IF;
ELSIF l_key = 'MODNO' THEN
p_pcdprmnt.prmnt_cstms_product.MOD_NO := l_Val;
ELSIF l_key = 'TXNSTAT' THEN
p_pcdprmnt.prmnt_cstms_product.RECORD_STAT := l_Val;
ELSIF l_key = 'AUTHSTAT' THEN
p_pcdprmnt.prmnt_cstms_product.AUTH_STAT := l_Val;
ELSIF l_key = 'ONCEAUTH' THEN
p_pcdprmnt.prmnt_cstms_product.ONCE_AUTH := l_Val;
END IF;
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
END LOOP;
p_pcdprmnt.prmnt_product_preference.product_code := p_pcdprmnt.prmnt_cstms_product.product_code;
ELSIF l_xsd_node = 'Product-Banks' THEN
l_Dsn_rec_cnt_3 :=  p_pcdprmnt.prmnt_pctms_product_banks.count +1 ;
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
WHILE (l_Key <> 'EOPL')
LOOP
--dbg('Key/Value   :'||l_Key ||':'||l_Val);
IF l_key = 'BNKCD' THEN
p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).BANKCODE := l_Val;
END IF;
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
END LOOP;
p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).product_code := p_pcdprmnt.prmnt_cstms_product.product_code;
ELSIF l_xsd_node = 'Product-Accrole' THEN
l_Dsn_rec_cnt_4 :=  p_pcdprmnt.prmnt_pctms_product_accrole.count +1 ;
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
WHILE (l_Key <> 'EOPL')
LOOP
--dbg('Key/Value   :'||l_Key ||':'||l_Val);
IF l_key = 'ACCROLE' THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ACCOUNTING_ROLE := l_Val;
ELSIF l_key = 'STATUS' THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).STATUS := l_Val;
ELSIF l_key = 'ROLTP' THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ROLE_TYPE := l_Val;
ELSIF l_key = 'ACCHD' THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).ACCOUNTING_HEAD := l_Val;
END IF;
l_Key       := Cspks_Req_Global.Fn_GetTag;
l_Val       := Cspks_Req_Global.Fn_GetVal;
END LOOP;
l_Parent_Rec := p_pcdprmnt.prmnt_pctms_product_banks.count;
IF l_Parent_Rec > 0 THEN
p_pcdprmnt.prmnt_pctms_product_accrole(l_dsn_rec_cnt_4).product_code := p_pcdprmnt.prmnt_pctms_product_banks(l_Parent_Rec).product_code;
p_pcdprmnt.prmnt_pctms_product_accrole(l_dsn_rec_cnt_4).bankcode := p_pcdprmnt.prmnt_pctms_product_banks(l_Parent_Rec).bankcode;
END IF;
ELSIF l_xsd_node = 'Product-Events' THEN
l_cscacadd := l_Dmy_CSCACADD;
l_key_vals :='PRODUCT_CODE~PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Cspks_CSCACADD_Main.Fn_Build_Ws_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Cspks_CSCACADD_Main.Fn_Build_Ws_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_cscacadd,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACADD_Main.Fn_Build_Ws_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_cscacadd := l_cscacadd;

ELSIF l_xsd_node = 'Role-To-Head-Mapping' THEN
l_cscacrhm := l_Dmy_CSCACRHM;
l_key_vals :='PRODUCT_CODE~PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Cspks_CSCACRHM_Main.Fn_Build_Ws_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Cspks_CSCACRHM_Main.Fn_Build_Ws_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_cscacrhm,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACRHM_Main.Fn_Build_Ws_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_cscacrhm := l_cscacrhm;

ELSIF l_xsd_node = 'Product-Mis-Details' THEN
l_micprmnt := l_Dmy_MICPRMNT;
l_key_vals :='PRODUCT_CODE~PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Mipks_MICPRMNT_Main.Fn_Build_Ws_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Mipks_MICPRMNT_Main.Fn_Build_Ws_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_micprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Mipks_MICPRMNT_Main.Fn_Build_Ws_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_micprmnt := l_micprmnt;

ELSIF l_xsd_node = 'PCProduct_Master' THEN
l_pccexpr := l_Dmy_PCCEXPR;
l_key_vals :='PRODUCT_CODE~PRODUCT_CODE'||'>'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
dbg('Calling Pcpks_PCCEXPR_Main.Fn_Build_Ws_Type..');
Cspks_Req_Global.Pr_Rewind_By_One;
IF NOT Pcpks_PCCEXPR_Main.Fn_Build_Ws_Type(
l_Module,
l_calling_Function,
l_Key_Vals,
p_addl_info ,
l_pccexpr,
p_err_code,
p_err_params)  THEN
dbg('Failed in Pcpks_PCCEXPR_Main.Fn_Build_Ws_Type..');
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Rewind_By_One;
p_pcdprmnt.ty_pccexpr := l_pccexpr;

END IF;
l_Xsd_Node := Cspks_Req_Global.Fn_GetNode;
END LOOP;

p_pcdprmnt.addl_info := p_addl_info;
dbg('Returning from Fn_Sys_Build_Fc_Type ');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Sys_Build_Ws_Type ');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Build_Ws_Type;
FUNCTION Fn_Build_Ws_Type (
p_addl_info       IN Cspks_Req_Handler.Ty_Addl_Info,
p_pcdprmnt       IN   OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';

BEGIN

dbg('In Fn_Build_Ws_Type..');

dbg('Calling Fn_Sys_Build_Ws_Type..');
IF NOT Fn_Sys_Build_Ws_Type(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Sys_Build_Ws_Type..');
RETURN FALSE;
END IF;
Pr_Skip_Handler('POSTTYPE');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Custom.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Cluster.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_KERNEL THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_Post_build_type_structure(
p_addl_info ,
p_PCDPRMNT,
p_err_code,
p_err_params)  THEN
dbg('Failed in pcpks_pcdprmnt_Kernel.fn_Post_build_type_structure..');
RETURN FALSE;
END IF;

END IF;
dbg('Returning from fn_check_mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.fn_check_mandatory ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Build_Ws_Type;
FUNCTION Fn_Sys_Build_Fc_Ts (
p_pcdprmnt          IN pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code        IN OUT VARCHAR2,
p_err_params      IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_Level_Format  VARCHAR2(32767);
l_Parent_Format VARCHAR2(32767);
l_Date_Val      VARCHAR2(32767);
l_Master_Childs NUMBER := 0;
l_Desc_Vc          VARCHAR2(32767);
l_0_Lvl_Counter NUMBER := 0;
l_1_Lvl_Counter NUMBER := 0;
l_2_Lvl_Counter   NUMBER := 0;
l_3_Lvl_Counter   NUMBER := 0;
l_dsn_rec_cnt_1    NUMBER := 0;
l_bnd_cntr_1    NUMBER;
l_dsn_rec_cnt_2    NUMBER := 0;
l_bnd_cntr_2    NUMBER;
l_dsn_rec_cnt_3    NUMBER := 0;
l_bnd_cntr_3    NUMBER;
l_dsn_rec_cnt_4    NUMBER := 0;
l_bnd_cntr_4    NUMBER;
l_cntr_before   NUMBER := 0;
l_Master_where  VARCHAR2(32767);
l_count         NUMBER := 0;
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN
dbg('In Fn_Sys_Build_Fc_Ts');
l_1_Lvl_Counter := 0;
l_2_Lvl_Counter := 0;
l_0_Lvl_Counter   := l_0_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter;
Cspks_Req_Global.pr_write('P','BLK_PRODUCT_DETAILS',l_level_Format);
Cspks_Req_Global.pr_write('V','PRDCD',p_pcdprmnt.prmnt_cstms_product.product_code);
Cspks_Req_Global.pr_write('V','PRDDESC',p_pcdprmnt.prmnt_cstms_product.product_description);
Cspks_Req_Global.pr_write('V','PRDTYP',p_pcdprmnt.prmnt_cstms_product.product_type);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDTYPDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :PRDTYPDESC');
END;
Cspks_Req_Global.pr_write('V','PRDTYPDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','PRDSLG',p_pcdprmnt.prmnt_cstms_product.product_slogan);
Cspks_Req_Global.pr_write('V','PRDGRP',p_pcdprmnt.prmnt_cstms_product.product_group);
IF trunc(p_pcdprmnt.prmnt_cstms_product.product_start_date) <>
   p_pcdprmnt.prmnt_cstms_product.product_start_date THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_start_date,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_start_date,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','PRDSTRTDT',l_Date_Val);
IF trunc(p_pcdprmnt.prmnt_cstms_product.product_end_date) <>
   p_pcdprmnt.prmnt_cstms_product.product_end_date THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_end_date,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_end_date,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','PRDENDDT',l_Date_Val);
Cspks_Req_Global.pr_write('V','PRDRMRKS',p_pcdprmnt.prmnt_cstms_product.product_remarks);
Cspks_Req_Global.pr_write('V','NRMLRTVARI',p_pcdprmnt.prmnt_cstms_product.normal_rate_variance);
Cspks_Req_Global.pr_write('V','MAXRTVARI',p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance);
Cspks_Req_Global.pr_write('V','RTCODEPRFERD',p_pcdprmnt.prmnt_cstms_product.rate_code_preferred);
Cspks_Req_Global.pr_write('V','RATETYPPREF',p_pcdprmnt.prmnt_cstms_product.rate_type_preferred);
Cspks_Req_Global.pr_write('V','MODU',p_pcdprmnt.prmnt_cstms_product.module);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDGRPDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :PRDGRPDESC');
END;
Cspks_Req_Global.pr_write('V','PRDGRPDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','COLLTP',p_pcdprmnt.prmnt_product_preference.collection_type);
Cspks_Req_Global.pr_write('V','REDTP',p_pcdprmnt.prmnt_product_preference.rfd_type);
Cspks_Req_Global.pr_write('V','TRANSTYPE',p_pcdprmnt.prmnt_product_preference.transfer_type);
Cspks_Req_Global.pr_write('V','CLGVOSTROBRN',p_pcdprmnt.prmnt_product_preference.clg_vostro_brn);
Cspks_Req_Global.pr_write('V','CLGVOSTROACC',p_pcdprmnt.prmnt_product_preference.clg_vostro_acc);
Cspks_Req_Global.pr_write('V','CLGVOSTROCCY',p_pcdprmnt.prmnt_product_preference.clg_vostro_ccy);
Cspks_Req_Global.pr_write('V','NETWRKID',p_pcdprmnt.prmnt_product_preference.network_id);
Cspks_Req_Global.pr_write('V','MINDIVIAMT',p_pcdprmnt.prmnt_product_preference.min_divisible_amt);
Cspks_Req_Global.pr_write('V','MINTXNAMT',p_pcdprmnt.prmnt_product_preference.min_txn_amt);
Cspks_Req_Global.pr_write('V','CHRGMODE',p_pcdprmnt.prmnt_product_preference.charge_mode);
Cspks_Req_Global.pr_write('V','INVCSPLTREQ',p_pcdprmnt.prmnt_product_preference.invoice_split_reqd);
Cspks_Req_Global.pr_write('V','MAXTXNAMT',p_pcdprmnt.prmnt_product_preference.max_txn_amt);
Cspks_Req_Global.pr_write('V','CUTOFFHR',p_pcdprmnt.prmnt_product_preference.cutoff_hr);
Cspks_Req_Global.pr_write('V','CUTOFFMIN',p_pcdprmnt.prmnt_product_preference.cutoff_min);
Cspks_Req_Global.pr_write('V','PRIORITY',p_pcdprmnt.prmnt_product_preference.priority);
Cspks_Req_Global.pr_write('V','CUSTENTDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof);
Cspks_Req_Global.pr_write('V','CUSTENTVALDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof);
Cspks_Req_Global.pr_write('V','CPTYENTDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof);
Cspks_Req_Global.pr_write('V','CPTYENTVALDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof);
Cspks_Req_Global.pr_write('V','OVEROVERDRFT',p_pcdprmnt.prmnt_product_preference.override_overdraft);
Cspks_Req_Global.pr_write('V','DISPACC',p_pcdprmnt.prmnt_product_preference.dispatch_accounting);
Cspks_Req_Global.pr_write('V','REFERLREQD',p_pcdprmnt.prmnt_product_preference.referral_required);
Cspks_Req_Global.pr_write('V','DISP',p_pcdprmnt.prmnt_product_preference.dispatch);
Cspks_Req_Global.pr_write('V','AUTODISPATCH',p_pcdprmnt.prmnt_product_preference.auto_dispatch);
Cspks_Req_Global.pr_write('V','OUTPMTWRKFLW',p_pcdprmnt.prmnt_product_preference.out_pmt_workflow);
Cspks_Req_Global.pr_write('V','DISPMEDIA',p_pcdprmnt.prmnt_product_preference.dispatch_media);
Cspks_Req_Global.pr_write('V','DISPDAYRECUTOF',p_pcdprmnt.prmnt_product_preference.dispatch_day_precutof);
Cspks_Req_Global.pr_write('V','AUTORESP',p_pcdprmnt.prmnt_product_preference.auto_response);
Cspks_Req_Global.pr_write('V','ASCIIHANDOFFREQD',p_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd);
Cspks_Req_Global.pr_write('V','COLLSTMTREQD',p_pcdprmnt.prmnt_product_preference.collection_stmt_reqd);
Cspks_Req_Global.pr_write('V','RESPADVCREQD',p_pcdprmnt.prmnt_product_preference.response_advice_reqd);
Cspks_Req_Global.pr_write('V','PRECOTRESPDAYS',p_pcdprmnt.prmnt_product_preference.pre_cot_response_days);
Cspks_Req_Global.pr_write('V','RESPADVCEBASIS',p_pcdprmnt.prmnt_product_preference.response_advice_basis);
Cspks_Req_Global.pr_write('V','MAXINTAMT',p_pcdprmnt.prmnt_product_preference.max_int_amt);
Cspks_Req_Global.pr_write('V','MAXSPLTCOUNT',p_pcdprmnt.prmnt_product_preference.max_split_count);
Cspks_Req_Global.pr_write('V','REJACTYPEBEFR',p_pcdprmnt.prmnt_product_preference.rej_ac_type_before);
Cspks_Req_Global.pr_write('V','REJPMNTBRNBEFORE',p_pcdprmnt.prmnt_product_preference.rej_payment_brn_before);
Cspks_Req_Global.pr_write('V','REJACCTBEFRRESPDAYS',p_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days);
Cspks_Req_Global.pr_write('V','REJPMNTCCYBEFORE',p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before);
Cspks_Req_Global.pr_write('V','BCKVALLMTDAYS',p_pcdprmnt.prmnt_product_preference.back_value_limit_days);
Cspks_Req_Global.pr_write('V','FUTUREVLLMTDAYS',p_pcdprmnt.prmnt_product_preference.future_value_limit_days);
Cspks_Req_Global.pr_write('V','MOVEBVTACTIVDT',p_pcdprmnt.prmnt_product_preference.move_bvt_activation_date);
Cspks_Req_Global.pr_write('V','DFLTACTIVDT',p_pcdprmnt.prmnt_product_preference.default_activation_date);
Cspks_Req_Global.pr_write('V','PROCSREJAFTRRESPDAYS',p_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days);
Cspks_Req_Global.pr_write('V','REJVERIFYFUNDS',p_pcdprmnt.prmnt_product_preference.rej_verify_funds);
Cspks_Req_Global.pr_write('V','REJACTYPEAFTR',p_pcdprmnt.prmnt_product_preference.rej_ac_type_after);
Cspks_Req_Global.pr_write('V','REJPMNTBRNAFTER',p_pcdprmnt.prmnt_product_preference.rej_payment_brn_after);
Cspks_Req_Global.pr_write('V','REJACCTAFTERRESPDAYS',p_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days);
Cspks_Req_Global.pr_write('V','REJPMNCCYAFTER',p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after);
Cspks_Req_Global.pr_write('V','ALLOWPOSTCOTTXN',p_pcdprmnt.prmnt_product_preference.allow_post_cot_txn);
Cspks_Req_Global.pr_write('V','AUTOEXCHRATEREQD',p_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd);
Cspks_Req_Global.pr_write('V','EXRATECD',p_pcdprmnt.prmnt_product_preference.ex_rate_code);
Cspks_Req_Global.pr_write('V','EXRATETP',p_pcdprmnt.prmnt_product_preference.ex_rate_type);
Cspks_Req_Global.pr_write('V','REDISPATCH_REQD',p_pcdprmnt.prmnt_product_preference.redispatch_reqd);
Cspks_Req_Global.pr_write('V','AUTOREDISP',p_pcdprmnt.prmnt_product_preference.auto_redispatch);
Cspks_Req_Global.pr_write('V','REDISPATCH_COUNT',p_pcdprmnt.prmnt_product_preference.redispatch_count);
Cspks_Req_Global.pr_write('V','REDISPATCH_DAYS',p_pcdprmnt.prmnt_product_preference.redispatch_days);
Cspks_Req_Global.pr_write('V','RECALLDAYS',p_pcdprmnt.prmnt_product_preference.recall_days);
Cspks_Req_Global.pr_write('V','RECALLDAYSBASIS',p_pcdprmnt.prmnt_product_preference.recall_days_basis);
Cspks_Req_Global.pr_write('V','AGREEIDREQD',p_pcdprmnt.prmnt_product_preference.agreement_id_reqd);
Cspks_Req_Global.pr_write('V','CREDITOR_ID_REQD',p_pcdprmnt.prmnt_product_preference.creditor_id_reqd);
Cspks_Req_Global.pr_write('V','CHARGE_WAIVER',p_pcdprmnt.prmnt_product_preference.charge_waiver);
Cspks_Req_Global.pr_write('V','ALLOWTHIRDPRTYCHG',p_pcdprmnt.prmnt_product_preference.allow_third_party_chg);
Cspks_Req_Global.pr_write('V','CHRGCUSTSTATCS',p_pcdprmnt.prmnt_product_preference.charge_cust_statistics);
Cspks_Req_Global.pr_write('V','CHRGACSTATCS',p_pcdprmnt.prmnt_product_preference.charge_ac_statistics);
Cspks_Req_Global.pr_write('V','COLLVLUMSTATCS',p_pcdprmnt.prmnt_product_preference.collect_volume_statistics);
Cspks_Req_Global.pr_write('V','CUSTENTCONSOLREQD',p_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd);
Cspks_Req_Global.pr_write('V','CUSTENTCONSOLLMT',p_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt);
Cspks_Req_Global.pr_write('V','DISPFILENAME',p_pcdprmnt.prmnt_product_preference.disp_file_name);
Cspks_Req_Global.pr_write('V','NOOFREC',p_pcdprmnt.prmnt_product_preference.no_of_rec);
Cspks_Req_Global.pr_write('V','REVSETLEGL',p_pcdprmnt.prmnt_product_preference.rev_settle_gl);
Cspks_Req_Global.pr_write('V','RESPDAYSBASIS',p_pcdprmnt.prmnt_product_preference.response_days_basis);
Cspks_Req_Global.pr_write('V','CLGCCY',p_pcdprmnt.prmnt_product_preference.clg_ccy);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('NETWRKDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :NETWRKDESC');
END;
Cspks_Req_Global.pr_write('V','NETWRKDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','CHRGCAT',p_pcdprmnt.prmnt_product_preference.charge_category);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('DESCRIPTION');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :DESCRIPTION');
END;
Cspks_Req_Global.pr_write('V','DESCRIPTION',l_Desc_vc);
Cspks_Req_Global.pr_write('V','CCYCAL',p_pcdprmnt.prmnt_product_preference.ccy_cal);
Cspks_Req_Global.pr_write('V','PYMTREJTDAYS',p_pcdprmnt.prmnt_product_preference.pymt_rejt_days);
Cspks_Req_Global.pr_write('V','SERVLEVELCODE',p_pcdprmnt.prmnt_product_preference.serv_level_code);
Cspks_Req_Global.pr_write('V','CHRGBEARER',p_pcdprmnt.prmnt_product_preference.charge_bearer);
Cspks_Req_Global.pr_write('V','EARLYCOLLDAYS',p_pcdprmnt.prmnt_product_preference.early_coll_days);
Cspks_Req_Global.pr_write('V','FIRSTCOLLDAYS',p_pcdprmnt.prmnt_product_preference.first_coll_days);
Cspks_Req_Global.pr_write('V','RECURCOLLDAYS',p_pcdprmnt.prmnt_product_preference.recur_coll_days);
Cspks_Req_Global.pr_write('V','FIRSTCOLLDISPDAYS',p_pcdprmnt.prmnt_product_preference.first_coll_disp_days);
Cspks_Req_Global.pr_write('V','RECALLDTBASIS',p_pcdprmnt.prmnt_product_preference.recall_date_basis);
Cspks_Req_Global.pr_write('V','PAYMNTTP',p_pcdprmnt.prmnt_product_preference.payment_type);
Cspks_Req_Global.pr_write('V','CLGMODE',p_pcdprmnt.prmnt_product_preference.clearing_mode);
Cspks_Req_Global.pr_write('V','PRDPRE',p_pcdprmnt.prmnt_product_preference.product_code);
Cspks_Req_Global.pr_write('V','PRDTYPPREF',p_pcdprmnt.prmnt_product_preference.product_type);
Cspks_Req_Global.pr_write('V','MAKER',p_pcdprmnt.prmnt_cstms_product.maker_id);
IF trunc(p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp) <>
   p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','MAKERSTAMP',l_Date_Val);
Cspks_Req_Global.pr_write('V','CHECKER',p_pcdprmnt.prmnt_cstms_product.checker_id);
IF trunc(p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp) <>
   p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','CHECKERSTAMP',l_Date_Val);
Cspks_Req_Global.pr_write('V','MODNO',p_pcdprmnt.prmnt_cstms_product.mod_no);
Cspks_Req_Global.pr_write('V','TXNSTAT',p_pcdprmnt.prmnt_cstms_product.record_stat);
Cspks_Req_Global.pr_write('V','AUTHSTAT',p_pcdprmnt.prmnt_cstms_product.auth_stat);
Cspks_Req_Global.pr_write('V','ONCEAUTH',p_pcdprmnt.prmnt_cstms_product.once_auth);

--dbg('Building Childs Of :BLK_PRODUCT_DETAILS..');
l_dsn_rec_cnt_3 := 0;
IF p_pcdprmnt.prmnt_pctms_product_banks.COUNT > 0 THEN
FOR i_3 IN  1..p_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
l_dsn_rec_cnt_3 := i_3;
l_2_Lvl_Counter := 0;
l_Master_Childs  :=  l_Master_Childs +1;
l_1_Lvl_Counter   := l_1_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter||'.'||l_1_Lvl_Counter;
Cspks_Req_Global.pr_write('P','BLK_PRODUCT_BANKS',l_level_Format);
Cspks_Req_Global.pr_write('V','PRDCD',p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).product_code);
Cspks_Req_Global.pr_write('V','BNKCD',p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).bankcode);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_BANKS')(l_Dsn_rec_cnt_3)('BANK_NAME');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :BANK_NAME');
END;
Cspks_Req_Global.pr_write('V','BANK_NAME',l_Desc_vc);

--dbg('Building Childs Of :BLK_PRODUCT_BANKS..');
l_dsn_rec_cnt_4 := 0;
IF p_pcdprmnt.prmnt_pctms_product_accrole.COUNT > 0 THEN
FOR i_4 IN  1..p_pcdprmnt.prmnt_pctms_product_accrole.COUNT LOOP
IF NVL(p_pcdprmnt.prmnt_pctms_product_accrole(i_4).product_code,'@') = NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).product_code,'@') AND NVL(p_pcdprmnt.prmnt_pctms_product_accrole(i_4).bankcode,'@') = NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).bankcode,'@') THEN
l_dsn_rec_cnt_4 := i_4;
l_2_Lvl_Counter   := l_2_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter||'.'||l_1_Lvl_Counter||'.'||l_2_Lvl_Counter;
Cspks_Req_Global.pr_write('P','BLK_PRODUCT_ACCROLE',l_level_Format);
Cspks_Req_Global.pr_write('V','PRDCD',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).product_code);
Cspks_Req_Global.pr_write('V','BNKCD',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).bankcode);
Cspks_Req_Global.pr_write('V','ACCROLE',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).accounting_role);
Cspks_Req_Global.pr_write('V','STATUS',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).status);
Cspks_Req_Global.pr_write('V','ROLTP',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).role_type);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(l_Dsn_rec_cnt_4)('ROLDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :ROLDESC');
END;
Cspks_Req_Global.pr_write('V','ROLDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','ACCHD',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).accounting_head);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(l_Dsn_rec_cnt_4)('GLDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :GLDESC');
END;
Cspks_Req_Global.pr_write('V','GLDESC',l_Desc_vc);
END IF;
END LOOP;
END IF;
END LOOP;
END IF;
l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_cscacadd  := p_pcdprmnt.ty_cscacadd;
IF NOT Cspks_CSCACADD_Main.Fn_Build_Fc_Ts(
l_cscacadd,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_cscacrhm  := p_pcdprmnt.ty_cscacrhm;
IF NOT Cspks_CSCACRHM_Main.Fn_Build_Fc_Ts(
l_cscacrhm,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_micprmnt  := p_pcdprmnt.ty_micprmnt;
IF NOT Mipks_MICPRMNT_Main.Fn_Build_Fc_Ts(
l_micprmnt,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_pccexpr  := p_pcdprmnt.ty_pccexpr;
IF NOT Pcpks_PCCEXPR_Main.Fn_Build_Fc_Ts(
l_pccexpr,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

dbg('Returning from Fn_Sys_Build_Fc_Ts');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Build_Fc_Ts');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Build_Fc_Ts;
FUNCTION Fn_Sys_Build_Ws_Ts (
p_pcdprmnt          IN pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_exchange_pattern IN       VARCHAR2,
p_err_code        IN OUT VARCHAR2,
p_err_params      IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_Level_Format  VARCHAR2(32767);
l_Parent_Format VARCHAR2(32767);
l_Date_Val      VARCHAR2(32767);
l_Desc_Vc          VARCHAR2(32767);
l_Master_Childs NUMBER := 0;
l_key_cols          VARCHAR2(32767);
l_key_vals          VARCHAR2(32767);
l_0_Lvl_Counter NUMBER := 0;
l_1_Lvl_Counter NUMBER := 0;
l_2_Lvl_Counter   NUMBER := 0;
l_3_Lvl_Counter   NUMBER := 0;
l_dsn_rec_cnt_3    NUMBER := 0;
l_bnd_cntr_3    NUMBER;
l_dsn_rec_cnt_4    NUMBER := 0;
l_bnd_cntr_4    NUMBER;
l_cntr_before   NUMBER := 0;
l_Master_where  VARCHAR2(32767);
l_count         NUMBER := 0;
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN
dbg('In Fn_Sys_Build_Ws_Ts');
IF SUBSTR(p_exchange_pattern,3,4) = 'FS' THEN
dbg('Building Full Scren Reply..');
IF ( (  p_pcdprmnt.prmnt_cstms_product.product_code IS NOT NULL ) OR(  p_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL ) )
 THEN
l_1_Lvl_Counter := 0;
l_2_Lvl_Counter := 0;
l_0_Lvl_Counter   := l_0_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter;
Cspks_Req_Global.pr_write('P','Product-Details-Full',l_level_Format);
Cspks_Req_Global.pr_write('V','PRDCD',p_pcdprmnt.prmnt_cstms_product.product_code);
Cspks_Req_Global.pr_write('V','PRDDESC',p_pcdprmnt.prmnt_cstms_product.product_description);
Cspks_Req_Global.pr_write('V','PRDTYP',p_pcdprmnt.prmnt_cstms_product.product_type);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDTYPDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :PRDTYPDESC');
END;
Cspks_Req_Global.pr_write('V','PRDTYPDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','PRDSLG',p_pcdprmnt.prmnt_cstms_product.product_slogan);
Cspks_Req_Global.pr_write('V','PRDGRP',p_pcdprmnt.prmnt_cstms_product.product_group);
IF trunc(p_pcdprmnt.prmnt_cstms_product.product_start_date) <>
   p_pcdprmnt.prmnt_cstms_product.product_start_date THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_start_date,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_start_date,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','PRDSTRTDT',l_Date_Val);
IF trunc(p_pcdprmnt.prmnt_cstms_product.product_end_date) <>
   p_pcdprmnt.prmnt_cstms_product.product_end_date THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_end_date,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.product_end_date,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','PRDENDDT',l_Date_Val);
Cspks_Req_Global.pr_write('V','PRDRMRKS',p_pcdprmnt.prmnt_cstms_product.product_remarks);
Cspks_Req_Global.pr_write('V','NRMLRTVARI',p_pcdprmnt.prmnt_cstms_product.normal_rate_variance);
Cspks_Req_Global.pr_write('V','MAXRTVARI',p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance);
Cspks_Req_Global.pr_write('V','RTCODEPRFERD',p_pcdprmnt.prmnt_cstms_product.rate_code_preferred);
Cspks_Req_Global.pr_write('V','RATETYPPREF',p_pcdprmnt.prmnt_cstms_product.rate_type_preferred);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDGRPDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :PRDGRPDESC');
END;
Cspks_Req_Global.pr_write('V','PRDGRPDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','COLLTP',p_pcdprmnt.prmnt_product_preference.collection_type);
Cspks_Req_Global.pr_write('V','REDTP',p_pcdprmnt.prmnt_product_preference.rfd_type);
Cspks_Req_Global.pr_write('V','TRANSTYPE',p_pcdprmnt.prmnt_product_preference.transfer_type);
Cspks_Req_Global.pr_write('V','CLGVOSTROBRN',p_pcdprmnt.prmnt_product_preference.clg_vostro_brn);
Cspks_Req_Global.pr_write('V','CLGVOSTROACC',p_pcdprmnt.prmnt_product_preference.clg_vostro_acc);
Cspks_Req_Global.pr_write('V','CLGVOSTROCCY',p_pcdprmnt.prmnt_product_preference.clg_vostro_ccy);
Cspks_Req_Global.pr_write('V','NETWRKID',p_pcdprmnt.prmnt_product_preference.network_id);
Cspks_Req_Global.pr_write('V','MINDIVIAMT',p_pcdprmnt.prmnt_product_preference.min_divisible_amt);
Cspks_Req_Global.pr_write('V','MINTXNAMT',p_pcdprmnt.prmnt_product_preference.min_txn_amt);
Cspks_Req_Global.pr_write('V','CHRGMODE',p_pcdprmnt.prmnt_product_preference.charge_mode);
Cspks_Req_Global.pr_write('V','INVCSPLTREQ',p_pcdprmnt.prmnt_product_preference.invoice_split_reqd);
Cspks_Req_Global.pr_write('V','MAXTXNAMT',p_pcdprmnt.prmnt_product_preference.max_txn_amt);
Cspks_Req_Global.pr_write('V','HOUR',p_pcdprmnt.prmnt_product_preference.cutoff_hr);
Cspks_Req_Global.pr_write('V','MINUTE',p_pcdprmnt.prmnt_product_preference.cutoff_min);
Cspks_Req_Global.pr_write('V','PRIORITY',p_pcdprmnt.prmnt_product_preference.priority);
Cspks_Req_Global.pr_write('V','CUSTENTDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof);
Cspks_Req_Global.pr_write('V','CUSTENTVALDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof);
Cspks_Req_Global.pr_write('V','CPTYENTDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof);
Cspks_Req_Global.pr_write('V','CPTYENTVALDAYPRECUTOF',p_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof);
Cspks_Req_Global.pr_write('V','OVEROVERDRFT',p_pcdprmnt.prmnt_product_preference.override_overdraft);
Cspks_Req_Global.pr_write('V','DISPACC',p_pcdprmnt.prmnt_product_preference.dispatch_accounting);
Cspks_Req_Global.pr_write('V','REFERLREQD',p_pcdprmnt.prmnt_product_preference.referral_required);
Cspks_Req_Global.pr_write('V','DISP',p_pcdprmnt.prmnt_product_preference.dispatch);
Cspks_Req_Global.pr_write('V','AUTODISPATCH',p_pcdprmnt.prmnt_product_preference.auto_dispatch);
Cspks_Req_Global.pr_write('V','OUTPMTWRKFLW',p_pcdprmnt.prmnt_product_preference.out_pmt_workflow);
Cspks_Req_Global.pr_write('V','DISPMEDIA',p_pcdprmnt.prmnt_product_preference.dispatch_media);
Cspks_Req_Global.pr_write('V','DISPDAYRECUTOF',p_pcdprmnt.prmnt_product_preference.dispatch_day_precutof);
Cspks_Req_Global.pr_write('V','AUT_RESP',p_pcdprmnt.prmnt_product_preference.auto_response);
Cspks_Req_Global.pr_write('V','ASCII',p_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd);
Cspks_Req_Global.pr_write('V','COL_STA_REQ',p_pcdprmnt.prmnt_product_preference.collection_stmt_reqd);
Cspks_Req_Global.pr_write('V','RESPADVCREQD',p_pcdprmnt.prmnt_product_preference.response_advice_reqd);
Cspks_Req_Global.pr_write('V','PRECOTRESPDAYS',p_pcdprmnt.prmnt_product_preference.pre_cot_response_days);
Cspks_Req_Global.pr_write('V','RESPADVCEBASIS',p_pcdprmnt.prmnt_product_preference.response_advice_basis);
Cspks_Req_Global.pr_write('V','MAXINTAMT',p_pcdprmnt.prmnt_product_preference.max_int_amt);
Cspks_Req_Global.pr_write('V','MAXSPLTCOUNT',p_pcdprmnt.prmnt_product_preference.max_split_count);
Cspks_Req_Global.pr_write('V','REJACTYPEBEFR',p_pcdprmnt.prmnt_product_preference.rej_ac_type_before);
Cspks_Req_Global.pr_write('V','LMTBRN',p_pcdprmnt.prmnt_product_preference.rej_payment_brn_before);
Cspks_Req_Global.pr_write('V','ATMACC',p_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days);
Cspks_Req_Global.pr_write('V','REJPMNTCCYBEFORE',p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before);
Cspks_Req_Global.pr_write('V','BCKVALLMTDAYS',p_pcdprmnt.prmnt_product_preference.back_value_limit_days);
Cspks_Req_Global.pr_write('V','FUTUREVLLMTDAYS',p_pcdprmnt.prmnt_product_preference.future_value_limit_days);
Cspks_Req_Global.pr_write('V','MOVEBVTACTIVDT',p_pcdprmnt.prmnt_product_preference.move_bvt_activation_date);
Cspks_Req_Global.pr_write('V','DFLTACTIVDT',p_pcdprmnt.prmnt_product_preference.default_activation_date);
Cspks_Req_Global.pr_write('V','PROCSREJAFTRRESPDAYS',p_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days);
Cspks_Req_Global.pr_write('V','REJVERIFYFUNDS',p_pcdprmnt.prmnt_product_preference.rej_verify_funds);
Cspks_Req_Global.pr_write('V','REJACTYPEAFTR',p_pcdprmnt.prmnt_product_preference.rej_ac_type_after);
Cspks_Req_Global.pr_write('V','ACCBRN',p_pcdprmnt.prmnt_product_preference.rej_payment_brn_after);
Cspks_Req_Global.pr_write('V','ACCOUNT_NUMBER',p_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days);
Cspks_Req_Global.pr_write('V','REJPMNCCYAFTER',p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after);
Cspks_Req_Global.pr_write('V','ALLOWPOSTCOTTXN',p_pcdprmnt.prmnt_product_preference.allow_post_cot_txn);
Cspks_Req_Global.pr_write('V','AUTOEXCHRATEREQD',p_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd);
Cspks_Req_Global.pr_write('V','EXRATECD',p_pcdprmnt.prmnt_product_preference.ex_rate_code);
Cspks_Req_Global.pr_write('V','EXRATETP',p_pcdprmnt.prmnt_product_preference.ex_rate_type);
Cspks_Req_Global.pr_write('V','REDISPATCH_REQD',p_pcdprmnt.prmnt_product_preference.redispatch_reqd);
Cspks_Req_Global.pr_write('V','AUTOREDISP',p_pcdprmnt.prmnt_product_preference.auto_redispatch);
Cspks_Req_Global.pr_write('V','REDISPATCH_COUNT',p_pcdprmnt.prmnt_product_preference.redispatch_count);
Cspks_Req_Global.pr_write('V','REDISPATCH_DAYS',p_pcdprmnt.prmnt_product_preference.redispatch_days);
Cspks_Req_Global.pr_write('V','RECALLDAYS',p_pcdprmnt.prmnt_product_preference.recall_days);
Cspks_Req_Global.pr_write('V','RECALLDAYSBASIS',p_pcdprmnt.prmnt_product_preference.recall_days_basis);
Cspks_Req_Global.pr_write('V','AGREEIDREQD',p_pcdprmnt.prmnt_product_preference.agreement_id_reqd);
Cspks_Req_Global.pr_write('V','CREDITOR_ID_REQD',p_pcdprmnt.prmnt_product_preference.creditor_id_reqd);
Cspks_Req_Global.pr_write('V','CHARGE_WAIVER',p_pcdprmnt.prmnt_product_preference.charge_waiver);
Cspks_Req_Global.pr_write('V','ALLOWTHIRDPRTYCHG',p_pcdprmnt.prmnt_product_preference.allow_third_party_chg);
Cspks_Req_Global.pr_write('V','CHRGCUSTSTATCS',p_pcdprmnt.prmnt_product_preference.charge_cust_statistics);
Cspks_Req_Global.pr_write('V','CHRGACSTATCS',p_pcdprmnt.prmnt_product_preference.charge_ac_statistics);
Cspks_Req_Global.pr_write('V','COLLVLUMSTATCS',p_pcdprmnt.prmnt_product_preference.collect_volume_statistics);
Cspks_Req_Global.pr_write('V','CUSTENTCONSOLREQD',p_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd);
Cspks_Req_Global.pr_write('V','CUSTENTCONSOLLMT',p_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt);
Cspks_Req_Global.pr_write('V','DISPFILENAME',p_pcdprmnt.prmnt_product_preference.disp_file_name);
Cspks_Req_Global.pr_write('V','NOOFREC',p_pcdprmnt.prmnt_product_preference.no_of_rec);
Cspks_Req_Global.pr_write('V','REVSETLEGL',p_pcdprmnt.prmnt_product_preference.rev_settle_gl);
Cspks_Req_Global.pr_write('V','RESPDAYSBASIS',p_pcdprmnt.prmnt_product_preference.response_days_basis);
Cspks_Req_Global.pr_write('V','CLGCCY',p_pcdprmnt.prmnt_product_preference.clg_ccy);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('NETWRKDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :NETWRKDESC');
END;
Cspks_Req_Global.pr_write('V','NETWRKDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','CHRGCAT',p_pcdprmnt.prmnt_product_preference.charge_category);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('DESCRIPTION');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :DESCRIPTION');
END;
Cspks_Req_Global.pr_write('V','DESCRIPTION',l_Desc_vc);
Cspks_Req_Global.pr_write('V','CCYCAL',p_pcdprmnt.prmnt_product_preference.ccy_cal);
Cspks_Req_Global.pr_write('V','PYMTREJTDAYS',p_pcdprmnt.prmnt_product_preference.pymt_rejt_days);
Cspks_Req_Global.pr_write('V','SERVLEVELCODE',p_pcdprmnt.prmnt_product_preference.serv_level_code);
Cspks_Req_Global.pr_write('V','CHRGBEARER',p_pcdprmnt.prmnt_product_preference.charge_bearer);
Cspks_Req_Global.pr_write('V','EARLYCOLLDAYS',p_pcdprmnt.prmnt_product_preference.early_coll_days);
Cspks_Req_Global.pr_write('V','FIRSTCOLLDAYS',p_pcdprmnt.prmnt_product_preference.first_coll_days);
Cspks_Req_Global.pr_write('V','RECURCOLLDAYS',p_pcdprmnt.prmnt_product_preference.recur_coll_days);
Cspks_Req_Global.pr_write('V','FIRSTCOLLDISPDAYS',p_pcdprmnt.prmnt_product_preference.first_coll_disp_days);
Cspks_Req_Global.pr_write('V','RECALLDTBASIS',p_pcdprmnt.prmnt_product_preference.recall_date_basis);
Cspks_Req_Global.pr_write('V','PAYMNTTP',p_pcdprmnt.prmnt_product_preference.payment_type);
Cspks_Req_Global.pr_write('V','CLGMODE',p_pcdprmnt.prmnt_product_preference.clearing_mode);
Cspks_Req_Global.pr_write('V','MAKER',p_pcdprmnt.prmnt_cstms_product.maker_id);
IF trunc(p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp) <>
   p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.maker_dt_stamp,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','MAKERSTAMP',l_Date_Val);
Cspks_Req_Global.pr_write('V','CHECKER',p_pcdprmnt.prmnt_cstms_product.checker_id);
IF trunc(p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp) <>
   p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp THEN
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp,Cspks_Req_Handler.g_ws_date_time_format);
ELSE
l_Date_Val :=  TO_CHAR( p_pcdprmnt.prmnt_cstms_product.checker_dt_stamp,Cspks_Req_Handler.g_ws_date_format);
END IF;
Cspks_Req_Global.pr_write('V','CHECKERSTAMP',l_Date_Val);
Cspks_Req_Global.pr_write('V','MODNO',p_pcdprmnt.prmnt_cstms_product.mod_no);
Cspks_Req_Global.pr_write('V','TXNSTAT',p_pcdprmnt.prmnt_cstms_product.record_stat);
Cspks_Req_Global.pr_write('V','AUTHSTAT',p_pcdprmnt.prmnt_cstms_product.auth_stat);

--dbg('Building Childs Of :BLK_PRODUCT_DETAILS..');
l_dsn_rec_cnt_3 := 0;
IF p_pcdprmnt.prmnt_pctms_product_banks.COUNT > 0 THEN
FOR i_3 IN  1..p_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
l_dsn_rec_cnt_3 := i_3;
l_2_Lvl_Counter := 0;
l_Master_Childs  :=  l_Master_Childs +1;
l_1_Lvl_Counter   := l_1_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter||'.'||l_1_Lvl_Counter;
Cspks_Req_Global.pr_write('P','Product-Banks',l_level_Format);
Cspks_Req_Global.pr_write('V','BNKCD',p_pcdprmnt.prmnt_pctms_product_banks(l_Dsn_rec_cnt_3).bankcode);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_BANKS')(l_Dsn_rec_cnt_3)('BANK_NAME');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :BANK_NAME');
END;
Cspks_Req_Global.pr_write('V','BANK_NAME',l_Desc_vc);

--dbg('Building Childs Of :BLK_PRODUCT_BANKS..');
l_dsn_rec_cnt_4 := 0;
IF p_pcdprmnt.prmnt_pctms_product_accrole.COUNT > 0 THEN
FOR i_4 IN  1..p_pcdprmnt.prmnt_pctms_product_accrole.COUNT LOOP
IF NVL(p_pcdprmnt.prmnt_pctms_product_accrole(i_4).product_code,'@') = NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).product_code,'@') AND NVL(p_pcdprmnt.prmnt_pctms_product_accrole(i_4).bankcode,'@') = NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_dsn_rec_cnt_3).bankcode,'@') THEN
l_dsn_rec_cnt_4 := i_4;
l_2_Lvl_Counter   := l_2_Lvl_Counter +1;
l_level_Format      := l_0_Lvl_Counter||'.'||l_1_Lvl_Counter||'.'||l_2_Lvl_Counter;
Cspks_Req_Global.pr_write('P','Product-Accrole',l_level_Format);
Cspks_Req_Global.pr_write('V','ACCROLE',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).accounting_role);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(l_Dsn_rec_cnt_4)('ROLDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :ROLDESC');
END;
Cspks_Req_Global.pr_write('V','ROLDESC',l_Desc_vc);
Cspks_Req_Global.pr_write('V','ACCHD',p_pcdprmnt.prmnt_pctms_product_accrole(l_Dsn_rec_cnt_4).accounting_head);
l_desc_vc := NULL;
BEGIN
l_desc_vc := p_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(l_Dsn_rec_cnt_4)('GLDESC');
EXCEPTION
WHEN OTHERS THEN
dbg(sqlerrm);
dbg('Failed in Populating Description Field   :GLDESC');
END;
Cspks_Req_Global.pr_write('V','GLDESC',l_Desc_vc);
END IF;
END LOOP;
END IF;
END LOOP;
END IF;
l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_cscacrhm  := p_pcdprmnt.ty_cscacrhm;
IF NOT Cspks_CSCACRHM_Main.Fn_Build_Ws_Ts(
l_cscacrhm,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Ws_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_cscacadd  := p_pcdprmnt.ty_cscacadd;
IF NOT Cspks_CSCACADD_Main.Fn_Build_Ws_Ts(
l_cscacadd,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Ws_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_micprmnt  := p_pcdprmnt.ty_micprmnt;
IF NOT Mipks_MICPRMNT_Main.Fn_Build_Ws_Ts(
l_micprmnt,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Ws_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

l_level_Format      := l_0_Lvl_Counter;
l_cntr_before := l_Master_Childs;
l_pccexpr  := p_pcdprmnt.ty_pccexpr;
IF NOT Pcpks_PCCEXPR_Main.Fn_Build_Ws_Ts(
l_pccexpr,
l_level_Format,
l_1_Lvl_Counter,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Ws_Ts');
RETURN FALSE;
END IF;
l_Master_Childs  :=  l_Master_Childs + (l_0_Lvl_Counter -  l_cntr_before);

END IF;
ELSE
dbg('Building Primary Key Reply..');
Cspks_Req_Global.pr_write('P','Product-Details-PK');
l_key_cols := 'PRDCD~';
l_key_vals := p_pcdprmnt.prmnt_cstms_product.product_code||'~';
Cspks_Req_Global.pr_write('V',l_Key_Cols,l_Key_Vals);
END IF;
dbg('Returning from Fn_Sys_Build_Ws_Ts');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Build_Ws_Ts');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Build_Ws_Ts;
FUNCTION Fn_Sys_Check_Mandatory (p_source		IN  VARCHAR2,
p_pk_or_full     IN  VARCHAR2 DEFAULT 'FULL',
p_pcdprmnt IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code       IN  OUT VARCHAR2,
p_err_params     IN  OUT VARCHAR2)
RETURN BOOLEAN IS

l_count          NUMBER:= 0;
l_key            VARCHAR2(5000);
l_blk            VARCHAR2(100);
l_fld            VARCHAR2(100);
l_rec_sent       BOOLEAN := TRUE;
l_base_data_from_fc  VARCHAR2(1):= 'Y';

BEGIN

dbg('In Fn_Sys_Check_Mandatory..');

l_fld := 'CSTMS_PRODUCT.PRODUCT_CODE';
IF p_pcdprmnt.prmnt_cstms_product.product_code IS Null THEN
dbg('Field product_code is Null..');
p_err_code    := 'ST-MAND-001';
p_err_params := '@'||l_fld;
RETURN FALSE;
END IF;

IF p_pk_or_full = 'FULL'  THEN
dbg('Full Mandatory Checks..');

l_blk := 'CSTMS_PRODUCT';
l_fld := 'CSTMS_PRODUCT.PRODUCT_DESCRIPTION';
IF p_pcdprmnt.prmnt_cstms_product.product_description IS Null THEN
dbg('Mandatory column product_description cannot be Null');
pr_log_error(p_source,'ST-MAND-004','@'||l_fld );
END IF;
l_fld := 'CSTMS_PRODUCT.NORMAL_RATE_VARIANCE';
IF p_pcdprmnt.prmnt_cstms_product.normal_rate_variance IS Null THEN
dbg('Mandatory column normal_rate_variance cannot be Null');
pr_log_error(p_source,'ST-MAND-004','@'||l_fld );
END IF;
l_fld := 'CSTMS_PRODUCT.MAXIMUM_RATE_VARIANCE';
IF p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance IS Null THEN
dbg('Mandatory column maximum_rate_variance cannot be Null');
pr_log_error(p_source,'ST-MAND-004','@'||l_fld );
END IF;
l_fld := 'CSTMS_PRODUCT.RATE_CODE_PREFERRED';
IF p_pcdprmnt.prmnt_cstms_product.rate_code_preferred IS Null THEN
dbg('Mandatory column rate_code_preferred cannot be Null');
pr_log_error(p_source,'ST-MAND-004','@'||l_fld );
END IF;
l_fld := 'CSTMS_PRODUCT.RATE_TYPE_PREFERRED';
IF p_pcdprmnt.prmnt_cstms_product.rate_type_preferred IS Null THEN
dbg('Mandatory column rate_type_preferred cannot be Null');
pr_log_error(p_source,'ST-MAND-004','@'||l_fld );
END IF;

l_blk := 'PCTMS_PRODUCT_PREFERENCE';
l_rec_sent  := FALSE;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PRODUCT_CODE';
IF p_pcdprmnt.prmnt_product_preference.product_code IS Null THEN
IF l_rec_sent  THEN
dbg('Primary key column product_code cannot be Null');
pr_log_error(p_source,'ST-MAND-002','@'||l_fld||'~@'||l_blk) ;
END IF;
ELSE
l_rec_sent  := TRUE;
END IF;

l_blk := 'PCTMS_PRODUCT_BANKS';
l_count := p_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_count > 0 THEN
FOR l_index IN 1 .. p_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
l_fld := 'PCTMS_PRODUCT_BANKS.BANKCODE';
IF p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode IS Null THEN
dbg('Primary key column bankcode cannot be Null');
l_key := Null;
pr_log_error(p_source,'ST-MAND-003','@'||l_fld||'~@'||l_blk||'~'||l_index );
END IF;
l_key := nvl(l_key, to_char(l_index));
END LOOP;
END IF;

l_blk := 'PCTMS_PRODUCT_ACCROLE';
l_count := p_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_count > 0 THEN
FOR l_index IN 1 .. p_pcdprmnt.prmnt_pctms_product_accrole.COUNT LOOP
l_fld := 'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE';
IF p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role IS Null THEN
dbg('Primary key column accounting_role cannot be Null');
l_key := Null;
pr_log_error(p_source,'ST-MAND-003','@'||l_fld||'~@'||l_blk||'~'||l_index );
END IF;
l_fld := 'PCTMS_PRODUCT_ACCROLE.STATUS';
IF p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status IS Null THEN
dbg('Primary key column status cannot be Null');
l_key := Null;
pr_log_error(p_source,'ST-MAND-003','@'||l_fld||'~@'||l_blk||'~'||l_index );
END IF;
l_key := nvl(l_key, to_char(l_index));
END LOOP;
END IF;
END IF;

dbg('Returning from Fn_Sys_Check_Mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Check_Mandatory ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Sys_Check_Mandatory;
FUNCTION Fn_Sys_Basic_Vals        (p_source            IN VARCHAR2,
p_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_count          NUMBER:= 0;
l_key            VARCHAR2(5000):= NULL;
i                NUMBER := 1;
l_blk            VARCHAR2(100):= 0;
l_fld            VARCHAR2(100):= 0;
l_inv_chr        VARCHAR2(5) :=NULL;
BEGIN

dbg('In Fn_Sys_Basic_Vals');
IF p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE IS NOT NULL THEN
l_inv_chr :=  Cspks_Req_Utils.Fn_Validate_Restr_Text(p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE);
IF l_inv_chr is NOT NULL THEN
dbg('Retricted Text :Invalid Value for the Field  :PRODUCT_CODE:'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE);
pr_log_error(p_source,'ST-VALS-014',l_inv_chr||'~'||p_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE||'~@CSTMS_PRODUCT.PRODUCT_CODE~@CSTMS_PRODUCT') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED IS NOT NULL THEN
IF p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED NOT IN ('M','B') THEN
dbg('Invalid Value for the Field  :RATE_CODE_PREFERRED:'||p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED);
pr_log_error(p_source,'ST-VALS-011',p_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED||'~@CSTMS_PRODUCT.RATE_CODE_PREFERRED~@CSTMS_PRODUCT') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE NOT IN ('DD','RFD') THEN
dbg('Invalid Value for the Field  :COLLECTION_TYPE:'||p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE||'~@PCTMS_PRODUCT_PREFERENCE.COLLECTION_TYPE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RFD_TYPE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RFD_TYPE NOT IN ('F','P','N') THEN
dbg('Invalid Value for the Field  :RFD_TYPE:'||p_pcdprmnt.prmnt_product_preference.RFD_TYPE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RFD_TYPE||'~@PCTMS_PRODUCT_PREFERENCE.RFD_TYPE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE NOT IN ('B','C') THEN
dbg('Invalid Value for the Field  :TRANSFER_TYPE:'||p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE||'~@PCTMS_PRODUCT_PREFERENCE.TRANSFER_TYPE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT < 0 THEN
dbg('Invalid Value for the Field  :MIN_DIVISIBLE_AMT:'||p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT||'~@PCTMS_PRODUCT_PREFERENCE.MIN_DIVISIBLE_AMT~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT < 0 THEN
dbg('Invalid Value for the Field  :MIN_TXN_AMT:'||p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT||'~@PCTMS_PRODUCT_PREFERENCE.MIN_TXN_AMT~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CHARGE_MODE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CHARGE_MODE NOT IN ('P','D') THEN
dbg('Invalid Value for the Field  :CHARGE_MODE:'||p_pcdprmnt.prmnt_product_preference.CHARGE_MODE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CHARGE_MODE||'~@PCTMS_PRODUCT_PREFERENCE.CHARGE_MODE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :INVOICE_SPLIT_REQD:'||p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD||'~@PCTMS_PRODUCT_PREFERENCE.INVOICE_SPLIT_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT < 0 THEN
dbg('Invalid Value for the Field  :MAX_TXN_AMT:'||p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT||'~@PCTMS_PRODUCT_PREFERENCE.MAX_TXN_AMT~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :OVERRIDE_OVERDRAFT:'||p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT||'~@PCTMS_PRODUCT_PREFERENCE.OVERRIDE_OVERDRAFT~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :DISPATCH_ACCOUNTING:'||p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING||'~@PCTMS_PRODUCT_PREFERENCE.DISPATCH_ACCOUNTING~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :REFERRAL_REQUIRED:'||p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED||'~@PCTMS_PRODUCT_PREFERENCE.REFERRAL_REQUIRED~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.DISPATCH IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.DISPATCH NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :DISPATCH:'||p_pcdprmnt.prmnt_product_preference.DISPATCH);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.DISPATCH||'~@PCTMS_PRODUCT_PREFERENCE.DISPATCH~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :AUTO_DISPATCH:'||p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH||'~@PCTMS_PRODUCT_PREFERENCE.AUTO_DISPATCH~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :OUT_PMT_WORKFLOW:'||p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW||'~@PCTMS_PRODUCT_PREFERENCE.OUT_PMT_WORKFLOW~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA NOT IN ('F','I') THEN
dbg('Invalid Value for the Field  :DISPATCH_MEDIA:'||p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA||'~@PCTMS_PRODUCT_PREFERENCE.DISPATCH_MEDIA~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :AUTO_RESPONSE:'||p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE||'~@PCTMS_PRODUCT_PREFERENCE.AUTO_RESPONSE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :ASCII_HANDOFF_REQD:'||p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD||'~@PCTMS_PRODUCT_PREFERENCE.ASCII_HANDOFF_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :COLLECTION_STMT_REQD:'||p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD||'~@PCTMS_PRODUCT_PREFERENCE.COLLECTION_STMT_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :RESPONSE_ADVICE_REQD:'||p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD||'~@PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS NOT IN ('E','R') THEN
dbg('Invalid Value for the Field  :RESPONSE_ADVICE_BASIS:'||p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS||'~@PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_BASIS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE NOT IN ('A','G') THEN
dbg('Invalid Value for the Field  :REJ_AC_TYPE_BEFORE:'||p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE||'~@PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_BEFORE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :MOVE_BVT_ACTIVATION_DATE:'||p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE||'~@PCTMS_PRODUCT_PREFERENCE.MOVE_BVT_ACTIVATION_DATE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE NOT IN ('T','N') THEN
dbg('Invalid Value for the Field  :DEFAULT_ACTIVATION_DATE:'||p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE||'~@PCTMS_PRODUCT_PREFERENCE.DEFAULT_ACTIVATION_DATE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :PROCESS_REJ_AFTER_RESP_DAYS:'||p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS||'~@PCTMS_PRODUCT_PREFERENCE.PROCESS_REJ_AFTER_RESP_DAYS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :REJ_VERIFY_FUNDS:'||p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS||'~@PCTMS_PRODUCT_PREFERENCE.REJ_VERIFY_FUNDS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER NOT IN ('A','G') THEN
dbg('Invalid Value for the Field  :REJ_AC_TYPE_AFTER:'||p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER||'~@PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_AFTER~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :ALLOW_POST_COT_TXN:'||p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN||'~@PCTMS_PRODUCT_PREFERENCE.ALLOW_POST_COT_TXN~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :AUTO_EXCH_RATE_REQD:'||p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD||'~@PCTMS_PRODUCT_PREFERENCE.AUTO_EXCH_RATE_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE NOT IN ('M','B','S') THEN
dbg('Invalid Value for the Field  :EX_RATE_TYPE:'||p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE||'~@PCTMS_PRODUCT_PREFERENCE.EX_RATE_TYPE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :REDISPATCH_REQD:'||p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD||'~@PCTMS_PRODUCT_PREFERENCE.REDISPATCH_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :AUTO_REDISPATCH:'||p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH||'~@PCTMS_PRODUCT_PREFERENCE.AUTO_REDISPATCH~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS NOT IN ('W','C') THEN
dbg('Invalid Value for the Field  :RECALL_DAYS_BASIS:'||p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS||'~@PCTMS_PRODUCT_PREFERENCE.RECALL_DAYS_BASIS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :AGREEMENT_ID_REQD:'||p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD||'~@PCTMS_PRODUCT_PREFERENCE.AGREEMENT_ID_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :CREDITOR_ID_REQD:'||p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD||'~@PCTMS_PRODUCT_PREFERENCE.CREDITOR_ID_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :ALLOW_THIRD_PARTY_CHG:'||p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG||'~@PCTMS_PRODUCT_PREFERENCE.ALLOW_THIRD_PARTY_CHG~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :CHARGE_CUST_STATISTICS:'||p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS||'~@PCTMS_PRODUCT_PREFERENCE.CHARGE_CUST_STATISTICS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :CHARGE_AC_STATISTICS:'||p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS||'~@PCTMS_PRODUCT_PREFERENCE.CHARGE_AC_STATISTICS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS NOT IN ('A','S','I') THEN
dbg('Invalid Value for the Field  :COLLECT_VOLUME_STATISTICS:'||p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS||'~@PCTMS_PRODUCT_PREFERENCE.COLLECT_VOLUME_STATISTICS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :CUST_ENTRY_CONSOL_REQD:'||p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD||'~@PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_REQD~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT < 0 THEN
dbg('Invalid Value for the Field  :CUST_ENTRY_CONSOL_LMT:'||p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT||'~@PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_LMT~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS NOT IN ('C','W') THEN
dbg('Invalid Value for the Field  :RESPONSE_DAYS_BASIS:'||p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS||'~@PCTMS_PRODUCT_PREFERENCE.RESPONSE_DAYS_BASIS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CCY_CAL IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CCY_CAL NOT IN ('Y','N') THEN
dbg('Invalid Value for the Field  :CCY_CAL:'||p_pcdprmnt.prmnt_product_preference.CCY_CAL);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CCY_CAL||'~@PCTMS_PRODUCT_PREFERENCE.CCY_CAL~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE NOT IN ('SEPA') THEN
dbg('Invalid Value for the Field  :SERV_LEVEL_CODE:'||p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE||'~@PCTMS_PRODUCT_PREFERENCE.SERV_LEVEL_CODE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER NOT IN ('SLEV') THEN
dbg('Invalid Value for the Field  :CHARGE_BEARER:'||p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CHARGE_BEARER||'~@PCTMS_PRODUCT_PREFERENCE.CHARGE_BEARER~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS NOT IN ('A','D') THEN
dbg('Invalid Value for the Field  :RECALL_DATE_BASIS:'||p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS||'~@PCTMS_PRODUCT_PREFERENCE.RECALL_DATE_BASIS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE NOT IN ('D','C','B') THEN
dbg('Invalid Value for the Field  :PAYMENT_TYPE:'||p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE||'~@PCTMS_PRODUCT_PREFERENCE.PAYMENT_TYPE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
IF p_pcdprmnt.prmnt_product_preference.CLEARING_MODE IS NOT NULL THEN
IF p_pcdprmnt.prmnt_product_preference.CLEARING_MODE NOT IN ('B','I','E') THEN
dbg('Invalid Value for the Field  :CLEARING_MODE:'||p_pcdprmnt.prmnt_product_preference.CLEARING_MODE);
pr_log_error(p_source,'ST-VALS-012',p_pcdprmnt.prmnt_product_preference.CLEARING_MODE||'~@PCTMS_PRODUCT_PREFERENCE.CLEARING_MODE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
dbg('Duplicate Records Check For :prmnt_pctms_product_banks..');
l_count      := p_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_count > 0 THEN
FOR l_index  IN 1 .. l_count LOOP
l_key := NULL;
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
IF l_index < l_count THEN
FOR l_index1 IN l_index+1 .. l_count LOOP
IF (NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_index1).product_code,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,'@')) THEN
dbg('Duplicare Record Found for :'||l_key);
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
pr_log_error(p_source,'ST-VALS-009','@PCTMS_PRODUCT_BANKS~'||l_key);
END IF;
END LOOP;
END IF;
END LOOP;
END IF;
dbg('Duplicate Records Check For :prmnt_pctms_product_accrole..');
l_count      := p_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_count > 0 THEN
FOR l_index  IN 1 .. l_count LOOP
l_key := NULL;
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
IF l_index < l_count THEN
FOR l_index1 IN l_index+1 .. l_count LOOP
IF (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index1).product_code,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,'@')) THEN
dbg('Duplicare Record Found for :'||l_key);
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
pr_log_error(p_source,'ST-VALS-009','@PCTMS_PRODUCT_ACCROLE~'||l_key);
END IF;
END LOOP;
END IF;
END LOOP;
END IF;
dbg('Returning from Fn_Sys_Basic_Vals');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Basic_Vals');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Basic_Vals;

FUNCTION Fn_Sys_Default_Vals        (p_source            IN VARCHAR2,
p_wrk_pcdprmnt     IN  OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_count          NUMBER:= 0;
BEGIN

dbg('In Fn_Sys_Default_Vals');
IF p_wrk_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE IS NULL THEN
p_wrk_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE := 'C';
END IF;
IF p_wrk_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS IS NULL THEN
p_wrk_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS := 'W';
END IF;
IF p_wrk_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE IS NULL THEN
p_wrk_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE := 'B';
END IF;
dbg('Returning from Fn_Sys_Default_Vals');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Default_Vals');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Default_Vals;

FUNCTION Fn_Sys_Merge_Amendables        (p_source            IN VARCHAR2,
p_source_operation  IN     VARCHAR2,
p_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_prev_pcdprmnt IN pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt IN OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_count          NUMBER:= 0;
l_wrk_count      NUMBER := 0 ;
l_deleted_recs   NUMBER := 0;
l_modified_flds  VARCHAR2(32000):= NULL;
l_key            VARCHAR2(5000):= NULL;
l_mod_fld        VARCHAR2(50):= NULL;
i                NUMBER := 1;
l_rec_found      BOOLEAN := FALSE;
l_rec_modified   BOOLEAN := FALSE;
l_rec_sent       BOOLEAN := FALSE;
l_blk            VARCHAR2(100):= 0;
l_fld            VARCHAR2(100):= 0;
l_pk_or_full     VARCHAR2(5) :='FULL';
l_inv_chr        VARCHAR2(5) :=NULL;
l_mod_no         NUMBER:= 0;
l_base_data_from_fc  VARCHAR2(1):= 'Y';
l_amendable_Nodes Cspks_Req_Utils.ty_amend_nodes;
l_amendable_Fields Cspks_Req_Utils.ty_amend_fields;
N_prmnt_pctms_product_banks       pcpks_pcdprmnt_Main.ty_tb_rmnt_pctms_product_banks;
N_prmnt_pctms_product_accrole       pcpks_pcdprmnt_Main.ty_tb_nt_pctms_product_accrole;

FUNCTION Fn_Amendable(p_Item IN VARCHAR2) RETURN BOOLEAN IS
BEGIN
IF l_Amendable_Fields.EXISTS(p_Item) THEN
RETURN TRUE;
ELSE
RETURN FALSE;
END IF;
END Fn_Amendable;
BEGIN

dbg('In Fn_Sys_Merge_Amendables');

IF NOT Cspks_Req_Utils.Fn_Get_Amendable_Details(p_source ,
p_source_operation,
l_amendable_Nodes,
l_amendable_Fields,
p_err_code,
p_err_params) THEN
dbg('Failed in ..');
pr_log_error(p_source,p_err_code,p_err_params);
END IF;


l_blk := 'CSTMS_PRODUCT';
l_rec_modified := FALSE;
l_modified_flds  := NULL;

l_fld := 'CSTMS_PRODUCT.PRODUCT_DESCRIPTION';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_DESCRIPTION') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_description := p_pcdprmnt.prmnt_cstms_product.product_description;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_description IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_description,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_description,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_TYPE';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_TYPE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_type := p_pcdprmnt.prmnt_cstms_product.product_type;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_type,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_SLOGAN';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_SLOGAN') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_slogan := p_pcdprmnt.prmnt_cstms_product.product_slogan;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_slogan IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_slogan,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_slogan,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_GROUP';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_GROUP') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_group := p_pcdprmnt.prmnt_cstms_product.product_group;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_group IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_group,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_group,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_START_DATE';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_START_DATE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_start_date := p_pcdprmnt.prmnt_cstms_product.product_start_date;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_start_date IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_start_date,Global.min_date) <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_start_date,Global.min_date)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_END_DATE';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_END_DATE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_end_date := p_pcdprmnt.prmnt_cstms_product.product_end_date;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_end_date IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_end_date,Global.min_date) <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_end_date,Global.min_date)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_REMARKS';
IF Fn_amendable('CSTMS_PRODUCT.PRODUCT_REMARKS') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.product_remarks := p_pcdprmnt.prmnt_cstms_product.product_remarks;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.product_remarks IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.product_remarks,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.product_remarks,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.NORMAL_RATE_VARIANCE';
IF Fn_amendable('CSTMS_PRODUCT.NORMAL_RATE_VARIANCE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.normal_rate_variance := p_pcdprmnt.prmnt_cstms_product.normal_rate_variance;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.normal_rate_variance IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.normal_rate_variance,-1) <>
NVL(p_pcdprmnt.prmnt_cstms_product.normal_rate_variance,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.MAXIMUM_RATE_VARIANCE';
IF Fn_amendable('CSTMS_PRODUCT.MAXIMUM_RATE_VARIANCE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.maximum_rate_variance := p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.maximum_rate_variance,-1) <>
NVL(p_pcdprmnt.prmnt_cstms_product.maximum_rate_variance,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.RATE_CODE_PREFERRED';
IF Fn_amendable('CSTMS_PRODUCT.RATE_CODE_PREFERRED') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.rate_code_preferred := p_pcdprmnt.prmnt_cstms_product.rate_code_preferred;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.rate_code_preferred IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.rate_code_preferred,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.rate_code_preferred,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.RATE_TYPE_PREFERRED';
IF Fn_amendable('CSTMS_PRODUCT.RATE_TYPE_PREFERRED') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.rate_type_preferred := p_pcdprmnt.prmnt_cstms_product.rate_type_preferred;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.rate_type_preferred IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.rate_type_preferred,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.rate_type_preferred,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.MODULE';
IF Fn_amendable('CSTMS_PRODUCT.MODULE') THEN
p_wrk_pcdprmnt.prmnt_cstms_product.module := p_pcdprmnt.prmnt_cstms_product.module;
ELSE
IF p_pcdprmnt.prmnt_cstms_product.module IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_cstms_product.module,'@') <>
NVL(p_pcdprmnt.prmnt_cstms_product.module,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;

l_modified_flds := LTRIM(l_modified_flds,'~');
IF  l_rec_modified THEN
IF l_modified_flds IS NOT NULL THEN
i :=  1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
WHILE l_mod_fld <> 'EOPL' LOOP
pr_log_error(p_source,'ST-AMND-002','@'||l_mod_fld||'~@'||l_blk) ;
i := i +1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
END LOOP;
END IF;
END IF;


l_blk := 'PCTMS_PRODUCT_PREFERENCE';
l_rec_modified := FALSE;
l_modified_flds  := NULL;

l_rec_sent := FALSE;
IF p_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Record has been Sent..');
p_wrk_pcdprmnt.prmnt_product_preference.product_code := p_pcdprmnt.prmnt_product_preference.product_code;
l_rec_sent := TRUE;
END IF;
IF l_rec_sent THEN
l_fld := 'PCTMS_PRODUCT_PREFERENCE.COLLECTION_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.COLLECTION_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.collection_type := p_pcdprmnt.prmnt_product_preference.collection_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.collection_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.collection_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.collection_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RFD_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RFD_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rfd_type := p_pcdprmnt.prmnt_product_preference.rfd_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rfd_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rfd_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rfd_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.TRANSFER_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.TRANSFER_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.transfer_type := p_pcdprmnt.prmnt_product_preference.transfer_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.transfer_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.transfer_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.transfer_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_BRN';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_BRN') THEN
p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_brn := p_pcdprmnt.prmnt_product_preference.clg_vostro_brn;
ELSE
IF p_pcdprmnt.prmnt_product_preference.clg_vostro_brn IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_brn,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.clg_vostro_brn,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_ACC';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_ACC') THEN
p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_acc := p_pcdprmnt.prmnt_product_preference.clg_vostro_acc;
ELSE
IF p_pcdprmnt.prmnt_product_preference.clg_vostro_acc IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_acc,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.clg_vostro_acc,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_CCY';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_CCY') THEN
p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_ccy := p_pcdprmnt.prmnt_product_preference.clg_vostro_ccy;
ELSE
IF p_pcdprmnt.prmnt_product_preference.clg_vostro_ccy IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_ccy,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.clg_vostro_ccy,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.NETWORK_ID';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.NETWORK_ID') THEN
p_wrk_pcdprmnt.prmnt_product_preference.network_id := p_pcdprmnt.prmnt_product_preference.network_id;
ELSE
IF p_pcdprmnt.prmnt_product_preference.network_id IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.network_id,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.network_id,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MIN_DIVISIBLE_AMT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MIN_DIVISIBLE_AMT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.min_divisible_amt := p_pcdprmnt.prmnt_product_preference.min_divisible_amt;
ELSE
IF p_pcdprmnt.prmnt_product_preference.min_divisible_amt IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.min_divisible_amt,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.min_divisible_amt,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MIN_TXN_AMT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MIN_TXN_AMT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.min_txn_amt := p_pcdprmnt.prmnt_product_preference.min_txn_amt;
ELSE
IF p_pcdprmnt.prmnt_product_preference.min_txn_amt IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.min_txn_amt,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.min_txn_amt,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_MODE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_MODE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_mode := p_pcdprmnt.prmnt_product_preference.charge_mode;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_mode IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_mode,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_mode,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.INVOICE_SPLIT_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.INVOICE_SPLIT_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.invoice_split_reqd := p_pcdprmnt.prmnt_product_preference.invoice_split_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.invoice_split_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.invoice_split_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.invoice_split_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MAX_TXN_AMT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MAX_TXN_AMT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.max_txn_amt := p_pcdprmnt.prmnt_product_preference.max_txn_amt;
ELSE
IF p_pcdprmnt.prmnt_product_preference.max_txn_amt IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.max_txn_amt,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.max_txn_amt,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUTOFF_HR';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUTOFF_HR') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cutoff_hr := p_pcdprmnt.prmnt_product_preference.cutoff_hr;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cutoff_hr IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cutoff_hr,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cutoff_hr,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUTOFF_MIN';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUTOFF_MIN') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cutoff_min := p_pcdprmnt.prmnt_product_preference.cutoff_min;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cutoff_min IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cutoff_min,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cutoff_min,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PRIORITY';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PRIORITY') THEN
p_wrk_pcdprmnt.prmnt_product_preference.priority := p_pcdprmnt.prmnt_product_preference.priority;
ELSE
IF p_pcdprmnt.prmnt_product_preference.priority IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.priority,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.priority,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUST_ENT_DAY_PRECUTOF';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUST_ENT_DAY_PRECUTOF') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof := p_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUST_ENT_VAL_DAY_PRECUTOF';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUST_ENT_VAL_DAY_PRECUTOF') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof := p_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CPTY_ENT_DAY_PRECUTOF';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CPTY_ENT_DAY_PRECUTOF') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof := p_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CPTY_ENT_VAL_DAY_PRECUTOF';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CPTY_ENT_VAL_DAY_PRECUTOF') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof := p_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.OVERRIDE_OVERDRAFT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.OVERRIDE_OVERDRAFT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.override_overdraft := p_pcdprmnt.prmnt_product_preference.override_overdraft;
ELSE
IF p_pcdprmnt.prmnt_product_preference.override_overdraft IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.override_overdraft,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.override_overdraft,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DISPATCH_ACCOUNTING';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DISPATCH_ACCOUNTING') THEN
p_wrk_pcdprmnt.prmnt_product_preference.dispatch_accounting := p_pcdprmnt.prmnt_product_preference.dispatch_accounting;
ELSE
IF p_pcdprmnt.prmnt_product_preference.dispatch_accounting IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.dispatch_accounting,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.dispatch_accounting,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REFERRAL_REQUIRED';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REFERRAL_REQUIRED') THEN
p_wrk_pcdprmnt.prmnt_product_preference.referral_required := p_pcdprmnt.prmnt_product_preference.referral_required;
ELSE
IF p_pcdprmnt.prmnt_product_preference.referral_required IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.referral_required,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.referral_required,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DISPATCH';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DISPATCH') THEN
p_wrk_pcdprmnt.prmnt_product_preference.dispatch := p_pcdprmnt.prmnt_product_preference.dispatch;
ELSE
IF p_pcdprmnt.prmnt_product_preference.dispatch IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.dispatch,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.dispatch,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.AUTO_DISPATCH';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.AUTO_DISPATCH') THEN
p_wrk_pcdprmnt.prmnt_product_preference.auto_dispatch := p_pcdprmnt.prmnt_product_preference.auto_dispatch;
ELSE
IF p_pcdprmnt.prmnt_product_preference.auto_dispatch IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.auto_dispatch,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.auto_dispatch,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.OUT_PMT_WORKFLOW';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.OUT_PMT_WORKFLOW') THEN
p_wrk_pcdprmnt.prmnt_product_preference.out_pmt_workflow := p_pcdprmnt.prmnt_product_preference.out_pmt_workflow;
ELSE
IF p_pcdprmnt.prmnt_product_preference.out_pmt_workflow IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.out_pmt_workflow,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.out_pmt_workflow,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DISPATCH_MEDIA';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DISPATCH_MEDIA') THEN
p_wrk_pcdprmnt.prmnt_product_preference.dispatch_media := p_pcdprmnt.prmnt_product_preference.dispatch_media;
ELSE
IF p_pcdprmnt.prmnt_product_preference.dispatch_media IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.dispatch_media,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.dispatch_media,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DISPATCH_DAY_PRECUTOF';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DISPATCH_DAY_PRECUTOF') THEN
p_wrk_pcdprmnt.prmnt_product_preference.dispatch_day_precutof := p_pcdprmnt.prmnt_product_preference.dispatch_day_precutof;
ELSE
IF p_pcdprmnt.prmnt_product_preference.dispatch_day_precutof IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.dispatch_day_precutof,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.dispatch_day_precutof,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.AUTO_RESPONSE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.AUTO_RESPONSE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.auto_response := p_pcdprmnt.prmnt_product_preference.auto_response;
ELSE
IF p_pcdprmnt.prmnt_product_preference.auto_response IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.auto_response,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.auto_response,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.ASCII_HANDOFF_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.ASCII_HANDOFF_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd := p_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.COLLECTION_STMT_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.COLLECTION_STMT_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.collection_stmt_reqd := p_pcdprmnt.prmnt_product_preference.collection_stmt_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.collection_stmt_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.collection_stmt_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.collection_stmt_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.response_advice_reqd := p_pcdprmnt.prmnt_product_preference.response_advice_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.response_advice_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.response_advice_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.response_advice_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PRE_COT_RESPONSE_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PRE_COT_RESPONSE_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.pre_cot_response_days := p_pcdprmnt.prmnt_product_preference.pre_cot_response_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.pre_cot_response_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.pre_cot_response_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.pre_cot_response_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_BASIS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RESPONSE_ADVICE_BASIS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.response_advice_basis := p_pcdprmnt.prmnt_product_preference.response_advice_basis;
ELSE
IF p_pcdprmnt.prmnt_product_preference.response_advice_basis IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.response_advice_basis,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.response_advice_basis,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MAX_INT_AMT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MAX_INT_AMT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.max_int_amt := p_pcdprmnt.prmnt_product_preference.max_int_amt;
ELSE
IF p_pcdprmnt.prmnt_product_preference.max_int_amt IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.max_int_amt,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.max_int_amt,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MAX_SPLIT_COUNT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MAX_SPLIT_COUNT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.max_split_count := p_pcdprmnt.prmnt_product_preference.max_split_count;
ELSE
IF p_pcdprmnt.prmnt_product_preference.max_split_count IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.max_split_count,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.max_split_count,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_BEFORE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_BEFORE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_before := p_pcdprmnt.prmnt_product_preference.rej_ac_type_before;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_ac_type_before IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_before,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_ac_type_before,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_BRN_BEFORE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_BRN_BEFORE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_before := p_pcdprmnt.prmnt_product_preference.rej_payment_brn_before;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_payment_brn_before IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_before,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_payment_brn_before,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_BEFORE_RESP_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_BEFORE_RESP_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days := p_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_CCY_BEFORE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_CCY_BEFORE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before := p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.BACK_VALUE_LIMIT_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.BACK_VALUE_LIMIT_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.back_value_limit_days := p_pcdprmnt.prmnt_product_preference.back_value_limit_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.back_value_limit_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.back_value_limit_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.back_value_limit_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.FUTURE_VALUE_LIMIT_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.FUTURE_VALUE_LIMIT_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.future_value_limit_days := p_pcdprmnt.prmnt_product_preference.future_value_limit_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.future_value_limit_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.future_value_limit_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.future_value_limit_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.MOVE_BVT_ACTIVATION_DATE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.MOVE_BVT_ACTIVATION_DATE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.move_bvt_activation_date := p_pcdprmnt.prmnt_product_preference.move_bvt_activation_date;
ELSE
IF p_pcdprmnt.prmnt_product_preference.move_bvt_activation_date IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.move_bvt_activation_date,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.move_bvt_activation_date,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DEFAULT_ACTIVATION_DATE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DEFAULT_ACTIVATION_DATE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.default_activation_date := p_pcdprmnt.prmnt_product_preference.default_activation_date;
ELSE
IF p_pcdprmnt.prmnt_product_preference.default_activation_date IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.default_activation_date,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.default_activation_date,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PROCESS_REJ_AFTER_RESP_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PROCESS_REJ_AFTER_RESP_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days := p_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_VERIFY_FUNDS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_VERIFY_FUNDS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_verify_funds := p_pcdprmnt.prmnt_product_preference.rej_verify_funds;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_verify_funds IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_verify_funds,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_verify_funds,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_AFTER';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_AC_TYPE_AFTER') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_after := p_pcdprmnt.prmnt_product_preference.rej_ac_type_after;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_ac_type_after IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_after,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_ac_type_after,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_BRN_AFTER';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_BRN_AFTER') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_after := p_pcdprmnt.prmnt_product_preference.rej_payment_brn_after;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_payment_brn_after IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_after,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_payment_brn_after,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_AFTER_RESP_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_AFTER_RESP_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days := p_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_CCY_AFTER';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REJ_PAYMENT_CCY_AFTER') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after := p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.ALLOW_POST_COT_TXN';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.ALLOW_POST_COT_TXN') THEN
p_wrk_pcdprmnt.prmnt_product_preference.allow_post_cot_txn := p_pcdprmnt.prmnt_product_preference.allow_post_cot_txn;
ELSE
IF p_pcdprmnt.prmnt_product_preference.allow_post_cot_txn IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.allow_post_cot_txn,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.allow_post_cot_txn,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.AUTO_EXCH_RATE_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.AUTO_EXCH_RATE_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd := p_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.EX_RATE_CODE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.EX_RATE_CODE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_code := p_pcdprmnt.prmnt_product_preference.ex_rate_code;
ELSE
IF p_pcdprmnt.prmnt_product_preference.ex_rate_code IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_code,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.ex_rate_code,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.EX_RATE_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.EX_RATE_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_type := p_pcdprmnt.prmnt_product_preference.ex_rate_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.ex_rate_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.ex_rate_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REDISPATCH_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REDISPATCH_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.redispatch_reqd := p_pcdprmnt.prmnt_product_preference.redispatch_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.redispatch_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.redispatch_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.redispatch_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.AUTO_REDISPATCH';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.AUTO_REDISPATCH') THEN
p_wrk_pcdprmnt.prmnt_product_preference.auto_redispatch := p_pcdprmnt.prmnt_product_preference.auto_redispatch;
ELSE
IF p_pcdprmnt.prmnt_product_preference.auto_redispatch IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.auto_redispatch,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.auto_redispatch,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REDISPATCH_COUNT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REDISPATCH_COUNT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.redispatch_count := p_pcdprmnt.prmnt_product_preference.redispatch_count;
ELSE
IF p_pcdprmnt.prmnt_product_preference.redispatch_count IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.redispatch_count,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.redispatch_count,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REDISPATCH_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REDISPATCH_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.redispatch_days := p_pcdprmnt.prmnt_product_preference.redispatch_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.redispatch_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.redispatch_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.redispatch_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RECALL_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RECALL_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.recall_days := p_pcdprmnt.prmnt_product_preference.recall_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.recall_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.recall_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.recall_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RECALL_DAYS_BASIS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RECALL_DAYS_BASIS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.recall_days_basis := p_pcdprmnt.prmnt_product_preference.recall_days_basis;
ELSE
IF p_pcdprmnt.prmnt_product_preference.recall_days_basis IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.recall_days_basis,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.recall_days_basis,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.AGREEMENT_ID_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.AGREEMENT_ID_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.agreement_id_reqd := p_pcdprmnt.prmnt_product_preference.agreement_id_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.agreement_id_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.agreement_id_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.agreement_id_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CREDITOR_ID_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CREDITOR_ID_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.creditor_id_reqd := p_pcdprmnt.prmnt_product_preference.creditor_id_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.creditor_id_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.creditor_id_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.creditor_id_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_WAIVER';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_WAIVER') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_waiver := p_pcdprmnt.prmnt_product_preference.charge_waiver;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_waiver IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_waiver,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_waiver,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.ALLOW_THIRD_PARTY_CHG';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.ALLOW_THIRD_PARTY_CHG') THEN
p_wrk_pcdprmnt.prmnt_product_preference.allow_third_party_chg := p_pcdprmnt.prmnt_product_preference.allow_third_party_chg;
ELSE
IF p_pcdprmnt.prmnt_product_preference.allow_third_party_chg IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.allow_third_party_chg,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.allow_third_party_chg,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_CUST_STATISTICS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_CUST_STATISTICS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_cust_statistics := p_pcdprmnt.prmnt_product_preference.charge_cust_statistics;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_cust_statistics IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_cust_statistics,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_cust_statistics,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_AC_STATISTICS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_AC_STATISTICS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_ac_statistics := p_pcdprmnt.prmnt_product_preference.charge_ac_statistics;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_ac_statistics IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_ac_statistics,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_ac_statistics,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.COLLECT_VOLUME_STATISTICS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.COLLECT_VOLUME_STATISTICS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.collect_volume_statistics := p_pcdprmnt.prmnt_product_preference.collect_volume_statistics;
ELSE
IF p_pcdprmnt.prmnt_product_preference.collect_volume_statistics IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.collect_volume_statistics,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.collect_volume_statistics,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_REQD';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_REQD') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd := p_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_LMT';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CUST_ENTRY_CONSOL_LMT') THEN
p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt := p_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt;
ELSE
IF p_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.DISP_FILE_NAME';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.DISP_FILE_NAME') THEN
p_wrk_pcdprmnt.prmnt_product_preference.disp_file_name := p_pcdprmnt.prmnt_product_preference.disp_file_name;
ELSE
IF p_pcdprmnt.prmnt_product_preference.disp_file_name IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.disp_file_name,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.disp_file_name,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.NO_OF_REC';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.NO_OF_REC') THEN
p_wrk_pcdprmnt.prmnt_product_preference.no_of_rec := p_pcdprmnt.prmnt_product_preference.no_of_rec;
ELSE
IF p_pcdprmnt.prmnt_product_preference.no_of_rec IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.no_of_rec,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.no_of_rec,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REV_SETTLE_GL';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.REV_SETTLE_GL') THEN
p_wrk_pcdprmnt.prmnt_product_preference.rev_settle_gl := p_pcdprmnt.prmnt_product_preference.rev_settle_gl;
ELSE
IF p_pcdprmnt.prmnt_product_preference.rev_settle_gl IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.rev_settle_gl,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.rev_settle_gl,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RESPONSE_DAYS_BASIS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RESPONSE_DAYS_BASIS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.response_days_basis := p_pcdprmnt.prmnt_product_preference.response_days_basis;
ELSE
IF p_pcdprmnt.prmnt_product_preference.response_days_basis IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.response_days_basis,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.response_days_basis,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_CCY';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CLG_CCY') THEN
p_wrk_pcdprmnt.prmnt_product_preference.clg_ccy := p_pcdprmnt.prmnt_product_preference.clg_ccy;
ELSE
IF p_pcdprmnt.prmnt_product_preference.clg_ccy IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.clg_ccy,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.clg_ccy,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_CATEGORY';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_CATEGORY') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_category := p_pcdprmnt.prmnt_product_preference.charge_category;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_category IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_category,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_category,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CCY_CAL';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CCY_CAL') THEN
p_wrk_pcdprmnt.prmnt_product_preference.ccy_cal := p_pcdprmnt.prmnt_product_preference.ccy_cal;
ELSE
IF p_pcdprmnt.prmnt_product_preference.ccy_cal IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.ccy_cal,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.ccy_cal,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PYMT_REJT_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PYMT_REJT_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.pymt_rejt_days := p_pcdprmnt.prmnt_product_preference.pymt_rejt_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.pymt_rejt_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.pymt_rejt_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.pymt_rejt_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.SERV_LEVEL_CODE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.SERV_LEVEL_CODE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.serv_level_code := p_pcdprmnt.prmnt_product_preference.serv_level_code;
ELSE
IF p_pcdprmnt.prmnt_product_preference.serv_level_code IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.serv_level_code,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.serv_level_code,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_BEARER';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CHARGE_BEARER') THEN
p_wrk_pcdprmnt.prmnt_product_preference.charge_bearer := p_pcdprmnt.prmnt_product_preference.charge_bearer;
ELSE
IF p_pcdprmnt.prmnt_product_preference.charge_bearer IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.charge_bearer,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.charge_bearer,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.EARLY_COLL_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.EARLY_COLL_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.early_coll_days := p_pcdprmnt.prmnt_product_preference.early_coll_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.early_coll_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.early_coll_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.early_coll_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.FIRST_COLL_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.FIRST_COLL_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.first_coll_days := p_pcdprmnt.prmnt_product_preference.first_coll_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.first_coll_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.first_coll_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.first_coll_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RECUR_COLL_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RECUR_COLL_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.recur_coll_days := p_pcdprmnt.prmnt_product_preference.recur_coll_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.recur_coll_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.recur_coll_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.recur_coll_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.FIRST_COLL_DISP_DAYS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.FIRST_COLL_DISP_DAYS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.first_coll_disp_days := p_pcdprmnt.prmnt_product_preference.first_coll_disp_days;
ELSE
IF p_pcdprmnt.prmnt_product_preference.first_coll_disp_days IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.first_coll_disp_days,-1) <>
NVL(p_pcdprmnt.prmnt_product_preference.first_coll_disp_days,-1)  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.RECALL_DATE_BASIS';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.RECALL_DATE_BASIS') THEN
p_wrk_pcdprmnt.prmnt_product_preference.recall_date_basis := p_pcdprmnt.prmnt_product_preference.recall_date_basis;
ELSE
IF p_pcdprmnt.prmnt_product_preference.recall_date_basis IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.recall_date_basis,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.recall_date_basis,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PAYMENT_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PAYMENT_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.payment_type := p_pcdprmnt.prmnt_product_preference.payment_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.payment_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.payment_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.payment_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLEARING_MODE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.CLEARING_MODE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.clearing_mode := p_pcdprmnt.prmnt_product_preference.clearing_mode;
ELSE
IF p_pcdprmnt.prmnt_product_preference.clearing_mode IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.clearing_mode,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.clearing_mode,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.PRODUCT_TYPE';
IF Fn_amendable('PCTMS_PRODUCT_PREFERENCE.PRODUCT_TYPE') THEN
p_wrk_pcdprmnt.prmnt_product_preference.product_type := p_pcdprmnt.prmnt_product_preference.product_type;
ELSE
IF p_pcdprmnt.prmnt_product_preference.product_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_product_preference.product_type,'@') <>
NVL(p_pcdprmnt.prmnt_product_preference.product_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified := TRUE;
END IF;
END IF;
END IF;

l_modified_flds := LTRIM(l_modified_flds,'~');
IF  l_rec_modified THEN
IF l_modified_flds IS NOT NULL THEN
i :=  1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
WHILE l_mod_fld <> 'EOPL' LOOP
pr_log_error(p_source,'ST-AMND-002','@'||l_mod_fld||'~@'||l_blk) ;
i := i +1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
END LOOP;
END IF;
END IF;
ELSE

IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_PREFERENCE') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_PREFERENCE').all_records = 'Y' THEN
p_wrk_pcdprmnt.prmnt_product_preference :=NULL;
END IF;
END IF;
END IF;

l_blk := 'PCTMS_PRODUCT_BANKS';
l_count      := p_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_count > 0 THEN
FOR l_index IN 1..l_count  LOOP
l_rec_found := FALSE;
l_rec_modified := FALSE;
l_modified_flds := NULL;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
IF (NVL(p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;

l_modified_flds := LTRIM(l_modified_flds,'~');
IF  l_rec_modified THEN
IF l_modified_flds IS NOT NULL THEN
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
i :=  1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
WHILE l_mod_fld <> 'EOPL' LOOP
pr_log_error(p_source,'ST-AMND-003','@'||l_mod_fld||'~@'||l_blk||'~'||l_key );
i := i +1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
END LOOP;
END IF;
END IF;
END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
p_wrk_pcdprmnt.prmnt_pctms_product_banks(p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT +1 ) :=  p_pcdprmnt.prmnt_pctms_product_banks(l_index);
IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_BANKS') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_BANKS').new_allowed = 'N' THEN
dbg('New Record cannot be Added..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
pr_log_error(p_source,'ST-AMND-004',l_key||'~@'||l_blk);
END IF;
ELSE
dbg('New Record cannot be Added..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
pr_log_error(p_source,'ST-AMND-004',l_key||'~@'||l_blk);
END IF;
END IF;
END LOOP;
END IF;

IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_BANKS') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_BANKS').all_records = 'Y' THEN
dbg('Logic For Deleting some records from work record  if not sent...');
l_wrk_count := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_count     := p_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
l_rec_found := FALSE;
IF l_count > 0 THEN
FOR l_index IN 1..l_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_banks	(l_index).bankcode,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF l_rec_found THEN
dbg('Adding  a Record...');
N_prmnt_pctms_product_banks(N_prmnt_pctms_product_banks.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1);
ELSE
l_deleted_recs := l_deleted_recs +1;
IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_BANKS') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_BANKS').delete_allowed = 'N' THEN
dbg('Record cannot be Deleted..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode;
pr_log_error(p_source,'ST-AMND-006',l_key||'~@'||l_blk);
END IF;
ELSE
dbg('Record cannot be Deleted..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode;
pr_log_error(p_source,'ST-AMND-006',l_key||'~@'||l_blk);
END IF;
END IF;
END LOOP;
END IF;
p_wrk_pcdprmnt.prmnt_pctms_product_banks:= N_prmnt_pctms_product_banks;
END IF;
END IF;

l_blk := 'PCTMS_PRODUCT_ACCROLE';
l_count      := p_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_count > 0 THEN
FOR l_index IN 1..l_count  LOOP
l_rec_found := FALSE;
l_rec_modified := FALSE;
l_modified_flds := NULL;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
IF (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,'@')) AND (NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
l_fld := 'PCTMS_PRODUCT_ACCROLE.ROLE_TYPE';
IF Fn_Amendable('PCTMS_PRODUCT_ACCROLE.ROLE_TYPE') THEN
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).role_type := p_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type;
ELSE
IF p_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).role_type,'@') <>
NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified  := TRUE;
END IF;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_HEAD';
IF Fn_Amendable('PCTMS_PRODUCT_ACCROLE.ACCOUNTING_HEAD') THEN
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_head := p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head;
ELSE
IF p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head IS NOT NULL THEN
IF NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_head,'@') <>
NVL(p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head,'@')  THEN
l_modified_flds := l_modified_flds ||'~'||l_fld;
l_rec_modified  := TRUE;
END IF;
END IF;
END IF;

l_modified_flds := LTRIM(l_modified_flds,'~');
IF  l_rec_modified THEN
IF l_modified_flds IS NOT NULL THEN
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
i :=  1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
WHILE l_mod_fld <> 'EOPL' LOOP
pr_log_error(p_source,'ST-AMND-003','@'||l_mod_fld||'~@'||l_blk||'~'||l_key );
i := i +1;
l_mod_fld := cspkes_misc.fn_GetParam(l_modified_flds,i,'~');
END LOOP;
END IF;
END IF;
END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT +1 ) :=  p_pcdprmnt.prmnt_pctms_product_accrole(l_index);
IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_ACCROLE') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_ACCROLE').new_allowed = 'N' THEN
dbg('New Record cannot be Added..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
pr_log_error(p_source,'ST-AMND-004',l_key||'~@'||l_blk);
END IF;
ELSE
dbg('New Record cannot be Added..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
pr_log_error(p_source,'ST-AMND-004',l_key||'~@'||l_blk);
END IF;
END IF;
END LOOP;
END IF;

IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_ACCROLE') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_ACCROLE').all_records = 'Y' THEN
dbg('Logic For Deleting some records from work record  if not sent...');
l_wrk_count := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_count     := p_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
l_rec_found := FALSE;
IF l_count > 0 THEN
FOR l_index IN 1..l_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole	(l_index).bankcode,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole	(l_index).accounting_role,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,'@')=  NVL(p_pcdprmnt.prmnt_pctms_product_accrole	(l_index).status,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF l_rec_found THEN
dbg('Adding  a Record...');
N_prmnt_pctms_product_accrole(N_prmnt_pctms_product_accrole.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1);
ELSE
l_deleted_recs := l_deleted_recs +1;
IF l_amendable_nodes.EXISTS('PCTMS_PRODUCT_ACCROLE') THEN
IF l_amendable_nodes('PCTMS_PRODUCT_ACCROLE').delete_allowed = 'N' THEN
dbg('Record cannot be Deleted..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status;
pr_log_error(p_source,'ST-AMND-006',l_key||'~@'||l_blk);
END IF;
ELSE
dbg('Record cannot be Deleted..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.BANKCODE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status;
pr_log_error(p_source,'ST-AMND-006',l_key||'~@'||l_blk);
END IF;
END IF;
END LOOP;
END IF;
p_wrk_pcdprmnt.prmnt_pctms_product_accrole:= N_prmnt_pctms_product_accrole;
END IF;
END IF;

dbg('Returning from Fn_Sys_Merge_Amendables');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Merge_Amendables');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Merge_Amendables;

FUNCTION Fn_Sys_Check_Mandatory_Nodes  (p_source            IN VARCHAR2,
p_wrk_pcdprmnt IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_count          NUMBER:= 0;
l_base_data_from_fc  VARCHAR2(1):= 'Y';
l_blk            VARCHAR2(100);
l_fld            VARCHAR2(100);
BEGIN

dbg('In Fn_Gen_Sys_Node_Mand_Checks');
dbg('Returning from Fn_Sys_Check_Mandatory_Nodes');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Check_Mandatory_Nodes');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Check_Mandatory_Nodes;

FUNCTION Fn_Sys_Lov_Vals        (p_source            IN VARCHAR2,
p_wrk_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_count          NUMBER:= 0;
l_key            VARCHAR2(5000):= NULL;
i                NUMBER := 1;
l_lov_count      NUMBER := 0;
l_blk            VARCHAR2(100):= 0;
l_fld            VARCHAR2(100):= 0;
l_inv_chr        VARCHAR2(5) :=NULL;
l_dsn_rec_cnt_1 NUMBER := 0;
l_bnd_cntr_1    NUMBER  := 0;
l_dsn_rec_cnt_2 NUMBER := 0;
l_bnd_cntr_2    NUMBER  := 0;
l_dsn_rec_cnt_3 NUMBER := 0;
l_bnd_cntr_3    NUMBER  := 0;
l_dsn_rec_cnt_4 NUMBER := 0;
l_bnd_cntr_4    NUMBER  := 0;
BEGIN

dbg('In Fn_Sys_Lov_Vals');
l_Blk := 'CSTMS_PRODUCT';
l_fld := 'CSTMS_PRODUCT.PRODUCT_TYPE';
IF p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select product_type,product_type_desc  from smtbs_product_types where function_id = 'PCDPRMNT' and language_code = GLOBAL.LANG and nvl(int_auth_stat,'A')='A' order by product_type) WHERE PRODUCT_TYPE = P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :PRODUCT_TYPE:'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE);
pr_log_error(p_source,'ST-VALS-011',p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE||'~@CSTMS_PRODUCT.PRODUCT_TYPE~@CSTMS_PRODUCT') ;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.PRODUCT_GROUP';
IF p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select product_group, product_group_description from cstms_product_group where record_stat = 'O' and once_auth = 'Y' order by product_group) WHERE PRODUCT_GROUP = P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :PRODUCT_GROUP:'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP);
pr_log_error(p_source,'ST-VALS-011',p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP||'~@CSTMS_PRODUCT.PRODUCT_GROUP~@CSTMS_PRODUCT') ;
END IF;
END IF;
l_fld := 'CSTMS_PRODUCT.RATE_TYPE_PREFERRED';
IF p_wrk_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ccy_rate_type,ccy_rate_type_desc from cytms_rate_type where once_auth = 'Y' and record_stat = 'O' order by ccy_rate_type) WHERE CCY_RATE_TYPE = P_wrk_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :RATE_TYPE_PREFERRED:'||p_wrk_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED);
pr_log_error(p_source,'ST-VALS-011',p_wrk_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED||'~@CSTMS_PRODUCT.RATE_TYPE_PREFERRED~@CSTMS_PRODUCT') ;
END IF;
END IF;
l_Blk := 'PCTMS_PRODUCT_PREFERENCE';
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_ACC';
IF p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select  branch_code,CUST_AC_NO,CCY from (select  a.branch_code,a.CUST_AC_NO,a.CCY from  sttms_cust_account a, sttms_branch b where   a.once_auth = 'Y' AND a.record_stat = 'O' AND b.branch_code = b.pc_clearing_brn AND a.branch_code = b.branch_code AND a.ccy = b.branch_lcy) where 1=1 order by branch_code,CUST_AC_NO,CCY) WHERE CUST_AC_NO = P_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :CLG_VOSTRO_ACC:'||p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC||'~@PCTMS_PRODUCT_PREFERENCE.CLG_VOSTRO_ACC~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.NETWORK_ID';
IF p_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select network_id,network_desc from pctms_clearing_network where record_stat='O' and once_auth='Y' order by network_id) WHERE NETWORK_ID = P_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :NETWORK_ID:'||p_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID||'~@PCTMS_PRODUCT_PREFERENCE.NETWORK_ID~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_BEFORE_RESP_DAYS';
IF p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ac_gl_no,ac_gl_ccy, branch_code from (select a.ac_gl_no,a.ac_gl_ccy, a.branch_code from sttbs_account  a where  a.ac_gl_ccy = (select branch_lcy from sttms_branch b where b.branch_code = GLOBAL.CURRENT_BRANCH) AND a.once_auth = 'Y'  AND  DECODE(a.AC_OR_GL,P_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE,'A',NULL)='A' UNION ALL select ac_gl_no,NULL,NULL from sttbs_account where  DECODE(AC_OR_GL,P_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE,'G',NULL)='G' and once_auth = 'Y') where 1=1 order by ac_gl_no,ac_gl_ccy,branch_code) WHERE AC_GL_NO = P_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :REJ_ACCT_BEFORE_RESP_DAYS:'||p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS||'~@PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_BEFORE_RESP_DAYS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_AFTER_RESP_DAYS';
IF p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ac_gl_no,ac_gl_ccy,branch_code from (select a.ac_gl_no,a.ac_gl_ccy, a.branch_code from sttbs_account  a where  a.ac_gl_ccy = (select branch_lcy from sttms_branch b where b.branch_code = GLOBAL.CURRENT_BRANCH) AND a.once_auth = 'Y'  AND  DECODE(a.AC_OR_GL,P_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER,'A',NULL)='A' UNION ALL select ac_gl_no,NULL,NULL from sttbs_account where  DECODE(AC_OR_GL,P_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER,'G',NULL)='G' and once_auth = 'Y') where 1=1  order by ac_gl_no,ac_gl_ccy,branch_code) WHERE AC_GL_NO = P_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :REJ_ACCT_AFTER_RESP_DAYS:'||p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS||'~@PCTMS_PRODUCT_PREFERENCE.REJ_ACCT_AFTER_RESP_DAYS~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.EX_RATE_CODE';
IF p_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_CODE IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ccy_rate_type,ccy_rate_type_desc from cytms_rate_type where once_auth = 'Y' and record_stat = 'O' order by ccy_rate_type) WHERE CCY_RATE_TYPE = P_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_CODE;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :EX_RATE_CODE:'||p_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_CODE);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_CODE||'~@PCTMS_PRODUCT_PREFERENCE.EX_RATE_CODE~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.REV_SETTLE_GL';
IF p_wrk_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ac_gl_no	from sttbs_account where AC_OR_GL='G' and once_auth = 'Y' order by ac_gl_no) WHERE AC_GL_NO = P_wrk_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :REV_SETTLE_GL:'||p_wrk_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL||'~@PCTMS_PRODUCT_PREFERENCE.REV_SETTLE_GL~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CLG_CCY';
IF p_wrk_pcdprmnt.prmnt_product_preference.CLG_CCY IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select ccy_code,ccy_name from cytms_ccy_defn where record_stat = 'O' and once_auth='Y' order by ccy_code) WHERE CCY_CODE = P_wrk_pcdprmnt.prmnt_product_preference.CLG_CCY;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :CLG_CCY:'||p_wrk_pcdprmnt.prmnt_product_preference.CLG_CCY);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.CLG_CCY||'~@PCTMS_PRODUCT_PREFERENCE.CLG_CCY~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_PREFERENCE.CHARGE_CATEGORY';
IF p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select charge_category,description from PCTMS_CHARGE_CATEGORY_DEFN where record_stat = 'O' and once_auth = 'Y' ORDER BY charge_category) WHERE CHARGE_CATEGORY = P_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :CHARGE_CATEGORY:'||p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY);
pr_log_error(p_source,'ST-VALS-012',p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY||'~@PCTMS_PRODUCT_PREFERENCE.CHARGE_CATEGORY~@PCTMS_PRODUCT_PREFERENCE') ;
END IF;
END IF;
l_count      := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_count > 0 THEN
FOR l_index  IN 1 .. l_count LOOP
l_Blk := 'PCTMS_PRODUCT_BANKS';
l_fld := 'PCTMS_PRODUCT_BANKS.BANKCODE';
IF p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).BANKCODE IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (SELECT BANK_CODE,BANK_NAME  FROM PCTMS_BANK_PARAM WHERE RECORD_STAT='O' AND ONCE_AUTH='Y' AND BANK_CODE NOT IN (SELECT BANKCODE                      FROM PCTMS_PRODUCT_BANKS                      WHERE PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE)ORDER BY BANK_CODE) WHERE BANK_CODE = P_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).BANKCODE;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :BANKCODE:'||p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).BANKCODE);
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_BANKS.BANKCODE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode;
pr_log_error(p_source,'ST-VALS-013',p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).BANKCODE||'~@PCTMS_PRODUCT_BANKS.BANKCODE'||'~'||l_key||'~@PCTMS_PRODUCT_BANKS') ;
END IF;
END IF;
END LOOP;
END IF;
l_count      := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_count > 0 THEN
FOR l_index  IN 1 .. l_count LOOP
l_Blk := 'PCTMS_PRODUCT_ACCROLE';
l_fld := 'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE';
IF p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_ROLE IS NOT NULL THEN
l_bnd_cntr_3 := 0;
IF P_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT > 0 THEN
FOR i_3 IN  1..P_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
IF NVL(P_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code,'@') = NVL(P_wrk_pcdprmnt.prmnt_pctms_product_banks(i_3).product_code,'@') AND NVL(P_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@') = NVL(P_wrk_pcdprmnt.prmnt_pctms_product_banks(i_3).bankcode,'@') THEN
l_bnd_cntr_3 := i_3;
EXIT;
END IF;
END LOOP;
END IF;
IF  l_bnd_cntr_3 > 0 THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (SELECT B.ACCOUNTING_ROLE,A.ROLE_DESCRIPTION FROM CSTMS_PRODUCT_ACCROLE B,CSTBS_ACCROLE A WHERE A.ROLE_CODE=B.ACCOUNTING_ROLE AND A.MODULE='PC' AND B.PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE AND  ACCOUNTING_ROLE NOT IN(                           SELECT ACCOUNTING_ROLE                            FROM PCTMS_PRODUCT_ACCROLE                           WHERE PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE                            AND   BANKCODE=P_wrk_pcdprmnt.prmnt_pctms_product_banks(l_bnd_cntr_3).BANKCODE )ORDER BY ACCOUNTING_ROLE) WHERE ACCOUNTING_ROLE = P_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_ROLE;
END IF;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :ACCOUNTING_ROLE:'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_ROLE);
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
pr_log_error(p_source,'ST-VALS-013',p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_ROLE||'~@PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE'||'~'||l_key||'~@PCTMS_PRODUCT_ACCROLE') ;
END IF;
END IF;
l_fld := 'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_HEAD';
IF p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_HEAD IS NOT NULL THEN
SELECT COUNT(*) INTO l_LOV_COUNT  FROM  (select a.gl_code, a.gl_desc from gltms_glmaster a where a.customer <> 'C' and a.leaf = 'Y' and a.record_stat = 'O' and a.once_auth='Y' and a.type <> '*' and a.type <> '*'order by gl_code) WHERE GL_CODE = P_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_HEAD;
IF l_lov_count = 0  THEN
dbg('Invalid Value for the Field  :ACCOUNTING_HEAD:'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_HEAD);
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.ACCOUNTING_ROLE')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||':'||
Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'PCTMS_PRODUCT_ACCROLE.STATUS')||'-'||
p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status;
pr_log_error(p_source,'ST-VALS-013',p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).ACCOUNTING_HEAD||'~@PCTMS_PRODUCT_ACCROLE.ACCOUNTING_HEAD'||'~'||l_key||'~@PCTMS_PRODUCT_ACCROLE') ;
END IF;
END IF;
END LOOP;
END IF;
dbg('Returning from Fn_Sys_Lov_Vals');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Lov_Vals');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Lov_Vals;

FUNCTION Fn_Sys_Default_and_Validate        (p_source            IN VARCHAR2,
p_source_operation  IN     VARCHAR2,
p_action_code       IN VARCHAR2,
p_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_prev_pcdprmnt IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_base_data_from_fc  VARCHAR2(1):= 'Y';
l_key  VARCHAR2(32767);
l_Fld  VARCHAR2(32767);


BEGIN

dbg('In Fn_Sys_Default_and_Validate..');

IF p_source <> 'FLEXCUBE'  THEN
BEGIN
SELECT base_data_from_fc
INTO   l_base_data_from_fc
FROM   cotms_source
WHERE  source_code = p_source;
EXCEPTION
WHEN NO_DATA_FOUND THEN
dbg('Failed in Selecting Source '||p_source);
dbg(SQLERRM);
p_err_code    := 'ST-VALS-002';
p_err_params  := p_source;
RETURN FALSE;
END;
END IF;
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'CSTMS_PRODUCT.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_cstms_product.product_code;
IF p_action_code = Cspks_Req_Handler.p_new THEN
IF p_prev_pcdprmnt.prmnt_cstms_product.product_code IS NOT NULL THEN
dbg('Record Already Exists..');
pr_log_error(p_source,'ST-VALS-001',l_key) ;
END IF;
ELSIF p_action_code IN (Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify,Cspks_Req_Handler.p_Auth,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen,Cspks_Req_Handler.p_Query,Cspks_Req_Handler.p_Delete) THEN
IF p_prev_pcdprmnt.prmnt_cstms_product.product_code IS NULL THEN
dbg('Record Does not Exist..');
pr_log_error(p_source,'ST-VALS-002',l_key) ;
END IF;
END IF;
IF NOT Cspks_Req_Utils.Fn_Maint_Basic_Validations (p_source,
g_Function_Id,
p_action_code,
p_prev_pcdprmnt.prmnt_cstms_product.mod_no,
p_pcdprmnt.prmnt_cstms_product.mod_no,
p_prev_pcdprmnt.prmnt_cstms_product.auth_stat,
p_prev_pcdprmnt.prmnt_cstms_product.record_stat,
p_prev_pcdprmnt.prmnt_cstms_product.once_auth,
g_key_id,
l_key,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_Req_Utils.Fn_Maint_Basic_Validations');
RETURN FALSE;
END IF;
IF ( p_action_code IN (Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen,Cspks_Req_Handler.p_Delete,Cspks_Req_Handler.p_Version_Delete,Cspks_Req_Handler.p_Query) OR
   ( p_action_code = Cspks_Req_Handler.p_Modify AND NVL(p_prev_pcdprmnt.prmnt_cstms_product.once_auth,'N') = 'Y')) THEN
p_wrk_pcdprmnt := p_prev_pcdprmnt;
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no := p_pcdprmnt.prmnt_cstms_product.mod_no;
p_wrk_pcdprmnt.addl_info := p_pcdprmnt.addl_info ;
ELSE
p_wrk_pcdprmnt := p_pcdprmnt;
END IF;
IF p_action_code = Cspks_Req_Handler.p_auth THEN
IF p_wrk_pcdprmnt.prmnt_cstms_product.mod_no IS NULL THEN
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no           := p_prev_pcdprmnt.prmnt_cstms_product.mod_no;
END IF;
p_wrk_pcdprmnt.prmnt_cstms_product.Checker_dt_stamp   := fn_mntstamp;
p_wrk_pcdprmnt.prmnt_cstms_product.Checker_id         := Global.user_id;
ELSIF p_action_code IN (Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen) THEN
p_wrk_pcdprmnt.prmnt_cstms_product.auth_stat        := 'U';
IF NOT Cspks_Req_Global.Fn_UnTanking THEN
p_wrk_pcdprmnt.prmnt_cstms_product.maker_id         := Global.user_id;
p_wrk_pcdprmnt.prmnt_cstms_product.maker_dt_stamp   := fn_mntstamp;
END IF;

IF p_action_code = Cspks_Req_Handler.p_new THEN
IF NOT Cspks_Req_Global.Fn_UnTanking THEN
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no           := 1;
ELSE
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no := NVL(p_wrk_pcdprmnt.prmnt_cstms_product.mod_no,1);
END IF;
p_wrk_pcdprmnt.prmnt_cstms_product.record_stat      := 'O';
p_wrk_pcdprmnt.prmnt_cstms_product.once_auth        := 'N';
ELSE
IF NOT Cspks_Req_Global.Fn_UnTanking THEN
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no           := NVL(p_prev_pcdprmnt.prmnt_cstms_product.mod_no,0)+1;
ELSE
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no           := NVL(p_pcdprmnt.prmnt_cstms_product.mod_no,1);
END IF;
p_wrk_pcdprmnt.prmnt_cstms_product.Once_Auth           := NVL(p_prev_pcdprmnt.prmnt_cstms_product.Once_Auth,'N');
p_wrk_pcdprmnt.prmnt_cstms_product.Record_Stat           := NVL(p_prev_pcdprmnt.prmnt_cstms_product.Record_Stat,'O');
END IF;
IF p_action_code = Cspks_Req_Handler.p_Close THEN
p_wrk_pcdprmnt.prmnt_cstms_product.record_stat      := 'C';
ELSIF p_action_code = Cspks_Req_Handler.p_Reopen THEN
p_wrk_pcdprmnt.prmnt_cstms_product.record_stat      := 'O';
END IF;
p_wrk_pcdprmnt.prmnt_cstms_product.Checker_id         := Null;
p_wrk_pcdprmnt.prmnt_cstms_product.Checker_dt_stamp         := Null;
ELSIF p_action_code IN ( Cspks_Req_Handler.p_delete,Cspks_Req_Handler.p_Version_Delete) THEN
IF p_wrk_pcdprmnt.prmnt_cstms_product.mod_no IS NULL THEN
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no           := p_prev_pcdprmnt.prmnt_cstms_product.mod_no;
END IF;
END IF;
IF p_action_code in  (Cspks_Req_Handler.p_new,Cspks_Req_Handler.p_modify) THEN
IF NOT Fn_Sys_Basic_Vals(p_source,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in .Fn_Sys_Basic_Vals..');
RETURN FALSE;
END IF;

IF p_action_code = Cspks_Req_Handler.p_new  THEN
IF NOT Fn_Sys_Default_Vals(p_source,
p_wrk_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in .Fn_Sys_Default_Vals..');
RETURN FALSE;
END IF;

END IF;
IF p_action_code = Cspks_Req_Handler.p_modify AND p_prev_pcdprmnt.prmnt_cstms_product.once_auth = 'Y'THEN
dbg('Calling Fn_Sys_Merge_Amendables..');
IF NOT Fn_Sys_Merge_Amendables(p_source,
p_source_operation,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in .Fn_Sys_Merge_Amendables..');
RETURN FALSE;
END IF;
END IF;

IF NOT Fn_Sys_Check_Mandatory_Nodes(p_source,
p_wrk_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in .Fn_Sys_Check_Mandatory_Nodes..');
RETURN FALSE;
END IF;

IF NOT Fn_Sys_Lov_Vals(p_source,
p_wrk_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in .Fn_Sys_Lov_Vals..');
RETURN FALSE;
END IF;

END IF;
dbg('Returning from Fn_Sys_Default_and_Validate');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Sys_Default_and_Validate ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Default_and_Validate;
FUNCTION Fn_Sys_Query  ( p_source		IN  VARCHAR2,
p_Full_Data     IN  VARCHAR2 DEFAULT 'Y',
p_with_lock     IN  VARCHAR2 DEFAULT 'N',
p_QryData_Reqd       IN  VARCHAR2,
p_pcdprmnt         IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt  IN   OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS
l_key            VARCHAR2(5000):= NULL;
l_count          NUMBER := 0;
l_wrk_count          NUMBER := 0;
l_key_tags       VARCHAR2(32767);
l_key_vals       VARCHAR2(32767);
l_rec_exists        BOOLEAN := TRUE;
RECORD_LOCKED    EXCEPTION;
PRAGMA EXCEPTION_INIT( RECORD_LOCKED, -54 );
l_Tanked_data_Found             BOOLEAN := FALSE;
l_Bld_Type_From_Tanked_Data     BOOLEAN := FALSE;
l_Mod_No                        NUMBER;
l_dsn_rec_cnt_2 NUMBER := 0;
l_bnd_cntr_2    NUMBER := 0;
l_dsn_rec_cnt_3 NUMBER := 0;
l_bnd_cntr_3    NUMBER := 0;
l_dsn_rec_cnt_4 NUMBER := 0;
l_bnd_cntr_4    NUMBER := 0;
Cursor c_prmnt_pctms_product_banks IS
SELECT *
FROM   PCTM_PRODUCT_BANKS
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;
Cursor c_prmnt_pctms_product_accrole IS
SELECT *
FROM   PCTM_PRODUCT_ACCROLE
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;
BEGIN
dbg('In Fn_Sys_Query..');
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'CSTMS_PRODUCT.PRODUCT_CODE')||'-'||
p_pcdprmnt.prmnt_cstms_product.product_code;
l_Mod_No := p_pcdprmnt.prmnt_cstms_product.Mod_No;
dbg('Calling Fn_Get_Tanked_Data');
IF NOT Cspks_Req_Utils.Fn_Get_Tanked_Data (p_source,
g_action_code,
g_Function_Id,
g_Key_Id,
l_Mod_No,
NVL(p_with_lock,'N'),
l_Tanked_data_Found,
l_Bld_Type_From_Tanked_Data,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_Req_Utils.Fn_Get_From_Tanked.');
pr_log_error(p_source,p_err_code,p_err_params);
END IF;

IF l_Tanked_data_Found THEN
IF l_Bld_Type_From_Tanked_Data THEN
IF NOT  fn_build_Fc_type(
p_pcdprmnt.addl_info,
p_Wrk_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_build_Fc_type');
l_Tanked_data_Found      := FALSE;
pr_log_error(p_source,'ST-TANK-001',NULL);
END IF;
END IF ;
END IF ;
IF NOT l_Tanked_data_Found THEN
dbg('Get the Master Record...');
IF NVL(p_with_lock,'N') = 'Y' THEN
BEGIN
SELECT *
INTO   p_wrk_pcdprmnt.prmnt_cstms_product
FROM  CSTM_PRODUCT
WHERE MODULE = 'PC' AND product_code = p_pcdprmnt.prmnt_cstms_product.product_code
 FOR UPDATE NOWAIT;
EXCEPTION
WHEN RECORD_LOCKED THEN
dbg('Failed to Obtain the Lock..');
pr_log_error(p_source,'ST-LOCK-001',NULL);
RETURN FALSE;
WHEN no_data_found THEN
dbg('Failed in selecting the master Recotrd');
dbg('Record Does not Exist..');
l_rec_exists := FALSE;
END;

ELSE
BEGIN
SELECT *
INTO   p_wrk_pcdprmnt.prmnt_cstms_product
FROM  CSTM_PRODUCT
WHERE MODULE = 'PC' AND product_code = p_pcdprmnt.prmnt_cstms_product.product_code
;
EXCEPTION
WHEN no_data_found THEN
dbg('Failed in selecting the master Recotrd');
dbg('Record Does not Exist..');
p_err_code    := 'ST-VALS-002';
p_err_params  := l_key;
RETURN FALSE;
END;

END IF;
IF p_full_data = 'Y' AND l_rec_exists THEN
dbg('Get the Record For :PCTMS_PRODUCT_PREFERENCE');
BEGIN
SELECT *
INTO p_wrk_pcdprmnt.prmnt_product_preference
FROM   PCTM_PRODUCT_PREFERENCE
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;
EXCEPTION
WHEN OTHERS THEN
dbg(SQLERRM);
dbg('Failed in selecting the Record for :PCTMS_PRODUCT_PREFERENCE');
END;
dbg('Get the Record For :PCTMS_PRODUCT_BANKS');
OPEN c_prmnt_pctms_product_banks;
LOOP
FETCH c_prmnt_pctms_product_banks
BULK COLLECT INTO p_wrk_pcdprmnt.prmnt_pctms_product_banks;
 EXIT WHEN c_prmnt_pctms_product_banks%NOTFOUND;
END LOOP;
CLOSE c_prmnt_pctms_product_banks;
dbg('Get the Record For :PCTMS_PRODUCT_ACCROLE');
OPEN c_prmnt_pctms_product_accrole;
LOOP
FETCH c_prmnt_pctms_product_accrole
BULK COLLECT INTO p_wrk_pcdprmnt.prmnt_pctms_product_accrole;
 EXIT WHEN c_prmnt_pctms_product_accrole%NOTFOUND;
END LOOP;
CLOSE c_prmnt_pctms_product_accrole;
IF  NVL(p_QryData_Reqd,'Y')  = 'Y' THEN
dbg('Querying Description Fields ');
BEGIN
SELECT PRODUCT_GROUP_DESCRIPTION INTO P_wrk_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDGRPDESC')   FROM (select product_group, product_group_description from cstms_product_group where record_stat = 'O' and once_auth = 'Y' order by product_group) WHERE PRODUCT_GROUP = P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDGRPDESC') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :PRDGRP');
END;
BEGIN
SELECT PRODUCT_TYPE_DESC INTO P_wrk_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDTYPDESC')   FROM (select product_type,product_type_desc  from smtbs_product_types where function_id = 'PCDPRMNT' and language_code = GLOBAL.LANG and nvl(int_auth_stat,'A')='A' order by product_type) WHERE PRODUCT_TYPE = P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('CSTMS_PRODUCT')(1)('PRDTYPDESC') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :PRDTYP');
END;
BEGIN
SELECT DESCRIPTION INTO P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('DESCRIPTION')   FROM (select charge_category,description from PCTMS_CHARGE_CATEGORY_DEFN where record_stat = 'O' and once_auth = 'Y' ORDER BY charge_category) WHERE CHARGE_CATEGORY = P_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('DESCRIPTION') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :CHRGCAT');
END;
BEGIN
SELECT NETWORK_DESC INTO P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('NETWRKDESC')   FROM (select network_id,network_desc from pctms_clearing_network where record_stat='O' and once_auth='Y' order by network_id) WHERE NETWORK_ID = P_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_PREFERENCE')(1)('NETWRKDESC') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :NETWRKID');
END;
IF p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT > 0 THEN
FOR i_3 IN  1..p_Wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
NULL;
BEGIN
SELECT BANK_NAME INTO P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_BANKS')(i_3)('BANK_NAME')   FROM (SELECT BANK_CODE,BANK_NAME  FROM PCTMS_BANK_PARAM WHERE RECORD_STAT='O' AND ONCE_AUTH='Y' AND BANK_CODE NOT IN (SELECT BANKCODE                      FROM PCTMS_PRODUCT_BANKS                      WHERE PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE)ORDER BY BANK_CODE) WHERE BANK_CODE = P_wrk_pcdprmnt.prmnt_pctms_product_banks(i_3).BANKCODE AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_BANKS')(i_3)('BANK_NAME') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :BNKCD');
END;
END LOOP;
END IF;
IF p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT > 0 THEN
FOR i_4 IN  1..p_Wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT LOOP
NULL;
BEGIN
SELECT GL_DESC INTO P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(i_4)('GLDESC')   FROM (select a.gl_code, a.gl_desc from gltms_glmaster a where a.customer <> 'C' and a.leaf = 'Y' and a.record_stat = 'O' and a.once_auth='Y' and a.type <> '*' and a.type <> '*'order by gl_code) WHERE GL_CODE = P_wrk_pcdprmnt.prmnt_pctms_product_accrole(i_4).ACCOUNTING_HEAD AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(i_4)('GLDESC') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :ACCHD');
END;
l_bnd_cntr_3 := 0;
IF P_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT > 0 THEN
FOR i_3 IN  1..P_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT LOOP
IF NVL(P_wrk_pcdprmnt.prmnt_pctms_product_accrole(i_4).product_code,'@') = NVL(P_wrk_pcdprmnt.prmnt_pctms_product_banks(i_3).product_code,'@') AND NVL(P_wrk_pcdprmnt.prmnt_pctms_product_accrole(i_4).bankcode,'@') = NVL(P_wrk_pcdprmnt.prmnt_pctms_product_banks(i_3).bankcode,'@') THEN
l_bnd_cntr_3 := i_3;
EXIT;
END IF;
END LOOP;
END IF;
IF  l_bnd_cntr_3 > 0 THEN
BEGIN
SELECT ROLE_DESCRIPTION INTO P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(i_4)('ROLDESC')   FROM (SELECT B.ACCOUNTING_ROLE,A.ROLE_DESCRIPTION FROM CSTMS_PRODUCT_ACCROLE B,CSTBS_ACCROLE A WHERE A.ROLE_CODE=B.ACCOUNTING_ROLE AND A.MODULE='PC' AND B.PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE AND  ACCOUNTING_ROLE NOT IN(                           SELECT ACCOUNTING_ROLE                            FROM PCTMS_PRODUCT_ACCROLE                           WHERE PRODUCT_CODE=P_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE                            AND   BANKCODE=P_wrk_pcdprmnt.prmnt_pctms_product_banks(l_bnd_cntr_3).BANKCODE )ORDER BY ACCOUNTING_ROLE) WHERE ACCOUNTING_ROLE = P_wrk_pcdprmnt.prmnt_pctms_product_accrole(i_4).ACCOUNTING_ROLE AND ROWNUM < 2;
EXCEPTION
WHEN OTHERS THEN
P_wrk_pcdprmnt.Desc_Fields('PCTMS_PRODUCT_ACCROLE')(i_4)('ROLDESC') := NULL;
dbg(SQLERRM);
dbg('Failed in selecting the Desc Fields For  :ACCROLE');
END;
END IF;
END LOOP;
END IF;
END IF;

END IF;
END IF;
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Query ..');
debug.pr_debug('**',SQLERRM);
IF  c_prmnt_pctms_product_banks%ISOPEN THEN
CLOSE c_prmnt_pctms_product_banks;
END IF;
IF  c_prmnt_pctms_product_accrole%ISOPEN THEN
CLOSE c_prmnt_pctms_product_accrole;
END IF;
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Query;
FUNCTION Fn_Sys_Upload_Db         (p_source            IN VARCHAR2,
p_Action_Code       IN     VARCHAR2,
p_prev_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt      IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_count             NUMBER:= 0;
l_ins_count         NUMBER:= 0;
l_upd_count         NUMBER:= 0;
l_del_count         NUMBER:= 0;
l_wrk_count         NUMBER:= 0;
l_prev_count        NUMBER:= 0;
l_rec_found         BOOLEAN:= FALSE;
l_row_id            ROWID;
l_key               VARCHAR2(5000):= NULL;
l_auth_stat         VARCHAR2(1) := 'A';
l_base_data_from_fc VARCHAR2(1):= 'Y';
I_prmnt_pctms_product_banks       pcpks_pcdprmnt_Main.ty_tb_rmnt_pctms_product_banks;
U_prmnt_pctms_product_banks       pcpks_pcdprmnt_Main.ty_tb_rmnt_pctms_product_banks;
D_prmnt_pctms_product_banks       pcpks_pcdprmnt_Main.ty_tb_rmnt_pctms_product_banks;
I_prmnt_pctms_product_accrole       pcpks_pcdprmnt_Main.ty_tb_nt_pctms_product_accrole;
U_prmnt_pctms_product_accrole       pcpks_pcdprmnt_Main.ty_tb_nt_pctms_product_accrole;
D_prmnt_pctms_product_accrole       pcpks_pcdprmnt_Main.ty_tb_nt_pctms_product_accrole;
BEGIN
dbg('In Fn_Sys_Upload_Db..');
IF p_Action_Code = Cspks_Req_Handler.p_new THEN

dbg('Inserting into CSTMS_PRODUCT..');
BEGIN
IF  p_wrk_pcdprmnt.prmnt_cstms_product.product_code IS NOT NULL THEN
dbg('Record Sent..');
INSERT INTO  CSTM_PRODUCT
VALUES p_wrk_pcdprmnt.prmnt_cstms_product;
END IF;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoCSTMS_PRODUCT..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@CSTMS_PRODUCT';
RETURN FALSE;
END;

dbg('Inserting into PCTMS_PRODUCT_PREFERENCE..');
BEGIN
IF  p_wrk_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Record Sent..');
INSERT INTO  PCTM_PRODUCT_PREFERENCE
VALUES p_wrk_pcdprmnt.prmnt_product_preference;
END IF;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoPCTMS_PRODUCT_PREFERENCE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_PREFERENCE';
RETURN FALSE;
END;

dbg('Inserting into PCTMS_PRODUCT_BANKS..');
BEGIN
l_count      := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
FORALL l_index IN  1..l_count
INSERT INTO PCTM_PRODUCT_BANKS
VALUES p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index);
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoPCTMS_PRODUCT_BANKS..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_BANKS';
RETURN FALSE;
END;

dbg('Inserting into PCTMS_PRODUCT_ACCROLE..');
BEGIN
l_count      := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
FORALL l_index IN  1..l_count
INSERT INTO PCTM_PRODUCT_ACCROLE
VALUES p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index);
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoPCTMS_PRODUCT_ACCROLE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_ACCROLE';
RETURN FALSE;
END;
ELSIF p_Action_Code = Cspks_Req_Handler.p_modify THEN

dbg('Updating Single Record Node :  CSTMS_PRODUCT..');
BEGIN
UPDATE CSTM_PRODUCT
SET ASSET_CATEGORIES_LIST = p_wrk_pcdprmnt.prmnt_cstms_product.ASSET_CATEGORIES_LIST,
BRANCHES_LIST = p_wrk_pcdprmnt.prmnt_cstms_product.BRANCHES_LIST,
CATEGORIES_LIST = p_wrk_pcdprmnt.prmnt_cstms_product.CATEGORIES_LIST,
CURRENCIES_LIST = p_wrk_pcdprmnt.prmnt_cstms_product.CURRENCIES_LIST,
GEN_MT103P = p_wrk_pcdprmnt.prmnt_cstms_product.GEN_MT103P,
INCLUDE_FOR_TDS_CALC = p_wrk_pcdprmnt.prmnt_cstms_product.INCLUDE_FOR_TDS_CALC,
INSTRUMENT_PRODUCT_ALLOW = p_wrk_pcdprmnt.prmnt_cstms_product.INSTRUMENT_PRODUCT_ALLOW,
LOCATION_LIST = p_wrk_pcdprmnt.prmnt_cstms_product.LOCATION_LIST,
MAXIMUM_RATE_VARIANCE = p_wrk_pcdprmnt.prmnt_cstms_product.MAXIMUM_RATE_VARIANCE,
MODULE = p_wrk_pcdprmnt.prmnt_cstms_product.MODULE,
NORMAL_RATE_VARIANCE = p_wrk_pcdprmnt.prmnt_cstms_product.NORMAL_RATE_VARIANCE,
NO_OF_LEGS = p_wrk_pcdprmnt.prmnt_cstms_product.NO_OF_LEGS,
PART_OF_PRODUCT = p_wrk_pcdprmnt.prmnt_cstms_product.PART_OF_PRODUCT,
POOL_CODE = p_wrk_pcdprmnt.prmnt_cstms_product.POOL_CODE,
PORTFOLIO_PRODUCT_ALLOW = p_wrk_pcdprmnt.prmnt_cstms_product.PORTFOLIO_PRODUCT_ALLOW,
PRODUCT_DESCRIPTION = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_DESCRIPTION,
PRODUCT_END_DATE = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_END_DATE,
PRODUCT_GROUP = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_GROUP,
PRODUCT_REMARKS = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_REMARKS,
PRODUCT_SLOGAN = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_SLOGAN,
PRODUCT_START_DATE = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_START_DATE,
PRODUCT_TYPE = p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_TYPE,
RATE_CODE_PREFERRED = p_wrk_pcdprmnt.prmnt_cstms_product.RATE_CODE_PREFERRED,
RATE_TYPE_PREFERRED = p_wrk_pcdprmnt.prmnt_cstms_product.RATE_TYPE_PREFERRED,
RTH_CLASS = p_wrk_pcdprmnt.prmnt_cstms_product.RTH_CLASS,
WAREHOUSE_CODE = p_wrk_pcdprmnt.prmnt_cstms_product.WAREHOUSE_CODE,
MAKER_ID = p_wrk_pcdprmnt.prmnt_cstms_product.MAKER_ID,
MAKER_DT_STAMP = p_wrk_pcdprmnt.prmnt_cstms_product.MAKER_DT_STAMP,
CHECKER_ID = p_wrk_pcdprmnt.prmnt_cstms_product.CHECKER_ID,
CHECKER_DT_STAMP = p_wrk_pcdprmnt.prmnt_cstms_product.CHECKER_DT_STAMP,
MOD_NO = p_wrk_pcdprmnt.prmnt_cstms_product.MOD_NO,
AUTH_STAT = p_wrk_pcdprmnt.prmnt_cstms_product.AUTH_STAT
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert into CSTMS_PRODUCT..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@CSTMS_PRODUCT';
RETURN FALSE;
END;

IF  p_wrk_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Record Sent..');
dbg('Updating Single Record Node :  PCTMS_PRODUCT_PREFERENCE..');
BEGIN
UPDATE PCTM_PRODUCT_PREFERENCE
SET ACTIVATION_DT_FWD = p_wrk_pcdprmnt.prmnt_product_preference.ACTIVATION_DT_FWD,
AGREEMENT_ID_REQD = p_wrk_pcdprmnt.prmnt_product_preference.AGREEMENT_ID_REQD,
ALLOW_POST_COT_TXN = p_wrk_pcdprmnt.prmnt_product_preference.ALLOW_POST_COT_TXN,
ALLOW_THIRD_PARTY_CHG = p_wrk_pcdprmnt.prmnt_product_preference.ALLOW_THIRD_PARTY_CHG,
ASCII_HANDOFF_REQD = p_wrk_pcdprmnt.prmnt_product_preference.ASCII_HANDOFF_REQD,
AUTO_DISPATCH = p_wrk_pcdprmnt.prmnt_product_preference.AUTO_DISPATCH,
AUTO_EXCH_RATE_REQD = p_wrk_pcdprmnt.prmnt_product_preference.AUTO_EXCH_RATE_REQD,
AUTO_REDISPATCH = p_wrk_pcdprmnt.prmnt_product_preference.AUTO_REDISPATCH,
AUTO_RESPONSE = p_wrk_pcdprmnt.prmnt_product_preference.AUTO_RESPONSE,
BACK_VALUE_LIMIT_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.BACK_VALUE_LIMIT_DAYS,
CCY_CAL = p_wrk_pcdprmnt.prmnt_product_preference.CCY_CAL,
CHARGE_AC_STATISTICS = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_AC_STATISTICS,
CHARGE_BEARER = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_BEARER,
CHARGE_CATEGORY = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CATEGORY,
CHARGE_CUST_STATISTICS = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_CUST_STATISTICS,
CHARGE_MODE = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_MODE,
CHARGE_WAIVER = p_wrk_pcdprmnt.prmnt_product_preference.CHARGE_WAIVER,
CHECK_AGREEMENT_ID = p_wrk_pcdprmnt.prmnt_product_preference.CHECK_AGREEMENT_ID,
CHECK_CPTY_AC_NO = p_wrk_pcdprmnt.prmnt_product_preference.CHECK_CPTY_AC_NO,
CHECK_CPTY_BANK_CODE = p_wrk_pcdprmnt.prmnt_product_preference.CHECK_CPTY_BANK_CODE,
CHECK_CREDITOR_ID = p_wrk_pcdprmnt.prmnt_product_preference.CHECK_CREDITOR_ID,
CLEARING_MODE = p_wrk_pcdprmnt.prmnt_product_preference.CLEARING_MODE,
CLEARING_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.CLEARING_TYPE,
CLG_CCY = p_wrk_pcdprmnt.prmnt_product_preference.CLG_CCY,
CLG_VOSTRO_ACC = p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_ACC,
CLG_VOSTRO_BRN = p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_BRN,
CLG_VOSTRO_CCY = p_wrk_pcdprmnt.prmnt_product_preference.CLG_VOSTRO_CCY,
COLLECTION_STMT_REQD = p_wrk_pcdprmnt.prmnt_product_preference.COLLECTION_STMT_REQD,
COLLECTION_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.COLLECTION_TYPE,
COLLECT_VOLUME_STATISTICS = p_wrk_pcdprmnt.prmnt_product_preference.COLLECT_VOLUME_STATISTICS,
CPTY_ENT_DAY_POSTCUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CPTY_ENT_DAY_POSTCUTOF,
CPTY_ENT_DAY_PRECUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CPTY_ENT_DAY_PRECUTOF,
CPTY_ENT_VAL_DAY_POSTCUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CPTY_ENT_VAL_DAY_POSTCUTOF,
CPTY_ENT_VAL_DAY_PRECUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CPTY_ENT_VAL_DAY_PRECUTOF,
CREDITOR_ID_REQD = p_wrk_pcdprmnt.prmnt_product_preference.CREDITOR_ID_REQD,
CUST_ENTRY_CONSOL_LMT = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_LMT,
CUST_ENTRY_CONSOL_REQD = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENTRY_CONSOL_REQD,
CUST_ENT_DAY_POSTCUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENT_DAY_POSTCUTOF,
CUST_ENT_DAY_PRECUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENT_DAY_PRECUTOF,
CUST_ENT_VAL_DAY_POSTCUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENT_VAL_DAY_POSTCUTOF,
CUST_ENT_VAL_DAY_PRECUTOF = p_wrk_pcdprmnt.prmnt_product_preference.CUST_ENT_VAL_DAY_PRECUTOF,
CUTOFF_HR = p_wrk_pcdprmnt.prmnt_product_preference.CUTOFF_HR,
CUTOFF_MIN = p_wrk_pcdprmnt.prmnt_product_preference.CUTOFF_MIN,
DD_AGREEMENT_REQD = p_wrk_pcdprmnt.prmnt_product_preference.DD_AGREEMENT_REQD,
DEFAULT_ACTIVATION_DATE = p_wrk_pcdprmnt.prmnt_product_preference.DEFAULT_ACTIVATION_DATE,
DISPATCH = p_wrk_pcdprmnt.prmnt_product_preference.DISPATCH,
DISPATCH_ACCOUNTING = p_wrk_pcdprmnt.prmnt_product_preference.DISPATCH_ACCOUNTING,
DISPATCH_DAY_POSTCUTOF = p_wrk_pcdprmnt.prmnt_product_preference.DISPATCH_DAY_POSTCUTOF,
DISPATCH_DAY_PRECUTOF = p_wrk_pcdprmnt.prmnt_product_preference.DISPATCH_DAY_PRECUTOF,
DISPATCH_MEDIA = p_wrk_pcdprmnt.prmnt_product_preference.DISPATCH_MEDIA,
DISP_FILE_NAME = p_wrk_pcdprmnt.prmnt_product_preference.DISP_FILE_NAME,
EARLY_COLL_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.EARLY_COLL_DAYS,
ELIXIR_DOC_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.ELIXIR_DOC_TYPE,
EX_RATE_CODE = p_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_CODE,
EX_RATE_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.EX_RATE_TYPE,
FIRST_COLL_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.FIRST_COLL_DAYS,
FIRST_COLL_DISP_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.FIRST_COLL_DISP_DAYS,
FUTURE_VALUE_LIMIT_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.FUTURE_VALUE_LIMIT_DAYS,
INVOICE_SPLIT_REQD = p_wrk_pcdprmnt.prmnt_product_preference.INVOICE_SPLIT_REQD,
IN_PROD_CATEGORY = p_wrk_pcdprmnt.prmnt_product_preference.IN_PROD_CATEGORY,
MAX_INT_AMT = p_wrk_pcdprmnt.prmnt_product_preference.MAX_INT_AMT,
MAX_SPLIT_COUNT = p_wrk_pcdprmnt.prmnt_product_preference.MAX_SPLIT_COUNT,
MAX_TXN_AMT = p_wrk_pcdprmnt.prmnt_product_preference.MAX_TXN_AMT,
MIN_DIVISIBLE_AMT = p_wrk_pcdprmnt.prmnt_product_preference.MIN_DIVISIBLE_AMT,
MIN_TXN_AMT = p_wrk_pcdprmnt.prmnt_product_preference.MIN_TXN_AMT,
MOVE_BVT_ACTIVATION_DATE = p_wrk_pcdprmnt.prmnt_product_preference.MOVE_BVT_ACTIVATION_DATE,
NETWORK_ID = p_wrk_pcdprmnt.prmnt_product_preference.NETWORK_ID,
NO_OF_REC = p_wrk_pcdprmnt.prmnt_product_preference.NO_OF_REC,
OUT_PMT_WORKFLOW = p_wrk_pcdprmnt.prmnt_product_preference.OUT_PMT_WORKFLOW,
OVERRIDE_OVERDRAFT = p_wrk_pcdprmnt.prmnt_product_preference.OVERRIDE_OVERDRAFT,
PAYMENT_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.PAYMENT_TYPE,
POST_COT_RESPONSE_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.POST_COT_RESPONSE_DAYS,
PRE_COT_RESPONSE_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.PRE_COT_RESPONSE_DAYS,
PRIORITY = p_wrk_pcdprmnt.prmnt_product_preference.PRIORITY,
PROCESS_REJ_AFTER_RESP_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.PROCESS_REJ_AFTER_RESP_DAYS,
PRODUCT_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.PRODUCT_TYPE,
PYMT_REJT_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.PYMT_REJT_DAYS,
RECALL_DATE_BASIS = p_wrk_pcdprmnt.prmnt_product_preference.RECALL_DATE_BASIS,
RECALL_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.RECALL_DAYS,
RECALL_DAYS_BASIS = p_wrk_pcdprmnt.prmnt_product_preference.RECALL_DAYS_BASIS,
RECUR_COLL_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.RECUR_COLL_DAYS,
REDISPATCH_COUNT = p_wrk_pcdprmnt.prmnt_product_preference.REDISPATCH_COUNT,
REDISPATCH_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.REDISPATCH_DAYS,
REDISPATCH_REQD = p_wrk_pcdprmnt.prmnt_product_preference.REDISPATCH_REQD,
REFERRAL_REQUIRED = p_wrk_pcdprmnt.prmnt_product_preference.REFERRAL_REQUIRED,
REJ_ACCT_AFTER_RESP_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_AFTER_RESP_DAYS,
REJ_ACCT_BEFORE_RESP_DAYS = p_wrk_pcdprmnt.prmnt_product_preference.REJ_ACCT_BEFORE_RESP_DAYS,
REJ_AC_TYPE_AFTER = p_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_AFTER,
REJ_AC_TYPE_BEFORE = p_wrk_pcdprmnt.prmnt_product_preference.REJ_AC_TYPE_BEFORE,
REJ_PAYMENT_BRN_AFTER = p_wrk_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_AFTER,
REJ_PAYMENT_BRN_BEFORE = p_wrk_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_BRN_BEFORE,
REJ_PAYMENT_CCY_AFTER = p_wrk_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_AFTER,
REJ_PAYMENT_CCY_BEFORE = p_wrk_pcdprmnt.prmnt_product_preference.REJ_PAYMENT_CCY_BEFORE,
REJ_VERIFY_FUNDS = p_wrk_pcdprmnt.prmnt_product_preference.REJ_VERIFY_FUNDS,
RESPONSE_ADVICE_BASIS = p_wrk_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_BASIS,
RESPONSE_ADVICE_REQD = p_wrk_pcdprmnt.prmnt_product_preference.RESPONSE_ADVICE_REQD,
RESPONSE_DAYS_BASIS = p_wrk_pcdprmnt.prmnt_product_preference.RESPONSE_DAYS_BASIS,
REV_SETTLE_GL = p_wrk_pcdprmnt.prmnt_product_preference.REV_SETTLE_GL,
RFD_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.RFD_TYPE,
SERV_LEVEL_CODE = p_wrk_pcdprmnt.prmnt_product_preference.SERV_LEVEL_CODE,
TRANSFER_TYPE = p_wrk_pcdprmnt.prmnt_product_preference.TRANSFER_TYPE
WHERE product_code = p_wrk_pcdprmnt.prmnt_product_preference.product_code
;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert into PCTMS_PRODUCT_PREFERENCE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_PREFERENCE';
RETURN FALSE;
END;
IF SQL%ROWCOUNT = 0 THEN
BEGIN
INSERT INTO  PCTM_PRODUCT_PREFERENCE
VALUES p_wrk_pcdprmnt.prmnt_product_preference;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert into PCTMS_PRODUCT_PREFERENCE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_PREFERENCE';
RETURN FALSE;
END;
END IF;
ELSE
dbg('Check if the Record is Already present for  PCTMS_PRODUCT_PREFERENCE. .');
IF  p_prev_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Prev Data exists and not sent for  PCTMS_PRODUCT_PREFERENCE. Delete the Existing Record.');
DELETE PCTM_PRODUCT_PREFERENCE
WHERE product_code = p_prev_pcdprmnt.prmnt_product_preference.product_code
;
END IF;
END IF;



dbg('Preapring Insert and Update Types for  PCTMS_PRODUCT_BANKS..');
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_prev_count := p_prev_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_wrk_count > 0 THEN
FOR l_index IN 1 .. l_wrk_count LOOP
l_rec_found    := FALSE;
IF l_prev_count >  0 THEN
FOR l_index1 IN 1..l_prev_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_banks	(l_index1).bankcode,'@')) THEN
dbg('Record Has been Found.Update Case..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF l_rec_found THEN
dbg('Record is Modified...');
U_prmnt_pctms_product_banks(U_prmnt_pctms_product_banks.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index);
ELSE
dbg('Record is Added...');
I_prmnt_pctms_product_banks(I_prmnt_pctms_product_banks.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index);
END IF;
END LOOP;
END IF;

dbg('Preapring Delete Types for  PCTMS_PRODUCT_BANKS..');
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_prev_count := p_prev_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_prev_count > 0 THEN
FOR l_index1 IN 1 .. l_prev_count LOOP
l_rec_found    := FALSE;
IF l_wrk_count >  0 THEN
FOR l_index IN 1..l_wrk_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_banks	(l_index1).bankcode,'@')) THEN
dbg('Record Has been Found.Update Case..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('Record is Deleted...');
D_prmnt_pctms_product_banks(D_prmnt_pctms_product_banks.COUNT +1 ) :=  p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index1);
END IF;
END LOOP;
END IF;
l_del_count  := D_prmnt_pctms_product_banks.COUNT;
dbg('Records Deleted  :'||l_del_count);
IF l_del_count > 0 THEN
FOR l_index IN 1 .. l_del_count LOOP
dbg('Deleting Record...');
DELETE PCTM_PRODUCT_BANKS
WHERE product_code = D_prmnt_pctms_product_banks(l_index).product_code
 AND bankcode = D_prmnt_pctms_product_banks(l_index).bankcode
;
END LOOP;
END IF;
l_ins_count  := I_prmnt_pctms_product_banks.COUNT;
dbg('New Records Added  :'||l_ins_count);
BEGIN
l_count      := I_prmnt_pctms_product_banks.COUNT;
FORALL l_index IN  1..l_count
INSERT INTO PCTM_PRODUCT_BANKS
VALUES I_prmnt_pctms_product_banks(l_index);
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoPCTMS_PRODUCT_BANKS..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_BANKS';
RETURN FALSE;
END;

dbg('Preapring Insert and Update Types for  PCTMS_PRODUCT_ACCROLE..');
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_prev_count := p_prev_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_wrk_count > 0 THEN
FOR l_index IN 1 .. l_wrk_count LOOP
l_rec_found    := FALSE;
IF l_prev_count >  0 THEN
FOR l_index1 IN 1..l_prev_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).bankcode,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).accounting_role,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).status,'@')) THEN
dbg('Record Has been Found.Update Case..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF l_rec_found THEN
dbg('Record is Modified...');
U_prmnt_pctms_product_accrole(U_prmnt_pctms_product_accrole.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index);
ELSE
dbg('Record is Added...');
I_prmnt_pctms_product_accrole(I_prmnt_pctms_product_accrole.COUNT +1 ) :=  p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index);
END IF;
END LOOP;
END IF;

dbg('Preapring Delete Types for  PCTMS_PRODUCT_ACCROLE..');
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_prev_count := p_prev_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_prev_count > 0 THEN
FOR l_index1 IN 1 .. l_prev_count LOOP
l_rec_found    := FALSE;
IF l_wrk_count >  0 THEN
FOR l_index IN 1..l_wrk_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).bankcode,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).accounting_role,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole	(l_index1).status,'@')) THEN
dbg('Record Has been Found.Update Case..');
l_rec_found := TRUE;
EXIT;
END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('Record is Deleted...');
D_prmnt_pctms_product_accrole(D_prmnt_pctms_product_accrole.COUNT +1 ) :=  p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1);
END IF;
END LOOP;
END IF;
l_del_count  := D_prmnt_pctms_product_accrole.COUNT;
dbg('Records Deleted  :'||l_del_count);
IF l_del_count > 0 THEN
FOR l_index IN 1 .. l_del_count LOOP
dbg('Deleting Record...');
DELETE PCTM_PRODUCT_ACCROLE
WHERE product_code = D_prmnt_pctms_product_accrole(l_index).product_code
 AND bankcode = D_prmnt_pctms_product_accrole(l_index).bankcode
 AND accounting_role = D_prmnt_pctms_product_accrole(l_index).accounting_role
 AND status = D_prmnt_pctms_product_accrole(l_index).status
;
END LOOP;
END IF;
l_ins_count  := I_prmnt_pctms_product_accrole.COUNT;
dbg('New Records Added  :'||l_ins_count);
BEGIN
l_count      := I_prmnt_pctms_product_accrole.COUNT;
FORALL l_index IN  1..l_count
INSERT INTO PCTM_PRODUCT_ACCROLE
VALUES I_prmnt_pctms_product_accrole(l_index);
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert intoPCTMS_PRODUCT_ACCROLE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_ACCROLE';
RETURN FALSE;
END;
l_upd_count  := U_prmnt_pctms_product_accrole.COUNT;
dbg('Records Modified  :'||l_upd_count);
IF l_upd_count > 0 THEN
FOR l_index IN 1 .. l_upd_count LOOP
dbg('Updating the  Record...');
BEGIN
UPDATE PCTM_PRODUCT_ACCROLE
SET ACCOUNTING_HEAD = U_prmnt_pctms_product_accrole(l_index).ACCOUNTING_HEAD,
ROLE_TYPE = U_prmnt_pctms_product_accrole(l_index).ROLE_TYPE
WHERE product_code = U_prmnt_pctms_product_accrole(l_index).product_code
 AND bankcode = U_prmnt_pctms_product_accrole(l_index).bankcode
 AND accounting_role = U_prmnt_pctms_product_accrole(l_index).accounting_role
 AND status = U_prmnt_pctms_product_accrole(l_index).status
;
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Updating PCTMS_PRODUCT_ACCROLE..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@PCTMS_PRODUCT_ACCROLE';
RETURN FALSE;
END;
END LOOP;
END IF;
ELSIF p_Action_Code = Cspks_Req_Handler.p_delete THEN
dbg('Action Code '||p_Action_Code);
dbg('Deleting the data..');


DELETE PCTM_PRODUCT_ACCROLE
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;


DELETE PCTM_PRODUCT_BANKS
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;


DELETE PCTM_PRODUCT_PREFERENCE
WHERE product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;

DELETE CSTM_PRODUCT WHERE MODULE = 'PC' AND product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;


ELSIF p_action_code IN (Cspks_Req_Handler.p_Auth,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen ) THEN
l_key := Cspks_Req_Utils.fn_get_item_desc(p_source,g_function_id,'CSTMS_PRODUCT.PRODUCT_CODE')||'-'||
p_wrk_pcdprmnt.prmnt_cstms_product.product_code;
BEGIN
SELECT ROWID
INTO   l_row_id
FROM  CSTM_PRODUCT
WHERE MODULE = 'PC' AND product_code = p_wrk_pcdprmnt.prmnt_cstms_product.product_code
;
EXCEPTION
WHEN no_data_found THEN
dbg('Failed in selecting the Previous master Recotrd');
p_err_code    := 'ST-VALS-002';
p_err_params  := l_key;
END;

IF NOT Cspks_Req_Utils.Fn_Maint_Operations(p_source,
g_Function_Id,
p_action_code,
'CSTM_PRODUCT',
l_Row_id,
p_wrk_pcdprmnt.prmnt_cstms_product.mod_no,
p_wrk_pcdprmnt.prmnt_cstms_product.Maker_dt_Stamp,
p_wrk_pcdprmnt.prmnt_cstms_product.Checker_dt_Stamp,
g_Key_Id,
l_Key,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_Req_Utils.Fn_Maint_Basic_Validations');
RETURN FALSE;
END IF;

END IF;

dbg('Returning from Fn_Sys_Upload_Db');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Sys_Upload_Db ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Sys_Upload_Db;
FUNCTION Fn_Build_Fc_Ts (
p_pcdprmnt          IN pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code        IN OUT VARCHAR2,
p_err_params      IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';

BEGIN

dbg('In Fn_Build_Fc_Ts..');

IF NOT Fn_Sys_Build_Fc_Ts(p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Sys_Build_Fc_Ts');
RETURN FALSE;
END IF;

dbg('Returning from Fn_Build_Fc_Ts');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Build_Ws_Ts ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Build_Fc_Ts;
FUNCTION Fn_Build_Ws_Ts (
p_pcdprmnt          IN pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_exchange_pattern	 IN  VARCHAR2,
p_err_code        IN OUT VARCHAR2,
p_err_params      IN OUT VARCHAR2)
RETURN BOOLEAN   IS

l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';

BEGIN

dbg('In Fn_Build_Ws_Ts..');

IF NOT  Fn_Sys_Build_Ws_Ts(p_pcdprmnt,
p_exchange_pattern,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Sys_Build_Ws_Ts');
RETURN FALSE;
END IF;

dbg('Returning from Fn_Build_Ws_Ts');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Build_Ws_Ts ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Build_Ws_Ts;
FUNCTION fn_check_mandatory (p_source		IN  VARCHAR2,
p_action_code		IN  VARCHAR2,
p_pk_or_full     IN  VARCHAR2 DEFAULT 'FULL',
p_pcdprmnt IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code       IN  OUT VARCHAR2,
p_err_params     IN  OUT VARCHAR2)
  RETURN BOOLEAN IS

l_pk_or_full      VARCHAR2(10) :=  'FULL';
l_Blk      VARCHAR2(100) ;
l_Fld      VARCHAR2(100) ;
l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN

dbg('In fn_check_mandatory..');

IF p_pk_or_full = 'FULL' OR p_action_code = Cspks_Req_Handler.p_new THEN
l_pk_or_full := 'FULL';
ELSE
l_pk_or_full := p_pk_or_full;
END IF;
Pr_Skip_Handler('PREMAND');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_pre_check_mandatory (p_source,
p_action_code,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_pre_check_mandatory (p_source,
p_action_code,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Kernel THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_pre_check_mandatory (p_source,
p_action_code,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Sys THEN
IF NOT fn_sys_check_mandatory(p_source,
l_pk_or_full,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_sys_check_mandatory..');
RETURN FALSE;
END IF;
END IF;

l_cscacadd := p_pcdprmnt.ty_cscacadd;
dbg('Calling Cspks_CSCACADD_Main.fn_check_mandatory..');
IF NOT Cspks_CSCACADD_Main.fn_check_mandatory(p_source,
l_Module,
l_calling_Function,
p_action_code,
p_pk_or_full,
l_cscacadd,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACADD_Main.fn_check_mandatory..');
pr_log_error(p_source,p_err_code, p_err_params);
RETURN FALSE;
END IF;

l_cscacrhm := p_pcdprmnt.ty_cscacrhm;
dbg('Calling Cspks_CSCACRHM_Main.fn_check_mandatory..');
IF NOT Cspks_CSCACRHM_Main.fn_check_mandatory(p_source,
l_Module,
l_calling_Function,
p_action_code,
p_pk_or_full,
l_cscacrhm,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACRHM_Main.fn_check_mandatory..');
pr_log_error(p_source,p_err_code, p_err_params);
RETURN FALSE;
END IF;

l_micprmnt := p_pcdprmnt.ty_micprmnt;
dbg('Calling Mipks_MICPRMNT_Main.fn_check_mandatory..');
IF NOT Mipks_MICPRMNT_Main.fn_check_mandatory(p_source,
l_Module,
l_calling_Function,
p_action_code,
p_pk_or_full,
l_micprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Mipks_MICPRMNT_Main.fn_check_mandatory..');
pr_log_error(p_source,p_err_code, p_err_params);
RETURN FALSE;
END IF;

l_pccexpr := p_pcdprmnt.ty_pccexpr;
dbg('Calling Pcpks_PCCEXPR_Main.fn_check_mandatory..');
IF NOT Pcpks_PCCEXPR_Main.fn_check_mandatory(p_source,
l_Module,
l_calling_Function,
p_action_code,
p_pk_or_full,
l_pccexpr,
p_err_code,
p_err_params)  THEN
dbg('Failed in Pcpks_PCCEXPR_Main.fn_check_mandatory..');
pr_log_error(p_source,p_err_code, p_err_params);
RETURN FALSE;
END IF;

Pr_Skip_Handler('POSTMAND');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Kernel THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_post_check_mandatory (p_source,
p_action_code,
l_pk_or_full,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_post_check_mandatory (p_source,
p_action_code,
l_pk_or_full,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_post_check_mandatory (p_source,
p_action_code,
l_pk_or_full,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_pre_check_mandatory..');
RETURN FALSE;
END IF;
END IF;
dbg('Returning from fn_check_mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.fn_check_mandatory ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END fn_check_mandatory;
FUNCTION Fn_Query  ( p_source		IN  VARCHAR2,
p_Full_Data     IN  VARCHAR2 DEFAULT 'Y',
p_with_lock     IN  VARCHAR2 DEFAULT 'N',
p_QryData_Reqd       IN  VARCHAR2,
p_pcdprmnt         IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt  IN   OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_wrk_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_wrk_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_wrk_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_wrk_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_Key_Vals VARCHAR2(32767);
l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';

BEGIN

dbg('In Fn_Query..');

Pr_Skip_Handler('PREQRY');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_pre_Query (p_source,
p_Full_Data  ,
p_with_lock,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_pre_Query (p_source,
p_Full_Data  ,
p_with_lock,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_KERNEL THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_pre_Query (p_source,
p_Full_Data  ,
p_with_lock,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Sys THEN
IF NOT fn_Sys_Query (p_source,
p_Full_Data  ,
p_with_lock,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;
END IF;

IF p_Full_Data = 'Y' THEN
IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
l_cscacadd := p_wrk_pcdprmnt.ty_cscacadd;
l_wrk_cscacadd := p_wrk_pcdprmnt.ty_cscacadd;
Cspks_CSCACADD_Main.Pr_Set_Skip_Sys;
ELSE
dbg('Tanked Data Not Found..');
l_cscacadd := p_pcdprmnt.ty_cscacadd;
END IF;
l_key_vals :='PRODUCT_CODE'||'>'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
IF NOT Cspks_CSCACADD_Main.Fn_Query (p_source,
l_Module,
l_calling_Function,
l_key_vals,
p_QryData_Reqd,
l_cscacadd,
l_wrk_cscacadd,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in Cspks_CSCACADD_Main. fn_pre_Query..');
RETURN FALSE;
END IF;

 p_wrk_pcdprmnt.ty_cscacadd := l_wrk_cscacadd;
IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
Cspks_CSCACADD_Main.Pr_Set_Activate_Sys;
END IF;

IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
l_cscacrhm := p_wrk_pcdprmnt.ty_cscacrhm;
l_wrk_cscacrhm := p_wrk_pcdprmnt.ty_cscacrhm;
Cspks_CSCACRHM_Main.Pr_Set_Skip_Sys;
ELSE
dbg('Tanked Data Not Found..');
l_cscacrhm := p_pcdprmnt.ty_cscacrhm;
END IF;
l_key_vals :='PRODUCT_CODE'||'>'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
IF NOT Cspks_CSCACRHM_Main.Fn_Query (p_source,
l_Module,
l_calling_Function,
l_key_vals,
p_QryData_Reqd,
l_cscacrhm,
l_wrk_cscacrhm,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in Cspks_CSCACRHM_Main. fn_pre_Query..');
RETURN FALSE;
END IF;

 p_wrk_pcdprmnt.ty_cscacrhm := l_wrk_cscacrhm;
IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
Cspks_CSCACRHM_Main.Pr_Set_Activate_Sys;
END IF;

IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
l_micprmnt := p_wrk_pcdprmnt.ty_micprmnt;
l_wrk_micprmnt := p_wrk_pcdprmnt.ty_micprmnt;
Mipks_MICPRMNT_Main.Pr_Set_Skip_Sys;
ELSE
dbg('Tanked Data Not Found..');
l_micprmnt := p_pcdprmnt.ty_micprmnt;
END IF;
l_key_vals :='PRODUCT_CODE'||'>'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
IF NOT Mipks_MICPRMNT_Main.Fn_Query (p_source,
l_Module,
l_calling_Function,
l_key_vals,
p_QryData_Reqd,
l_micprmnt,
l_wrk_micprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in Mipks_MICPRMNT_Main. fn_pre_Query..');
RETURN FALSE;
END IF;

 p_wrk_pcdprmnt.ty_micprmnt := l_wrk_micprmnt;
IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
Mipks_MICPRMNT_Main.Pr_Set_Activate_Sys;
END IF;

IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
l_pccexpr := p_wrk_pcdprmnt.ty_pccexpr;
l_wrk_pccexpr := p_wrk_pcdprmnt.ty_pccexpr;
Pcpks_PCCEXPR_Main.Pr_Set_Skip_Sys;
ELSE
dbg('Tanked Data Not Found..');
l_pccexpr := p_pcdprmnt.ty_pccexpr;
END IF;
l_key_vals :='PRODUCT_CODE'||'>'||p_wrk_pcdprmnt.prmnt_cstms_product.PRODUCT_CODE;
IF NOT Pcpks_PCCEXPR_Main.Fn_Query (p_source,
l_Module,
l_calling_Function,
l_key_vals,
p_QryData_Reqd,
l_pccexpr,
l_wrk_pccexpr,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in Pcpks_PCCEXPR_Main. fn_pre_Query..');
RETURN FALSE;
END IF;

 p_wrk_pcdprmnt.ty_pccexpr := l_wrk_pccexpr;
IF Cspks_Req_Global.Fn_Tanked_Data_Found THEN
dbg('Tanked Data Found..');
Pcpks_PCCEXPR_Main.Pr_Set_Activate_Sys;
END IF;

END IF;
Pr_Skip_Handler('POSTQRY');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Kernel THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_Post_Query (p_source,
p_Full_Data  ,
p_with_lock ,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_CLUSTER THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_Post_Query (p_source,
p_Full_Data  ,
p_with_lock ,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_Post_Query (p_source,
p_Full_Data  ,
p_with_lock ,
p_QryData_Reqd,
p_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in fn_pre_Query..');
RETURN FALSE;
END IF;

END IF;
dbg('Returning from fn_check_mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Query ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Query;
FUNCTION fn_default_and_validate        (p_source            IN VARCHAR2,
p_source_operation  IN     VARCHAR2,
p_action_code       IN VARCHAR2,
p_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_prev_pcdprmnt IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_Check_Amendables  VARCHAR2(1) := 'N';
l_source_operation       VARCHAR2(100) := p_source_operation;
l_Full_data    VARCHAR2(1) := 'N';
l_With_Lock    VARCHAR2(1) := 'Y';
l_Qrydata_Reqd    VARCHAR2(1) := 'N';
l_pk_or_full      VARCHAR2(10) := 'FULL';

l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_prev_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_wrk_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_prev_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_wrk_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_prev_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_wrk_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_prev_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_wrk_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN

dbg('In fn_default_and_validate..');

l_Full_data   := 'Y';
IF NOT Fn_Query(p_source,
l_Full_data,
l_With_Lock,
l_Qrydata_Reqd,
p_pcdprmnt,
p_prev_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Query..');
RETURN FALSE;
END IF;
Pr_Skip_Handler('PREDFLT');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_pre_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_pre_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_KERNEL THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_pre_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_pre_default_and_validate');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Sys THEN
IF NOT Fn_Sys_Default_and_Validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code  ,
p_err_params ) THEN
dbg('Failed in Fn_Sys_Default_and_Validate..');
RETURN FALSE;
END IF;
END IF;

IF p_action_code = Cspks_Req_Handler.p_modify AND p_prev_pcdprmnt.prmnt_cstms_product.Once_Auth = 'Y'THEN
l_Check_Amendables := 'Y';
END IF;

IF p_source = 'FLEXCUBE'  THEN
l_source_operation :='CSCACADD_MODIFY';
END IF;
l_cscacadd := p_pcdprmnt.ty_cscacadd;
l_prev_cscacadd := p_prev_pcdprmnt.ty_cscacadd;
l_wrk_cscacadd := p_wrk_pcdprmnt.ty_cscacadd;
IF NOT Cspks_CSCACADD_Main.fn_default_and_validate (p_source,
l_Module,
l_calling_Function,
l_source_operation,
p_action_code,
l_Check_Amendables,
l_cscacadd,
l_prev_cscacadd,
l_wrk_cscacadd,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACADD_Main.fn_default_and_validate');
RETURN FALSE;
END IF;
p_prev_pcdprmnt.ty_cscacadd:= l_prev_cscacadd;
p_wrk_pcdprmnt.ty_cscacadd:= l_wrk_cscacadd;


IF p_source = 'FLEXCUBE'  THEN
l_source_operation :='CSCACRHM_MODIFY';
END IF;
l_cscacrhm := p_pcdprmnt.ty_cscacrhm;
l_prev_cscacrhm := p_prev_pcdprmnt.ty_cscacrhm;
l_wrk_cscacrhm := p_wrk_pcdprmnt.ty_cscacrhm;
IF NOT Cspks_CSCACRHM_Main.fn_default_and_validate (p_source,
l_Module,
l_calling_Function,
l_source_operation,
p_action_code,
l_Check_Amendables,
l_cscacrhm,
l_prev_cscacrhm,
l_wrk_cscacrhm,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACRHM_Main.fn_default_and_validate');
RETURN FALSE;
END IF;
p_prev_pcdprmnt.ty_cscacrhm:= l_prev_cscacrhm;
p_wrk_pcdprmnt.ty_cscacrhm:= l_wrk_cscacrhm;


IF p_source = 'FLEXCUBE'  THEN
l_source_operation :='MICPRMNT_MODIFY';
END IF;
l_micprmnt := p_pcdprmnt.ty_micprmnt;
l_prev_micprmnt := p_prev_pcdprmnt.ty_micprmnt;
l_wrk_micprmnt := p_wrk_pcdprmnt.ty_micprmnt;
IF NOT Mipks_MICPRMNT_Main.fn_default_and_validate (p_source,
l_Module,
l_calling_Function,
l_source_operation,
p_action_code,
l_Check_Amendables,
l_micprmnt,
l_prev_micprmnt,
l_wrk_micprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Mipks_MICPRMNT_Main.fn_default_and_validate');
RETURN FALSE;
END IF;
p_prev_pcdprmnt.ty_micprmnt:= l_prev_micprmnt;
p_wrk_pcdprmnt.ty_micprmnt:= l_wrk_micprmnt;


IF p_source = 'FLEXCUBE'  THEN
l_source_operation :='PCCEXPR_MODIFY';
END IF;
l_pccexpr := p_pcdprmnt.ty_pccexpr;
l_prev_pccexpr := p_prev_pcdprmnt.ty_pccexpr;
l_wrk_pccexpr := p_wrk_pcdprmnt.ty_pccexpr;
IF NOT Pcpks_PCCEXPR_Main.fn_default_and_validate (p_source,
l_Module,
l_calling_Function,
l_source_operation,
p_action_code,
l_Check_Amendables,
l_pccexpr,
l_prev_pccexpr,
l_wrk_pccexpr,
p_err_code,
p_err_params) THEN
dbg('Failed in Pcpks_PCCEXPR_Main.fn_default_and_validate');
RETURN FALSE;
END IF;
p_prev_pcdprmnt.ty_pccexpr:= l_prev_pccexpr;
p_wrk_pcdprmnt.ty_pccexpr:= l_wrk_pccexpr;


Pr_Skip_Handler('POSTDFLT');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Kernel THEN
IF NOT pcpks_pcdprmnt_Kernel.fn_post_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_CLUSTER THEN
IF NOT pcpks_pcdprmnt_Cluster.fn_post_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.fn_post_default_and_validate (p_source,
p_source_operation,
p_action_code,
p_pcdprmnt,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
RETURN FALSE;
END IF;

END IF;
IF p_action_code = Cspks_Req_Handler.p_Modify THEN
IF NOT fn_check_mandatory(p_source,
p_action_code,
l_pk_or_full,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Query..');
RETURN FALSE;
END IF;
END IF;
dbg('Returning from fn_check_mandatory');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.fn_default_and_validate ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END fn_default_and_validate;
FUNCTION Fn_Upload_Db         (p_source            IN VARCHAR2,
p_action_code       IN     VARCHAR2,
p_post_upl_stat     IN     VARCHAR2,
p_multi_trip_id		IN  VARCHAR2,
p_prev_pcdprmnt     IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_wrk_pcdprmnt      IN OUT  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_calling_function smtb_menu.function_id%TYPE := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_row_id            ROWID;
l_key  VARCHAR2(32767);
l_Fld  VARCHAR2(32767);

l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_prev_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_wrk_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_prev_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_wrk_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_prev_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_wrk_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_prev_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_wrk_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

BEGIN

dbg('In Fn_Upload_Db..');

IF p_Action_Code = Cspks_Req_Handler.p_delete THEN
l_prev_cscacadd := p_prev_pcdprmnt.ty_cscacadd;
l_wrk_cscacadd := p_wrk_pcdprmnt.ty_cscacadd;
IF NOT Cspks_CSCACADD_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_cscacadd,
l_wrk_cscacadd,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACADD_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_cscacadd:= l_wrk_cscacadd;


l_prev_cscacrhm := p_prev_pcdprmnt.ty_cscacrhm;
l_wrk_cscacrhm := p_wrk_pcdprmnt.ty_cscacrhm;
IF NOT Cspks_CSCACRHM_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_cscacrhm,
l_wrk_cscacrhm,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACRHM_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_cscacrhm:= l_wrk_cscacrhm;


l_prev_micprmnt := p_prev_pcdprmnt.ty_micprmnt;
l_wrk_micprmnt := p_wrk_pcdprmnt.ty_micprmnt;
IF NOT Mipks_MICPRMNT_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_micprmnt,
l_wrk_micprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Mipks_MICPRMNT_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_micprmnt:= l_wrk_micprmnt;


l_prev_pccexpr := p_prev_pcdprmnt.ty_pccexpr;
l_wrk_pccexpr := p_wrk_pcdprmnt.ty_pccexpr;
IF NOT Pcpks_PCCEXPR_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_pccexpr,
l_wrk_pccexpr,
p_err_code,
p_err_params) THEN
dbg('Failed in Pcpks_PCCEXPR_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_pccexpr:= l_wrk_pccexpr;


END IF;
Pr_Skip_Handler('PREUPLD');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.Fn_Pre_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.Fn_Pre_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_KERNEL THEN
IF NOT pcpks_pcdprmnt_Kernel.Fn_Pre_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Sys THEN
IF NOT Fn_Sys_Upload_Db (p_source,
p_action_code,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;
END IF;

IF p_Action_Code <> Cspks_Req_Handler.p_delete THEN
l_prev_cscacadd := p_prev_pcdprmnt.ty_cscacadd;
l_wrk_cscacadd := p_wrk_pcdprmnt.ty_cscacadd;
IF NOT Cspks_CSCACADD_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_cscacadd,
l_wrk_cscacadd,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACADD_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_cscacadd:= l_wrk_cscacadd;


l_prev_cscacrhm := p_prev_pcdprmnt.ty_cscacrhm;
l_wrk_cscacrhm := p_wrk_pcdprmnt.ty_cscacrhm;
IF NOT Cspks_CSCACRHM_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_cscacrhm,
l_wrk_cscacrhm,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_CSCACRHM_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_cscacrhm:= l_wrk_cscacrhm;


l_prev_micprmnt := p_prev_pcdprmnt.ty_micprmnt;
l_wrk_micprmnt := p_wrk_pcdprmnt.ty_micprmnt;
IF NOT Mipks_MICPRMNT_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_micprmnt,
l_wrk_micprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Mipks_MICPRMNT_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_micprmnt:= l_wrk_micprmnt;


l_prev_pccexpr := p_prev_pcdprmnt.ty_pccexpr;
l_wrk_pccexpr := p_wrk_pcdprmnt.ty_pccexpr;
IF NOT Pcpks_PCCEXPR_Main.fn_upload_db (p_source,
l_Module,
l_calling_Function,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
l_prev_pccexpr,
l_wrk_pccexpr,
p_err_code,
p_err_params) THEN
dbg('Failed in Pcpks_PCCEXPR_Main.fn_upload_db');
RETURN FALSE;
END IF;
p_wrk_pcdprmnt.ty_pccexpr:= l_wrk_pccexpr;


END IF;
Pr_Skip_Handler('POSTUPLD');
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Kernel THEN
IF NOT pcpks_pcdprmnt_Kernel.Fn_Post_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;

END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Cluster THEN
IF NOT pcpks_pcdprmnt_Cluster.Fn_Post_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;
END IF;
IF NOT pcpks_pcdprmnt_Main.Fn_Skip_Custom THEN
IF NOT pcpks_pcdprmnt_Custom.Fn_Post_Upload_Db (p_source,
p_action_code,
p_post_upl_stat,
p_multi_trip_id,
p_prev_pcdprmnt,
p_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed inFn_Pre_Upload_Db..');
RETURN FALSE;
END IF;

END IF;
dbg('Returning from Fn_Upload_Db');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Upload_Db ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Upload_Db;
FUNCTION Fn_Set_Key_Information (p_source		IN  VARCHAR2,
p_Action_Code       IN     VARCHAR2,
p_pcdprmnt       IN   pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_err_code          IN OUT VARCHAR2,
p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN   IS
l_key_cols        VARCHAR2(32767);
l_key_vals        VARCHAR2(32767);
l_Func_Type       VARCHAR2(32767);
BEGIN

dbg('In Fn_Set_Key_Information ');
l_key_cols := 'PRODUCT_CODE~';
l_key_vals := p_pcdprmnt.prmnt_cstms_product.product_code||'~';
IF NOT Cspks_Req_Utils.Fn_Set_Key_Information(p_source,
p_Action_Code ,
g_Function_Id,
'FCCMAINTENANCE',
'CSTMS_PRODUCT',
l_key_cols,
l_key_vals,
p_err_code,
p_err_params) THEN
dbg('Failed in  Fn_Set_Key_Information..');
RETURN FALSE;
END IF;
IF NOT Cspks_Req_Utils.Fn_Get_Key_Id(g_Function_Id,
'CSTMS_PRODUCT',
l_key_cols,
l_key_vals,
g_Key_Id,
p_err_code,
p_err_params) THEN
dbg('Failed in  Fn_Get_Key_Id..');
RETURN FALSE;
END IF;
dbg('Returning from Fn_Set_Key_Information ');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of pcpks_pcdprmnt_Main.Fn_Set_Key_Information ');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := NULL;
RETURN FALSE;
END Fn_Set_Key_Information;
FUNCTION  Fn_ReBuild_Fc_Ts(
                        p_err_code          IN OUT VARCHAR2,
                        p_err_params        IN OUT VARCHAR2) RETURN BOOLEAN IS
BEGIN

dbg('In Fn_ReBuild_Fc_Ts');
IF NOT  Fn_Build_Fc_Ts(g_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
RETURN FALSE;
END IF;

RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_ReBuild_Fc_Ts');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_ReBuild_Fc_Ts;

FUNCTION Fn_Extract_Custom_Data   (p_source          IN     VARCHAR2,
p_addl_info		IN OUT Cspks_Req_Handler.Ty_Addl_Info,
                        p_err_code        IN OUT VARCHAR2,
                        p_err_params      IN OUT VARCHAR2) RETURN BOOLEAN IS
l_Action_Code VARCHAR2(50) := 'EXTCSTDATA';
l_pcdprmnt     pcpks_pcdprmnt_Main.ty_pcdprmnt;
l_key_id            VARCHAR2(5000):= NULL;
l_rec_key           VARCHAR2(5000):= NULL;
l_key_cols          VARCHAR2(32767);
l_key_vals          VARCHAR2(32767);
BEGIN

dbg('In Fn_Extract_Custom_Data');
IF p_source = 'FLEXCUBE' THEN
IF NOT  fn_build_Fc_type(
p_addl_info,
l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_build_Fc_type');
RETURN FALSE;
END IF;
ELSE
IF NOT  fn_build_Ws_type(
p_addl_info,
l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_build_Ws_type');
RETURN FALSE;
END IF;
END IF;
IF NOT  Fn_Set_Key_Information(p_source,
l_Action_Code,
l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Set_Key_Information');
RETURN FALSE;
END IF;
p_addl_info('MASTER_TABLE') := 'CSTMS_PRODUCT';
p_addl_info('FUNCTION_ID') := g_Function_Id;
p_addl_info('KEY_ID') := g_Key_Id;
p_addl_info('SENT_MOD_NO') := l_pcdprmnt.prmnt_cstms_product.mod_no;
dbg('In Fn_Extract_Custom_Data');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Extract_Custom_Data');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Extract_Custom_Data;

FUNCTION Fn_Get_Custom_Data   (p_source          IN     VARCHAR2,
p_addl_info		IN OUT Cspks_Req_Handler.Ty_Addl_Info,
                        p_err_code        IN OUT VARCHAR2,
                        p_err_params      IN OUT VARCHAR2) RETURN BOOLEAN IS
BEGIN

dbg('In Fn_Get_Custom_Data');
p_addl_info := g_Addl_Info;
dbg('Returning From Fn_Get_Custom_Data');
RETURN TRUE;
EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Get_Custom_Data');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Get_Custom_Data;

FUNCTION Fn_Maint_Log (p_source            IN     VARCHAR2,
                       p_action_code       IN     VARCHAR2,
                        p_pcdprmnt          IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
                        p_prev_pcdprmnt          IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
                        p_wrk_pcdprmnt          IN  pcpks_pcdprmnt_Main.ty_pcdprmnt,
p_Tanking_Status IN VARCHAR2,
                        p_err_code          IN OUT VARCHAR2,
                        p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_calling_function VARCHAR2(50) := 'PCDPRMNT';
l_Module smtb_modules.module_id%TYPE := 'PC';
l_Auth_Stat       VARCHAR2(32767):= NULL;
l_Key_Id         VARCHAR2(32767):= g_Key_Id;
l_Mod_No          NUMBER := 1;
l_Summary_Rec_Found BOOLEAN := TRUE;
l_Record_Master   Sttbs_Record_Master%ROWTYPE;
l_summary_rec     CSTM_PRODUCT%ROWTYPE;
l_Blk             VARCHAR2(32767):= NULL;
l_Fld             VARCHAR2(32767):= NULL;
l_Dbt             VARCHAR2(32767):= NULL;
l_Dbc             VARCHAR2(32767):= NULL;
l_rec_Action      VARCHAR2(32767):= 'M';
l_Dtl_Key          VARCHAR2(32767):= NULL;
l_Prev_Count      NUMBER := 0;
l_Wrk_Count      NUMBER := 0;
l_Count          NUMBER := 0;
l_Log_Count       NUMBER := 0;
l_Fld_Count       NUMBER := 0;
l_Matched_Rec     NUMBER := 0;
l_rec_found       BOOLEAN:= FALSE;
l_prev_found       BOOLEAN:= FALSE;
l_wrk_found       BOOLEAN:= FALSE;
l_rec_modified    BOOLEAN:= FALSE;
l_Record_log      sttbs_record_log%ROWTYPE;
l_Field_log       sttbs_Field_log%ROWTYPE;
l_Tb_Field_Log    Cspks_Req_Utils.Ty_Tb_Fld_Log;
l_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_Dmy_cscacadd    Cspks_CSCACADD_Main.ty_cscacadd;
l_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_Dmy_cscacrhm    Cspks_CSCACRHM_Main.ty_cscacrhm;
l_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_Dmy_micprmnt    Mipks_MICPRMNT_Main.ty_micprmnt;
l_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;
l_Dmy_pccexpr    Pcpks_PCCEXPR_Main.ty_pccexpr;

PROCEDURE Pr_Log_Change(p_Dbc     IN VARCHAR2,
                        p_Action  IN VARCHAR2,
                        p_Old_Val IN VARCHAR2,
                        p_New_Val IN VARCHAR2) IS
BEGIN
IF NVL(p_Old_Val,'@') <> NVL(p_New_Val,'@') THEN
 l_Log_Count := l_Log_Count +1;
 l_Fld_Count := l_Fld_Count +1;
l_Field_log.Detail_Key := l_Dtl_Key;
l_Field_log.Block_Name := l_Blk;
l_Field_log.Field_Name := p_Dbc;
l_Field_log.Table_Name := l_Dbt;
l_Field_log.Item_no := l_Fld_Count;
l_Field_log.Record_Stat := p_Action;
l_Field_log.Old_Value := p_Old_Val;
l_Field_log.New_Value := p_New_Val;
l_Tb_Field_Log(l_Log_Count) := l_Field_log;
END IF;
END Pr_Log_Change;

BEGIN

dbg('In Fn_Maint_Log');

IF  p_action_code IN (Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen,Cspks_Req_Handler.p_Auth,Cspks_Req_Handler.p_Delete,Cspks_Req_Handler.p_Version_Delete) THEN
dbg('Doing Maintenance Log ..');
IF l_Key_Id IS NOT NULL THEN
IF p_action_code IN( Cspks_Req_Handler.p_auth,Cspks_Req_Handler.p_Delete,Cspks_Req_Handler.p_Version_Delete) THEN
IF p_pcdprmnt.prmnt_cstms_product.mod_no IS NOT NULL THEN
l_mod_no           := p_pcdprmnt.prmnt_cstms_product.mod_no;
ELSE
l_mod_no           := p_wrk_pcdprmnt.prmnt_cstms_product.mod_no;
END IF;
ELSE
l_mod_no           := p_wrk_pcdprmnt.prmnt_cstms_product.mod_no;
END IF;
  l_Auth_Stat := NVL(p_Wrk_pcdprmnt.prmnt_cstms_product.Auth_Stat,'U') ;
IF p_action_code IN(Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify ) THEN
l_Summary_Rec := p_wrk_pcdprmnt.prmnt_cstms_product;
IF p_Tanking_Status = 'T' THEN
Dbg('Rolling Back For Modification..');
ROLLBACK TO Sp_Primary_Request;
END IF;
IF l_Summary_Rec_Found THEN
Dbg('Summary Record Found..');
l_Record_Master.Key_Id := g_Key_Id;
l_Record_Master.CHAR_FLD_1 := l_Summary_Rec.PRODUCT_CODE;
l_Record_Master.CHAR_FLD_2 := l_Summary_Rec.PRODUCT_DESCRIPTION;
l_Record_Master.DATE_FLD_1 := l_Summary_Rec.PRODUCT_END_DATE;
l_Record_Master.CHAR_FLD_3 := l_Summary_Rec.PRODUCT_GROUP;
l_Record_Master.DATE_FLD_2 := l_Summary_Rec.PRODUCT_START_DATE;
l_Record_Master.CHAR_FLD_4 := l_Summary_Rec.PRODUCT_TYPE;
l_Record_Master.CHAR_FLD_5 := l_Summary_Rec.MODULE;
END IF;
ELSE
IF p_Tanking_Status = 'T' THEN
Dbg('Rolling Back For Other Actions..');
ROLLBACK TO Sp_Primary_Request;
END IF;
END IF;
IF NOT Cspks_Req_Utils.Fn_Maint_Log(p_source,
p_Action_Code,
g_Function_Id,
'CSTMS_PRODUCT',
l_Key_Id,
l_mod_no,
l_Auth_Stat,
p_Tanking_Status ,
l_Record_Master ,
p_err_code,
p_err_params) THEN
dbg('Failed in   Cspks_Req_Utils.Fn_Maint_Log..');
RETURN FALSE;
END IF;
IF Cspks_Req_Utils.Fn_Field_Log_Reqd(p_Action_Code,g_Function_Id) THEN
l_Field_log.Key_id := l_Key_Id;
l_Field_log.Mod_No := l_mod_no;
l_Field_log.Function_id := g_Function_Id;

l_Dbt := 'CSTM_PRODUCT';

l_blk := 'CSTMS_PRODUCT';
l_rec_modified := FALSE;
l_prev_found := FALSE;
l_wrk_found := FALSE;

IF p_prev_pcdprmnt.prmnt_cstms_product.product_code IS NOT NULL THEN
dbg('Record has been Sent..');
l_prev_found := TRUE;
END IF;
IF p_wrk_pcdprmnt.prmnt_cstms_product.product_code IS NOT NULL THEN
dbg('Record has been Sent..');
l_wrk_found := TRUE;
END IF;
IF l_prev_found   THEN
l_Dtl_key := '~CSTM_PRODUCT~'||p_prev_pcdprmnt.prmnt_cstms_product.product_code||'~';
ELSIF l_wrk_found   THEN
l_Dtl_key := '~CSTM_PRODUCT~'||p_wrk_pcdprmnt.prmnt_cstms_product.product_code||'~';
END IF;
IF l_wrk_found  OR l_prev_found THEN
IF l_wrk_found  AND l_prev_found THEN
l_rec_action := 'M';
ELSIF l_wrk_found  AND ( NOT l_prev_found) THEN
l_rec_action := 'N';
ELSIF (NOT l_wrk_found)  AND l_prev_found THEN
l_rec_action := 'D';
END IF;
Pr_Log_Change('PRODUCT_CODE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_code,p_wrk_pcdprmnt.prmnt_cstms_product.product_code);
Pr_Log_Change('PRODUCT_DESCRIPTION',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_description,p_wrk_pcdprmnt.prmnt_cstms_product.product_description);
Pr_Log_Change('PRODUCT_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_type,p_wrk_pcdprmnt.prmnt_cstms_product.product_type);
Pr_Log_Change('PRODUCT_SLOGAN',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_slogan,p_wrk_pcdprmnt.prmnt_cstms_product.product_slogan);
Pr_Log_Change('PRODUCT_GROUP',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_group,p_wrk_pcdprmnt.prmnt_cstms_product.product_group);
Pr_Log_Change('PRODUCT_START_DATE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_start_date,p_wrk_pcdprmnt.prmnt_cstms_product.product_start_date);
Pr_Log_Change('PRODUCT_END_DATE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_end_date,p_wrk_pcdprmnt.prmnt_cstms_product.product_end_date);
Pr_Log_Change('PRODUCT_REMARKS',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.product_remarks,p_wrk_pcdprmnt.prmnt_cstms_product.product_remarks);
Pr_Log_Change('NORMAL_RATE_VARIANCE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.normal_rate_variance,p_wrk_pcdprmnt.prmnt_cstms_product.normal_rate_variance);
Pr_Log_Change('MAXIMUM_RATE_VARIANCE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.maximum_rate_variance,p_wrk_pcdprmnt.prmnt_cstms_product.maximum_rate_variance);
Pr_Log_Change('RATE_CODE_PREFERRED',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.rate_code_preferred,p_wrk_pcdprmnt.prmnt_cstms_product.rate_code_preferred);
Pr_Log_Change('RATE_TYPE_PREFERRED',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.rate_type_preferred,p_wrk_pcdprmnt.prmnt_cstms_product.rate_type_preferred);
Pr_Log_Change('MODULE',l_rec_action,p_prev_pcdprmnt.prmnt_cstms_product.module,p_wrk_pcdprmnt.prmnt_cstms_product.module);
END IF;

dbg('Calling Cspks_CSCACADD_Main.Fn_Maint_Log..');
IF NOT Cspks_CSCACADD_Main.Fn_Maint_Log(p_source,
p_Action_Code,
l_Module,
l_calling_Function,
l_Key_Id,
l_Mod_No,
p_Prev_pcdprmnt.ty_cscacadd,
p_Wrk_pcdprmnt.ty_cscacadd,
l_Tb_Field_Log,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACADD_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
dbg('Calling Cspks_CSCACRHM_Main.Fn_Maint_Log..');
IF NOT Cspks_CSCACRHM_Main.Fn_Maint_Log(p_source,
p_Action_Code,
l_Module,
l_calling_Function,
l_Key_Id,
l_Mod_No,
p_Prev_pcdprmnt.ty_cscacrhm,
p_Wrk_pcdprmnt.ty_cscacrhm,
l_Tb_Field_Log,
p_err_code,
p_err_params)  THEN
dbg('Failed in Cspks_CSCACRHM_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
dbg('Calling Mipks_MICPRMNT_Main.Fn_Maint_Log..');
IF NOT Mipks_MICPRMNT_Main.Fn_Maint_Log(p_source,
p_Action_Code,
l_Module,
l_calling_Function,
l_Key_Id,
l_Mod_No,
p_Prev_pcdprmnt.ty_micprmnt,
p_Wrk_pcdprmnt.ty_micprmnt,
l_Tb_Field_Log,
p_err_code,
p_err_params)  THEN
dbg('Failed in Mipks_MICPRMNT_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;
dbg('Calling Pcpks_PCCEXPR_Main.Fn_Maint_Log..');
IF NOT Pcpks_PCCEXPR_Main.Fn_Maint_Log(p_source,
p_Action_Code,
l_Module,
l_calling_Function,
l_Key_Id,
l_Mod_No,
p_Prev_pcdprmnt.ty_pccexpr,
p_Wrk_pcdprmnt.ty_pccexpr,
l_Tb_Field_Log,
p_err_code,
p_err_params)  THEN
dbg('Failed in Pcpks_PCCEXPR_Main.Fn_Build_Fc_Type..');
RETURN FALSE;
END IF;

l_Dbt := 'PCTM_PRODUCT_PREFERENCE';

l_blk := 'PCTMS_PRODUCT_PREFERENCE';
l_rec_modified := FALSE;
l_prev_found := FALSE;
l_wrk_found := FALSE;

IF p_prev_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Record has been Sent..');
l_prev_found := TRUE;
END IF;
IF p_wrk_pcdprmnt.prmnt_product_preference.product_code IS NOT NULL THEN
dbg('Record has been Sent..');
l_wrk_found := TRUE;
END IF;
IF l_prev_found   THEN
l_Dtl_key := '~PCTM_PRODUCT_PREFERENCE~'||p_prev_pcdprmnt.prmnt_product_preference.product_code||'~';
ELSIF l_wrk_found   THEN
l_Dtl_key := '~PCTM_PRODUCT_PREFERENCE~'||p_wrk_pcdprmnt.prmnt_product_preference.product_code||'~';
END IF;
IF l_wrk_found  OR l_prev_found THEN
IF l_wrk_found  AND l_prev_found THEN
l_rec_action := 'M';
ELSIF l_wrk_found  AND ( NOT l_prev_found) THEN
l_rec_action := 'N';
ELSIF (NOT l_wrk_found)  AND l_prev_found THEN
l_rec_action := 'D';
END IF;
Pr_Log_Change('COLLECTION_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.collection_type,p_wrk_pcdprmnt.prmnt_product_preference.collection_type);
Pr_Log_Change('RFD_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rfd_type,p_wrk_pcdprmnt.prmnt_product_preference.rfd_type);
Pr_Log_Change('TRANSFER_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.transfer_type,p_wrk_pcdprmnt.prmnt_product_preference.transfer_type);
Pr_Log_Change('CLG_VOSTRO_BRN',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.clg_vostro_brn,p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_brn);
Pr_Log_Change('CLG_VOSTRO_ACC',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.clg_vostro_acc,p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_acc);
Pr_Log_Change('CLG_VOSTRO_CCY',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.clg_vostro_ccy,p_wrk_pcdprmnt.prmnt_product_preference.clg_vostro_ccy);
Pr_Log_Change('NETWORK_ID',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.network_id,p_wrk_pcdprmnt.prmnt_product_preference.network_id);
Pr_Log_Change('MIN_DIVISIBLE_AMT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.min_divisible_amt,p_wrk_pcdprmnt.prmnt_product_preference.min_divisible_amt);
Pr_Log_Change('MIN_TXN_AMT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.min_txn_amt,p_wrk_pcdprmnt.prmnt_product_preference.min_txn_amt);
Pr_Log_Change('CHARGE_MODE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_mode,p_wrk_pcdprmnt.prmnt_product_preference.charge_mode);
Pr_Log_Change('INVOICE_SPLIT_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.invoice_split_reqd,p_wrk_pcdprmnt.prmnt_product_preference.invoice_split_reqd);
Pr_Log_Change('MAX_TXN_AMT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.max_txn_amt,p_wrk_pcdprmnt.prmnt_product_preference.max_txn_amt);
Pr_Log_Change('CUTOFF_HR',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cutoff_hr,p_wrk_pcdprmnt.prmnt_product_preference.cutoff_hr);
Pr_Log_Change('CUTOFF_MIN',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cutoff_min,p_wrk_pcdprmnt.prmnt_product_preference.cutoff_min);
Pr_Log_Change('PRIORITY',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.priority,p_wrk_pcdprmnt.prmnt_product_preference.priority);
Pr_Log_Change('CUST_ENT_DAY_PRECUTOF',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof,p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_day_precutof);
Pr_Log_Change('CUST_ENT_VAL_DAY_PRECUTOF',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof,p_wrk_pcdprmnt.prmnt_product_preference.cust_ent_val_day_precutof);
Pr_Log_Change('CPTY_ENT_DAY_PRECUTOF',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof,p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_day_precutof);
Pr_Log_Change('CPTY_ENT_VAL_DAY_PRECUTOF',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof,p_wrk_pcdprmnt.prmnt_product_preference.cpty_ent_val_day_precutof);
Pr_Log_Change('OVERRIDE_OVERDRAFT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.override_overdraft,p_wrk_pcdprmnt.prmnt_product_preference.override_overdraft);
Pr_Log_Change('DISPATCH_ACCOUNTING',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.dispatch_accounting,p_wrk_pcdprmnt.prmnt_product_preference.dispatch_accounting);
Pr_Log_Change('REFERRAL_REQUIRED',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.referral_required,p_wrk_pcdprmnt.prmnt_product_preference.referral_required);
Pr_Log_Change('DISPATCH',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.dispatch,p_wrk_pcdprmnt.prmnt_product_preference.dispatch);
Pr_Log_Change('AUTO_DISPATCH',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.auto_dispatch,p_wrk_pcdprmnt.prmnt_product_preference.auto_dispatch);
Pr_Log_Change('OUT_PMT_WORKFLOW',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.out_pmt_workflow,p_wrk_pcdprmnt.prmnt_product_preference.out_pmt_workflow);
Pr_Log_Change('DISPATCH_MEDIA',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.dispatch_media,p_wrk_pcdprmnt.prmnt_product_preference.dispatch_media);
Pr_Log_Change('DISPATCH_DAY_PRECUTOF',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.dispatch_day_precutof,p_wrk_pcdprmnt.prmnt_product_preference.dispatch_day_precutof);
Pr_Log_Change('AUTO_RESPONSE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.auto_response,p_wrk_pcdprmnt.prmnt_product_preference.auto_response);
Pr_Log_Change('ASCII_HANDOFF_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd,p_wrk_pcdprmnt.prmnt_product_preference.ascii_handoff_reqd);
Pr_Log_Change('COLLECTION_STMT_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.collection_stmt_reqd,p_wrk_pcdprmnt.prmnt_product_preference.collection_stmt_reqd);
Pr_Log_Change('RESPONSE_ADVICE_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.response_advice_reqd,p_wrk_pcdprmnt.prmnt_product_preference.response_advice_reqd);
Pr_Log_Change('PRE_COT_RESPONSE_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.pre_cot_response_days,p_wrk_pcdprmnt.prmnt_product_preference.pre_cot_response_days);
Pr_Log_Change('RESPONSE_ADVICE_BASIS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.response_advice_basis,p_wrk_pcdprmnt.prmnt_product_preference.response_advice_basis);
Pr_Log_Change('MAX_INT_AMT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.max_int_amt,p_wrk_pcdprmnt.prmnt_product_preference.max_int_amt);
Pr_Log_Change('MAX_SPLIT_COUNT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.max_split_count,p_wrk_pcdprmnt.prmnt_product_preference.max_split_count);
Pr_Log_Change('REJ_AC_TYPE_BEFORE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_ac_type_before,p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_before);
Pr_Log_Change('REJ_PAYMENT_BRN_BEFORE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_payment_brn_before,p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_before);
Pr_Log_Change('REJ_ACCT_BEFORE_RESP_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days,p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_before_resp_days);
Pr_Log_Change('REJ_PAYMENT_CCY_BEFORE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before,p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_before);
Pr_Log_Change('BACK_VALUE_LIMIT_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.back_value_limit_days,p_wrk_pcdprmnt.prmnt_product_preference.back_value_limit_days);
Pr_Log_Change('FUTURE_VALUE_LIMIT_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.future_value_limit_days,p_wrk_pcdprmnt.prmnt_product_preference.future_value_limit_days);
Pr_Log_Change('MOVE_BVT_ACTIVATION_DATE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.move_bvt_activation_date,p_wrk_pcdprmnt.prmnt_product_preference.move_bvt_activation_date);
Pr_Log_Change('DEFAULT_ACTIVATION_DATE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.default_activation_date,p_wrk_pcdprmnt.prmnt_product_preference.default_activation_date);
Pr_Log_Change('PROCESS_REJ_AFTER_RESP_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days,p_wrk_pcdprmnt.prmnt_product_preference.process_rej_after_resp_days);
Pr_Log_Change('REJ_VERIFY_FUNDS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_verify_funds,p_wrk_pcdprmnt.prmnt_product_preference.rej_verify_funds);
Pr_Log_Change('REJ_AC_TYPE_AFTER',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_ac_type_after,p_wrk_pcdprmnt.prmnt_product_preference.rej_ac_type_after);
Pr_Log_Change('REJ_PAYMENT_BRN_AFTER',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_payment_brn_after,p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_brn_after);
Pr_Log_Change('REJ_ACCT_AFTER_RESP_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days,p_wrk_pcdprmnt.prmnt_product_preference.rej_acct_after_resp_days);
Pr_Log_Change('REJ_PAYMENT_CCY_AFTER',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after,p_wrk_pcdprmnt.prmnt_product_preference.rej_payment_ccy_after);
Pr_Log_Change('ALLOW_POST_COT_TXN',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.allow_post_cot_txn,p_wrk_pcdprmnt.prmnt_product_preference.allow_post_cot_txn);
Pr_Log_Change('AUTO_EXCH_RATE_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd,p_wrk_pcdprmnt.prmnt_product_preference.auto_exch_rate_reqd);
Pr_Log_Change('EX_RATE_CODE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.ex_rate_code,p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_code);
Pr_Log_Change('EX_RATE_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.ex_rate_type,p_wrk_pcdprmnt.prmnt_product_preference.ex_rate_type);
Pr_Log_Change('REDISPATCH_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.redispatch_reqd,p_wrk_pcdprmnt.prmnt_product_preference.redispatch_reqd);
Pr_Log_Change('AUTO_REDISPATCH',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.auto_redispatch,p_wrk_pcdprmnt.prmnt_product_preference.auto_redispatch);
Pr_Log_Change('REDISPATCH_COUNT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.redispatch_count,p_wrk_pcdprmnt.prmnt_product_preference.redispatch_count);
Pr_Log_Change('REDISPATCH_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.redispatch_days,p_wrk_pcdprmnt.prmnt_product_preference.redispatch_days);
Pr_Log_Change('RECALL_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.recall_days,p_wrk_pcdprmnt.prmnt_product_preference.recall_days);
Pr_Log_Change('RECALL_DAYS_BASIS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.recall_days_basis,p_wrk_pcdprmnt.prmnt_product_preference.recall_days_basis);
Pr_Log_Change('AGREEMENT_ID_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.agreement_id_reqd,p_wrk_pcdprmnt.prmnt_product_preference.agreement_id_reqd);
Pr_Log_Change('CREDITOR_ID_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.creditor_id_reqd,p_wrk_pcdprmnt.prmnt_product_preference.creditor_id_reqd);
Pr_Log_Change('CHARGE_WAIVER',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_waiver,p_wrk_pcdprmnt.prmnt_product_preference.charge_waiver);
Pr_Log_Change('ALLOW_THIRD_PARTY_CHG',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.allow_third_party_chg,p_wrk_pcdprmnt.prmnt_product_preference.allow_third_party_chg);
Pr_Log_Change('CHARGE_CUST_STATISTICS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_cust_statistics,p_wrk_pcdprmnt.prmnt_product_preference.charge_cust_statistics);
Pr_Log_Change('CHARGE_AC_STATISTICS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_ac_statistics,p_wrk_pcdprmnt.prmnt_product_preference.charge_ac_statistics);
Pr_Log_Change('COLLECT_VOLUME_STATISTICS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.collect_volume_statistics,p_wrk_pcdprmnt.prmnt_product_preference.collect_volume_statistics);
Pr_Log_Change('CUST_ENTRY_CONSOL_REQD',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd,p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_reqd);
Pr_Log_Change('CUST_ENTRY_CONSOL_LMT',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt,p_wrk_pcdprmnt.prmnt_product_preference.cust_entry_consol_lmt);
Pr_Log_Change('DISP_FILE_NAME',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.disp_file_name,p_wrk_pcdprmnt.prmnt_product_preference.disp_file_name);
Pr_Log_Change('NO_OF_REC',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.no_of_rec,p_wrk_pcdprmnt.prmnt_product_preference.no_of_rec);
Pr_Log_Change('REV_SETTLE_GL',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.rev_settle_gl,p_wrk_pcdprmnt.prmnt_product_preference.rev_settle_gl);
Pr_Log_Change('RESPONSE_DAYS_BASIS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.response_days_basis,p_wrk_pcdprmnt.prmnt_product_preference.response_days_basis);
Pr_Log_Change('CLG_CCY',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.clg_ccy,p_wrk_pcdprmnt.prmnt_product_preference.clg_ccy);
Pr_Log_Change('CHARGE_CATEGORY',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_category,p_wrk_pcdprmnt.prmnt_product_preference.charge_category);
Pr_Log_Change('CCY_CAL',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.ccy_cal,p_wrk_pcdprmnt.prmnt_product_preference.ccy_cal);
Pr_Log_Change('PYMT_REJT_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.pymt_rejt_days,p_wrk_pcdprmnt.prmnt_product_preference.pymt_rejt_days);
Pr_Log_Change('SERV_LEVEL_CODE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.serv_level_code,p_wrk_pcdprmnt.prmnt_product_preference.serv_level_code);
Pr_Log_Change('CHARGE_BEARER',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.charge_bearer,p_wrk_pcdprmnt.prmnt_product_preference.charge_bearer);
Pr_Log_Change('EARLY_COLL_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.early_coll_days,p_wrk_pcdprmnt.prmnt_product_preference.early_coll_days);
Pr_Log_Change('FIRST_COLL_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.first_coll_days,p_wrk_pcdprmnt.prmnt_product_preference.first_coll_days);
Pr_Log_Change('RECUR_COLL_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.recur_coll_days,p_wrk_pcdprmnt.prmnt_product_preference.recur_coll_days);
Pr_Log_Change('FIRST_COLL_DISP_DAYS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.first_coll_disp_days,p_wrk_pcdprmnt.prmnt_product_preference.first_coll_disp_days);
Pr_Log_Change('RECALL_DATE_BASIS',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.recall_date_basis,p_wrk_pcdprmnt.prmnt_product_preference.recall_date_basis);
Pr_Log_Change('PAYMENT_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.payment_type,p_wrk_pcdprmnt.prmnt_product_preference.payment_type);
Pr_Log_Change('CLEARING_MODE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.clearing_mode,p_wrk_pcdprmnt.prmnt_product_preference.clearing_mode);
Pr_Log_Change('PRODUCT_CODE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.product_code,p_wrk_pcdprmnt.prmnt_product_preference.product_code);
Pr_Log_Change('PRODUCT_TYPE',l_rec_action,p_prev_pcdprmnt.prmnt_product_preference.product_type,p_wrk_pcdprmnt.prmnt_product_preference.product_type);
END IF;


l_Dbt := 'PCTM_PRODUCT_BANKS';
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_Prev_count      := p_prev_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_Wrk_count > 0 THEN
FOR l_index IN 1..l_wrk_count  LOOP
l_Dtl_key := '~PCTM_PRODUCT_BANKS~'||p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code||'~'||p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode||'~';
l_rec_found := FALSE;
l_rec_modified := FALSE;
IF l_Prev_count > 0 THEN
FOR l_index1 IN 1..l_Prev_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
l_Matched_Rec := l_index1;
Pr_Log_Change('PRODUCT_CODE','M',p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index1).product_code,p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code);
Pr_Log_Change('BANKCODE','M',p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode);

END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('New Record Found..');
Pr_Log_Change('PRODUCT_CODE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code);
Pr_Log_Change('BANKCODE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode);
END IF;
END LOOP;
END IF;
l_Prev_count      := p_prev_pcdprmnt.prmnt_pctms_product_banks.COUNT;
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_banks.COUNT;
IF l_Prev_count > 0 THEN
FOR l_index IN 1..l_Prev_count  LOOP
l_rec_found := FALSE;
l_rec_modified := FALSE;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
IF (NVL(p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_banks(l_index1).bankcode,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
EXIT;

END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('Record Deleted..');
l_Dtl_key := '~PCTM_PRODUCT_BANKS~'||p_Prev_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code||'~'||p_Prev_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode||'~';
Pr_Log_Change('PRODUCT_CODE','D',p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index).product_code,NULL);
Pr_Log_Change('BANKCODE','D',p_prev_pcdprmnt.prmnt_pctms_product_banks(l_index).bankcode,NULL);
END IF;
END LOOP;
END IF;

l_Dbt := 'PCTM_PRODUCT_ACCROLE';
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_Prev_count      := p_prev_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_Wrk_count > 0 THEN
FOR l_index IN 1..l_wrk_count  LOOP
l_Dtl_key := '~PCTM_PRODUCT_ACCROLE~'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code||'~'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||'~'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||'~'||p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status||'~';
l_rec_found := FALSE;
l_rec_modified := FALSE;
IF l_Prev_count > 0 THEN
FOR l_index1 IN 1..l_Prev_count  LOOP
IF (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,'@')) AND (NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
l_Matched_Rec := l_index1;
Pr_Log_Change('PRODUCT_CODE','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).product_code,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code);
Pr_Log_Change('BANKCODE','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode);
Pr_Log_Change('ACCOUNTING_ROLE','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role);
Pr_Log_Change('STATUS','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status);
Pr_Log_Change('ROLE_TYPE','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).role_type,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type);
Pr_Log_Change('ACCOUNTING_HEAD','M',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_head,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head);

END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('New Record Found..');
Pr_Log_Change('PRODUCT_CODE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code);
Pr_Log_Change('BANKCODE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode);
Pr_Log_Change('ACCOUNTING_ROLE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role);
Pr_Log_Change('STATUS','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).status);
Pr_Log_Change('ROLE_TYPE','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type);
Pr_Log_Change('ACCOUNTING_HEAD','N',NULL,p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head);
END IF;
END LOOP;
END IF;
l_Prev_count      := p_prev_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
l_wrk_count  := p_wrk_pcdprmnt.prmnt_pctms_product_accrole.COUNT;
IF l_Prev_count > 0 THEN
FOR l_index IN 1..l_Prev_count  LOOP
l_rec_found := FALSE;
l_rec_modified := FALSE;
IF l_wrk_count > 0 THEN
FOR l_index1 IN 1..l_wrk_count  LOOP
IF (NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).bankcode,'@')) AND (NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).accounting_role,'@')) AND (NVL(p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,'@')=  NVL(p_wrk_pcdprmnt.prmnt_pctms_product_accrole(l_index1).status,'@')) THEN
dbg('Record Found..');
l_rec_found := TRUE;
EXIT;

END IF;
END LOOP;
END IF;
IF NOT l_rec_found THEN
dbg('Record Deleted..');
l_Dtl_key := '~PCTM_PRODUCT_ACCROLE~'||p_Prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code||'~'||p_Prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode||'~'||p_Prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role||'~'||p_Prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).status||'~';
Pr_Log_Change('PRODUCT_CODE','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).product_code,NULL);
Pr_Log_Change('BANKCODE','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).bankcode,NULL);
Pr_Log_Change('ACCOUNTING_ROLE','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_role,NULL);
Pr_Log_Change('STATUS','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).status,NULL);
Pr_Log_Change('ROLE_TYPE','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).role_type,NULL);
Pr_Log_Change('ACCOUNTING_HEAD','D',p_prev_pcdprmnt.prmnt_pctms_product_accrole(l_index).accounting_head,NULL);
END IF;
END LOOP;
END IF;

l_count      := l_Tb_Field_Log.COUNT;
IF l_count   > 0 THEN
dbg('Inserting into Field Log..');
BEGIN
FORALL l_index IN  1..l_count
INSERT INTO STTBS_FIELD_LOG
VALUES l_Tb_Field_Log(l_index);
EXCEPTION
WHEN OTHERS THEN
dbg('Failed in Insert into Field Log..');
dbg(SQLERRM);
p_err_code    := 'ST-UPLD-001';
p_err_params  := '@STTBS_FIELD_LOG';
END;
END IF;

END IF;
END IF;
END IF;

dbg('Returning Success From Fn_Maint_Log..');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Maint_Log ..');
debug.pr_debug('**',SQLERRM);
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Maint_Log;

FUNCTION Fn_Main       (p_source            IN     VARCHAR2,
                        p_source_operation  IN     VARCHAR2,
                        p_action_code       IN     VARCHAR2,
                        p_multi_trip_id     IN  OUT VARCHAR2,
                        p_pcdprmnt          IN OUT pcpks_pcdprmnt_Main.ty_pcdprmnt,
                        p_status            IN OUT VARCHAR2 ,
                        p_err_code          IN OUT VARCHAR2,
                        p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

E_Failure_Exception     EXCEPTION;
E_Override_Exception    EXCEPTION;
l_Resultant_Error_Type  VARCHAR2(32767):= 'I';
l_post_upl_stat         VARCHAR2(1) :='A';
l_prev_Auth_stat        VARCHAR2(1) :='U';
l_wrk_pcdprmnt     pcpks_pcdprmnt_Main.ty_pcdprmnt;
l_prev_pcdprmnt    pcpks_pcdprmnt_Main.ty_pcdprmnt;
l_dmy_pcdprmnt    pcpks_pcdprmnt_Main.ty_pcdprmnt;
l_pk_or_full    VARCHAR2(5) :='PK';
l_module    smtb_modules.module_id%TYPE := 'PC';
l_Full_data    VARCHAR2(1) := 'Y';
l_With_Lock    VARCHAR2(1) := 'N';
l_Qrydata_Reqd    VARCHAR2(1) := 'Y';
l_Count         NUMBER;
l_Action_Code       VARCHAR2(100):= p_Action_Code;
l_Sent_Mod_No                NUMBER;
l_Tanking_Status                VARCHAR2(1) := 'N';

BEGIN

dbg('In Fn_Main');

SAVEPOINT sp_main;
IF NOT Cspks_Req_Global.Fn_UnTanking THEN
SAVEPOINT Sp_Primary_Request;
END IF;
p_status := 'S';
g_Original_Action := p_Action_Code;
g_Action_Code := p_Action_Code;
g_pcdprmnt := p_pcdprmnt;
l_wrk_pcdprmnt := p_pcdprmnt;

IF NOT fn_check_mandatory(p_source,
p_Action_Code,
l_pk_or_full,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_check_mandatory..');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;

IF NOT  Fn_Set_Key_Information(p_source,
p_Action_Code,
p_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_main');
RAISE e_Failure_Exception;
END IF;
l_Sent_Mod_No := l_wrk_pcdprmnt.prmnt_cstms_product.Mod_No;
IF NOT Cspks_Req_Utils.Fn_Process_Tanked_Entries(p_source,
l_action_code,
g_Function_Id,
g_Key_Id,
l_Sent_Mod_No,
l_action_code,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Process_Tanked_Entries..');
RAISE E_Failure_Exception;
END IF;
g_Action_Code := l_action_code;

IF p_Action_Code = Cspks_Req_Handler.p_query THEN
IF NOT Fn_Query(p_source,
l_Full_data,
l_with_lock,
l_Qrydata_Reqd,
p_pcdprmnt,
l_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Query..');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;
ELSE
IF NOT fn_default_and_validate (p_source,
p_source_operation,
l_action_code,
p_pcdprmnt,
l_prev_pcdprmnt,
l_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in fn_default_and_validate');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;

-- Get Resultant Error Type
l_Resultant_Error_Type := Cspks_Req_Utils.Fn_Get_Resultant_Error_Type;
IF l_Resultant_Error_Type <> 'E' THEN
IF NOT Fn_Upload_Db (p_source,
l_Action_Code,
l_post_upl_stat,
p_multi_trip_id,
l_prev_pcdprmnt,
l_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Upload_Db..');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;
IF  l_Action_Code IN (Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen) THEN
l_Prev_Auth_Stat := NVL(l_prev_pcdprmnt.prmnt_cstms_product.auth_stat,'A') ;
--Get Upload Status
IF NOT Cspks_Req_Utils.Fn_Get_Auto_Auth_Status (p_source,
l_module,
g_Function_Id,
l_Action_Code,
l_Prev_Auth_Stat,
p_multi_trip_id,
l_post_upl_stat,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_Req_Utils.Fn_Get_Auto_Auth_Status.');
pr_log_error(p_source,p_err_code,p_err_params);
RAISE E_Failure_Exception;
END IF;

IF l_post_upl_stat NOT IN ('A','U','O') THEN
dbg('Cannot Proceed Further..');
RAISE E_Failure_Exception;
ELSE
IF l_post_upl_stat = 'A'THEN
IF NOT Fn_Upload_Db (p_source,
Cspks_Req_Handler.p_auth,
l_post_upl_stat,
p_multi_trip_id,
l_prev_pcdprmnt,
l_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Upload_Db..');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;
END IF;
END IF;
END IF;
--Get Upload Status
IF NOT Cspks_Req_Utils.Fn_Get_Upload_Status (p_source,
l_module,
g_Function_Id,
l_Action_Code,
p_multi_trip_id,
l_post_upl_stat,
p_err_code,
p_err_params) THEN
dbg('Failed in Cspks_Req_Utils.Fn_Get_Upload_Status.');
pr_log_error(p_source,p_err_code,p_err_params);
RAISE E_Failure_Exception;
END IF;

IF l_post_upl_stat IN ('A','U') THEN
dbg('Success Case...');
IF l_Action_Code IN (Cspks_Req_Handler.p_New,Cspks_Req_Handler.p_Modify,Cspks_Req_Handler.p_Auth,Cspks_Req_Handler.p_Close,Cspks_Req_Handler.p_Reopen,Cspks_Req_Handler.p_Query,Cspks_Req_Handler.p_version_delete ) THEN
IF NOT Fn_Query(p_source,
l_Full_data,
l_with_lock,
l_Qrydata_Reqd,
l_wrk_pcdprmnt,
l_wrk_pcdprmnt,
p_err_code,
p_err_params) THEN
dbg('Failed in Fn_Query..');
pr_log_error(p_source,p_err_code, p_err_params);
RAISE E_Failure_Exception;
END IF;
END IF;
ELSIF l_post_upl_stat ='O' THEN
dbg('Raising Override Exception...');
RAISE E_Override_Exception;
ELSE
dbg('Not Feasible to Proceed...');
RAISE E_Failure_Exception;
END IF;
ELSE
dbg('Encountered Errros..');
RAISE E_Failure_Exception;
END IF;
IF Cspks_Req_Utils.Fn_Tank_Modification(p_source,
l_action_code,
g_Function_Id,
p_err_code,
p_err_params) THEN
dbg('Rolling Back the Modification');
l_Tanking_Status    := 'T';
END IF;

IF NOT Fn_Maint_Log(p_source,
l_Action_Code,
p_pcdprmnt,
l_prev_pcdprmnt,
l_wrk_pcdprmnt,
l_Tanking_Status,
p_err_code,
p_err_params) THEN
dbg('Failed in   Cspks_Req_Utils.Fn_Maint_Log..');
RAISE E_Failure_Exception;
END IF;
END IF; -- Action Code

g_pcdprmnt := l_wrk_pcdprmnt;
IF l_Action_Code = Cspks_Req_Handler.p_delete AND p_source = 'FLEXCUBE'  THEN
l_wrk_pcdprmnt := l_Dmy_pcdprmnt;
END IF;
p_pcdprmnt := l_wrk_pcdprmnt;
Cspks_Req_Utils.Pr_Get_Final_Err_Code(g_Function_Id,l_Action_Code,l_post_upl_stat,p_err_code,p_err_params);
pr_log_error(p_source,p_err_code,p_err_params);
dbg('Errors     :'||p_err_code);
dbg('Parameters :'||p_err_params);

dbg('Returning Success From Fn_Main..');
RETURN TRUE;

EXCEPTION
WHEN E_Failure_Exception THEN
dbg('From E_Failure_Exception of Fn_Main');
p_status        := 'F';
l_post_upl_stat := 'F';
ROLLBACK TO Sp_Main;
Cspks_Req_Utils.Pr_Get_Final_Err_Code(g_Function_Id,l_Action_Code,l_post_upl_stat,p_err_code,p_err_params);
pr_log_error(p_source,p_err_code,p_err_params);
dbg('Errors     :'||p_err_code);
dbg('Parameters :'||p_err_params);
RETURN TRUE;

WHEN E_Override_Exception THEN
dbg('From E_Override_Exception of Fn_Main');
p_status        := 'O';
l_post_upl_stat := 'O';
Cspks_Req_Utils.Pr_Get_Final_Err_Code(g_Function_Id,l_Action_Code,l_post_upl_stat,p_err_code,p_err_params);
pr_log_error(p_source,p_err_code,p_err_params);
dbg('Errors     :'||p_err_code);
dbg('Parameters :'||p_err_params);
RETURN TRUE;

WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Main ..');
debug.pr_debug('**',SQLERRM);
ROLLBACK TO Sp_Main;
p_status      := 'F';
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Main;

FUNCTION Fn_Process_Fc_Request (p_source           IN     VARCHAR2,
                        p_source_operation  IN     VARCHAR2,
                        p_action_code       IN     VARCHAR2,
                        p_multi_trip_id     IN OUT VARCHAR2,
                        p_addl_info			IN OUT Cspks_Req_Handler.Ty_Addl_Info,
                        p_status            IN OUT VARCHAR2 ,
                        p_err_code          IN OUT VARCHAR2,
                        p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_pcdprmnt     pcpks_pcdprmnt_Main.ty_pcdprmnt;

BEGIN

dbg('In Fn_Process_Fc_Request ..');
IF NOT  fn_build_Fc_type(
p_addl_info,
l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_build_Fc_type');
p_status      := 'F';
RETURN FALSE;
END IF;

IF NOT  Fn_main(p_source,
p_source_operation,
p_action_code,
p_multi_trip_id,
l_pcdprmnt,
p_status,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_main');
RETURN FALSE;
END IF;

p_addl_info := l_pcdprmnt.Addl_Info;
IF Cspks_Req_Global.Fn_Build_Resp THEN
Cspks_Req_Global.Pr_Reset;
IF NOT  Fn_Build_Fc_Ts(l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Fc_Ts');
p_status      := 'F';
RETURN FALSE;
END IF;
Cspks_Req_Global.Pr_Close_Ts;
END IF;
dbg('Returning from Fn_Process_Fc_Request ..');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Process_Fc_Request');
debug.pr_debug('**',SQLERRM);
p_status      := 'F';
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Process_Fc_Request;

FUNCTION Fn_Process_Ws_Request (p_source           IN     VARCHAR2,
                        p_source_operation  IN     VARCHAR2,
                        p_action_code       IN     VARCHAR2,
                        p_exchange_pattern	IN     VARCHAR2,
                        p_multi_trip_id     IN OUT VARCHAR2,
                        p_addl_info			IN OUT Cspks_Req_Handler.Ty_Addl_Info,
                        p_status            IN OUT VARCHAR2 ,
                        p_err_code          IN OUT VARCHAR2,
                        p_err_params        IN OUT VARCHAR2)
RETURN BOOLEAN IS

l_pcdprmnt     pcpks_pcdprmnt_Main.ty_pcdprmnt;
l_exchange_pattern	  VARCHAR2(4) := p_exchange_pattern;

BEGIN

dbg('In Fn_Process_Ws_Request for Web Service');
IF NOT  fn_build_Ws_type(
p_addl_info,
l_pcdprmnt,
p_err_code,
p_err_params)  THEN
dbg('Failed in fn_build_Ws_type');
p_status      := 'F';
RETURN FALSE;
END IF;

IF NOT  fn_main(p_source,
p_source_operation,
p_action_code,
p_multi_trip_id,
l_pcdprmnt,
p_status,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Main');
RETURN FALSE;
END IF;

p_addl_info := l_pcdprmnt.Addl_Info;
IF Cspks_Req_Global.Fn_Build_Resp THEN
Cspks_Req_Global.Pr_Reset;
IF NOT  Fn_Build_Ws_Ts(l_pcdprmnt,
p_exchange_pattern,
p_err_code,
p_err_params)  THEN
dbg('Failed in Fn_Build_Ws_Ts');
p_status      := 'F';
RETURN FALSE;
END IF;

Cspks_Req_Global.Pr_Close_Ts;
END IF;
dbg('Returning from Fn_Process_Ws_Request of Web Service');
RETURN TRUE;

EXCEPTION
WHEN OTHERS THEN
debug.pr_debug('**','In when others of Fn_Process_Ws_Request');
debug.pr_debug('**',SQLERRM);
p_status      := 'F';
p_err_code    := 'ST-OTHR-001';
p_err_params  := Null;
RETURN FALSE;
END Fn_Process_Ws_Request;

END pcpks_pcdprmnt_Main;
/

