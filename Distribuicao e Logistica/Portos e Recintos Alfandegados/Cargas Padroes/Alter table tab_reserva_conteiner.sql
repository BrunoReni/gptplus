ALTER table sara_db..tab_reserva_container add rcnt_compr_excedente numeric(18,6) null; 
ALTER table sara_db..tab_reserva_container add rcnt_largura_excedente numeric(18,6) null;
ALTER table sara_db..tab_reserva_container add rcnt_altura_excedente numeric(18,6) null;
ALTER table sara_db..tab_reserva_container add rcnt_temperatura numeric(18,6) null;
ALTER table sara_db..tab_reserva_container add rcnt_variacao_temper numeric(18,6) null;

ALTER table sara_log..tab_reserva_container add rcnt_compr_excedente numeric(18,6) null;
ALTER table sara_log..tab_reserva_container add rcnt_largura_excedente numeric(18,6) null;
ALTER table sara_log..tab_reserva_container add rcnt_altura_excedente numeric(18,6) null;
ALTER table sara_log..tab_reserva_container add rcnt_temperatura numeric(18,6) null;
ALTER table sara_log..tab_reserva_container add rcnt_variacao_temper numeric(18,6) null;