/* Clustering and Decision Trees Graded Case Study*/
libname cluster "D:\Users\ms\Graded Assignments\Topic 11-Case Study Clustering & Decision Trees";
run;

/*Importing data*/
proc import 
datafile  = "Z:\Assignments\Graded Assignment\Topic 11.2 - Clustering & Decision Trees\Credit.csv"
out = cluster.creditcard dbms = csv replace;
getnames = yes;
run;


/*Data Exploration*/
proc contents data= cluster.creditcard;
run;
proc means data = cluster.creditcard n nmiss;
proc freq data = cluster.creditcard;
tables Numberofdependents Gender MonthlyIncome region rented_ownhouse occupation education MonthlyIncome1;
run;


/*Note : After summarizing the data, it was found that out of 16 variables(17th variable is
MonthlyIncome1 which is a duplicate of MonthlyIncome and will be dropped):
9 variables were numeric each with 2 missing values
6 variables were character each with 2 missing values,
with No. of dependents having 3924 values which are labeled 'NA' and 2 values
labeled 'Good' and 'Bad';
MonthlyIncome with 29731 values which are labeled 'NA'
After checking the data it was found that deleting 'Good' and 'Bad' from
No. of Dependents variables removes all 2 missing values from the remaining 15 variables*/

/*Deleting 'good' 'bad' values from NumberOfDependents variables and 
dropping MonthlyIncome1*/
data cluster.creditcard1 (drop = MonthlyIncome1);
set cluster.creditcard;
if numberofdependents = "Goo" or numberofdependents="Bad" then delete;
run;


/*Summarizing Data*/
proc means data = cluster.creditcard1 n nmiss;
proc freq data = cluster.creditcard1;
tables Numberofdependents Gender MonthlyIncome region rented_ownhouse occupation education;
run;






/*Checking for Outliers and imputing and treating outlier 'variable by variable':
NPA_Status revolvingutilizationofunsecuredl debtratio numberoftimes90dayslate 
numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw Age NumerOfOpenCreditLinesAndLoans NumberRealEstateLoansOrLines*/
proc univariate data = cluster.creditcard1;
var NPA_Status revolvingutilizationofunsecuredl;
run; 


/*Limiting the value of RevolvingUtilization between 0-1 and deleting
values > 1 while imputing 1 for values between > 1 and < =5.*/
data cluster.creditcard2;
set cluster.creditcard1;
if revolvingutilizationofunsecuredl >5 then delete;
if 5 gt revolvingutilizationofunsecuredl >1  then revolvingutilizationofunsecuredl = 0.32;
run;

/*Outlier detection in numberoftimes90dayslate 
numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw*/
proc univariate data = cluster.creditcard2;
var numberoftimes90dayslate numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw;
run;

/*deleting the outliers i,e, values >90 from
numberoftimes90dayslate numberoftime60_89dayspastduenotw numberoftime30_59dayspastduenotw*/
data cluster.creditcard3;
set cluster.creditcard2;
if NumberOfTime30_59DaysPastDueNotW >=90 then delete;
if NumberOfTime60_89DaysPastDueNotW >=90 then delete;
if NumberOfTimes90DaysLate >=90 then delete;
run;

/*outliers detection in  NumerOfOpenCreditLinesAndLoans NumberRealEstateLoansOrLines*/ 
proc univariate data = cluster.creditcard3;
var NumberOfOpenCreditLinesAndLoans NumberRealEstateLoansOrLines;
run;

data cluster.creditcard4;
set cluster.creditcard3;
if NumberOfOpenCreditLinesAndLoans>40 then delete;
if NumberRealEstateLoansOrLines>40 then delete;
run;

/*Outlier detection in age*/
proc univariate data = cluster.creditcard4;
var age;
run;

data cluster.creditcard5;
set cluster.creditcard4;
if age = 0 then delete;
run;

/*converting monthlyincome into numeric*/
data cluster.creditcard5;
set cluster.creditcard5;
if index(MonthlyIncome,'NA') > 0 then MonthlyIncome = -1;
run;


data cluster.minusone;
set cluster.creditcard5;
if MonthlyIncome = -1;
run;
/*There are 29533 values of Monthly Income = -1.imputing -1 with the mean*/
/*Finding the mean of monthlyincome without mean*/

data cluster.creditcard5;
set cluster.creditcard5;
test =1;
run;

data cluster.minusone;
set cluster.creditcard5;
informat income BEST12.;
income = monthlyincome;
if monthlyincome = -1 then delete;
run;

proc means mean data = cluster.minusone;
output out = cluster.avg_income mean(income) = mean_income;
run;

data cluster.avg_income(drop= _TYPE_ _FREQ_);
set cluster.avg_income;
test = 1;
run;

data cluster.merging;
merge cluster.creditcard5 cluster.avg_income;
by test;
run;

/*substituting -1 =mean of monthly income*/
data cluster.merging;
set cluster.merging;
format monthlyincome1 BEST12.;
if monthlyincome = -1 then monthlyincome1 = round(mean_income,0.01);
else monthlyincome1 = monthlyincome;
run;

/*Merging datasets*/
data cluster.merging (drop = test mean_income);
set cluster.merging;
run;

proc univariate data = cluster.merging;
var monthlyincome1;
run;


data cluster.creditcard6;
set cluster.merging;
run;

data cluster.creditcard7;
set cluster.creditcard6;
if monthlyincome1 = 0 then delete;
if MonthlyIncome1 >= 400000 then delete;
run;

/*Outlier in debtratio*/
proc univariate data = cluster.creditcard7;
var debtratio;
run;

data cluster.debit(keep = monthlyincome monthlyincome1 debtratio) ;
set cluster.creditcard7;
if monthlyincome=-1;
run;

data cluster.creditcard8;
set cluster.creditcard7;
if monthlyincome=-1 then debtratio1 = round((debtratio/monthlyincome1),0.01);
else debtratio1 = debtratio;
run;
proc univariate data = cluster.creditcard8;
var debtratio;
run;

/*deleting debtratio above*/
data cluster.creditcard9;
set cluster.creditcard8;
if debtratio1 > 1 then debtratio1 = 1;
run;


/*Outlier detection in Number of depedents*/
/*Converting it into numeric*/

data cluster.creditcard10;
set cluster.creditcard9;
if index(NumberOfDependents,'NA') > 0 then NumberOfDependents = '0';
run;

data cluster.creditcard10;
set cluster.creditcard10;
format NumberOfDependents1 BEST12.;
NumberOfDependents1 = NumberOfDependents;
run;


data cluster.creditcard10 (drop = NumberOfDependents);
set cluster.creditcard10;
run;

proc univariate data = cluster.creditcard10;
var NumberOfDependents1;
run;

data cluster.creditcard11;
set cluster.creditcard10;
if NumberOfDependents1 > 4 then delete;
run;

proc univariate data = cluster.creditcard11;
var NumberOfDependents1;
run;

proc contents data = cluster.creditcard11 varnum;
run;

data cluster.creditcard_analyze(drop = NumberOfDependents MonthlyIncome Debtratio);
set cluster.creditcard11;
run;







/******End of Data Exploration,Cleaning*******************************************
Dataset : cluster.creditcard_analyze is the treated Population Dataset which will
*****************************be used for Segmentation*****************************/














/*Start of Customer segmentation*/

proc means data = cluster.creditcard_analyze;
run;

/*creating duplicates to be used while scaling*/
data cluster.creditcard_analyze;
set cluster.creditcard_analyze;
d_RUOUL = RevolvingUtilizationOfUnsecuredL;
d_age = age;
d_NoOfTime30_59DaysPastDueNotW =NumberOfTime30_59DaysPastDueNotW;
d_NoOfOpenCreditLinesAndLoans=NumberOfOpenCreditLinesAndLoans;
d_NoOfTimes90DaysLate=NumberOfTimes90DaysLate;
d_NoRealEstateLoansOrLines=NumberRealEstateLoansOrLines;
d_NoOfTime60_89DaysPastDueNotW=NumberOfTime60_89DaysPastDueNotW;
d_monthlyincome1=monthlyincome1;
d_debtratio1=debtratio1;
d_NoOfDependents1=NumberOfDependents1;
run;

/*Scaling*/
proc standard data = cluster.creditcard_analyze mean = 0 std =1
out = cluster.clust1;
var d_RUOUL d_age d_NoOfTime30_59DaysPastDueNotW d_NoOfOpenCreditLinesAndLoans
d_NoRealEstateLoansOrLines d_NoOfTimes90DaysLate d_NoOfTime60_89DaysPastDueNotW
 d_monthlyincome1 d_debtratio1 d_NoOfDependents1;
run;





/***********************************************************************************************
************************************************************************************************
**********************Start of Segmentation 1 based on age and monthly income*******************
/**********************************************************************************************/



/*Segmentation 1 : K = 3*/
proc fastclus data = cluster.clust1 maxclusters = 3 maxiter=75 converge = 0
out = cluster.out_k;
var  d_age d_monthlyincome1;
run;

/*Segmentation 1 : K = 4*/
proc fastclus data = cluster.clust1 maxclusters = 4 maxiter=75 converge = 0
out = cluster.out_k1;
var  d_age d_monthlyincome1;
run;

data cluster.clust1;
set cluster.clust1;
test = 1;
run;

data cluster.out_k1(keep = cluster test);
set cluster.out_k1;
test = 1;
run;

/*Selecting the strong cluster from Segmentation 1 i.e. K = 4*/
data cluster.merged;
merge cluster.clust1 cluster.out_k1;
by test;
run;

data cluster.merged (drop = test);
set cluster.merged;
run;

/*Profiling of Segmentation 1,K=4 for all 4 clusters*/

/*Finding the mean and std dev of Population for age and income variables*/
proc means data = cluster.creditcard_analyze mean stddev;
var age monthlyincome1;
output out = cluster.population;
run;

data cluster.population;
set cluster.population (drop = _TYPE_ _FREQ_);
if _STAT_ = 'MEAN' or _STAT_ = 'STD';
run;




/*Profiling Cluster1 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster1_profile;
set cluster.merged;
if cluster = 1;
run;

proc means data = cluster.cluster1_profile;
var age monthlyincome1;
output out = cluster.cluster1;
run;

data cluster.cluster1_means;
set cluster.cluster1 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster1 with population*/
proc append base = cluster.cluster1_means data = cluster.population;
run;

proc transpose data = cluster.cluster1_means
out = cluster.cluster1_zscore;
run;

/*finding z-score*/
data cluster.cluster1_zscorefinal (drop = _LABEL_);
set cluster.cluster1_zscore;
rename
COL1 = cluster1_mean
COL2 = cluster1_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run; 

proc sort data = cluster.cluster1_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster1_profile;
tables education gender occupation region;
run; 



/*Profiling Cluster2 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster2_profile;
set cluster.merged;
if cluster = 2;
run;

proc means data = cluster.cluster2_profile;
var age monthlyincome1;
output out = cluster.cluster2;
run;

data cluster.cluster2_means;
set cluster.cluster2 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster2 with population*/
proc append base = cluster.cluster2_means data = cluster.population;
run;

proc transpose data = cluster.cluster2_means
out = cluster.cluster2_zscore;
run;

/*finding z-score*/
data cluster.cluster2_zscorefinal (drop = _LABEL_);
set cluster.cluster2_zscore;
rename
COL1 = cluster2_mean
COL2 = cluster2_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster2_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster2_profile;
tables education gender occupation region;
run; 






/*Profiling Cluster3 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster3_profile;
set cluster.merged;
if cluster = 3;
run;

proc means data = cluster.cluster3_profile;
var age monthlyincome1;
output out = cluster.cluster3;
run;

data cluster.cluster3_means;
set cluster.cluster3 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster3 with population*/
proc append base = cluster.cluster3_means data = cluster.population;
run;

proc transpose data = cluster.cluster3_means
out = cluster.cluster3_zscore;
run;

/*finding z-score*/
data cluster.cluster3_zscorefinal (drop = _LABEL_);
set cluster.cluster3_zscore;
rename
COL1 = cluster3_mean
COL2 = cluster3_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster3_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster3_profile;
tables education gender occupation region;
run; 


/*Profiling Cluster4 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster4_profile;
set cluster.merged;
if cluster = 4;
run;

proc means data = cluster.cluster4_profile;
var age monthlyincome1;
output out = cluster.cluster4;
run;

data cluster.cluster4_means;
set cluster.cluster4 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster4 with population*/
proc append base = cluster.cluster4_means data = cluster.population;
run;

proc transpose data = cluster.cluster4_means
out = cluster.cluster4_zscore;
run;

/*finding z-score*/
data cluster.cluster4_zscorefinal (drop = _LABEL_);
set cluster.cluster4_zscore;
rename
COL1 = cluster4_mean
COL2 = cluster4_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster4_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster4_profile;
tables education gender occupation region;
run; 

/***********************************************************
************************************************************
*********************End of Segementation 1*****************
***********************************************************/







/*******************************************************************************************************************
********************************************************************************************************************
********Start of Segmentation 2 based on monthly income,debt ratio,real estate loans and open credit lines**********
********************************************************************************************************************/



/*Segmentation 2 : K = 3*/
proc fastclus data = cluster.clust1 maxclusters = 3 maxiter=75 converge = 0
out = cluster.out_m;
var  d_monthlyincome1 d_debtratio1 d_NoRealEstateLoansOrLines d_NoOfOpenCreditLinesAndLoans;
/*d_RUOUL = RevolvingUtilizationOfUnsecuredL;
d_age = age;
d_NoOfTime30_59DaysPastDueNotW =NumberOfTime30_59DaysPastDueNotW;
d_NoOfOpenCreditLinesAndLoans=NumberOfOpenCreditLinesAndLoans;
d_NoOfTimes90DaysLate=NumberOfTimes90DaysLate;
d_NoRealEstateLoansOrLines=NumberRealEstateLoansOrLines;
d_NoOfTime60_89DaysPastDueNotW=NumberOfTime60_89DaysPastDueNotW;
d_monthlyincome1=monthlyincome1;
d_debtratio1=debtratio1;
d_NoOfDependents1=NumberOfDependents1;*/
run;

/*Segmentation 2 : K = 4*/
proc fastclus data = cluster.clust1 maxclusters = 4 maxiter=120 converge = 0
out = cluster.out_m1;
var  d_monthlyincome1 d_debtratio1 d_NoRealEstateLoansOrLines d_NoOfOpenCreditLinesAndLoans;
run;

data cluster.clust1;
set cluster.clust1;
test = 1;
run;

data cluster.out_m1(keep = cluster test);
set cluster.out_m1;
test = 1;
run;

/*Selecting the strong cluster from Segmentation 2 i.e. K = 4*/
data cluster.merged1;
merge cluster.clust1 cluster.out_m1;
by test;
run;

data cluster.merged1 (drop = test);
set cluster.merged1;
run;

/*Profiling of Segmentation 2,K=4 for all 4 clusters*/


/*Finding the mean and std dev of Population for income,debtratio,creditlines,real estate loans*/
proc means data = cluster.creditcard_analyze mean stddev;
var monthlyincome1 debtratio1 NumberRealEstateLoansOrLines NumberOfOpenCreditLinesAndLoans;
output out = cluster.population1;
run;

data cluster.population1;
set cluster.population1 (drop = _TYPE_ _FREQ_);
if _STAT_ = 'MEAN' or _STAT_ = 'STD';
run;
/*Profiling Cluster1:-Finding mean and std dev of all 4 clusters in Segmentation 2*/
data cluster.cluster1_profile1;
set cluster.merged1;
if cluster = 1;
run;

proc means data = cluster.cluster1_profile1;
var monthlyincome1 debtratio1 NumberRealEstateLoansOrLines NumberOfOpenCreditLinesAndLoans;
output out = cluster.cluster1_1;
run;

data cluster.cluster1_means1;
set cluster.cluster1_1 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster1 with population*/
proc append base = cluster.cluster1_means1 data = cluster.population1;
run;

proc transpose data = cluster.cluster1_means1
out = cluster.cluster1_zscore1;
run;

/*finding z-score*/
data cluster.cluster1_zscorefinal1 (drop = _LABEL_);
set cluster.cluster1_zscore1;
rename
COL1 = cluster2_mean
COL2 = cluster2_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run; 

proc sort data = cluster.cluster1_zscorefinal1;
by descending z_score;
run;

proc freq data = cluster.cluster1_profile1;
tables NPA_Status Gender;
run; 



/*Profiling Cluster2 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster2_profile1;
set cluster.merged1;
if cluster = 2;
run;

proc means data = cluster.cluster2_profile1;
var monthlyincome1 debtratio1 NumberRealEstateLoansOrLines NumberOfOpenCreditLinesAndLoans;
output out = cluster.cluster2_1;
run;

data cluster.cluster2_means1;
set cluster.cluster2_1 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster2 with population*/
proc append base = cluster.cluster2_means1 data = cluster.population1;
run;

proc transpose data = cluster.cluster2_means1
out = cluster.cluster2_zscore1;
run;

/*finding z-score*/
data cluster.cluster2_zscorefinal1 (drop = _LABEL_);
set cluster.cluster2_zscore1;
rename
COL1 = cluster2_mean
COL2 = cluster2_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster2_zscorefinal1;
by descending z_score;
run;

proc freq data = cluster.cluster2_profile1;
tables npa_status gender;
run; 






/*Profiling Cluster3 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster3_profile1;
set cluster.merged;
if cluster = 3;
run;

proc means data = cluster.cluster3_profile1;
var monthlyincome1 debtratio1 NumberRealEstateLoansOrLines NumberOfOpenCreditLinesAndLoans;
output out = cluster.cluster3_1;
run;

data cluster.cluster3_means1;
set cluster.cluster3_1 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster3 with population*/
proc append base = cluster.cluster3_means1 data = cluster.population1;
run;

proc transpose data = cluster.cluster3_means1
out = cluster.cluster3_zscore1;
run;

/*finding z-score*/
data cluster.cluster3_zscorefinal1 (drop = _LABEL_);
set cluster.cluster3_zscore1;
rename
COL1 = cluster3_mean
COL2 = cluster3_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster3_zscorefinal1;
by descending z_score;
run;

proc freq data = cluster.cluster3_profile1;
tables npa_status gender;
run; 


/*Profiling Cluster4 :-Finding mean and std dev of all 4 clusters in Segmentation 1*/
data cluster.cluster4_profile1;
set cluster.merged;
if cluster = 4;
run;

proc means data = cluster.cluster4_profile1;
var monthlyincome1 debtratio1 NumberRealEstateLoansOrLines NumberOfOpenCreditLinesAndLoans;
output out = cluster.cluster4_1;
run;

data cluster.cluster4_means1;
set cluster.cluster4_1 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster4 with population*/
proc append base = cluster.cluster4_means1 data = cluster.population1;
run;

proc transpose data = cluster.cluster4_means1
out = cluster.cluster4_zscore1;
run;

/*finding z-score*/
data cluster.cluster4_zscorefinal1 (drop = _LABEL_);
set cluster.cluster4_zscore1;
rename
COL1 = cluster4_mean
COL2 = cluster4_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster4_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster4_profile1;
tables npa_status gender;
run; 

/*********************************************************************************************
**********************************************************************************************
*********************End of Segementation 2***************************************************
*********************************************************************************************/














/*************************************************************************************************************************
**************************************************************************************************************************
**********************Start of Segmentation 3 based on income,30-59 days late,60-89 days late,>90 days late*******************
/*****************************************************************************************************************************/



/*Segmentation 3 : K = 3*/
proc fastclus data = cluster.clust1 maxclusters = 3 maxiter=75 converge = 0
out = cluster.out_o;
var d_monthlyincome1 d_NoOfTime30_59DaysPastDueNotW d_NoOfTime60_89DaysPastDueNotW d_NoOfTimes90DaysLate;
/*d_RUOUL = RevolvingUtilizationOfUnsecuredL;
d_age = age;
d_NoOfTime30_59DaysPastDueNotW =NumberOfTime30_59DaysPastDueNotW;
d_NoOfOpenCreditLinesAndLoans=NumberOfOpenCreditLinesAndLoans;
d_NoOfTimes90DaysLate=NumberOfTimes90DaysLate;
d_NoRealEstateLoansOrLines=NumberRealEstateLoansOrLines;
d_NoOfTime60_89DaysPastDueNotW=NumberOfTime60_89DaysPastDueNotW;
d_monthlyincome1=monthlyincome1;
d_debtratio1=debtratio1;
d_NoOfDependents1=NumberOfDependents1;*/
run;

/*Segmentation 3 : K = 4*/
proc fastclus data = cluster.clust1 maxclusters = 4 maxiter=75 converge = 0
out = cluster.out_o1;
var  d_monthlyincome1 d_NoOfTime30_59DaysPastDueNotW d_NoOfTime60_89DaysPastDueNotW d_NoOfTimes90DaysLate;
run;

data cluster.clust1;
set cluster.clust1;
test = 1;
run;

data cluster.out_o1(keep = cluster test);
set cluster.out_o1;
test = 1;
run;

/*Selecting the strong cluster from Segmentation 3 i.e. K = 4*/
data cluster.merged2;
merge cluster.clust1 cluster.out_o1;
by test;
run;

data cluster.merged2 (drop = test);
set cluster.merged2;
run;

/*Profiling of Segmentation 3,K=4 for all 4 clusters*/

/*Finding the mean and std dev of Population for age and income variables*/
proc means data = cluster.creditcard_analyze mean stddev;
var monthlyincome1 NumberOfTime30_59DaysPastDueNotW NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate;
output out = cluster.population2;
run;

data cluster.population2;
set cluster.population2 (drop = _TYPE_ _FREQ_);
if _STAT_ = 'MEAN' or _STAT_ = 'STD';
run;




/*Profiling Cluster1 :-Finding mean and std dev of all 4 clusters in Segmentation 3*/
data cluster.cluster1_profile2;
set cluster.merged2;
if cluster = 1;
run;

proc means data = cluster.cluster1_profile2;
var monthlyincome1 NumberOfTime30_59DaysPastDueNotW NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate;
output out = cluster.cluster1_2;
run;

data cluster.cluster1_means2;
set cluster.cluster1_2 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster1 with population*/
proc append base = cluster.cluster1_means2 data = cluster.population2;
run;

proc transpose data = cluster.cluster1_means2
out = cluster.cluster1_zscore2;
run;

/*finding z-score*/
data cluster.cluster1_zscorefinal2 (drop = _LABEL_);
set cluster.cluster1_zscore2;
rename
COL1 = cluster1_mean
COL2 = cluster1_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run; 

proc sort data = cluster.cluster1_zscorefinal2;
by descending z_score;
run;

proc freq data = cluster.cluster1_profile2;
tables npa_status gender;
run; 




/*Profiling Cluster2 :-Finding mean and std dev of all 4 clusters in Segmentation 3*/
data cluster.cluster2_profile2;
set cluster.merged2;
if cluster = 2;
run;

proc means data = cluster.cluster2_profile2;
var monthlyincome1 NumberOfTime30_59DaysPastDueNotW NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate;
output out = cluster.cluster2_2;
run;

data cluster.cluster2_means2;
set cluster.cluster2_2 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster2 with population*/
proc append base = cluster.cluster2_means2 data = cluster.population2;
run;

proc transpose data = cluster.cluster2_means2
out = cluster.cluster2_zscore2;
run;

/*finding z-score*/
data cluster.cluster2_zscorefinal2 (drop = _LABEL_);
set cluster.cluster2_zscore2;
rename
COL1 = cluster2_mean
COL2 = cluster2_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster2_zscorefinal;
by descending z_score;
run;

proc freq data = cluster.cluster2_profile2;
tables npa_status gender;
run; 






/*Profiling Cluster3 :-Finding mean and std dev of all 4 clusters in Segmentation 3*/
data cluster.cluster3_profile2;
set cluster.merged2;
if cluster = 3;
run;

proc means data = cluster.cluster3_profile2;
var monthlyincome1 NumberOfTime30_59DaysPastDueNotW NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate;
output out = cluster.cluster3_2;
run;

data cluster.cluster3_means2;
set cluster.cluster3_2 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster3 with population*/
proc append base = cluster.cluster3_means2 data = cluster.population2;
run;

proc transpose data = cluster.cluster3_means2
out = cluster.cluster3_zscore2;
run;

/*finding z-score*/
data cluster.cluster3_zscorefinal2 (drop = _LABEL_);
set cluster.cluster3_zscore2;
rename
COL1 = cluster3_mean
COL2 = cluster3_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster3_zscorefinal2;
by descending z_score;
run;

proc freq data = cluster.cluster3_profile;
tables npa_status gender;
run; 


/*Profiling Cluster4 :-Finding mean and std dev of all 4 clusters in Segmentation 3*/
data cluster.cluster4_profile2;
set cluster.merged2;
if cluster = 4;
run;

proc means data = cluster.cluster4_profile2;
var monthlyincome1 NumberOfTime30_59DaysPastDueNotW NumberOfTime60_89DaysPastDueNotW NumberOfTimes90DaysLate;
output out = cluster.cluster4_2;
run;

data cluster.cluster4_means2;
set cluster.cluster4_2 (drop = _TYPE_ _FREQ_);
if _STAT_ = "MEAN" or  _STAT_ = "STD";
run;

/*combine cluster4 with population*/
proc append base = cluster.cluster4_means2 data = cluster.population2;
run;

proc transpose data = cluster.cluster4_means2
out = cluster.cluster4_zscore2;
run;

/*finding z-score*/
data cluster.cluster4_zscorefinal2 (drop = _LABEL_);
set cluster.cluster4_zscore2;
rename
COL1 = cluster4_mean
COL2 = cluster4_std
COL3 = population_mean
COL4 = population_std;
difference = abs(COL3-COL1);
z_score = difference/COL4;
run;

proc sort data = cluster.cluster4_zscorefinal2;
by descending z_score;
run;

proc freq data = cluster.cluster4_profile2;
tables npa_status gender;
run; 

/***********************************************************
************************************************************
*********************End of Segementation 3*****************
***********************************************************/
