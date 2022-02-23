clear

// set "filepath" to be the source folder of your CSVs
local filepath = "`c(pwd)'\..\data\output"
local files : dir "`filepath'" files "*.csv"
tempfile merged
save `merged', replace empty

foreach x of local files {
    local y = subinstr("_`x'", ".csv", ".dta", .)
    local extant_filename = "`c(pwd)'" + "\" + "`y'";    
    capture confirm file `extant_filename'
        
    if (_rc == 601) {
        local filename = "`filepath'" + "\" + "`x'";
        di "Importing `filename'..."
        import delimited "`filename'", stringcols(192 217) clear
        
        // save as Stata binary
        save "`extant_filename'", replace
    }
    else {
        // load from Stata binary
        di "Loading `extant_filename'..."
        use "`extant_filename'", clear
    }
    
    // remove committee-level variables
    drop ///
        committee__affiliated_committee_ ///
        committee__city ///
        committee__committee_id ///
        committee__committee_type ///
        committee__committee_type_full ///
        committee__convert_to_pac_flag ///
        committee__cycle ///
        committee__cycles__0 ///
        committee__cycles__1 ///
        committee__cycles__2 ///
        committee__cycles__3 ///
        committee__cycles__4 ///
        committee__cycles__5 ///
        committee__cycles__6 ///
        committee__cycles__7 ///
        committee__cycles__8 ///
        committee__cycles__9 ///
        committee__cycles_has_activity__ ///
        v35 ///
        v36 ///
        v37 ///
        v38 ///
        v39 ///
        v40 ///
        v41 ///
        v42 ///
        v43 ///
        committee__cycles_has_financial_ ///
        v45 ///
        v46 ///
        v47 ///
        v48 ///
        v49 ///
        v50 ///
        v51 ///
        v52 ///
        v53 ///
        committee__designation ///
        committee__designation_full ///
        committee__filing_frequency ///
        committee__first_f1_date ///
        committee__first_file_date ///
        committee__former_candidate_elec ///
        committee__former_candidate_id ///
        committee__former_candidate_name ///
        committee__former_committee_name ///
        committee__is_active ///
        committee__last_cycle_has_activi ///
        committee__last_cycle_has_financ ///
        committee__last_f1_date ///
        committee__last_file_date ///
        committee__name ///
        committee__organization_type ///
        committee__organization_type_ful ///
        committee__party ///
        committee__party_full ///
        committee__sponsor_candidate_ids ///
        committee__state ///
        committee__state_full ///
        committee__street_1 ///
        committee__street_2 ///
        committee__treasurer_name ///
        committee__zip ///
        committee_id ///
        committee_name ///
        contributor
    
    // generate id
    gen id = subinstr("`x'", ".csv", "", .)
    replace id = subinstr(id, "-", "", .)
    replace id = subinstr(id, "actblue", "", .)
    gen _total = _n
    tostring _total, gen(_total_string) format("%08.0f")
    replace id = id + _total_string
    destring id, replace
    format id %16.0g
    drop _*
    
    // remove non-presidential observations
    drop if substr(candidate_id, 1, 1) != "P"
    
    // clean up variable names
    rename contributor__city com_city
    rename contributor__committee_id com_committee_id
    rename contributor__committee_type com_committee_type
    rename contributor__committee_type_full com_committee_type_full
    rename contributor__convert_to_pac_flag com_convert_to_pac_flag
    rename contributor__cycle com_cycle
    rename contributor__cycles__0 com_cycles_00
    rename contributor__cycles__1 com_cycles_01
    rename contributor__cycles__2 com_cycles_02
    rename contributor__cycles__3 com_cycles_03
    rename contributor__cycles__4 com_cycles_04
    rename contributor__cycles__5 com_cycles_05
    rename contributor__cycles__6 com_cycles_06
    rename contributor__cycles__7 com_cycles_07
    rename contributor__cycles__8 com_cycles_08
    rename contributor__cycles__9 com_cycles_09
    rename contributor__cycles__10 com_cycles_10
    rename contributor__cycles__11 com_cycles_11
    rename contributor__cycles__12 com_cycles_12
    rename contributor__cycles__13 com_cycles_13
    rename contributor__cycles__14 com_cycles_14
    rename contributor__cycles__15 com_cycles_15
    rename contributor__cycles__16 com_cycles_16
    rename contributor__cycles__17 com_cycles_17
    rename contributor__cycles__18 com_cycles_18
    rename contributor__cycles__19 com_cycles_19
    rename contributor__cycles__20 com_cycles_20
    rename contributor__cycles__21 com_cycles_21
    rename contributor__cycles__22 com_cycles_22
    rename contributor__cycles__23 com_cycles_23
    rename contributor__cycles_has_activity com_cycles_has_activity_00
    rename v127 com_cycles_has_activity_01
    rename v128 com_cycles_has_activity_02
    rename v129 com_cycles_has_activity_03
    rename v130 com_cycles_has_activity_04
    rename v131 com_cycles_has_activity_05
    rename v132 com_cycles_has_activity_06
    rename v133 com_cycles_has_activity_07
    rename v134 com_cycles_has_activity_08
    rename v135 com_cycles_has_activity_09
    rename v136 com_cycles_has_activity_10
    rename v137 com_cycles_has_activity_11
    rename v138 com_cycles_has_activity_12
    rename v139 com_cycles_has_activity_13
    rename v140 com_cycles_has_activity_14
    rename v141 com_cycles_has_activity_15
    rename v142 com_cycles_has_activity_16
    rename v143 com_cycles_has_activity_17
    rename v144 com_cycles_has_activity_18
    rename v145 com_cycles_has_activity_19
    rename v146 com_cycles_has_activity_20
    rename v147 com_cycles_has_activity_21
    rename v148 com_cycles_has_activity_22
    rename v149 com_cycles_has_activity_23
    rename v150 com_cycles_has_activity_24
    rename v151 com_cycles_has_activity_25
    rename contributor__cycles_has_financia com_cycles_has_financial_00
    rename v153 com_cycles_has_financial_01
    rename v154 com_cycles_has_financial_02
    rename v155 com_cycles_has_financial_03
    rename v156 com_cycles_has_financial_04
    rename v157 com_cycles_has_financial_05
    rename v158 com_cycles_has_financial_06
    rename v159 com_cycles_has_financial_07
    rename v160 com_cycles_has_financial_08
    rename v161 com_cycles_has_financial_09
    rename v162 com_cycles_has_financial_10
    rename v163 com_cycles_has_financial_11
    rename v164 com_cycles_has_financial_12
    rename v165 com_cycles_has_financial_13
    rename v166 com_cycles_has_financial_14
    rename v167 com_cycles_has_financial_15
    rename v168 com_cycles_has_financial_16
    rename v169 com_cycles_has_financial_17
    rename v170 com_cycles_has_financial_18
    rename v171 com_cycles_has_financial_19
    rename v172 com_cycles_has_financial_20
    rename v173 com_cycles_has_financial_21
    rename v174 com_cycles_has_financial_22
    rename v175 com_cycles_has_financial_23
    rename v176 com_cycles_has_financial_24
    rename contributor__designation com_designation
    rename contributor__designation_full com_designation_full
    rename contributor__filing_frequency com_filing_frequency
    rename contributor__first_f1_date com_first_f1_date
    rename contributor__first_file_date com_first_file_date
    rename contributor__former_candidate_el com_former_candidate_el
    rename contributor__former_candidate_id com_former_candidate_id
    rename contributor__former_candidate_na com_former_candidate_na
    rename contributor__former_committee_na com_former_committee_na
    rename contributor__is_active com_is_active
    rename contributor__last_cycle_has_acti com_last_cycle_has_active
    rename contributor__last_cycle_has_fina com_last_cycle_has_financial
    rename contributor__last_f1_date com_last_f1_date
    rename contributor__last_file_date com_last_file_date
    rename contributor__name com_name
    rename contributor__organization_type com_organization_type
    rename contributor__organization_type_f com_organization_type_full
    rename contributor__party com_party
    rename contributor__party_full com_party_full
    rename contributor__sponsor_candidate_i com_sponsor_candidate_ids
    rename v197 com_sponsor_candidate_ids_1
    rename contributor__state com_state
    rename contributor__state_full com_state_full
    rename contributor__street_1 com_street_1
    rename contributor__street_2 com_street_2
    rename contributor__treasurer_name com_treasurer_name
    rename contributor__zip com_zip
    rename contributor__affiliated_committe com_affiliated_committee 
    rename contributor__candidate_ids__0 com_candidate_ids_00
    rename contributor__candidate_ids__1 com_candidate_ids_01
    rename contributor__candidate_ids__2 com_candidate_ids_02

    // amendment indicator
    gen byte amendment = .
    replace amendment = 0 if amendment_indicator == "N"
    replace amendment = 1 if amendment_indicator == "A"
    replace amendment = 2 if amendment_indicator == "T"
    replace amendment = 3 if amendment_indicator == "C"
    replace amendment = 4 if amendment_indicator == "M"
    replace amendment = 5 if amendment_indicator == "S"
    drop amendment_indicator amendment_indicator_desc

    // contributor committee type
    gen byte _com_committee_type = .
    replace _com_committee_type = 0 if com_committee_type == "C"
    replace _com_committee_type = 1 if com_committee_type == "D"
    replace _com_committee_type = 2 if com_committee_type == "E"
    replace _com_committee_type = 3 if com_committee_type == "H"
    replace _com_committee_type = 4 if com_committee_type == "I"
    replace _com_committee_type = 5 if com_committee_type == "N"
    replace _com_committee_type = 6 if com_committee_type == "O"
    replace _com_committee_type = 7 if com_committee_type == "P"
    replace _com_committee_type = 8 if com_committee_type == "Q"
    replace _com_committee_type = 9 if com_committee_type == "S"
    replace _com_committee_type = 10 if com_committee_type == "U"
    replace _com_committee_type = 11 if com_committee_type == "V"
    replace _com_committee_type = 12 if com_committee_type == "W"
    replace _com_committee_type = 13 if com_committee_type == "X"
    replace _com_committee_type = 14 if com_committee_type == "Y"
    replace _com_committee_type = 15 if com_committee_type == "Z"
    drop com_committee_type com_committee_type_full 
    rename _com_committee_type com_committee_type
    
    // contributor committee designation
    gen byte _com_designation = .
    replace _com_designation = 0 if com_designation == "A"
    replace _com_designation = 1 if com_designation == "J"
    replace _com_designation = 2 if com_designation == "P"
    replace _com_designation = 3 if com_designation == "U"
    replace _com_designation = 4 if com_designation == "B"
    replace _com_designation = 5 if com_designation == "D"
    drop com_designation com_designation_full
    rename _com_designation com_designation

    // contributor committee filing frequency
    gen byte _com_filing_frequency = .
    replace _com_filing_frequency = 0 if com_filing_frequency == "A"
    replace _com_filing_frequency = 1 if com_filing_frequency == "D"
    replace _com_filing_frequency = 2 if com_filing_frequency == "M"
    replace _com_filing_frequency = 3 if com_filing_frequency == "Q"
    replace _com_filing_frequency = 4 if com_filing_frequency == "T"
    replace _com_filing_frequency = 5 if com_filing_frequency == "W"
    drop com_filing_frequency
    rename _com_filing_frequency com_filing_frequency

    // com_first_f1_date
    gen _com_first_f1_date = date(com_first_f1_date, "YMD")
    format _com_first_f1_date %td
    drop com_first_f1_date
    rename _com_first_f1_date com_first_f1_date

    // com_first_file_date
    gen _com_first_file_date = date(com_first_file_date, "YMD")
    format _com_first_file_date %td
    drop com_first_file_date
    rename _com_first_file_date com_first_file_date

    // com_last_f1_date
    gen _com_last_f1_date = date(com_last_f1_date, "YMD")
    format _com_last_f1_date %td
    drop com_last_f1_date
    rename _com_last_f1_date com_last_f1_date

    // com_last_file_date
    gen _com_last_file_date = date(com_last_file_date, "YMD")
    format _com_last_file_date %td
    drop com_last_file_date
    rename _com_last_file_date com_last_file_date

    // contributor committee organization type
    gen byte _com_organization_type = .
    replace _com_organization_type = 0 if com_organization_type == "C"
    replace _com_organization_type = 1 if com_organization_type == "L"
    replace _com_organization_type = 2 if com_organization_type == "M"
    replace _com_organization_type = 3 if com_organization_type == "T"
    replace _com_organization_type = 4 if com_organization_type == "V"
    replace _com_organization_type = 5 if com_organization_type == "W"
    drop com_organization_type com_organization_type_full
    rename _com_organization_type com_organization_type
    
    // contributor party
    gen _com_party = .
    replace _com_party = 0 if com_party == "DEM"
    replace _com_party = 1 if com_party == "REP"    
    replace _com_party = 2 if com_party == "AIC"
    replace _com_party = 3 if com_party == "AIP"
    replace _com_party = 4 if com_party == "AMP"
    replace _com_party = 5 if com_party == "APF"
    replace _com_party = 6 if com_party == "CIT"
    replace _com_party = 7 if com_party == "CMP"
    replace _com_party = 8 if com_party == "COM"
    replace _com_party = 9 if com_party == "CRV"
    replace _com_party = 10 if com_party == "CST"
    replace _com_party = 11 if com_party == "DC "
    replace _com_party = 12 if com_party == "DFL"
    replace _com_party = 13 if com_party == "FLP"
    replace _com_party = 14 if com_party == "GRE"
    replace _com_party = 15 if com_party == "GWP"
    replace _com_party = 16 if com_party == "HRP"
    replace _com_party = 17 if com_party == "IAP"
    replace _com_party = 18 if com_party == "ICD"
    replace _com_party = 19 if com_party == "IGD"
    replace _com_party = 20 if com_party == "IND"
    replace _com_party = 21 if com_party == "LAB"
    replace _com_party = 22 if com_party == "LBL"
    replace _com_party = 23 if com_party == "LBR"
    replace _com_party = 24 if com_party == "LBU"
    replace _com_party = 25 if com_party == "LFT"
    replace _com_party = 26 if com_party == "LIB"
    replace _com_party = 27 if com_party == "LRU"
    replace _com_party = 28 if com_party == "NAP"
    replace _com_party = 29 if com_party == "NDP"
    replace _com_party = 30 if com_party == "NLP"
    replace _com_party = 31 if com_party == "PAF"
    replace _com_party = 32 if com_party == "PFD"
    replace _com_party = 33 if com_party == "POP"
    replace _com_party = 34 if com_party == "PPD"
    replace _com_party = 35 if com_party == "PPY"
    replace _com_party = 36 if com_party == "REF"
    replace _com_party = 37 if com_party == "RTL"
    replace _com_party = 38 if com_party == "SLP"
    replace _com_party = 39 if com_party == "SUS"
    replace _com_party = 40 if com_party == "SWP"
    replace _com_party = 41 if com_party == "THD"
    replace _com_party = 42 if com_party == "TWR"
    replace _com_party = 43 if com_party == "TX "
    replace _com_party = 44 if com_party == "USP"
    replace _com_party = 45 if com_party == "WFP"
    replace _com_party = 45 if com_party == "WOR"
    replace _com_party = 46 if com_party == "OTH"
    drop com_party com_party_full
    rename _com_party com_party

    // contribution receipt date
    gen _crd = contribution_receipt_date
    replace _crd = substr(_crd, 1, 10)
    gen _contribution_receipt_date = date(_crd, "YMD")
    format _contribution_receipt_date %td
    drop _crd contribution_receipt_date
    rename _contribution_receipt_date contribution_receipt_date

    // filing form
    gen _filing_form = .
    replace _filing_form = 0 if filing_form == "F1"
    replace _filing_form = 1 if filing_form == "F1M"
    replace _filing_form = 2 if filing_form == "F2"
    replace _filing_form = 3 if filing_form == "F3"
    replace _filing_form = 4 if filing_form == "F3P"
    replace _filing_form = 5 if filing_form == "F3X"
    replace _filing_form = 6 if filing_form == "F3L"
    replace _filing_form = 7 if filing_form == "F4"
    replace _filing_form = 8 if filing_form == "F5"
    replace _filing_form = 9 if filing_form == "F24"
    replace _filing_form = 10 if filing_form == "F6"
    replace _filing_form = 11 if filing_form == "F7"
    replace _filing_form = 12 if filing_form == "F8"
    replace _filing_form = 13 if filing_form == "F9"
    replace _filing_form = 14 if filing_form == "F13"
    replace _filing_form = 15 if filing_form == "F99"
    replace _filing_form = 16 if filing_form == "F10"
    replace _filing_form = 17 if filing_form == "F11"
    replace _filing_form = 18 if filing_form == "F12"
    replace _filing_form = 19 if filing_form == "RFAI"
    drop filing_form
    rename _filing_form filing_form
    
    // line number
    gen _line_number = .
    replace _line_number = 0 if filing_form == 3 & line_number == "11AI"
    replace _line_number = 1 if filing_form == 3 & line_number == "11B"
    replace _line_number = 2 if filing_form == 3 & line_number == "11C"
    replace _line_number = 3 if filing_form == 3 & line_number == "11D"
    replace _line_number = 4 if filing_form == 3 & line_number == "12"
    replace _line_number = 5 if filing_form == 3 & line_number == "13A"
    replace _line_number = 6 if filing_form == 3 & line_number == "13B"
    replace _line_number = 7 if filing_form == 3 & line_number == "14"
    replace _line_number = 8 if filing_form == 3 & line_number == "15"
    replace _line_number = 9 if filing_form == 4 & line_number == "16"
    replace _line_number = 10 if filing_form == 4 & line_number == "17A"
    replace _line_number = 11 if filing_form == 4 & line_number == "17B"
    replace _line_number = 12 if filing_form == 4 & line_number == "17C"
    replace _line_number = 13 if filing_form == 4 & line_number == "17D"
    replace _line_number = 14 if filing_form == 4 & line_number == "18"
    replace _line_number = 15 if filing_form == 4 & line_number == "19A"
    replace _line_number = 16 if filing_form == 4 & line_number == "19B"
    replace _line_number = 17 if filing_form == 4 & line_number == "20A"
    replace _line_number = 18 if filing_form == 4 & line_number == "20B"
    replace _line_number = 19 if filing_form == 4 & line_number == "20C"
    replace _line_number = 20 if filing_form == 4 & line_number == "21"
    replace _line_number = 21 if filing_form == 5 & line_number == "11AI"
    replace _line_number = 22 if filing_form == 5 & line_number == "11B"
    replace _line_number = 23 if filing_form == 5 & line_number == "11C"
    replace _line_number = 24 if filing_form == 5 & line_number == "12"
    replace _line_number = 25 if filing_form == 5 & line_number == "13"
    replace _line_number = 26 if filing_form == 5 & line_number == "14"
    replace _line_number = 27 if filing_form == 5 & line_number == "15"
    replace _line_number = 28 if filing_form == 5 & line_number == "16"
    replace _line_number = 29 if filing_form == 5 & line_number == "17"
    drop line_number line_number_label
    rename _line_number line_number

    // load date
    gen _ld = load_date
    replace _ld = subinstr(_ld, "T", " ", .)
    replace _ld = subinstr(_ld, ".", ":", .)
    replace _ld = substr(_ld, 1, 19)
    gen _load_date = clock(_ld, "YMDhms")
    format _load_date %tc
    drop load_date _ld
    rename _load_date load_date

    // receipt type
    gen int _receipt_type = .
    replace _receipt_type = 0 if receipt_type == "10"
    replace _receipt_type = 1 if receipt_type == "10J"
    replace _receipt_type = 2 if receipt_type == "11"
    replace _receipt_type = 3 if receipt_type == "11J"
    replace _receipt_type = 4 if receipt_type == "12"
    replace _receipt_type = 5 if receipt_type == "13"
    replace _receipt_type = 6 if receipt_type == "15"
    replace _receipt_type = 7 if receipt_type == "15C"
    replace _receipt_type = 8 if receipt_type == "15E"
    replace _receipt_type = 9 if receipt_type == "15F"
    replace _receipt_type = 10 if receipt_type == "15I"
    replace _receipt_type = 11 if receipt_type == "15J"
    replace _receipt_type = 12 if receipt_type == "15T"
    replace _receipt_type = 13 if receipt_type == "15Z"
    replace _receipt_type = 14 if receipt_type == "16C"
    replace _receipt_type = 15 if receipt_type == "16F"
    replace _receipt_type = 16 if receipt_type == "16G"
    replace _receipt_type = 17 if receipt_type == "16H"
    replace _receipt_type = 18 if receipt_type == "16J"
    replace _receipt_type = 19 if receipt_type == "16K"
    replace _receipt_type = 20 if receipt_type == "16L"
    replace _receipt_type = 21 if receipt_type == "16R"
    replace _receipt_type = 22 if receipt_type == "16U"
    replace _receipt_type = 23 if receipt_type == "17R"
    replace _receipt_type = 24 if receipt_type == "17U"
    replace _receipt_type = 25 if receipt_type == "17Y"
    replace _receipt_type = 26 if receipt_type == "17Z"
    replace _receipt_type = 27 if receipt_type == "18G"
    replace _receipt_type = 28 if receipt_type == "18H"
    replace _receipt_type = 29 if receipt_type == "18J"
    replace _receipt_type = 30 if receipt_type == "18K"
    replace _receipt_type = 31 if receipt_type == "18L"
    replace _receipt_type = 32 if receipt_type == "18U"
    replace _receipt_type = 33 if receipt_type == "19"
    replace _receipt_type = 34 if receipt_type == "19J"
    replace _receipt_type = 35 if receipt_type == "20"
    replace _receipt_type = 36 if receipt_type == "20A"
    replace _receipt_type = 37 if receipt_type == "20B"
    replace _receipt_type = 38 if receipt_type == "20C"
    replace _receipt_type = 39 if receipt_type == "20D"
    replace _receipt_type = 40 if receipt_type == "20F"
    replace _receipt_type = 41 if receipt_type == "20G"
    replace _receipt_type = 42 if receipt_type == "20R"
    replace _receipt_type = 43 if receipt_type == "20V"
    replace _receipt_type = 44 if receipt_type == "20Y"
    replace _receipt_type = 45 if receipt_type == "21Y"
    replace _receipt_type = 46 if receipt_type == "22G"
    replace _receipt_type = 47 if receipt_type == "22H"
    replace _receipt_type = 48 if receipt_type == "22J"
    replace _receipt_type = 49 if receipt_type == "22K"
    replace _receipt_type = 50 if receipt_type == "22L"
    replace _receipt_type = 51 if receipt_type == "22R"
    replace _receipt_type = 52 if receipt_type == "22U"
    replace _receipt_type = 53 if receipt_type == "22X"
    replace _receipt_type = 54 if receipt_type == "22Y"
    replace _receipt_type = 55 if receipt_type == "22Z"
    replace _receipt_type = 56 if receipt_type == "23Y"
    replace _receipt_type = 57 if receipt_type == "24A"
    replace _receipt_type = 58 if receipt_type == "24C"
    replace _receipt_type = 59 if receipt_type == "24E"
    replace _receipt_type = 60 if receipt_type == "24F"
    replace _receipt_type = 61 if receipt_type == "24G"
    replace _receipt_type = 62 if receipt_type == "24H"
    replace _receipt_type = 63 if receipt_type == "24I"
    replace _receipt_type = 64 if receipt_type == "24K"
    replace _receipt_type = 65 if receipt_type == "24N"
    replace _receipt_type = 66 if receipt_type == "24P"
    replace _receipt_type = 67 if receipt_type == "24R"
    replace _receipt_type = 68 if receipt_type == "24T"
    replace _receipt_type = 69 if receipt_type == "24U"
    replace _receipt_type = 70 if receipt_type == "24Z"
    replace _receipt_type = 71 if receipt_type == "28L"
    replace _receipt_type = 72 if receipt_type == "29"
    replace _receipt_type = 73 if receipt_type == "30"
    replace _receipt_type = 74 if receipt_type == "30T"
    replace _receipt_type = 75 if receipt_type == "30K"
    replace _receipt_type = 76 if receipt_type == "30G"
    replace _receipt_type = 77 if receipt_type == "30J"
    replace _receipt_type = 78 if receipt_type == "30F"
    replace _receipt_type = 79 if receipt_type == "31"
    replace _receipt_type = 80 if receipt_type == "31T"
    replace _receipt_type = 81 if receipt_type == "31K"
    replace _receipt_type = 82 if receipt_type == "31G"
    replace _receipt_type = 83 if receipt_type == "31J"
    replace _receipt_type = 84 if receipt_type == "31F"
    replace _receipt_type = 85 if receipt_type == "32"
    replace _receipt_type = 86 if receipt_type == "32T"
    replace _receipt_type = 87 if receipt_type == "32K"
    replace _receipt_type = 88 if receipt_type == "32G"
    replace _receipt_type = 89 if receipt_type == "32J"
    replace _receipt_type = 90 if receipt_type == "32F"
    replace _receipt_type = 91 if receipt_type == "40"
    replace _receipt_type = 92 if receipt_type == "40Y"
    replace _receipt_type = 93 if receipt_type == "40T"
    replace _receipt_type = 94 if receipt_type == "40Z"
    replace _receipt_type = 95 if receipt_type == "41"
    replace _receipt_type = 96 if receipt_type == "41Y"
    replace _receipt_type = 97 if receipt_type == "41T"
    replace _receipt_type = 98 if receipt_type == "41Z"
    replace _receipt_type = 99 if receipt_type == "42"
    replace _receipt_type = 100 if receipt_type == "42Y"
    replace _receipt_type = 101 if receipt_type == "42T"
    replace _receipt_type = 102 if receipt_type == "42Z"
    drop receipt_type receipt_type_desc
    rename _receipt_type receipt_type

    // recipient committee designation
    gen byte _recipient_committee_designation = .
    replace _recipient_committee_designation = 0 if recipient_committee_designation == "A"
    replace _recipient_committee_designation = 1 if recipient_committee_designation == "J"
    replace _recipient_committee_designation = 2 if recipient_committee_designation == "P"
    replace _recipient_committee_designation = 3 if recipient_committee_designation == "U"
    replace _recipient_committee_designation = 4 if recipient_committee_designation == "B"
    replace _recipient_committee_designation = 5 if recipient_committee_designation == "D"
    drop recipient_committee_designation
    rename _recipient_committee_designation recipient_committee_designation

    // recipient committee type
    gen byte _recipient_committee_type = .
    replace _recipient_committee_type = 0 if recipient_committee_type == "C"
    replace _recipient_committee_type = 1 if recipient_committee_type == "D"
    replace _recipient_committee_type = 2 if recipient_committee_type == "E"
    replace _recipient_committee_type = 3 if recipient_committee_type == "H"
    replace _recipient_committee_type = 4 if recipient_committee_type == "I"
    replace _recipient_committee_type = 5 if recipient_committee_type == "N"
    replace _recipient_committee_type = 6 if recipient_committee_type == "O"
    replace _recipient_committee_type = 7 if recipient_committee_type == "P"
    replace _recipient_committee_type = 8 if recipient_committee_type == "Q"
    replace _recipient_committee_type = 9 if recipient_committee_type == "S"
    replace _recipient_committee_type = 10 if recipient_committee_type == "U"
    replace _recipient_committee_type = 11 if recipient_committee_type == "V"
    replace _recipient_committee_type = 12 if recipient_committee_type == "W"
    replace _recipient_committee_type = 13 if recipient_committee_type == "X"
    replace _recipient_committee_type = 14 if recipient_committee_type == "Y"
    replace _recipient_committee_type = 15 if recipient_committee_type == "Z"
    drop recipient_committee_type 
    rename _recipient_committee_type recipient_committee_type

    // report type
    gen byte _report_type = .
    replace _report_type = 0 if report_type == "10D"
    replace _report_type = 1 if report_type == "10G"
    replace _report_type = 2 if report_type == "10P"
    replace _report_type = 3 if report_type == "10R"
    replace _report_type = 4 if report_type == "10S"
    replace _report_type = 5 if report_type == "12C"
    replace _report_type = 6 if report_type == "12G"
    replace _report_type = 7 if report_type == "12P"
    replace _report_type = 8 if report_type == "12R"
    replace _report_type = 9 if report_type == "12S"
    replace _report_type = 10 if report_type == "30D"
    replace _report_type = 11 if report_type == "30G"
    replace _report_type = 12 if report_type == "30P"
    replace _report_type = 13 if report_type == "30R"
    replace _report_type = 14 if report_type == "30S"
    replace _report_type = 15 if report_type == "60D"
    replace _report_type = 16 if report_type == "M1"
    replace _report_type = 17 if report_type == "M10"
    replace _report_type = 18 if report_type == "M11"
    replace _report_type = 19 if report_type == "M12"
    replace _report_type = 20 if report_type == "M2"
    replace _report_type = 21 if report_type == "M3"
    replace _report_type = 22 if report_type == "M4"
    replace _report_type = 23 if report_type == "M5"
    replace _report_type = 24 if report_type == "M6"
    replace _report_type = 25 if report_type == "M7"
    replace _report_type = 26 if report_type == "M8"
    replace _report_type = 27 if report_type == "M9"
    replace _report_type = 28 if report_type == "MY"
    replace _report_type = 29 if report_type == "Q1"
    replace _report_type = 30 if report_type == "Q2"
    replace _report_type = 31 if report_type == "Q3"
    replace _report_type = 32 if report_type == "TER"
    replace _report_type = 33 if report_type == "YE"
    replace _report_type = 34 if report_type == "ADJ"
    replace _report_type = 35 if report_type == "CA"
    replace _report_type = 36 if report_type == "90S"
    replace _report_type = 37 if report_type == "90D"
    replace _report_type = 38 if report_type == "48"
    replace _report_type = 39 if report_type == "24"
    replace _report_type = 40 if report_type == "M7S"
    replace _report_type = 41 if report_type == "MSA"
    replace _report_type = 42 if report_type == "MYS"
    replace _report_type = 43 if report_type == "Q2S"
    replace _report_type = 44 if report_type == "QSA"
    replace _report_type = 45 if report_type == "QYS"
    replace _report_type = 46 if report_type == "QYE"
    replace _report_type = 47 if report_type == "QMS"
    replace _report_type = 48 if report_type == "MSY"
    drop report_type
    rename _report_type report_type

    // order
    order *, alphabetic
    order id, first

    // save
    append using `merged'
    save `merged', replace
}

// helper variables
gen contribution_receipt_year = year(contribution_receipt_date)
gen contribution_receipt_month = month(contribution_receipt_date)
recode contribution_receipt_month (1/3=1) (4/6=2) (7/9=3) (10/12=4), ///
    gen(contribution_receipt_quarter)
order contribution_receipt_month, after(contribution_receipt_date)
order contribution_receipt_quarter, after(contribution_receipt_month)
order contribution_receipt_year, after(contribution_receipt_quarter)
    
// clear variable names
foreach var of varlist _all {
    label var `var' ""
}

// values labels
label define amendment 0 "N New" ///
    1 "A Amendment" ///
    2 "T Terminated" ///
    3 "C Consolidated" ///
    4 "M Multicandidate" ///
    5 "S Secondary"
label values amendment amendment

label define committee_designation 0 "A authorized by a candidate" ///
    1 "J join fundraising committee" ///
    2 "P principal campaign committee of a candidate" ///
    3 "U unauthorized" ///
    4 "B lobbyist/registrant PAC" ///
    5 "D leadership PAC"
label values com_designation recipient_committee_designation committee_designation

label define committee_type 0 "C communication cost" ///
    1 "D delegate" ///
    2 "E electioneering communication" ///
    3 "H House" ///
    4 "I independent expenditor (person or group)" ///
    5 "N PAC - nonqualified" ///
    6 "O independent expenditure-only (super PACs)" ///
    7 "P presidential" ///
    8 "Q PAC - qualified" /// 
    9 "S Senate" ///
    10 "U single candidate independent expenditure" ///
    11 "V PAC with non-contribution account, nonqualified" ///
    12 "W PAC with non-contribution account, qualified" ///
    13 "X party, nonqualified" ///
    14 "Y party, qualified" ///
    15 "Z national party non-federal account"
label values com_committee_type recipient_committee_type committee_type

label define filing_frequency 0 "A Administratively terminated" ///
    1 "D Debt" ///
    2 "M Monthy filer" ///
    3 "Q Quarterly filer" ///
    4 "T Terminated" ///
    5 "W Waived"
label values com_filing_frequency filing_frequency

label define form_type 0 "F1 Statements Of Organization (Form 1)" ///
    1 "F1M Multicandidate status (Form 1M)" ///
    2 "F2 Statements Of Candidacy (Form 2)" ///
    3 "F3 Congressional candidate financial reports (Form 3)" ///
    4 "F3P Presidential financial reports (Form 3P)" ///
    5 "F3X PAC and party financial reports (Form 3X)" ///
    6 "F3L Bundled contributions reports (Form 3L)" ///
    7 "F4 Convention financial reports (Form 4)" ///
    8 "F5 Independent expenditure reports and notices (by a person or group) (Form 5)" ///
    9 "F24 Independent expenditure reports and notices (by a registered committee) (Form 24)" ///
    10 "F6 Contributions and loans notices (Form 6)" ///
    11 "F7 Communication cost reports (Form 7)" ///
    12 "F8 Debt settlement plans (Form 8)" ///
    13 "F9 Electioneering communications notices (Form 9)" ///
    14 "F13 Inaugural committee donation reports (Form 13)" ///
    15 "F99 Miscellaneous submission (Form 99)" ///
    16 "F10 Expenditure of personal funds notices (Form 10)" ///
    17 "F11 Opposition personal funds notices (Form 11)" ///
    18 "F12 Suspension of increased limits notices (Form 12)" ///
    19 "RFAI Request For Additional Information (RFAI)"
label values filing_form form_type

label define line_number 0 "F3-11AI Contributions from individuals (Line 11ai)" ///
    1 "F3-11B Contributions from political party committees (Line 11b)" ///
    2 "F3-11C Contributions from other political committees (Line 11c)" ///
    3 "F3-11D Contributions from the candidate (Line 11d)" ///
    4 "F3-12  Transfers from authorized committees (Line 12)" ///
    5 "F3-13A Loans received from the candidate (Line 13a)" ///
    6 "F3-13B All other loans (Line 13b)" ///
    7 "F3-14  Offsets to operating expenditures (Line 14)" ///
    8 "F3-15  Other receipts (Line 15)" ///
    9 "F3P-16 Federal funds (Line 16)" ///
    10 "F3P-17A Contributions from individuals (Line 17ai)" ///
    11 "F3P-17B Contributions from political party committees (Line 17b)" ///
    12 "F3P-17C Contributions from other political committees (Line 17c)" ///
    13 "F3P-17D Contributions from the candidate (Line 17d)" ///
    14 "F3P-18 Transfers from other authorized committees (Line 18)" ///
    15 "F3P-19A Loans received from candidate (Line 19a)" ///
    16 "F3P-19B Other loans (Line 19b)" ///
    17 "F3P-20A Offsets to operating expenditures - operating (Line 20a)" ///
    18 "F3P-20B Offsets to operating expenditures - fundraising (Line 20b)" ///
    19 "F3P-20C Offsets to operating expenditures - legal and accounting (Line 20c)" ///
    20 "F3P-21 Other receipts (Line 21)" ///
    21 "F3X-11AI Contributions from individuals (Line 11ai)" ///
    22 "F3X-11B Contributions from political party committees (Line 11b)" ///
    23 "F3X-11C Contributions from other political committees (Line 11c)" ///
    24 "F3X-12 Transfers from affiliated committees (Line 12)" ///
    25 "F3X-13 Loans received (Line 13)" ///
    26 "F3X-14 Loan repayments received (Line 14)" ///
    27 "F3X-15 Offsets to operating expenditures (Line 15)" ///
    28 "F3X-16 Refunds of contributions made to federal candidates and other political committees (Line 16)" ///
    29 "F3X-17 Other federal receipts (Line 17)"
label values line_number line_number

label define organization_type 0 "C corporation" ///
    1 "L labor organization" ///
    2 "M membership organization" ///
    3 "T trade association" ///
    4 "V cooperative" ///
    5 "W corporation without capital stock"
label values com_organization_type organization_type

label define party 0 "DEM Democratic" ///
    1 "REP Republican" ///
    2 "AIC American Independent Conservative" ///
    3 "AIP American Independent Party" ///
    4 "AMP American Party" ///
    5 "APF American People's Freedom Party" ///
    6 "CIT Citizens' Party" ///
    7 "CMP Commonwealth Party of the US" ///
    8 "COM Communist Party" ///
    9 "CRV Conservative Party" ///
    10 "CST Constitutional" ///
    11 "DC Democratic/Conservative" ///
    12 "DFL Democratic-Farm-Labor" ///
    13 "FLP Freedom Labor Party" ///
    14 "GRE Green Party" ///
    15 "GWP George Wallace Party" ///
    16 "HRP Human Rights Party" ///
    17 "IAP Independent American Party" ///
    18 "ICD Independent Conserv. Democratic" ///
    19 "IGD Industrial Government Party" ///
    20 "IND Independent" ///
    21 "LAB US Labor Party" ///
    22 "LBL Liberal Party" ///
    23 "LBR Labor Party" ///
    24 "LBU Liberty Union Party" ///
    25 "LFT Less Federal Taxes" ///
    26 "LIB Libertarian" ///
    27 "LRU La Raza Unida" ///
    28 "NAP Prohibition Party" ///
    29 "NDP National Democratic Party" ///
    30 "NLP Natural Law Party" ///
    31 "PAF Peace and Freedom" ///
    32 "PFD Peace Freedom Party" ///
    33 "POP People Over Politics" ///
    34 "PPD Protest, Progress, Dignity" ///
    35 "PPY People's Party" ///
    36 "REF Reform Party" ///
    37 "RTL Right to Life" ///
    38 "SLP Socialist Labor Party" ///
    39 "SUS Socialist Party USA" ///
    40 "SWP Socialist Workers Party" ///
    41 "THD Theo-Dem" ///
    42 "TWR Taxpayers Without Representation" ///
    43 "TX Taxpayers" ///
    44 "USP US People's Party" ///
    45 "WFP Working Families Party" ///
    46 "OTH Other"
label values com_party party

label define receipt_type 0 "10 Contribution to Independent Expenditure-Only Committees (Super PACs), Political Committees with non-contribution accounts (Hybrid PACs) and nonfederal party 'soft money' accounts (1991-2002) from a person (individual, partnership, limited liability company, corporation, labor organization, or any other organization or group of persons)" ///
    1 "10J Memo - Recipient committee's percentage of nonfederal receipt from a person (individual, partnership, limited liability company, corporation, labor organization, or any other organization or group of persons)" ///
    2 "11 Native American Tribe contribution" ///
    3 "11J Memo - Recipient committee's percentage of contribution from Native American Tribe given to joint fundraising committee" ///
    4 "12 Nonfederal other receipt - Levin Account (Line 2)" ///
    5 "13 Inaugural donation accepted" ///
    6 "15 Contribution to political committees (other than Super PACs and Hybrid PACs) from an individual, partnership or limited liability company" ///
    7 "15C Contribution from candidate" ///
    8 "15E Earmarked contributions to political committees (other than Super PACs and Hybrid PACs) from an individual, partnership or limited liability company" ///
    9 "15F Loans forgiven by candidate" ///
    10 "15I Earmarked contribution from an individual, partnership or limited liability company received by intermediary committee and passed on in the form of contributor's check (intermediary in)" ///
    11 "15J Memo - Recipient committee's percentage of contribution from an individual, partnership or limited liability company given to joint fundraising committee" ///
    12 "15T Earmarked contribution from an individual, partnership or limited liability company received by intermediary committee and entered into intermediary's treasury (intermediary treasury in)" ///
    13 "15Z In-kind contribution received from registered filer" ///
    14 "16C Loan received from the candidate" ///
    15 "16F Loan received from bank" ///
    16 "16G Loan from individual" ///
    17 "16H Loan from registered filers" ///
    18 "16J Loan repayment from individual" ///
    19 "16K Loan repayment from from registered filer" ///
    20 "16L Loan repayment received from unregistered entity" ///
    21 "16R Loan received from registered filers" ///
    22 "16U Loan received from unregistered entity" ///
    23 "17R Contribution refund received from registered entity" ///
    24 "17U Refund/Rebate/Return received from unregistered entity" ///
    25 "17Y Refund/Rebate/Return from individual or corporation" ///
    26 "17Z Refund/Rebate/Return from candidate or committee" ///
    27 "18G Transfer in from affiliated committee" ///
    28 "18H Honorarium received" ///
    29 "18J Memo - Recipient committee's percentage of contribution from a registered committee given to joint fundraising committee" ///
    30 "18K Contribution received from registered filer" ///
    31 "18L Bundled contribution" ///
    32 "18U Contribution received from unregistered committee" ///
    33 "19 Electioneering communication donation received" ///
    34 "19J Memo - Recipient committee's percentage of Electioneering Communication donation given to joint fundraising committee" ///
    35 "20 Nonfederal disbursement - nonfederal party 'soft money' accounts (1991-2002)" ///
    36 "20A Nonfederal disbursement - Levin Account (Line 4A) Voter Registration" ///
    37 "20B Nonfederal Disbursement - Levin Account (Line 4B) Voter Identification" ///
    38 "20C Loan repayment made to candidate" ///
    39 "20D Nonfederal disbursement - Levin Account (Line 4D) Generic Campaign" ///
    40 "20F Loan repayment made to banks" ///
    41 "20G Loan repayment made to individual" ///
    42 "20R Loan repayment made to registered filer" ///
    43 "20V Nonfederal disbursement - Levin Account (Line 4C) Get Out The Vote" ///
    44 "20Y Nonfederal refund" ///
    45 "21Y Native American Tribe refund" ///
    46 "22G Loan to individual" ///
    47 "22H Loan to candidate or committee" ///
    48 "22J Loan repayment to individual" ///
    49 "22K Loan repayment to candidate or committee" ///
    50 "22L Loan repayment to bank" ///
    51 "22R Contribution refund to unregistered entity" ///
    52 "22U Loan repaid to unregistered entity" ///
    53 "22X Loan made to unregistered entity" ///
    54 "22Y Contribution refund to an individual, partnership or limited liability company" ///
    55 "22Z Contribution refund to candidate or committee" ///
    56 "23Y Inaugural donation refund" ///
    57 "24A Independent expenditure opposing election of candidate" ///
    58 "24C Coordinated party expenditure" ///
    59 "24E Independent expenditure advocating election of candidate" ///
    60 "24F Communication cost for candidate (only for Form 7 filer)" ///
    61 "24G Transfer out to affiliated committee" ///
    62 "24H Honorarium to candidate" ///
    63 "24I Earmarked contributor's check passed on by intermediary committee to intended recipient (intermediary out)" ///
    64 "24K Contribution made to nonaffiliated committee" ///
    65 "24N Communication cost against candidate (only for Form 7 filer)" ///
    66 "24P Contribution made to possible federal candidate including in-kind contributions" ///
    67 "24R Election recount disbursement" ///
    68 "24T Earmarked contribution passed to intended recipient from intermediary's treasury (treasury out)" ///
    69 "24U Contribution made to unregistered entity" ///
    70 "24Z In-kind contribution made to registered filer" ///
    71 "28L Refund of bundled contribution" ///
    72 "29 Electioneering Communication disbursement or obligation" ///
    73 "30 Convention Account receipt from an individual, partnership or limited liability company" ///
    74 "30T Convention Account receipt from Native American Tribe" ///
    75 "30K Convention Account receipt from registered filer" ///
    76 "30G Convention Account - transfer in from affiliated committee" ///
    77 "30J Convention Account - Memo - Recipient committee's percentage of contributions from an individual, partnership or limited liability company given to joint fundraising committee" ///
    78 "30F Convention Account - Memo - Recipient committee's percentage of contributions from a registered committee given to joint fundraising committee" ///
    79 "31 Headquarters Account receipt from an individual, partnership or limited liability company" ///
    80 "31T Headquarters Account receipt from Native American Tribe" ///
    81 "31K Headquarters Account receipt from registered filer" ///
    82 "31G Headquarters Account - transfer in from affiliated committee" ///
    83 "31J Headquarters Account - Memo - Recipient committee's percentage of contributions from an individual, partnership or limited liability company given to joint fundraising committee" ///
    84 "31F Headquarters Account - Memo - Recipient committee's percentage of contributions from a registered committee given to joint fundraising committee" ///
    85 "32 Recount Account receipt from an individual, partnership or limited liability company" ///
    86 "32T Recount Account receipt from Native American Tribe" ///
    87 "32K Recount Account receipt from registered filer" ///
    88 "32G Recount Account - transfer in from affiliated committee" ///
    89 "32J Recount Account - Memo - Recipient committee's percentage of contributions from an individual, partnership or limited liability company given to joint fundraising committee" ///
    90 "32F Recount Account - Memo - Recipient committee's percentage of contributions from a registered committee given to joint fundraising committee" ///
    91 "40 Convention Account disbursement" ///
    92 "40Y Convention Account refund to an individual, partnership or limited liability company" ///
    93 "40T Convention Account refund to Native American Tribe" ///
    94 "40Z Convention Account refund to registered filer" ///
    95 "41 Headquarters Account disbursement" ///
    96 "41Y Headquarters Account refund to an individual, partnership or limited liability company" ///
    97 "41T Headquarters Account refund to Native American Tribe" ///
    98 "41Z Headquarters Account refund to registered filer" ///
    99 "42 Recount Account disbursement" ///
    100 "42Y Recount Account refund to an individual, partnership or limited liability company" ///
    101 "42T Recount Account refund to Native American Tribe" ///
    102 "42Z Recount Account refund to registered filer"    
label values receipt_type receipt_type

label define report_type 0 "10D Pre-Election" ///
    1 "10G Pre-General" ///
    2 "10P Pre-Primary" ///
    3 "10R Pre-Run-Off" ///
    4 "10S Pre-Special" ///
    5 "12C Pre-Convention" ///
    6 "12G Pre-General" ///
    7 "12P Pre-Primary" ///
    8 "12R Pre-Run-Off" ///
    9 "12S Pre-Special" ///
    10 "30D Post-Election" ///
    11 "30G Post-General" ///
    12 "30P Post-Primary" ///
    13 "30R Post-Run-Off" ///
    14 "30S Post-Special" ///
    15 "60D Post-Convention" ///
    16 "M1 January Monthly" ///
    17 "M10 October Monthly" ///
    18 "M11 November Monthly" ///
    19 "M12 December Monthly" ///
    20 "M2 February Monthly" ///
    21 "M3 March Monthly" ///
    22 "M4 April Monthly" ///
    23 "M5 May Monthly" ///
    24 "M6 June Monthly" ///
    25 "M7 July Monthly" ///
    26 "M8 August Monthly" ///
    27 "M9 September Monthly" ///
    28 "MY Mid-Year Report" ///
    29 "Q1 April Quarterly" ///
    30 "Q2 July Quarterly" ///
    31 "Q3 October Quarterly" ///
    32 "TER Termination Report" ///
    33 "YE Year-End" ///
    34 "ADJ COMP ADJUST AMEND" ///
    35 "CA COMPREHENSIVE AMEND" ///
    36 "90S Post Inaugural Supplement" ///
    37 "90D Post Inaugural" ///
    38 "48 48 Hour Notification" ///
    39 "24 24 Hour Notification" ///
    40 "M7S July Monthly/Semi-Annual" ///
    41 "MSA Monthly Semi-Annual (MY)" ///
    42 "MYS Monthly Year End/Semi-Annual" ///
    43 "Q2S July Quarterly/Semi-Annual" ///
    44 "QSA Quarterly Semi-Annual (MY)" ///
    45 "QYS Quarterly Year End/Semi-Annual" ///
    46 "QYE Quarterly Semi-Annual (YE)" ///
    47 "QMS Quarterly Mid-Year/ Semi-Annual" ///
    48 "MSY Monthly Semi-Annual (YE)"
label values report_type report_type

// formatting
format image_number %18.0f
format link_id %19.0f
format sub_id %19.0f

// merge
merge m:1 id using "`c(pwd)'\act-blue-contributors.dta", ///
    keepusing(person_id similarity)
drop if _merge == 2
drop _merge
order id person_id similarity contributor_* candidate_*
order com_*, last

// compress and save
sort id
compress
save "`c(pwd)'\act-blue-presidential.dta", replace
