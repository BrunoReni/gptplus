#INCLUDE "PROTHEUS.CH"
#INCLUDE "FWMVCDEF.CH"

Function SRPayload()
return

Class SRPayload
	Method New() Constructor
	//Data Novo	
	Method Container(aCntId)
	Method QryPayload(aResId, aCntId)
	//Method NrReserva(aResId, aCntId) 
	Method ListDocStr(aRCntId)
	Method Destroy()	
EndClass

//Constructor
Method New() Class SRPayload
Return Self

Method Container(aCntId)Class SRPayload	
	Local cResult := 0
	Local QryPayload := SRQuery():New("select cnt_mgw - cnt_tara as payload from tab_container ";
	                               +" where cnt_id = '" + aCntId + "'")
	QryPayload:Open()
	
	cResult := QryPayload:FieldByName(payload)
	QryPayload:Destroy
Return cResult

Method QryPayload(aResId, aCntId) Class SRPayload
Local QryPayload := SRQuery():New(;
							 "select c.res_numero as NumeroReserva,";
							+"	   a.rcnt_id as RCNTID,";
							+"	   a.cnt_id  as Container,";
							+"	   d.cnt_tara as Tara,";
							+"	   Coalesce(d.cnt_mgw,0) as ContainerSuporta,";
							+"       b.trp_cnt_cheio as ContainerCheio,";
							+"	   (select COUNT(rrc_id)"; 
							+"	      from tab_reserva_rateio_cnt ra"; 
							+"		 where ra.res_id = b.res_id and ra.rcnt_id = a.rcnt_id) as QtdDocumentos,";     
							+"	   (select SUM(dent_peso_rateio)"; 
							+"	      from tab_reserva_rateio_cnt rb";  
							+"		 where rb.res_id = b.res_id and rb.rcnt_id = a.rcnt_id) as PesoDocumental,";     
							+"       m.vgm_numero Viagem";            
							+"  from tab_reserva_container a";            
							+" inner join tab_reserva_programacao b on b.trp_id = a.trp_id";             
							+" inner join tab_reserva c on c.res_id = b.res_id";                           
							+" left outer join tab_container d on d.cnt_id = a.cnt_id";
							+" left outer join tab_viagem m ON m.vgm_id = c.vgm_id";                      
							+" where c.res_id = " + aResId;
							+"   and d.cnt_id = '" + aCntId +"'";
						)
	QryPayload:Open()
Return QryPayload

/*
Method NrReserva(aResId, aCntId) Class SRPayload
	Local cResult := 0
	Local QryPayload := QryPayload(aResId, aCntId) 
	
	cResult := QryPayload:FieldByName(PesoDocumental)
	QryPayload:Destroy
Return cResult
*/

Method ListDocStr(aRCntId) Class SRPayload
Local cResult := ""
Local QryListDoc := SRQuery():New(;
							"select dent_id, dent_peso_rateio from tab_reserva_rateio_cnt where rcnt_id = " +cValToChar(aRCntId);
						)
	QryListDoc:Open()
	
	cResult := '|-----------------Documento-----------------|----Peso----' + Chr(13) + Chr(10)
	While !QryListDoc:Eof_()
		cResult :=  cResult + QryListDoc:FieldByName(dent_id) + '     ';
						+ cValToChar(QryListDoc:FieldByName(dent_peso_rateio)) + Chr(13) + Chr(10) 
		QryListDoc:Next_()
	EndDo
Return cResult


Method Destroy() Class SRPayload	
	FreeObj(Self)
Return
