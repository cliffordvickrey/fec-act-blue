import delimited "`c(pwd)'\act-blue-contributors-import.csv", clear
format id %16.0g
compress
save "`c(pwd)'\act-blue-contributors.dta", replace
