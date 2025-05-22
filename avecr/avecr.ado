*!avecr version: 1.0
*!Date: 23.Oct.2018
*!Author: Frank Sun (franksun@ynufe.edu.cn) based on program "condisc" of Mehmet Mehmetoglu, 
*!Contributor: Thanks to Mehmet's greate contribution on "condisc"!
capture program drop avecr
program avecr
	version 1.0
	di ""
	di in blue "Average-Variance-Extracted & Composite-factor-Reliability:"
	di ""

	/*takes the average of AVEs for each factor*/
	qui estat framework
	mat L = r(Gamma) //Lambda matrix
	local obsstripes : rowfullnames L
	local latstripes : colfullnames L
	//di "`obsstripes'"
	//di "`latstripes'"
	local nu = wordcount("`e(oyvars)'")
	//di `nu'
	qui estat eqgof
	mat R = r(eqfit)
	//mat list R
	mat ldr = R[1..`nu', 5]
	//mat list loader
	mat R2 = R[1..`nu', 4]
	//mat list R2
	local latent "`e(lxvars)'" 
	foreach lat of local latent { 
		local sumve = 0
		local sumldr = 0
		local sumerr = 0
		local i = 0
		foreach obs of local obsstripes {
			if L[rownumb(L, "`obs'"), colnumb(L,"`lat'")] !=0 {
				local sumve = `sumve' + R2[rownumb(L,"`obs'"), 1]
				local sumldr = `sumldr' + ldr[rownumb(L,"`obs'"), 1]
				local sumerr = `sumerr' + 1 - R2[rownumb(L,"`obs'"), 1]
				local ++i
			}
		}
		tempname ave
		tempname cr
		scalar `ave' = `sumve'/`i'
		scalar `cr' = `sumldr'^2/(`sumldr'^2 + `sumerr')

		di as text %10s abbrev("AVE_`lat':",10) as result %7.4f `ave' ///
			"    " as text %10s abbrev("CR_`lat':",10) as result %7.4f `cr'
	}	
end
