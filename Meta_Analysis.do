 *SET PATH
  * 1. root
  *
  global Root "C:\"
 * 2. path to the working directory
  cd "$Root\do" 
  *Import data - Use the sheet named Final and first row as names
 *import excel "C:\YOUR OWN path where you saved the data\Data.xlsx", sheet("Final") firstrow
 
 *3. Create study label that combines authors name and year of study :
 generate Studylbl = Author + " (" + string(Year) + ")"
 label variable Studylbl "Study label 
 *4 Declare data as meta analysis using Precomputed effect = PCC . This gives us features of our meta analysis data
meta set PCC SEpcc, studylabel(Studylbl) studysize(Sample_size) eslabel(PCC)
*Notes: By decaring the data to be meta-analysis, STATA creates meta variables; Meta_es = stores study-specific effect size, Meta_Se = respective standard errors, Meta_cil/meta_ciu= stores lower and upper limit of confidence intervals for study's effect sizes 
 *==============================================================================
 *META - Analysis Summary Statistics 
 * ==============================================================================
*4 Summary statistics using random effect model: put it into word doc or to get table without the list of studies results use 
meta summarize, random(reml)
 meta summarize, random(reml) nostudies
*5 Summary stats using common effect
meta summarize, common(invvariance) nostudies
*6 Summary stats using Fixed effect
meta summarize, fixed(invvariance) nostudies

*7. Publication bias:Do journal prefer mostly significant results / results based on the sign of the coefficient ? Also use regression to test for bias
meta funnelplot
meta funnelplot, random
meta funnelplot, contours(1 5 10)
meta bias, egger

 *==============================================================================
 *META - Analysis regression  
 * ==============================================================================
*Codding variables and creating dumies for meta-regression 
*1.creat ids for each regression and declare meta setup using the id
 egen id = group(Study_id i_regression_estimate)
 meta set PCC SEpcc, studylabel(id) studysize(Sample_size) eslabel(PCC)
 *Changing string variables to numerical for the modarate variables.  
 encode Data_type, gen(data_type_num)
 encode Methodology, gen(Methodology_num)
 encode Dependent_Var, gen(Dependent_Var_Num)
 encode Geographic, gen(Geographic_num)

  ***META REGRESSION 
  *By using syntax of: meta regress, stata uses the declared meta modl and effect size in the stata meta setup. 
  *Meta regression : 1.Data_type, 2.Data lenght, 3.Methods, 4. No.countries, 5.No.control_var, 

 meta regress NoControl   i.Dependent_Var_Num
   estimates store Meta1
meta regress  i.Methodology_num 
  estimates store Meta2
 meta regress NoControl   i.data_type_num
   estimates store Meta3
  meta regress NoControl i.Geographic_num  i.Dependent_Var_Num
    estimates store Meta4
	    
 outreg2 [Meta1 Meta2  Meta3 Meta4] using "$Root\table1.doc", replace  
 

//
meta regress  i.Methodology_num  
meta regress NoControl 
meta regress data_type_num  
meta regress Geographic_num
meta regress Dependent_Var_Num 

* Excluded from the model 

 meta regress NoControl Methodology_num   data_type_num  Dependent_Var_Num 
     estimates store Meta1 
 meta regress NoControl  Study_id 
  estimates store Meta2 
  meta regress  i.Methodology_num  i.Dependent_Var_Num 
  estimates store Meta3
 
 
 meta regress NoControl  i.Study_id
 