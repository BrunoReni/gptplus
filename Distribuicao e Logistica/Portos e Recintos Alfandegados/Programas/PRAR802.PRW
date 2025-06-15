#INCLUDE "FWMVCDEF.CH"
#INCLUDE 'DBINFO.CH'
#INCLUDE 'TOTVS.CH'
#INCLUDE "FWBROWSE.CH"
#INCLUDE "PARMTYPE.CH"
#INCLUDE "PRCONST.CH"
#INCLUDE "PROTHEUS.CH"

Function PRAR802()
   Local oReport
   Private aDadosT := ''

   If ExistFunc("PRARXML")
        PRARXML()
        return .T.
    Endif

   if !Empty(cProg_ID)       
      oReport := ReportDef()	
      oReport:PrintDialog()
   endif   	
Return .T.

Static Function ReportDef()
   Local oReport
   Local oSection1
   Local cAlias  := GetNextAlias()
   Local cAlias2 := GetNextAlias()
   Local cAlias3 := GetNextAlias()
       
   oReport := TReport():New("PRAR802","","PRAR802",{|oReport| PrintReport(oReport,cAlias,cAlias2,cAlias3)},"Este relatorio ira imprimir a minuta de agendamento.")
   oReport:SetTotalInLine(.F.)
   oReport:HideParamPage()       
   //Informações da CESV - Veiculos - Motorista      
   oSection1 := TRSection():New(oReport,"DADOS DO TRANSPORTE",{cAlias}) 
      
   oSection1:Finish()
   delTabTmp(cAlias)
   delTabTmp(cAlias2)
   delTabTmp(cAlias3)
Return oReport
      
Static function PrintReport(oReport,cAlias,cAlias2,cAlias3) 
   Local cObservacao :=''
   Local cObsDocs    :=''
   Local oFont10N	:= TFont():New("Times New Roman",10,10,,.T.,,,,.T.,.F.)
   Local oFont9N	:= TFont():New("Courier New",9,9,,.F.,,,,.T.,.F.)
   Local oFont10N	:= TFont():New("Courier New",10,10,,.F.,,,,.T.,.F.)
   Local oFont10B	:= TFont():New("Courier New",10,10,,.T.,,,,.T.,.F.)
   Local oFont11B	:= TFont():New("Courier New",11,11,,.T.,,,,.T.,.F.)
   Local oFont14B	:= TFont():New("Courier New",14,14,,.T.,,,,.T.,.F.)

   Local impType := oReport:nDevice

   Local oPen := TPen():New(0,6,CLR_BLACK)
   Local cPixel := '-2'
   local cQryAux1:=''
   local cQryAux2:=''
   local cQryAux3:=''
   Local oSection1 := oReport:Section(1)
   Local ntotal :=0
   Local nColA1:=130
   Local nColA2:=500
   Local nColB1:=1350
   Local nColB2:=1700

   Local nCon1:=110 
   Local nCon2:=400
   Local nCon7:=810
   Local nCon3:=1150
   Local nCon4:=1500
   Local nCon5:=1750
   Local nCon6:=1950

   Local nDoc1:=130 
   Local nDoc2:=130
   Local nDoc3:=650
   Local nDoc4:=1100
   Local nDoc5:=1400
   Local nDoc6:=1950
   Local nDoc7:=130
   Local nDoc8:=130
   Local nDoc9:=550
   Local nDoc10:=130
   Local nDoc11:=1500

   Local nLin:=0
   Local nLargura:=2330
   Local nBloco1 :=270
   Local nBloco2 :=nBloco1+360
   Local nBloco3 :=nBloco2+260
   Local nBloco4 :=nBloco3+270
   Local nBloco5 :=0
   Local nBloco6 :=0
   Local lBloco5 :=.F.

   Local cObsReefer :=''
   Local cObsExtra  :=''
   Local cDocAux    :=''
   Loca  nDocCount  :=0
   Local iDocLin    :=0
   Local cCnt       :=''
   Local cObsCnt    :=''
   Local nLinhaOBS  := ''
   Local nX         := 1

   if((impType = 4) .or. (impType = 5) .or. (impType = 1))
      oPen := TPen():New(0,6,CLR_BLACK)
      cPixel := TPen():New(0,6,CLR_BLACK)
   elseif(impType = 6)
      oPen := -2
   else
      oPen := TPen():New(0,6,CLR_BLACK)
   endif
  
       
   cQryAux1:=" "+;
   "select convert(char(8),a.prog_id) as prog_id,a.vei_id,a.reb_id, b.trans_nome, "+;
   "(select min(reb_id) from rel_prog_reboque where prog_id = a. prog_id and reb_id <> a.reb_id) as vei_id_rel,"+; 
   "       case len(b.trans_cgc)"+;
   "            when 14 then (substring(b.trans_cgc,1,2)+'.'+substring(b.trans_cgc,3,3)+'.'+substring(b.trans_cgc,6,3)+'/'+substring(b.trans_cgc,9,4)+'-'+substring(b.trans_cgc,13,2) )"+;
   "            else         (substring(b.trans_cgc,1,3)+'.'+substring(b.trans_cgc,4,3)+'.'+substring(b.trans_cgc,7,3)+'-'+substring(b.trans_cgc,10,2))"+;
   "       end as trans_cgc,    "+;
   "       c.pes_nome, (substring(c.pes_cpf,1,3)+'.'+substring(c.pes_cpf,4,3)+'.'+substring(c.pes_cpf,7,3)+'-'+substring(c.pes_cpf,10,2)) as pes_cpf,"+; 
   "       c.pes_cnh, convert(varchar(10),c.pes_dt_cnh,103) as Validade_cnh, "+;
   "       convert(varchar(10),d.dt_ini_agenda,103)+' '+convert(varchar(10),d.dt_ini_agenda,108)+' - '+convert(varchar(10),d.dt_fim_agenda,103)+' '+convert(varchar(10),d.dt_fim_agenda,108) as Janela, "+;
   "       convert(varchar(10),d.dt_hr_previsto,103)+' '+convert(varchar(10),d.dt_hr_previsto,108) as prev_chegada, "+;
   "       e.cli_nome as cliente,"+;
   " case len(e.cli_cgc)"+;
   "      when 14 then ( substring(e.cli_cgc,1,2)+'.'+substring(e.cli_cgc,3,3)+'.'+substring(e.cli_cgc,6,3)+'/'+substring(e.cli_cgc,9,4)+'-'+substring(e.cli_cgc,13,2) )"+;
   "      else (substring(e.cli_cgc,1,3)+'.'+substring(e.cli_cgc,4,3)+'.'+substring(e.cli_cgc,7,3)+'-'+substring(e.cli_cgc,10,2))"+; 
   " end as CNPJ, "+;
   "       d.peso, convert(char,d.mtcubico) as mtcubico, "+;
   "       case a.prog_tipo_modal "+;
   "            when 'V' then 'Rodoviário'  "+;
   "            when 'M' then 'Marítimo'    "+;
   "            when 'F' then 'Ferroviário' "+;
   "            when 'A' then 'Aéreo'       "+;
   "       end as Modal,                    "+; 
   "       f.op_descricao as Operacao,      "+;
   "       g.sub_descricao as Sub_operacao, "+;
   "       h.dc_descricao as Driver,        "+;
   "       d.qtd_janela as Quantidade,      "+;
   "       a.observacao                     "+;
   "  from tab_programacao a left join tab_transportadora b on b.trans_id = a.trans_id "+; 
   "                         left join tab_pessoas c on c.pes_id = a.pes_id    "+;
   "                         left join tab_prog_janela d on d.prog_id = a.prog_id  "+;
   "                         left join tab_clientes e on e.cli_id = a.cli_id       "+;
   "                         left join tab_operacao f on f.op_id =  a.op_id        "+;  
   "                         left join tab_sub_operacao g on g.op_id = a.op_id and g.sub_id = a.sub_id  "+;
   "                         left join tab_driver_capacidade h on h.dc_id = d.dc_id                     "+;
   " where a.prog_id="+cProg_Id;

   oReport:HideHeader()
   oReport:HideFooter()

   oReport:SayBitmap(30,100,"logo_minuta.bmp",400,200)
   oReport:Say(100,970, "Minuta de Agendamento",	oFont14B)
   oReport:Say(150,1840, "Agendamento: ",	oFont11B)
   oReport:Say(150,2130, StrZero(Val(cProg_ID),8),	oFont11B)
   oSection1:PrintLine()
 
   cQryAux1:=ChangeQuery(cQryAux1)

   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux1),cAlias,.T.,.T.)

   Count to nTotal

   oReport:SetMeter(nTotal)

   //Bloco 01 DADOS DO TRANSPORTE
   OReport:Box(nBloco1,100,nBloco1+350,nLargura,cPixel)
   oReport:Say(nBloco1,110, "DADOS DO TRANSPORTE",	oFont11B)

   oSection1:init()

   oReport:Say(70+nBloco1, nColA1,"Veículo:",	oFont11B)
   oReport:Say(120+nBloco1,nColA1,"Reboque1:",	oFont11B)
   oReport:Say(120+nBloco1,nColB1,"Reboque2:",	oFont11B)
   oReport:Say(170+nBloco1,nColA1,"Transportador:",	oFont11B)
   oReport:Say(170+nBloco1,nColB1,"CNPJ:",	oFont11B)
   oReport:Say(220+nBloco1,nColA1,"Motorista:",	oFont11B)
   oReport:Say(220+nBloco1,nColB1,"CPF:",	oFont11B)
   oReport:Say(270+nBloco1,nColA1,"CNH:",	oFont11B)
   oReport:Say(270+nBloco1,nColB1,"Validade CNH:",	oFont11B)

   (cAlias)->(dbGoTop())
   if !(cAlias)->(eof())
       oReport:IncMeter()
       
       nLinhaOBS := MLCount((cAlias)->observacao)
       
       For nX := 1 To nLinhaOBS
	       cObservacao += AllTrim(MemoLine((cAlias)->observacao,,nX))+ " " 
	   Next
          
       oReport:Say(200,1840, "Veículo: ", oFont11B)
       oReport:Say(200,2130, (cAlias)->vei_id,	oFont11B)
    
       oReport:Say(70+nBloco1, nColA2, (cAlias)->vei_id,	oFont10N)
       oReport:Say(120+nBloco1,nColA2, (cAlias)->reb_id,	oFont10N)
       oReport:Say(120+nBloco1,nColB2, (cAlias)->vei_id_rel,	oFont10N)
       oReport:Say(170+nBloco1,nColA2, (cAlias)->trans_nome,	oFont9N)
       oReport:Say(170+nBloco1,nColB2, (cAlias)->trans_cgc,	oFont9N)
       oReport:Say(220+nBloco1,nColA2, (cAlias)->pes_nome,	oFont9N)
       oReport:Say(220+nBloco1,nColB2, (cAlias)->pes_cpf,	oFont10N)
       oReport:Say(270+nBloco1,nColA2, (cAlias)->pes_cnh,	oFont10N)
       oReport:Say(270+nBloco1,nColB2, (cAlias)->Validade_cnh,	oFont10N)
      
       oSection1:PrintLine()    
   EndIf
   //Fim do BLOCO 01

   //Bloco 02 DADOS DO AGENDAMENTO
   OReport:Box(nBloco2,100,250+nBloco2,nLargura,cPixel)
   oReport:Say(nBloco2,110, "DADOS DO AGENDAMENTO",	oFont11B)

   oReport:IncMeter()
   oReport:Say(70+nBloco2,nColA1,  "Janela:",	oFont11B)
   oReport:Say(70+nBloco2,nColB1,  "Prev. de Chegada:",	oFont11B)
   oReport:Say(120+nBloco2,nColA1, "Cliente:",	oFont11B)
   oReport:Say(120+nBloco2,nColB1, "CNPJ:",	oFont11B)
   oReport:Say(170+nBloco2,nColA1, "Peso Bruto:",	oFont11B)
   oReport:Say(170+nBloco2,nColB1, "Metragem cúbica:",	oFont11B)

   oReport:Say(70+nBloco2, nColA2, (cAlias)->Janela,	oFont9N)
   oReport:Say(70+nBloco2, nColB2+70, (cAlias)->prev_chegada,	oFont9N)
   oReport:Say(120+nBloco2,nColA2, (cAlias)->cliente,	oFont9N)
   oReport:Say(120+nBloco2,nColB2+70, (cAlias)->cnpj,	oFont9N)
   oReport:Say(170+nBloco2,nColA2, Transform((cAlias)->Peso,'@E 99,999,999.999')+' KG',	oFont10N)
   oReport:Say(170+nBloco2,nColB2+70, (cAlias)->mtcubico,	oFont10N)
   //Fim do BLOCO 02

   //Bloco 03 DADOS DA OPERAÇÃO
   OReport:Box(nBloco3,100,260+nBloco3,nLargura,cPixel)
   oReport:Say(nBloco3,110, "DADOS DA OPERAÇÃO",	oFont11B)

   oReport:IncMeter()
   oReport:Say(70+nBloco3, nColA1,"Modal:",	oFont11B)
   oReport:Say(120+nBloco3,nColA1, "Operação:",	oFont11B)
   oReport:Say(120+nBloco3,nColB1, "Sub-operação:",	oFont11B)
   oReport:Say(170+nBloco3,nColA1, "Driver:",	oFont11B)
   oReport:Say(170+nBloco3,nColB1, "Quantidade:",	oFont11B)

   oReport:Say(70+nBloco3, nColA2, (cAlias)->Modal,	oFont10N)
   oReport:Say(120+nBloco3,nColA2, (cAlias)->Operacao,	oFont10N)
   oReport:Say(120+nBloco3,nColB2, (cAlias)->Sub_Operacao,	oFont10N)
   oReport:Say(170+nBloco3,nColA2, (cAlias)->Driver,	oFont10N)
   oReport:Say(170+nBloco3,nColB2, alltrim(Str((cAlias)->Quantidade)),	oFont10N)
   oSection1:PrintLine()   
   //Fim do BLOCO 03
   
   (cAlias)->(dbSkip())

   cQryAux2:=" "+;
   " select distinct a.prog_id,a.res_id,d.res_numero, b.dent_id, a.cnt_id, a.tiso_id,a.qtd_cnt,    "+;
   "       (substring(b.dent_id,1,4)+rtrim(c.doc_id)+substring(b.dent_id,9,13)) as documento,   "+; 
   "       case a.cnt_cheio                                                             "+;
   "            when 'S' then 'Cheio'                                                   "+;
   "            when 'N' then 'Vazio'                                                   "+;
   "       end as Status,                                                               "+;
   "       case a.cnt_operacao                                                          "+;
   "            when 'E' then 'Entrada'                                                 "+;
   "            when 'S' then 'Saída'                                                   "+;
   "       end as tipo_oper,                                                            "+;
   "       e.rcnt_compr_excedente, e.rcnt_largura_excedente, e.rcnt_altura_excedente,   "+; 
   "       e.rcnt_temperatura, e.rcnt_variacao_temper   "+;
   "  from tab_programacao_cnt a                        "+;
   "    left join rel_dent_programacao b                "+;
   "      on b.prog_id=a.prog_id and                    "+;
   "         b.dp_id=a.dp_id                            "+;
   "    left join tab_documentos c                      "+; 
   "      on c.doc_ordem1 = substring(b.dent_id,5,1)    "+;         
   "    left join tab_reserva d                   "+;
   "      on d.res_id = a.res_id                  "+;
   "    left outer join tab_reserva_container e   "+;
   "      on e.cnt_id = a.cnt_id and      "+;
   "         e.trp_id in (select trp_id from tab_reserva_programacao where res_id = a.res_id)"+;
   " where a.prog_id="+cProg_Id;

   cQryAux2:=ChangeQuery(cQryAux2)

   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux2),cAlias2,.T.,.T.)

   Count to nTotal

   oReport:SetMeter(nTotal)

   //Bloco 04 CONTAINERS ASSOCIADOS

   (cAlias2)->(dbGoTop())
   if !(cAlias2)->(eof())
       oReport:IncMeter()

       oReport:Say(nBloco4,110, "CONTAINERS ASSOCIADOS",	oFont11B)
       oReport:Line(120+nBloco4,110,120+nBloco4,nLargura-10,oPen)
       nLin:=70  
       oReport:Say(nLin+nBloco4,nCon1,"Reserva:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon7,"Tipo e/s:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon2,"Documento:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon3,"Container:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon4,"Tipo ISO:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon5,"Status:",	  oFont11B)
       oReport:Say(nLin+nBloco4,nCon6,"Quantidade:",  oFont11B)
    
       cObsReefer :=''
       cObsExtra  :=''
       cDocAux    :=''
       nDocCount  :=0
       cCnt       :=''
       cObsCnt    :=''
       iDocLin    :=0
       nLin+=10 //adicionado 10 pelo 'line' 
       
       while !(cAlias2)->(eof())
          cDocAux:=''
          iDocLin:=0
          if cCnt <> (cAlias2)->cnt_id    
             if Len(Alltrim(cObsCnt)) > 1 .and. nDocCount > 1 
    	        nLin+=50
    	        oReport:Say(nLin+nBloco4,nCon1,('Doctos.: '+substring(cObsCnt,1,(len(cObsCnt)-2))),oFont9N)
    	        cObsCnt:=''    	  
    	      endif     
              nDocCount:=0
              nLin+=50
    	    	
              cCnt := (cAlias2)->cnt_id
              if alltrim((cAlias2)->documento)<>''
                 cObsCnt+=(rtrim((cAlias2)->documento)+', ')
                 nDocCount+=1
              endif   
              cDocAux :=rtrim((cAlias2)->documento)
                      
              if ((cAlias2)->rcnt_compr_excedente)>0 .or. ((cAlias2)->rcnt_largura_excedente)>0 .or. ((cAlias2)->rcnt_altura_excedente)>0
                 cObsExtra := "- Comp. Exc: "+Alltrim(Str((cAlias2)->rcnt_compr_excedente))+"  Larg. Exc: "+Alltrim(Str((cAlias2)->rcnt_largura_excedente))+" Alt. Exc: "  +Alltrim(Str((cAlias2)->rcnt_altura_excedente))
              endif
              if ((cAlias2)->rcnt_temperatura)<> 0 .or. ((cAlias2)->rcnt_variacao_temper)<>0
                 cObsReefer := "- Temp.: "+alltrim(Str((cAlias2)->rcnt_temperatura))+"  Variação: "+Alltrim(Str((cAlias2)->rcnt_variacao_temper))
              endif
              
              oReport:Say(nLin+nBloco4,nCon1,(cAlias2)->res_numero, oFont10N)
    	      oReport:Say(nLin+nBloco4,nCon7,(cAlias2)->tipo_oper,  oFont9N)
    	      oReport:Say(nLin+nBloco4,nCon3,(cAlias2)->cnt_id,	    oFont10N)
    	      oReport:Say(nLin+nBloco4,nCon4,(cAlias2)->tiso_id,    oFont10N)
    	      oReport:Say(nLin+nBloco4,nCon5,(cAlias2)->Status,	    oFont10N)
    	      oReport:Say(nLin+nBloco4,nCon6,alltrim(Str((cAlias2)->Qtd_cnt)),oFont10N)
    	      iDocLin:=nLin+nBloco4
    	      
    	      if Len(Alltrim(cObsReefer+cObsExtra)) > 1 
    	         nLin+=50
    	         oReport:Say(nLin+nBloco4,nCon1,(cObsReefer+" "+cObsExtra),oFont9N)
    	         cObsReefer:=''
    	         cObsExtra:=''
    	      endif
          else    
              if alltrim((cAlias2)->documento)<>''
                 cObsCnt+=(rtrim((cAlias2)->documento)+', ')
                 nDocCount+=1
              endif      
          endif	
    	  (cAlias2)->(dbSkip())   
    	  if cCnt <> (cAlias2)->cnt_id 
    	     oReport:Say(iDocLin,nCon2,cDocAux,  oFont9N)
    	  endif 
    	
       enddo
       if Len(Alltrim(cObsCnt)) > 1 .and. nDocCount > 1
          nLin+=50
          oReport:Say(nLin+nBloco4,nCon1,('Doctos.: '+substring(cObsCnt,1,(len(cObsCnt)-2))),oFont9N)
          cObsCnt:=''
       endif     

       oReport:Box(nBloco4,100,nBloco4+nLin+50,nLargura,cPixel)
       oSection1:PrintLine()
       nLin+=60           
   endif
   //Fim do Bloco 04

   cQryAux3:=''+;
   " select a.prog_id,b.dent_id,                  "+;
   "        i.res_numero,                         "+;
   "        case b.tp_dent_dsai                   "+; 
   "             when 'E' then 'ENTRADA'          "+;
   "             when 'S' then 'SAÍDA'            "+;
   "        end as tipo,                          "+; 
   "        h.doc_id,                             "+;
   "        substring(b.dent_id,1,4) as ano,      "+;
   "        case b.tp_dent_dsai                   "+; 
   "             when 'E' then substring(b.dent_id,9,13)   "+;
   "             when 'S' then                             "+;
   "                case h.doc_id                          "+;
   "                     when 'NF' then substring(b.dent_id,9,9)   "+;
   "                     else substring(b.dent_id,6,13)      "+;
   "                 end                          "+;
   "        end as doc,                           "+;                              
   "        substring(b.dent_id,9,13) as doc,     "+;
   "        case h.doc_id                         "+;
   "           when 'NF' then substring(b.dent_id,6,3)  "+;
   "           else ''                                  "+;   
   "        end as serie,                               "+;   
   "        e.proc_nome as procedencia,                 "+;
   "        substring(b.dent_id,22,3),                  "+;
   "        b.cfop,                                     "+;
   "        f.cfop_descricao,                           "+;
   "        g.cli_nome as beneficiario,                 "+;
   "        case len(g.cli_cgc)                         "+;
   "             when 14 then (substring(g.cli_cgc,1,2)+'.'+substring(g.cli_cgc,3,3)+'.'+substring(g.cli_cgc,6,3)+'/'+substring(g.cli_cgc,9,4)+'-'+substring(g.cli_cgc,13,2) )"+;
   "            else          (substring(g.cli_cgc,1,3)+'.'+substring(g.cli_cgc,4,3)+'.'+substring(g.cli_cgc,7,3)+'-'+substring(g.cli_cgc,10,2))"+;
   "        end as cli_cgc  "+;
   " from tab_programacao a left join rel_dent_programacao b on b.prog_id=a.prog_id       "+;
   "                        left join tab_doc_entrada  c     on c.dent_id=b.dent_id and b.tp_dent_dsai='E' "+;
   "                        left join tab_doc_saida  d       on d.dsai_id=b.dent_id and b.tp_dent_dsai='S' "+;
   "                        left join tab_procedencia e on e.proc_id = substring(b.dent_id,22,3)           "+;
   "                        left join tab_cfop f on f.cfop_id = b.cfop                                     "+;
   "                        left join tab_clientes g on g.cli_id = b.beneficiario                          "+;
   "                        left join tab_documentos h on h.doc_ordem1 = substring(b.dent_id,5,1)          "+;
   "                        left join tab_reserva i on i.res_id = b.res_id                                 "+;
   "  where a.prog_id="+cProg_Id;
   
   cQryAux3:=ChangeQuery(cQryAux3)
   DbUseArea(.T.,'TOPCONN',TCGENQRY(,,cQryAux3),cAlias3,.T.,.T.)

   Count to nTotal

   oReport:SetMeter(nTotal)

   //Bloco 05 DOCUMENTOS ASSOCIADOS
   nBloco5+=(nBloco4+nLin)
   (cAlias3)->(dbGoTop())
   if !(cAlias3)->(eof())
      lBloco5:=.T.
      oReport:IncMeter()

      oReport:Say(nBloco5,110, "DOCUMENTOS ASSOCIADOS",	oFont11B)
       
      nLin:=50  
      nDocCount:=0
      while !(cAlias3)->(eof())
         nDocCount+=1
         if nDocCount>5           
            cObsDocs:='*** A quantidade de documentos associdados excedeu o limite de impressão. Listando 5 documentos. ***'
            exit
         endif        
         oReport:Line(nlin+nBloco5+50,110,nlin+nBloco5+50,nLargura-10,oPen) 
         nLin+=50                
         oReport:Say(nLin+nBloco5,nDoc1,"Reserva:",	oFont11B)
    	 oReport:Say(nLin+nBloco5,nDoc1+300,(cAlias3)->res_numero, oFont9N)        
         nLin+=50
         oReport:Say(nLin+nBloco5,nDoc2,"Tipo e/s:",	oFont11B)
         oReport:Say(nLin+nBloco5,nDoc3,"Tipo doc.:",	oFont11B)
         oReport:Say(nLin+nBloco5,nDoc4,"Ano:",	oFont11B)
         oReport:Say(nLin+nBloco5,nDoc5,"Nr. doc.:",	    oFont11B)
         oReport:Say(nLin+nBloco5,nDoc6,"Série:",	oFont11B)
        
    	 oReport:Say(nLin+nBloco5,nDoc2+300,(cAlias3)->tipo,   oFont10N)
    	 oReport:Say(nLin+nBloco5,nDoc3+260,(cAlias3)->doc_id, oFont10N)
    	 oReport:Say(nLin+nBloco5,nDoc4+120,(cAlias3)->ano,	  oFont10N)
    	 oReport:Say(nLin+nBloco5,nDoc5+220,(cAlias3)->doc,    oFont9N)
    	 oReport:Say(nLin+nBloco5,nDoc6+150,(cAlias3)->serie,  oFont10N)        
        
         nLin+=50
         oReport:Say(nLin+nBloco5,nDoc7,"Procedência:",	  oFont11B)
         oReport:Say(nLin+nBloco5,nDoc7+300,(cAlias3)->procedencia,  oFont10N)
         nLin+=50
         oReport:Say(nLin+nBloco5,nDoc8,"CFOP:",	            oFont11B)
         oReport:Say(nLin+nBloco5,nDoc9,"Descrição CFOP:",	oFont11B)
    	 oReport:Say(nLin+nBloco5,nDoc8+200,(cAlias3)->cfop,           oFont10N)
    	 oReport:Say(nLin+nBloco5,nDoc9+370,(cAlias3)->cfop_descricao, oFont9N)        
        
         nLin+=50        
         oReport:Say(nLin+nBloco5,nDoc10,"Beneficiário:",	oFont11B)    
         oReport:Say(nLin+nBloco5,nDoc11,"CNPJ/CPF:",	    oFont11B)    
    	 oReport:Say(nLin+nBloco5,nDoc10+320,(cAlias3)->beneficiario, oFont9N)
    	 oReport:Say(nLin+nBloco5,nDoc11+250,(cAlias3)->cli_cgc,    	    oFont10N)
                         
    	 (cAlias3)->(dbSkip())
    	 nLin+=10
      enddo

      oReport:Box(nBloco5,100,nBloco5+nLin+50,nLargura,cPixel)
      oSection1:PrintLine()           
   endif

   //Bloco 06 OBSERVAÇÃO
   if lBloco5
      nBloco6+=(nBloco5+nLin+60)
   else  
      nBloco6+=nBloco5
   endif 
  
   oReport:Say(nBloco6,110, "OBSERVAÇÃO",	oFont11B)
   oReport:Box(nBloco6,100,260+nBloco6,nLargura,cPixel)
   
   
   oReport:Say(nBloco6+50,130, Substring(cObservacao,1,150),	oFont9N)
   oSection1:PrintLine()
  
   If (Len(cObservacao) > 150)
       oReport:Say(nBloco6+100,130, Substring(cObservacao,151,302),	oFont9N)
	   oSection1:PrintLine()             
   EndIf     
     
   oReport:Say(nBloco6+200,150, cObsDocs, oFont10B)
   oSection1:PrintLine()    

   //MSCBSAYBAR(23,22,Strzero(nX,10),"MB07","C",8.36,.F.,.T.,.F.,,2,1)
   //MSBAR3("CODE128", 10 , 1800 ,"12345678901" ,oReport,NIL,NIL,NIL,NIL,NIL,NIL,NIL,"A")
   //oPr := ReturnPrtObj()
   //MSBAR4("CODE128", 10 , 1800 ,"12345678901" ,oPr,NIL,NIL,NIL,,NIL,NIL,NIL,"A") 
   oSection1:PrintLine()      
   oSection1:Print()

   oSection1:Finish()
Return	


