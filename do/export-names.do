use "`c(pwd)'\act-blue-presidential.dta", clear
keep id contributor_name contributor_occupation contributor_street_1 ///
	contributor_city contributor_state contributor_zip
renpfix contributor_
rename street_1 address
order id name address city state zip occupation
export delimited using "`c(pwd)'\act-blue-contributors.csv", novarnames replace
