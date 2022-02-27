clear

// set "filepath" to be the source folder of your CSVs
local filepath = "`c(pwd)'\..\data\output"
local files : dir "`filepath'" files "*.csv"
tempfile merged
save `merged', replace empty

foreach x of local files {
    local y = subinstr("_`x'", ".csv", ".dta", .) // imported Stata binary
    local z = subinstr("`y'", ".dta", "-parsed.dta", .) // parsed Stata binary
    local k = _N // how many cases do we have so far (for generating unique IDs)

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

    // contribution receipt date
    gen _rd = substr(receipt_date, 1, 10)
    gen _receipt_date = date(_rd, "YMD")
    drop _rd receipt_date
    rename _receipt_date receipt_date
    format receipt_date %td
        
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
    replace candidate_id = "P00010298" if candidate_id == "" ///
        & strpos(memo_text, "C00697441") // BUTTIGIEG, PETE
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
    replace candidate_id = "P00009183" if candidate_id == "" ///
        & strpos(memo_text, "C00693713") // GABBARD, TULSI
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
        & strpos(memo_text, "C00699090") // O'ROURKE, ROBERT BETO
    replace candidate_id = "P00014407" if candidate_id == "" ///
        & strpos(memo_text, "C00727156") // PATRICK, DEVAL
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
    
    // replace FEC ID string with smaller categorical variable
    gen byte _candidate_id = .
    replace _candidate_id = 1 if candidate_id == "P00006296"
    replace _candidate_id = 2 if candidate_id == "P00008128"
    replace _candidate_id = 3 if candidate_id == "P00011833"
    replace _candidate_id = 4 if candidate_id == "P80000722"
    replace _candidate_id = 5 if candidate_id == "P00014530"
    replace _candidate_id = 6 if candidate_id == "P00009795"
    replace _candidate_id = 7 if candidate_id == "P00013201"
    replace _candidate_id = 8 if candidate_id == "P00008532"
    replace _candidate_id = 9 if candidate_id == "P00011999"
    replace _candidate_id = 10 if candidate_id == "P00010298"
    replace _candidate_id = 11 if candidate_id == "P80000268"
    replace _candidate_id = 12 if candidate_id == "P00009092"
    replace _candidate_id = 13 if candidate_id == "P00006825"
    replace _candidate_id = 14 if candidate_id == "P00012054"
    replace _candidate_id = 15 if candidate_id == "P00014613"
    replace _candidate_id = 16 if candidate_id == "P00006213"
    replace _candidate_id = 17 if candidate_id == "P20004347"
    replace _candidate_id = 18 if candidate_id == "P00006981"
    replace _candidate_id = 19 if candidate_id == "P00007179"
    replace _candidate_id = 20 if candidate_id == "P00009183"
    replace _candidate_id = 21 if candidate_id == "P00009290"
    replace _candidate_id = 22 if candidate_id == "P00011726"
    replace _candidate_id = 23 if candidate_id == "P00016360"
    replace _candidate_id = 24 if candidate_id == "P00011254"
    replace _candidate_id = 25 if candidate_id == "P60021508"
    replace _candidate_id = 26 if candidate_id == "P00015669"
    replace _candidate_id = 27 if candidate_id == "P00008193"
    replace _candidate_id = 28 if candidate_id == "P00009423"
    replace _candidate_id = 29 if candidate_id == "P80004765"
    replace _candidate_id = 30 if candidate_id == "P00010520"
    replace _candidate_id = 31 if candidate_id == "P00011791"
    replace _candidate_id = 32 if candidate_id == "P00013904"
    replace _candidate_id = 33 if candidate_id == "P00008565"
    replace _candidate_id = 34 if candidate_id == "P00010454"
    replace _candidate_id = 35 if candidate_id == "P80006117"
    replace _candidate_id = 36 if candidate_id == "P00010108"
    replace _candidate_id = 37 if candidate_id == "P00012427"
    replace _candidate_id = 38 if candidate_id == "P00010827"
    replace _candidate_id = 39 if candidate_id == "P00011866"
    replace _candidate_id = 40 if candidate_id == "P00012146"
    replace _candidate_id = 41 if candidate_id == "P00006403"
    replace _candidate_id = 42 if candidate_id == "P00008763"
    replace _candidate_id = 43 if candidate_id == "P00010793"
    replace _candidate_id = 44 if candidate_id == "P00014407"
    replace _candidate_id = 45 if candidate_id == "P00010587"
    replace _candidate_id = 46 if candidate_id == "P00008946"
    replace _candidate_id = 47 if candidate_id == "P00011338"
    replace _candidate_id = 48 if candidate_id == "P60007168"
    replace _candidate_id = 49 if candidate_id == "P00009225"
    replace _candidate_id = 50 if candidate_id == "P00012567"
    replace _candidate_id = 51 if candidate_id == "P20005229"
    replace _candidate_id = 52 if candidate_id == "P00008003"
    replace _candidate_id = 53 if candidate_id == "P00007500"
    replace _candidate_id = 54 if candidate_id == "P00012716"
    replace _candidate_id = 55 if candidate_id == "P00011312"
    replace _candidate_id = 56 if candidate_id == "P00011759"
    replace _candidate_id = 57 if candidate_id == "P00008102"
    replace _candidate_id = 58 if candidate_id == "P00009621"
    replace _candidate_id = 59 if candidate_id == "P00007641"
    replace _candidate_id = 60 if candidate_id == "P00005942"
    replace _candidate_id = 61 if candidate_id == "P00009910"
    replace _candidate_id = 62 if candidate_id == "P00009456"
    replace _candidate_id = 63 if candidate_id == "P00006486"

    gen id = _n + `k'
    qui sum id if missing(_candidate_id)
    
    if (r(N) > 0) {
        di as error "Candidate ID is missing for observations"
        exit 1
    }
    
    drop candidate_id
    rename _candidate_id candidate_id
        
    label define candidate_id ///
        1 "ANTHONY, NAKIA LACQUERS" ///
        2 "ATANUS, SUSANNE" ///
        3 "BENNET, MICHAEL F." ///
        4 "BIDEN, JOSEPH R JR" ///
        5 "BLOOMBERG, MICHAEL R." ///
        6 "BOOKER, CORY A." ///
        7 "BOYD, MOSEMARIE DORA ('MOSIE')" ///
        8 "BRADFORD, DAPHNE DENISE" ///
        9 "BULLOCK, STEVE" ///
        10 "BUTTIGIEG, PETE" ///
        11 "CARTER, WILLIE FELIX" ///
        12 "CASTRO, JULIAN" ///
        13 "CUNNINGHAM, HART P." ///
        14 "DE BLASIO, BILL" ///
        15 "DE LA FUENTE, ROQUE III" ///
        16 "DELANEY, JOHN K." ///
        17 "ELY, BOB (ROBERT MOULTON-ELY)" ///
        18 "FARBER, RYAN ANDREW" ///
        19 "FORSMAN, CATHERINE ANNE" ///
        20 "GABBARD, TULSI" ///        
        21 "GILLIBRAND, KIRSTEN" ///
        22 "GLEIBERMAN, BEN" ///
        23 "GOMEZ, PAMELA MARIE MS." ///
        24 "GRAVEL, MAURICE ROBERT" ///
        25 "GREENSTEIN, MARK" ///
        26 "HALL, ELLA REE" ///
        27 "HARDWICK, STETSON" ///
        28 "HARRIS, KAMALA D." ///
        29 "HEWES, HENRY" ///
        30 "HICKENLOOPER, JOHN W." ///
        31 "HOROWITZ, AMI" ///
        32 "HOWARD, ADRIENNE" ///
        33 "HOWE, ALAN" ///
        34 "INSLEE, JAY R" ///
        35 "KLOBUCHAR, AMY J." ///
        36 "LEFFERT, AKIVA" ///
        37 "MCINNIS, CHARLETA" ///
        38 "MESSAM, WAYNE MARTIN" ///
        39 "MOULTON, SETH" ///
        40 "NEWNAN, BRIAN DEAN" ///
        41 "NWADIKE JR, KENNETH E" ///
        42 "OJEDA, RICHARD NEECE II" ///
        43 "O'ROURKE, ROBERT BETO" ///
        44 "PATRICK, DEVAL" ///        
        45 "PIERCE, MARK ALLAN" ///
        46 "POWERS, CHRISTIN NOEL MS." ///
        47 "RYAN, TIMOTHY J." ///
        48 "SANDERS, BERNARD" ///
        49 "SENEY, RAYMOND J" ///
        50 "SESTAK, JOSEPH A JR" ///
        51 "SHREFFLER, DOUG (I)" ///
        52 "SMITH, SHARMIN LYNN" ///
        53 "SMYTH, HERBERT EZEKIEL ZEKE" ///
        54 "STEYER, TOM" ///
        55 "SWALWELL, ERIC MICHAEL" ///
        56 "VOGEL-WALCUTT, JENNIFER" ///
        57 "VON BEVERN, RYAN NICHOLAS" ///
        58 "WARREN, ELIZABETH" ///
        59 "WELLS, ROBERT CARR MR. JR." ///
        60 "WIAND, FRED" ///
        61 "WILLIAMSON, MARIANNE" ///
        62 "WILSON, KURTIS KING MR" ///
        63 "YANG, ANDREW MR."        
    label values candidate_id candidate_id
    
    label var id "ID"
    label var candidate_id "Candidate ID"    
    label var receipt_date "Receipt date"
    label var amount "Amount"
    label var name "Contributor name"
    label var address "Contributor Address"    
    label var city "Contributor city"
    label var state "Contributor State"
    label var zip "Contributor ZIP"
    label var occupation "Contributor occupation"
    label var employer "Contributor employer"

    // order
    order id ///
        candidate_id ///
        receipt_date ///
        amount ///
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
    save `merged', replace
}

// file 01: receipts
sort id
save `c(pwd)'\act-blue-presidential_01.dta, replace

// export names
preserve
keep id name address city state zip occupation employer
order id name address city state zip occupation employer
export delimited using "`c(pwd)'\..\data\match\raw.csv", novarnames replace
restore

keep id candidate_id receipt_date amount
preserve

// file 02: partial match list
import delimited "`c(pwd)'\..\data\match\partial-matches.csv", clear
label var similarity "Similarity Score"
label var info_a "Donor info (A)"
label var info_b "Donor info (B)"
label var hash_a "Unique donor hash (A)"
label var hash_b "Unique donor hash (B)"
compress
sort similarity
save `c(pwd)'\act-blue-presidential_02.dta, replace

// file 03: donor IDs
import delimited "`c(pwd)'\..\data\match\donor-ids.csv", colrange(1:2) clear
label var id "ID"
label var donor_id "Unique donor ID"
compress
save `c(pwd)'\act-blue-presidential_03.dta, replace
restore

// file 04: receipts with donor IDs
merge m:1 id using `c(pwd)'\act-blue-presidential_03.dta, keepusing(donor_id)
drop if _merge == 2
drop _merge
label var donor_id "Unique donor ID"
order donor_id, after(id)
save `c(pwd)'\act-blue-presidential_04.dta, replace

// stub for candidate reports
preserve
clear
gen str10 candidate_name = ""
gen int year = 0
gen int quarter = 0
gen int contributions = 0
gen int unique_donors = 0
gen float amount = 0
input
"" 0 0 0 0 0
end

label var candidate_name "Candidate name"
label var year "Year"
label var quarter "Quarter"
label var contributions "Contributions via ActBlue"
label var unique_donors "Unique ActBlue donors"
label var amount "Amount raised via ActBlue"
save `c(pwd)'\act-blue-presidential_06.dta, replace
restore

// candidate name
gen str10 candidate_name = ""
replace candidate_name = "anthony" if candidate_id == 1
replace candidate_name = "atanus" if candidate_id == 2
replace candidate_name = "bennet" if candidate_id == 3
replace candidate_name = "biden" if candidate_id == 4
replace candidate_name = "bloomberg" if candidate_id == 5
replace candidate_name = "booker" if candidate_id == 6
replace candidate_name = "boyd" if candidate_id == 7
replace candidate_name = "bradford" if candidate_id == 8
replace candidate_name = "bullock" if candidate_id == 9
replace candidate_name = "buttigieg" if candidate_id == 10
replace candidate_name = "carter" if candidate_id == 11
replace candidate_name = "castro" if candidate_id == 12
replace candidate_name = "cunningham" if candidate_id == 13
replace candidate_name = "de_blasio" if candidate_id == 14
replace candidate_name = "fuente" if candidate_id == 15
replace candidate_name = "delaney" if candidate_id == 16
replace candidate_name = "ely" if candidate_id == 17
replace candidate_name = "farber" if candidate_id == 18
replace candidate_name = "forsman" if candidate_id == 19
replace candidate_name = "gabbard" if candidate_id == 20
replace candidate_name = "gillibrand" if candidate_id == 21
replace candidate_name = "gleiberman" if candidate_id == 22
replace candidate_name = "gomez" if candidate_id == 23
replace candidate_name = "gravel" if candidate_id == 24
replace candidate_name = "greenstein" if candidate_id == 25
replace candidate_name = "hall" if candidate_id == 26
replace candidate_name = "hardwick" if candidate_id == 27
replace candidate_name = "harris" if candidate_id == 28
replace candidate_name = "hewes" if candidate_id == 29
replace candidate_name = "hickenloop" if candidate_id == 30
replace candidate_name = "horowitz" if candidate_id == 31
replace candidate_name = "howard" if candidate_id == 32
replace candidate_name = "howe" if candidate_id == 33
replace candidate_name = "inslee" if candidate_id == 34
replace candidate_name = "klobuchar" if candidate_id == 35
replace candidate_name = "leffert" if candidate_id == 36
replace candidate_name = "mcinnis" if candidate_id == 37
replace candidate_name = "messam" if candidate_id == 38
replace candidate_name = "moulton" if candidate_id == 39
replace candidate_name = "newman" if candidate_id == 40
replace candidate_name = "nwadike" if candidate_id == 41
replace candidate_name = "ojeda" if candidate_id == 42
replace candidate_name = "orourke" if candidate_id == 43
replace candidate_name = "patrick" if candidate_id == 44
replace candidate_name = "pierce" if candidate_id == 45
replace candidate_name = "powers" if candidate_id == 46
replace candidate_name = "ryan" if candidate_id == 47
replace candidate_name = "sanders" if candidate_id == 48
replace candidate_name = "seney" if candidate_id == 49
replace candidate_name = "sestak" if candidate_id == 50
replace candidate_name = "shreffler" if candidate_id == 51
replace candidate_name = "smith" if candidate_id == 52
replace candidate_name = "smyth" if candidate_id == 53
replace candidate_name = "steyer" if candidate_id == 54
replace candidate_name = "swalwell" if candidate_id == 55
replace candidate_name = "v_walcutt" if candidate_id == 56
replace candidate_name = "von_bevern" if candidate_id == 57
replace candidate_name = "warren" if candidate_id == 58
replace candidate_name = "wells" if candidate_id == 59
replace candidate_name = "wiand" if candidate_id == 60
replace candidate_name = "williamson" if candidate_id == 61
replace candidate_name = "wilson" if candidate_id == 62
replace candidate_name = "yang" if candidate_id == 63
drop candidate_id

// date extras
gen int year = year(receipt_date)
gen int month = month(receipt_date)
recode month (1/3=1) (4/6=2) (7/9=3) (10/12=4), gen(quarter)

// loop through candidates and create sum variables
bysort donor_id : gen byte _unique = _n == 1
levelsof candidate_name, local(candidates)
levelsof year, local(years)
levelsof quarter, local(quarters)

foreach i of local candidates {
    local iv = proper("`i'")
    
    if ("de_blasio" == "`i'") {
        local iv = "de Blasio"
    }
    
    if ("fuente" == "`i'") {
        local iv = "de la Fuente"
    }
    
    if ("hickenloop" == "`i'") {
        local iv = "Hickenlooper"
    }
    
    if ("orourke" == "`i'") {
        local iv = "O'Rourke"
    }
    
    if ("v_walcutt" == "`i'") {
        local iv = "Vogel-Walcutt"
    }

    if ("von_bevern" == "`i'") {
        local iv = "von Bevern"
    }    
        
    foreach ii of local years {
        local v = substr("`ii'", 3, 2)
    
        foreach iii of local quarters {
            // amount given by person for given quarter
            qui gen _amt = amount
            qui replace _amt = 0 if year != `ii' | quarter != `iii' ///
                | candidate_name != "`i'"
            qui egen donor_amt_`i'_`v'_q`iii' = total(_amt), by(donor_id)
            
            // amount a candidate raised for a given quarter
            qui egen cand_amt_`i'_`v'_q`iii' = total(_amt)
            
            // times a person gave for a given quarter
            qui replace _amt = . if _amt <= 0            
            qui egen donor_ct_`i'_`v'_q`iii' = count(_amt), by(donor_id)
            
            // candidate contributions for a given quarter
            qui egen cand_ct_`i'_`v'_q`iii' = count(_amt)            
            
            // unique candidate donors for a given quarter
            qui gen byte _valid = _unique
            qui replace _valid = 0 if donor_ct_`i'_`v'_q`iii' <= 0
            qui egen cand_unique_ct_`i'_`v'_q`iii' = total(_valid)
            
            // clean up
            qui drop _amt _valid
            
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
                
            // report
            
            di ""
            di "------------------"
            di "`iv' `ii' Q`iii'"
            di "------------------"
            qui sum cand_ct_`i'_`v'_q`iii'
            local cand_ct = r(max)
            qui sum cand_unique_ct_`i'_`v'_q`iii'
            local cand_unique_ct = r(max)
            qui sum cand_amt_`i'_`v'_q`iii'
            local cand_amount = r(max)
            di "ActBlue earmarked receipts:  `cand_ct'"
            di "ActBlue unique contributors: `cand_unique_ct'"
            di "ActBlue received:            $`cand_amount'"
            
            drop cand_*
            
            preserve
            use `c(pwd)'\act-blue-presidential_06.dta, clear
            qui expand 2 if year == 0, gen(_c)
            qui replace candidate_name = "`i'" if _c == 1
            qui replace year = `ii' if _c == 1
            qui replace quarter = `iii' if _c == 1
            qui replace contributions = `cand_ct' if _c == 1
            qui replace unique_donors = `cand_unique_ct' if _c == 1
            qui replace amount = `cand_amount' if _c == 1
            drop _c
            qui save `c(pwd)'\act-blue-presidential_06.dta, replace            
            restore
        }
    }

    qui drop if _unique == 0 & candidate_name == "`i'"
}
keep if _unique == 1
keep donor_*

// order our variables
order donor_id donor_amt_* donor_ct_*

// file 05: donor-level totals
sort donor_id
compress
save `c(pwd)'\act-blue-presidential_05.dta, replace

// file 06: candidate-level totals
use `c(pwd)'\act-blue-presidential_06.dta, replace
drop if year == 0
sort candidate_name year quarter
compress
save `c(pwd)'\act-blue-presidential_06.dta, replace
