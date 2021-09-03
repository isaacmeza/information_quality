use "$directorio\DB\lawyer_dataset.dta", clear

********************************************************************************

*Generation of variables of interest
do "$directorio\DoFiles\gen_measures.do"


collapse (count) num_casefiles=gp_office ///
		(mean) mean_perc_pos_rec=perc_pos_rec ///
		(sd) sd_perc_pos_rec=perc_pos_rec ///
		(count) n_perc_pos_rec=perc_pos_rec ///
		(mean) mean_perc_pos_rec_cr=perc_pos_rec_cr ///
		(sd) sd_perc_pos_rec_cr=perc_pos_rec_cr ///
		(count) n_perc_pos_rec_cr=perc_pos_rec_cr ///
		(mean) mean_perc_settlement=perc_settlement ///
		(sd) sd_perc_settlement=perc_settlement ///
		(count) n_perc_settlement=perc_settlement ///
		(mean) mean_perc_cr=perc_cr ///
		(sd) sd_perc_cr=perc_cr ///
		(count) n_perc_cr=perc_cr ///
		(mean) mean_ratio_win_asked=ratio_win_asked ///
		(sd) sd_ratio_win_asked=ratio_win_asked ///
		(count) n_ratio_win_asked=ratio_win_asked ///
		(mean) mean_ratio_winpos_asked=ratio_winpos_asked ///
		(sd) sd_ratio_winpos_asked=ratio_winpos_asked ///
		(count) n_ratio_winpos_asked=ratio_winpos_asked ///		
		(mean) mean_ratio_win_asked_cr=ratio_win_asked_cr ///
		(sd) sd_ratio_win_asked_cr=ratio_win_asked_cr ///
		(count) n_ratio_win_asked_cr=ratio_win_asked_cr ///
		(mean) mean_ratio_winpos_asked_cr=ratio_winpos_asked_cr ///
		(sd) sd_ratio_winpos_asked_cr=ratio_winpos_asked_cr ///
		(count) n_ratio_winpos_asked_cr=ratio_winpos_asked_cr ///			
		(mean) mean_ratio_win_minley=ratio_win_minley ///
		(sd) sd_ratio_win_minley=ratio_win_minley ///
		(count) n_ratio_win_minley=ratio_win_minley ///
		(mean) mean_ratio_win_minley_cr=ratio_win_minley_cr ///
		(sd) sd_ratio_win_minley_cr=ratio_win_minley_cr ///
		(count) n_ratio_win_minley_cr=ratio_win_minley_cr ///
		(mean) mean_ratio_wage=ratio_wage ///
		(sd) sd_ratio_wage=ratio_wage ///
		(count) n_ratio_wage=ratio_wage ///
		(mean) mean_ratio_win_cprocu=ratio_win_cprocu ///
		(sd) sd_ratio_win_cprocu=ratio_win_cprocu ///
		(count) n_ratio_win_cprocu=ratio_win_cprocu ///
		(mean) mean_ratio_rel_procu=ratio_rel_procu ///
		(sd) sd_ratio_rel_procu=ratio_rel_procu ///
		(count) n_ratio_rel_procu=ratio_rel_procu ///
		(mean) mean_ratio_rel_ent=ratio_rel_ent ///
		(sd) sd_ratio_rel_ent=ratio_rel_ent ///
		(count) n_ratio_rel_ent=ratio_rel_ent ///		
		(mean) mean_ratio_dw_scian=ratio_dw_scian ///
		(sd) sd_ratio_dw_scian=ratio_dw_scian ///
		(count) n_ratio_dw_scian=ratio_dw_scian ///	
		(mean) mean_ratio_dw_giro_procu=ratio_dw_giro_procu ///
		(sd) sd_ratio_dw_giro_procu=ratio_dw_giro_procu ///
		(count) n_ratio_dw_giro_procu=ratio_dw_giro_procu ///		
		(mean) mean_perc_indem=perc_indem ///
		(sd) sd_perc_indem=perc_indem ///
		(count) n_perc_indem=perc_indem ///
		(mean) mean_perc_sal_caidos=perc_sal_caidos ///
		(sd) sd_perc_sal_caidos=perc_sal_caidos ///
		(count) n_perc_sal_caidos=perc_sal_caidos ///
		(mean) mean_perc_prima_antig=perc_prima_antig ///
		(sd) sd_perc_prima_antig=perc_prima_antig ///
		(count) n_perc_prima_antig=perc_prima_antig ///
		(mean) mean_perc_prima_vac=perc_prima_vac ///
		(sd) sd_perc_prima_vac=perc_prima_vac ///
		(count) n_perc_prima_vac=perc_prima_vac ///
		(mean) mean_perc_hextra=perc_hextra ///
		(sd) sd_perc_hextra=perc_hextra ///
		(count) n_perc_hextra=perc_hextra ///
		(mean) mean_perc_prima_dom=perc_prima_dom ///
		(sd) sd_perc_prima_dom=perc_prima_dom ///
		(count) n_perc_prima_dom=perc_prima_dom ///
		(mean) mean_perc_desc_sem=perc_desc_sem ///
		(sd) sd_perc_desc_sem=perc_desc_sem ///
		(count) n_perc_desc_sem=perc_desc_sem ///
		(mean) mean_perc_desc_ob=perc_desc_ob ///
		(sd) sd_perc_desc_ob=perc_desc_ob ///
		(count) n_perc_desc_ob=perc_desc_ob ///
		(mean) mean_perc_sarimssinf=perc_sarimssinf ///
		(sd) sd_perc_sarimssinf=perc_sarimssinf ///
		(count) n_perc_sarimssinf=perc_sarimssinf ///
		(mean) mean_perc_utilidades=perc_utilidades ///
		(sd) sd_perc_utilidades=perc_utilidades ///
		(count) n_perc_utilidades=perc_utilidades ///
		(mean) mean_perc_nulidad=perc_nulidad ///
		(sd) sd_perc_nulidad=perc_nulidad ///
		(count) n_perc_nulidad=perc_nulidad ///
		(mean) mean_perc_codem=perc_codem ///
		(sd) sd_perc_codem=perc_codem ///
		(count) n_perc_codem=perc_codem ///
		(mean) mean_perc_reinst=perc_reinst ///
		(sd) sd_perc_reinst=perc_reinst ///
		(count) n_perc_reinst=perc_reinst ///
		(mean) mean_duration=duration ///
		(sd) sd_duration=duration ///
		(count) n_duration=duration ///
		(mean) mean_perc_non_pos_npv=perc_non_pos_npv ///
		(sd) sd_perc_non_pos_npv=perc_non_pos_npv ///
		(count) n_perc_non_pos_npv=perc_non_pos_npv ///		
		(mean) mean_ratio_npv=ratio_npv ///
		(sd) sd_ratio_npv=ratio_npv ///
		(count) n_ratio_npv=ratio_npv ///				
				, by(office_emp_law)

*Generate CI
generate hi_perc_pos_rec = max( min (mean_perc_pos_rec + invttail(n_perc_pos_rec-1,0.05)*(sd_perc_pos_rec / sqrt(n_perc_pos_rec)),1),0) if n_perc_pos_rec>=2
generate low_perc_pos_rec = max( min (mean_perc_pos_rec - invttail(n_perc_pos_rec-1,0.05)*(sd_perc_pos_rec / sqrt(n_perc_pos_rec)),1),0) if n_perc_pos_rec>=2
generate hi_perc_pos_rec_cr = max( min (mean_perc_pos_rec_cr + invttail(n_perc_pos_rec_cr-1,0.05)*(sd_perc_pos_rec_cr / sqrt(n_perc_pos_rec_cr)),1),0) if n_perc_pos_rec_cr>=2
generate low_perc_pos_rec_cr = max( min (mean_perc_pos_rec_cr - invttail(n_perc_pos_rec_cr-1,0.05)*(sd_perc_pos_rec_cr / sqrt(n_perc_pos_rec_cr)),1),0) if n_perc_pos_rec_cr>=2
generate hi_perc_settlement = max( min (mean_perc_settlement + invttail(n_perc_settlement-1,0.05)*(sd_perc_settlement / sqrt(n_perc_settlement)),1),0) if n_perc_settlement>=2
generate low_perc_settlement = max( min (mean_perc_settlement - invttail(n_perc_settlement-1,0.05)*(sd_perc_settlement / sqrt(n_perc_settlement)),1),0) if n_perc_settlement>=2
generate hi_perc_cr = max( min (mean_perc_cr + invttail(n_perc_cr-1,0.05)*(sd_perc_cr / sqrt(n_perc_cr)),1),0) if n_perc_cr>=2
generate low_perc_cr = max( min (mean_perc_cr - invttail(n_perc_cr-1,0.05)*(sd_perc_cr / sqrt(n_perc_cr)),1),0) if n_perc_cr>=2
generate hi_perc_indem = max( min (mean_perc_indem + invttail(n_perc_indem-1,0.05)*(sd_perc_indem / sqrt(n_perc_indem)),1),0) if n_perc_indem>=2
generate low_perc_indem = max( min (mean_perc_indem - invttail(n_perc_indem-1,0.05)*(sd_perc_indem / sqrt(n_perc_indem)),1),0) if n_perc_indem>=2
generate hi_perc_sal_caidos = max( min (mean_perc_sal_caidos + invttail(n_perc_sal_caidos-1,0.05)*(sd_perc_sal_caidos / sqrt(n_perc_sal_caidos)),1),0) if n_perc_sal_caidos>=2
generate low_perc_sal_caidos = max( min (mean_perc_sal_caidos - invttail(n_perc_sal_caidos-1,0.05)*(sd_perc_sal_caidos / sqrt(n_perc_sal_caidos)),1),0) if n_perc_sal_caidos>=2
generate hi_perc_prima_antig = max( min (mean_perc_prima_antig + invttail(n_perc_prima_antig-1,0.05)*(sd_perc_prima_antig / sqrt(n_perc_prima_antig)),1),0) if n_perc_prima_antig>=2
generate low_perc_prima_antig = max( min (mean_perc_prima_antig - invttail(n_perc_prima_antig-1,0.05)*(sd_perc_prima_antig / sqrt(n_perc_prima_antig)),1),0) if n_perc_prima_antig>=2
generate hi_perc_prima_vac = max( min (mean_perc_prima_vac + invttail(n_perc_prima_vac-1,0.05)*(sd_perc_prima_vac / sqrt(n_perc_prima_vac)),1),0) if n_perc_prima_vac>=2
generate low_perc_prima_vac = max( min (mean_perc_prima_vac - invttail(n_perc_prima_vac-1,0.05)*(sd_perc_prima_vac / sqrt(n_perc_prima_vac)),1),0) if n_perc_prima_vac>=2
generate hi_perc_hextra = max( min (mean_perc_hextra + invttail(n_perc_hextra-1,0.05)*(sd_perc_hextra / sqrt(n_perc_hextra)),1),0) if n_perc_hextra>=2
generate low_perc_hextra = max( min (mean_perc_hextra - invttail(n_perc_hextra-1,0.05)*(sd_perc_hextra / sqrt(n_perc_hextra)),1),0) if n_perc_hextra>=2
generate hi_perc_prima_dom = max( min (mean_perc_prima_dom + invttail(n_perc_prima_dom-1,0.05)*(sd_perc_prima_dom / sqrt(n_perc_prima_dom)),1),0) if n_perc_prima_dom>=2
generate low_perc_prima_dom = max( min (mean_perc_prima_dom - invttail(n_perc_prima_dom-1,0.05)*(sd_perc_prima_dom / sqrt(n_perc_prima_dom)),1),0) if n_perc_prima_dom>=2
generate hi_perc_desc_sem = max( min (mean_perc_desc_sem + invttail(n_perc_desc_sem-1,0.05)*(sd_perc_desc_sem / sqrt(n_perc_desc_sem)),1),0) if n_perc_desc_sem>=2
generate low_perc_desc_sem = max( min (mean_perc_desc_sem - invttail(n_perc_desc_sem-1,0.05)*(sd_perc_desc_sem / sqrt(n_perc_desc_sem)),1),0) if n_perc_desc_sem>=2
generate hi_perc_desc_ob = max( min (mean_perc_desc_ob + invttail(n_perc_desc_ob-1,0.05)*(sd_perc_desc_ob / sqrt(n_perc_desc_ob)),1),0) if n_perc_desc_ob>=2
generate low_perc_desc_ob = max( min (mean_perc_desc_ob - invttail(n_perc_desc_ob-1,0.05)*(sd_perc_desc_ob / sqrt(n_perc_desc_ob)),1),0) if n_perc_desc_ob>=2
generate hi_perc_sarimssinf = max( min (mean_perc_sarimssinf + invttail(n_perc_sarimssinf-1,0.05)*(sd_perc_sarimssinf / sqrt(n_perc_sarimssinf)),1),0) if n_perc_sarimssinf>=2
generate low_perc_sarimssinf = max( min (mean_perc_sarimssinf - invttail(n_perc_sarimssinf-1,0.05)*(sd_perc_sarimssinf / sqrt(n_perc_sarimssinf)),1),0) if n_perc_sarimssinf>=2
generate hi_perc_utilidades = max( min (mean_perc_utilidades + invttail(n_perc_utilidades-1,0.05)*(sd_perc_utilidades / sqrt(n_perc_utilidades)),1),0) if n_perc_utilidades>=2
generate low_perc_utilidades = max( min (mean_perc_utilidades - invttail(n_perc_utilidades-1,0.05)*(sd_perc_utilidades / sqrt(n_perc_utilidades)),1),0) if n_perc_utilidades>=2
generate hi_perc_nulidad = max( min (mean_perc_nulidad + invttail(n_perc_nulidad-1,0.05)*(sd_perc_nulidad / sqrt(n_perc_nulidad)),1),0) if n_perc_nulidad>=2
generate low_perc_nulidad = max( min (mean_perc_nulidad - invttail(n_perc_nulidad-1,0.05)*(sd_perc_nulidad / sqrt(n_perc_nulidad)),1),0) if n_perc_nulidad>=2
generate hi_perc_codem = max( min (mean_perc_codem + invttail(n_perc_codem-1,0.05)*(sd_perc_codem / sqrt(n_perc_codem)),1),0) if n_perc_codem>=2
generate low_perc_codem = max( min (mean_perc_codem - invttail(n_perc_codem-1,0.05)*(sd_perc_codem / sqrt(n_perc_codem)),1),0) if n_perc_codem>=2
generate hi_perc_reinst = max( min (mean_perc_reinst + invttail(n_perc_reinst-1,0.05)*(sd_perc_reinst / sqrt(n_perc_reinst)),1),0) if n_perc_reinst>=2
generate low_perc_reinst = max( min (mean_perc_reinst - invttail(n_perc_reinst-1,0.05)*(sd_perc_reinst / sqrt(n_perc_reinst)),1),0) if n_perc_reinst>=2
generate hi_perc_non_pos_npv = max( min (mean_perc_non_pos_npv + invttail(n_perc_non_pos_npv-1,0.05)*(sd_perc_non_pos_npv / sqrt(n_perc_non_pos_npv)),1),0) if n_perc_non_pos_npv>=2
generate low_perc_non_pos_npv = max( min (mean_perc_non_pos_npv - invttail(n_perc_non_pos_npv-1,0.05)*(sd_perc_non_pos_npv / sqrt(n_perc_non_pos_npv)),1),0) if n_perc_non_pos_npv>=2


generate hi_ratio_win_asked = mean_ratio_win_asked + invttail(n_ratio_win_asked-1,0.05)*(sd_ratio_win_asked / sqrt(n_ratio_win_asked)) if n_ratio_win_asked>=2
generate low_ratio_win_asked =mean_ratio_win_asked - invttail(n_ratio_win_asked-1,0.05)*(sd_ratio_win_asked / sqrt(n_ratio_win_asked)) if n_ratio_win_asked>=2
generate hi_ratio_winpos_asked = mean_ratio_winpos_asked + invttail(n_ratio_winpos_asked-1,0.05)*(sd_ratio_winpos_asked / sqrt(n_ratio_winpos_asked)) if n_ratio_winpos_asked>=2
generate low_ratio_winpos_asked =mean_ratio_winpos_asked - invttail(n_ratio_winpos_asked-1,0.05)*(sd_ratio_winpos_asked / sqrt(n_ratio_winpos_asked)) if n_ratio_winpos_asked>=2
generate hi_ratio_win_asked_cr = mean_ratio_win_asked_cr + invttail(n_ratio_win_asked_cr-1,0.05)*(sd_ratio_win_asked_cr / sqrt(n_ratio_win_asked_cr)) if n_ratio_win_asked_cr>=2
generate low_ratio_win_asked_cr =mean_ratio_win_asked_cr - invttail(n_ratio_win_asked_cr-1,0.05)*(sd_ratio_win_asked_cr / sqrt(n_ratio_win_asked_cr)) if n_ratio_win_asked_cr>=2
generate hi_ratio_winpos_asked_cr = mean_ratio_winpos_asked_cr + invttail(n_ratio_winpos_asked_cr-1,0.05)*(sd_ratio_winpos_asked_cr / sqrt(n_ratio_winpos_asked_cr)) if n_ratio_winpos_asked_cr>=2
generate low_ratio_winpos_asked_cr =mean_ratio_winpos_asked_cr - invttail(n_ratio_winpos_asked_cr-1,0.05)*(sd_ratio_winpos_asked_cr / sqrt(n_ratio_winpos_asked_cr)) if n_ratio_winpos_asked_cr>=2
generate hi_ratio_win_minley = mean_ratio_win_minley + invttail(n_ratio_win_minley-1,0.05)*(sd_ratio_win_minley / sqrt(n_ratio_win_minley)) if n_ratio_win_minley>=2
generate low_ratio_win_minley =mean_ratio_win_minley - invttail(n_ratio_win_minley-1,0.05)*(sd_ratio_win_minley / sqrt(n_ratio_win_minley)) if n_ratio_win_minley>=2
generate hi_ratio_win_minley_cr = mean_ratio_win_minley_cr + invttail(n_ratio_win_minley_cr-1,0.05)*(sd_ratio_win_minley_cr / sqrt(n_ratio_win_minley_cr)) if n_ratio_win_minley_cr>=2
generate low_ratio_win_minley_cr =mean_ratio_win_minley_cr - invttail(n_ratio_win_minley_cr-1,0.05)*(sd_ratio_win_minley_cr / sqrt(n_ratio_win_minley_cr)) if n_ratio_win_minley_cr>=2
generate hi_ratio_wage = mean_ratio_wage + invttail(n_ratio_wage-1,0.05)*(sd_ratio_wage / sqrt(n_ratio_wage)) if n_ratio_wage>=2
generate low_ratio_wage =mean_ratio_wage - invttail(n_ratio_wage-1,0.05)*(sd_ratio_wage / sqrt(n_ratio_wage)) if n_ratio_wage>=2
generate hi_ratio_win_cprocu = mean_ratio_win_cprocu + invttail(n_ratio_win_cprocu-1,0.05)*(sd_ratio_win_cprocu / sqrt(n_ratio_win_cprocu)) if n_ratio_win_cprocu>=2
generate low_ratio_win_cprocu =mean_ratio_win_cprocu - invttail(n_ratio_win_cprocu-1,0.05)*(sd_ratio_win_cprocu / sqrt(n_ratio_win_cprocu)) if n_ratio_win_cprocu>=2
generate hi_ratio_rel_procu = mean_ratio_rel_procu + invttail(n_ratio_rel_procu-1,0.05)*(sd_ratio_rel_procu / sqrt(n_ratio_rel_procu)) if n_ratio_rel_procu>=2
generate low_ratio_rel_procu =mean_ratio_rel_procu - invttail(n_ratio_rel_procu-1,0.05)*(sd_ratio_rel_procu / sqrt(n_ratio_rel_procu)) if n_ratio_rel_procu>=2
generate hi_ratio_rel_ent = mean_ratio_rel_ent + invttail(n_ratio_rel_ent-1,0.05)*(sd_ratio_rel_ent / sqrt(n_ratio_rel_ent)) if n_ratio_rel_ent>=2
generate low_ratio_rel_ent =mean_ratio_rel_ent - invttail(n_ratio_rel_ent-1,0.05)*(sd_ratio_rel_ent / sqrt(n_ratio_rel_ent)) if n_ratio_rel_ent>=2
generate hi_ratio_dw_scian = mean_ratio_dw_scian + invttail(n_ratio_dw_scian-1,0.05)*(sd_ratio_dw_scian / sqrt(n_ratio_dw_scian)) if n_ratio_dw_scian>=2
generate low_ratio_dw_scian =mean_ratio_dw_scian - invttail(n_ratio_dw_scian-1,0.05)*(sd_ratio_dw_scian / sqrt(n_ratio_dw_scian)) if n_ratio_dw_scian>=2
generate hi_ratio_dw_giro_procu = mean_ratio_dw_giro_procu + invttail(n_ratio_dw_giro_procu-1,0.05)*(sd_ratio_dw_giro_procu / sqrt(n_ratio_dw_giro_procu)) if n_ratio_dw_giro_procu>=2
generate low_ratio_dw_giro_procu =mean_ratio_dw_giro_procu - invttail(n_ratio_dw_giro_procu-1,0.05)*(sd_ratio_dw_giro_procu / sqrt(n_ratio_dw_giro_procu)) if n_ratio_dw_giro_procu>=2
generate hi_ratio_npv = mean_ratio_npv + invttail(n_ratio_npv-1,0.05)*(sd_ratio_npv / sqrt(n_ratio_npv)) if n_ratio_npv>=2
generate low_ratio_npv =mean_ratio_npv - invttail(n_ratio_npv-1,0.05)*(sd_ratio_npv / sqrt(n_ratio_npv)) if n_ratio_npv>=2


generate hi_duration = mean_duration + invttail(n_duration-1,0.05)*(sd_duration / sqrt(n_duration)) if n_duration>=2
generate low_duration =mean_duration - invttail(n_duration-1,0.05)*(sd_duration / sqrt(n_duration)) if n_duration>=2


********************************************************************************

tab num_casefiles
keep if num_casefiles>=5

sort office_emp_law
gen id=_n			
order id
********************************************************************************

save "$directorio\DB\lawyer_dataset_collapsed.dta", replace
