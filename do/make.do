clear

// set "filepath" to be the source folder of your CSVs
local filepath = "`c(pwd)'\..\data\output"
local files : dir "`filepath'" files "*.csv"
tempfile merged
save `merged', replace empty

// x = CSV basename; y = imported Stata binary; z = parsed Stata binary
foreach x of local files {
    local y = subinstr("_`x'", ".csv", ".dta", .)
    local z = subinstr("`y'", ".dta", "-parsed.dta", .)    

    local stata_binary = "`c(pwd)'" + "\" + "`y'"
    local stata_binary_parsed = "`c(pwd)'" + "\" + "`z'"

    capture confirm file `stata_binary_parsed'
        
    if (_rc == 601) {
        capture confirm file `stata_binary'
        
        if (_rc == 601) {
            local filename = "`filepath'" + "\" + "`x'"
            di "Importing `filename'..."
            import delimited "`filename'", stringcols(192 217) clear
            
            // save as Stata binary
            save `stata_binary', replace        
        }
        else {
            // load from Stata binary
            di "Loading `stata_binary'..."
            use `stata_binary', clear
        }        
    }
    else {
        // load from parsed Stata binary
        di "Loading `stata_binary_parsed'..."
        use `stata_binary_parsed', clear        
        
        // append to temp file
        append using `merged'
        save `merged', replace

        continue
    }
    
    keep candidate_id /// 
        contribution_receipt_date /// 
        contribution_receipt_amount /// 
        contributor_city /// 
        contributor_employer /// 
        contributor_name ///
        contributor_occupation ///
        contributor_state ///
        contributor_street_1 ///
        contributor_zip ///
        memo_text
        
    rename contributor_* *
    rename contribution_* *
    rename receipt_amount amount
    rename street_1 address

    // generate ID
    gen id = subinstr("`x'", ".csv", "", .)
    replace id = subinstr(id, "-", "", .)
    replace id = subinstr(id, "actblue", "", .)
    gen _total = _n
    tostring _total, gen(_total_string) format("%08.0f")
    replace id = id + _total_string
    destring id, replace
    format id %16.0g
    drop _*

    // contribution receipt date
    gen rd = receipt_date
    replace rd = substr(rd, 1, 10)
    gen _receipt_date = date(rd, "YMD")
    format _receipt_date %td
    drop rd receipt_date
    rename _receipt_date receipt_date
        
    // candidate IDs
    replace candidate_id = "" if substr(candidate_id, 1, 1) != "P"
    replace candidate_id = "P00006296" if candidate_id == "" ///
        & strpos(memo_text, "C00654673") // ANTHONY, NAKIA LACQUERS
    replace candidate_id = "P00008128" if candidate_id == "" ///
        & strpos(memo_text, "C00685271") // ATANUS, SUSANNE
    replace candidate_id = "P00011833" if candidate_id == "" ///
        & strpos(memo_text, "C00705186") // BENNET, MICHAEL F.
    replace candidate_id = "P80000722" if candidate_id == "" ///
        & strpos(memo_text, "C00703975") // BIDEN, JOSEPH R JR
    replace candidate_id = "P00014530" if candidate_id == "" ///
        & strpos(memo_text, "C00728154") // BLOOMBERG, MICHAEL R.
    replace candidate_id = "P00009795" if candidate_id == "" ///
        & strpos(memo_text, "C00695510") // BOOKER, CORY A.
    replace candidate_id = "P00013201" if candidate_id == "" ///
        & strpos(memo_text, "C00716431") // BOYD, MOSEMARIE DORA ("MOSIE")
    replace candidate_id = "P00008532" if candidate_id == "" ///
        & strpos(memo_text, "C00689885") // BRADFORD, DAPHNE DENISE
    replace candidate_id = "P00011999" if candidate_id == "" ///
        & strpos(memo_text, "C00706416") // BULLOCK, STEVE
    replace candidate_id = "P80000268" if candidate_id == "" ///
        & strpos(memo_text, "C00202176") // CARTER, WILLIE FELIX
    replace candidate_id = "P00009092" if candidate_id == "" ///
        & strpos(memo_text, "C00693044") // CASTRO, JULIAN
    replace candidate_id = "P00006825" if candidate_id == "" ///
        & strpos(memo_text, "C00664086") // CUNNINGHAM, HART P.
    replace candidate_id = "P00012054" if candidate_id == "" ///
        & strpos(memo_text, "C00706697") // DE BLASIO, BILL
    replace candidate_id = "P00014613" if candidate_id == "" ///
        & strpos(memo_text, "C00727776") // DE LA FUENTE, ROQUE III
    replace candidate_id = "P00006213" if candidate_id == "" ///
        & strpos(memo_text, "C00508416") // DELANEY, JOHN K.
    replace candidate_id = "P20004347" if candidate_id == "" ///
        & strpos(memo_text, "C00726976") // ELY, BOB (ROBERT MOULTON-ELY)
    replace candidate_id = "P00006981" if candidate_id == "" ///
        & strpos(memo_text, "C00671610") // FARBER, RYAN ANDREW
    replace candidate_id = "P00007179" if candidate_id == "" ///
        & strpos(memo_text, "C00702134") // FORSMAN, CATHERINE ANNE
    replace candidate_id = "P00009290" if candidate_id == "" ///
        & strpos(memo_text, "C00694018") // GILLIBRAND, KIRSTEN
    replace candidate_id = "P00011726" if candidate_id == "" ///
        & strpos(memo_text, "C00704627") // GLEIBERMAN, BEN
    replace candidate_id = "P00016360" if candidate_id == "" ///
        & strpos(memo_text, "C00746859") // GOMEZ, PAMELA MARIE MS.
    replace candidate_id = "P00011254" if candidate_id == "" ///
        & strpos(memo_text, "C00700609") // GRAVEL, MAURICE ROBERT
    replace candidate_id = "P60021508" if candidate_id == "" ///
        & strpos(memo_text, "C00591578") // GREENSTEIN, MARK
    replace candidate_id = "P00015669" if candidate_id == "" ///
        & strpos(memo_text, "C00741389") // HALL, ELLA REE
    replace candidate_id = "P00008193" if candidate_id == "" ///
        & strpos(memo_text, "C00686162") // HARDWICK, STETSON
    replace candidate_id = "P00009423" if candidate_id == "" ///
        & strpos(memo_text, "C00694455") // HARRIS, KAMALA D.
    replace candidate_id = "P80004765" if candidate_id == "" ///
        & strpos(memo_text, "C00697227") // HEWES, HENRY
    replace candidate_id = "P00010520" if candidate_id == "" ///
        & strpos(memo_text, "C00698258") // HICKENLOOPER, JOHN W.
    replace candidate_id = "P00011791" if candidate_id == "" ///
        & strpos(memo_text, "C00705095") // HOROWITZ, AMI
    replace candidate_id = "P00013904" if candidate_id == "" ///
        & strpos(memo_text, "C00724054") // HOWARD, ADRIENNE
    replace candidate_id = "P00008565" if candidate_id == "" ///
        & strpos(memo_text, "C00690842") // HOWE, ALAN
    replace candidate_id = "P00010454" if candidate_id == "" ///
        & strpos(memo_text, "C00698050") // INSLEE, JAY R
    replace candidate_id = "P80006117" if candidate_id == "" ///
        & strpos(memo_text, "C00696419") // KLOBUCHAR, AMY J.
    replace candidate_id = "P00010108" if candidate_id == "" ///
        & strpos(memo_text, "C00696690") // LEFFERT, AKIVA
    replace candidate_id = "P00012427" if candidate_id == "" ///
        & strpos(memo_text, "C00711812") // MCINNIS, CHARLETA
    replace candidate_id = "P00010827" if candidate_id == "" ///
        & strpos(memo_text, "C00699280") // MESSAM, WAYNE MARTIN
    replace candidate_id = "P00011866" if candidate_id == "" ///
        & strpos(memo_text, "C00704510") // MOULTON, SETH
    replace candidate_id = "P00012146" if candidate_id == "" ///
        & strpos(memo_text, "C00707380") // NEWNAN, BRIAN DEAN
    replace candidate_id = "P00006403" if candidate_id == "" ///
        & strpos(memo_text, "C00658914") // NWADIKE JR, KENNETH E
    replace candidate_id = "P00008763" if candidate_id == "" ///
        & strpos(memo_text, "C00691444") // OJEDA, RICHARD NEECE II
    replace candidate_id = "P00010793" if candidate_id == "" ///
        & strpos(memo_text, "C00501197") // O'ROURKE, ROBERT BETO
    replace candidate_id = "P00010587" if candidate_id == "" ///
        & strpos(memo_text, "C00693788") // PIERCE, MARK ALLAN
    replace candidate_id = "P00008946" if candidate_id == "" ///
        & strpos(memo_text, "C00695429") // POWERS, CHRISTIN NOEL MS.
    replace candidate_id = "P00011338" if candidate_id == "" ///
        & strpos(memo_text, "C00701979") // RYAN, TIMOTHY J.
    replace candidate_id = "P60007168" if candidate_id == "" ///
        & strpos(memo_text, "C00696948") // SANDERS, BERNARD
    replace candidate_id = "P00009225" if candidate_id == "" ///
        & strpos(memo_text, "C00693697") // SENEY, RAYMOND J
    replace candidate_id = "P00012567" if candidate_id == "" ///
        & strpos(memo_text, "C00710574") // SESTAK, JOSEPH A JR
    replace candidate_id = "P20005229" if candidate_id == "" ///
        & strpos(memo_text, "C00532663") // SHREFFLER, DOUG (I)
    replace candidate_id = "P00008003" if candidate_id == "" ///
        & strpos(memo_text, "C00683631") // SMITH, SHARMIN LYNN
    replace candidate_id = "P00007500" if candidate_id == "" ///
        & strpos(memo_text, "C00677195") // SMYTH, HERBERT EZEKIEL ZEKE
    replace candidate_id = "P00012716" if candidate_id == "" ///
        & strpos(memo_text, "C00711614") // STEYER, TOM
    replace candidate_id = "P00011312" if candidate_id == "" ///
        & strpos(memo_text, "C00701698") // SWALWELL, ERIC MICHAEL
    replace candidate_id = "P00011759" if candidate_id == "" ///
        & strpos(memo_text, "C00704551") // VOGEL-WALCUTT, JENNIFER
    replace candidate_id = "P00008102" if candidate_id == "" ///
        & strpos(memo_text, "C00684829") // VON BEVERN, RYAN NICHOLAS
    replace candidate_id = "P00009621" if candidate_id == "" ///
        & strpos(memo_text, "C00693234") // WARREN, ELIZABETH
    replace candidate_id = "P00007641" if candidate_id == "" ///
        & strpos(memo_text, "C00678953") // WELLS, ROBERT CARR MR. JR.
    replace candidate_id = "P00005942" if candidate_id == "" ///
        & strpos(memo_text, "C00641100") // WIAND, FRED
    replace candidate_id = "P00009910" if candidate_id == "" ///
        & strpos(memo_text, "C00696054") // WILLIAMSON, MARIANNE
    replace candidate_id = "P00009456" if candidate_id == "" ///
        & strpos(memo_text, "C00694513") // WILSON, KURTIS KING MR
    replace candidate_id = "P00006486" if candidate_id == "" ///
        & strpos(memo_text, "C00659938") // YANG, ANDREW MR.
    drop if candidate_id == ""
    drop memo_text
    
    // candidate name
    gen candidate_name = ""
    replace candidate_name = "anthony" if candidate_id == "P00006296"
    replace candidate_name = "atanus" if candidate_id == "P00008128"
    replace candidate_name = "bennet" if candidate_id == "P00011833"
    replace candidate_name = "biden" if candidate_id == "P80000722"
    replace candidate_name = "bloomberg" if candidate_id == "P00014530"
    replace candidate_name = "booker" if candidate_id == "P00009795"
    replace candidate_name = "boyd" if candidate_id == "P00013201"
    replace candidate_name = "bradford" if candidate_id == "P00008532"
    replace candidate_name = "bullock" if candidate_id == "P00011999"
    replace candidate_name = "carter" if candidate_id == "P80000268"
    replace candidate_name = "castro" if candidate_id == "P00009092"
    replace candidate_name = "cunningham" if candidate_id == "P00006825"
    replace candidate_name = "de_blasio" if candidate_id == "P00012054"
    replace candidate_name = "fuente" if candidate_id == "P00014613"
    replace candidate_name = "delaney" if candidate_id == "P00006213"
    replace candidate_name = "ely" if candidate_id == "P20004347"
    replace candidate_name = "farber" if candidate_id == "P00006981"
    replace candidate_name = "forsman" if candidate_id == "P00007179"
    replace candidate_name = "gillibrand" if candidate_id == "P00009290"
    replace candidate_name = "gleiberman" if candidate_id == "P00011726"
    replace candidate_name = "gomez" if candidate_id == "P00016360"
    replace candidate_name = "gravel" if candidate_id == "P00011254"
    replace candidate_name = "greenstein" if candidate_id == "P60021508"
    replace candidate_name = "hall" if candidate_id == "P00015669"
    replace candidate_name = "hardwick" if candidate_id == "P00008193"
    replace candidate_name = "harris" if candidate_id == "P00009423"
    replace candidate_name = "hewes" if candidate_id == "P80004765"
    replace candidate_name = "hickenloop" if candidate_id == "P00010520"
    replace candidate_name = "horowitz" if candidate_id == "P00011791"
    replace candidate_name = "howard" if candidate_id == "P00013904"
    replace candidate_name = "howe" if candidate_id == "P00008565"
    replace candidate_name = "inslee" if candidate_id == "P00010454"
    replace candidate_name = "klobuchar" if candidate_id == "P80006117"
    replace candidate_name = "leffert" if candidate_id == "P00010108"
    replace candidate_name = "mcinnis" if candidate_id == "P00012427"
    replace candidate_name = "messam" if candidate_id == "P00010827"
    replace candidate_name = "moulton" if candidate_id == "P00011866"
    replace candidate_name = "newman" if candidate_id == "P00012146"
    replace candidate_name = "nwadike" if candidate_id == "P00006403"
    replace candidate_name = "ojeda" if candidate_id == "P00008763"
    replace candidate_name = "orourke" if candidate_id == "P00010793"
    replace candidate_name = "pierce" if candidate_id == "P00010587"
    replace candidate_name = "powers" if candidate_id == "P00008946"
    replace candidate_name = "ryan" if candidate_id == "P00011338"
    replace candidate_name = "sanders" if candidate_id == "P60007168"
    replace candidate_name = "seney" if candidate_id == "P00009225"
    replace candidate_name = "sestak" if candidate_id == "P00012567"
    replace candidate_name = "shreffler" if candidate_id == "P20005229"
    replace candidate_name = "smith" if candidate_id == "P00008003"
    replace candidate_name = "smyth" if candidate_id == "P00007500"
    replace candidate_name = "steyer" if candidate_id == "P00012716"
    replace candidate_name = "swalwell" if candidate_id == "P00011312"
    replace candidate_name = "v_walcutt" if candidate_id == "P00011759"
    replace candidate_name = "bevern" if candidate_id == "P00008102"
    replace candidate_name = "warren" if candidate_id == "P00009621"
    replace candidate_name = "wells" if candidate_id == "P00007641"
    replace candidate_name = "wiand" if candidate_id == "P00005942"
    replace candidate_name = "williamson" if candidate_id == "P00009910"
    replace candidate_name = "wilson" if candidate_id == "P00009456"
    replace candidate_name = "yang" if candidate_id == "P00006486"
        
    // date extras
    gen year = year(receipt_date)
    gen month = month(receipt_date)
    recode month (1/3=1) (4/6=2) (7/9=3) (10/12=4), gen(quarter)

    label var id "ID"
    label var receipt_date "Receipt date"
    label var month "Receipt month"
    label var quarter "Receipt quarter"
    label var year "Receipt year"
    label var amount "Amount"
    label var candidate_id "Candidate ID"
    label var candidate_name "Candidate name"
    label var name "Contributor name"
    label var address "Contributor Address"    
    label var city "Contributor city"
    label var state "Contributor State"
    label var zip "Contributor ZIP"
    label var occupation "Contributor occupation"
    label var employer "Contributor employer"

    // order
    order id ///
        receipt_date ///
        month ///
        quarter ///
        year ///
        amount ///
        candidate_id ///
        candidate_name ////
        name ///
        address ///
        city ///
        state ///
        zip ///
        occupation ///
        employer

    // save
    compress
    save `stata_binary_parsed', replace

    // merge
    append using `merged'
    sort id
    save `merged', replace
}

save _act-blue-merged.dta, replace

// export names
preserve
keep id name address city state zip occupation employer
order id name address city state zip occupation employer
export delimited using "`c(pwd)'\act-blue-export.csv", novarnames replace
restore

// merge in donor IDs
merge m:1 id using `c(pwd)'\act-blue-contributors.dta, ///
    keepusing(donor_id similarity)
drop if _merge == 2
drop _merge

// loop through candidates and create sum variables
bysort donor_id : gen byte _unique = _n == 1
levelsof candidate_name, local(candidates)
levelsof year, local(years)
levelsof quarter, local(quarters)

foreach i of local candidates {
    local iv = proper("`i'")
    
    if ("hickenloop" == "`i'") {
        local iv = "Hickenlooper"
    }
    
    if ("orourke" == "`i'") {
        local iv = "O'Rourke"
    }
    
    if ("de_blasio" == "`i'") {
        local iv = "de Blasio"
    }

    foreach ii of local years {
        local v = substr("`ii'", 3, 2)
    
        foreach iii of local quarters {
            di "`iv' Q`iii' '`v'"
        
            // amount given by person for given quarter
            gen _amt = amount
            replace _amt = 0 if year != `ii' | ///
                quarter != `iii' | ///
                candidate_name != "`i'"
            egen donor_amt_`i'_`v'_q`iii' = total(_amt), by(donor_id)
            
            // amount a candiate raised for a given quarter
            egen cand_amt_`i'_`v'_q`iii' = total(_amt)
            
            // times a person gave for a given quarter
            replace _amt = . if _amt <= 0            
            egen donor_ct_`i'_`v'_q`iii' = count(_amt), by(donor_id)
            
            // candidate contributions for a given quarter
            egen cand_ct_`i'_`v'_q`iii' = count(_amt)            
            
            // unique candidate donors for a given quarter
            gen byte _valid = _unique
            replace _valid = 0 if donor_ct_`i'_`v'_q`iii' <= 0
            egen cand_unique_ct_`i'_`v'_q`iii' = total(_valid)
            
            // clean up
            drop _amt _valid
            
            // label variables
            label var donor_amt_`i'_`v'_q`iii' ///
                "Amount this donor gave to `iv' via ActBlue in Q`iii' `ii'"
            label var donor_ct_`i'_`v'_q`iii' /// 
                "# of times this donor gave to `iv' via ActBlue in Q`iii' `ii'"            
            label var cand_ct_`i'_`v'_q`iii' ///
                "# contributions `iv' received via ActBlue in Q`iii' `ii'"            
            label var cand_unique_ct_`i'_`v'_q`iii' ///
                "# unique `iv' ActBlue contributors in Q`iii' `ii'"
            label var cand_amt_`i'_`v'_q`iii' ///
                "Amount `iv' raised via ActBlue in Q`iii' `ii'"
        }
    }
}
drop _unique

// label our variables
label var donor_id "Unique contributor ID"
label var similarity "% Similarity of countributor to first match"

// order our variables
order donor_id similarity, after(candidate_name)
order donor_ct_* donor_amt_* cand_unique_ct_* cand_ct_* cand_amt_* donor_*, last

// compress and save
sort id
compress
save `c(pwd)'\act-blue.dta, replace
