create database bank_loan;
select * from l_approved;
select count(*) from l_approved where Gender='Female';
select count(*) from l_approved group by Gender;
alter table l_approved
drop MyUnknownColumn;

-- View the first 10 records from the table.
select * from l_approved limit 10;

-- Count the total number of loan applications.
select count(*) as total_applicants from l_approved;

-- List all unique property areas.
select distinct(property_area) from l_approved;

-- show all applicants who are self-employed and have an income above 5000
select * from l_approved where self_employed='Yes' and applicantincome>5000;
select count(*) from l_approved where self_employed='Yes' and applicantincome>5000;

-- Find the total number of approved loans
select count(*) as loan_approved from l_approved where loan_status = 'Y';

-- Find average loan amount by education level
select Education, round(avg(LoanAmount),2) from l_approved group by Education;

-- Find average total income ( Applicant + coapplicant) by marital status 
select married, round(avg(applicantincome+coapplicantincome),2) as Total_income from l_approved group by married;

-- Show average loan amount by credit history
select Credit_History,round(avg(loanamount),2) from l_approved group by Credit_History;

-- Find total applications and approval rate by gender 
select count(*) from l_approved where gender='Male'and Loan_Status='Y';
select count(*) from l_approved where gender='Female'and Loan_Status='Y';
select gender,
       count(*) as total_applicants,
       sum(case when loan_status='Y' then 1 else 0 end) as approved,
       round(sum(case when loan_status='Y' then 1 else 0 end)/count(*)*100,2) as approved_rate
from l_approved group by gender;

-- Approval rate by property area
select
   property_area,
   (sum(case when Loan_Status="y" then 1 else 0 end)*
   100.0)/count(*) as approval_rate 
   from l_approved 
   group by property_area
   order by approval_rate desc;

-- Show applicants who are graduates, not self-employed, and have loan amount greater than 150 
select * from l_approved where education='Graduate' and self_employed= 'no' and loanamount>150;

-- Display approved loans from urban area with good credit history
select * from l_approved where Property_Area= 'urban' and Credit_History>=1 and Loan_Status='Y';

-- List top 5 applicants with highest total income
select *, (applicantincome+coapplicantincome) as Total_income from l_approved order by Total_income desc limit 5;

-- Create column for total income each applicant
select *, (ApplicantIncome+CoapplicantIncome) as Total_income from l_approved;

-- classify applicants into income groups(Low, Medium, High) based on applicant income
select Applicantincome from l_approved order by ApplicantIncome desc;

select Loan_ID,
	  ApplicantIncome,
      case 
      when ApplicantIncome<3000 then 
'Low income'
	  when ApplicantIncome between 3000 
and 6000 then 'Medium income'
      else 'High income'
      end as income_group
from l_approved;

-- Find average loan amount for each income group 
select 
            case 
            when ApplicantIncome<3000 then 
'Low income'
            when ApplicantIncome between 3000
and 6000 then 'Medium income'
            else 'High income'
            end as income_group,
		round (avg(LoanAmount),2) as avg_loan 
from l_approved group by income_group;

-- Find applicants whose loan amount is greater than the overall average loan amount
select * from l_approved
where loanamount > (select avg(LoanAmount)
from l_approved);

-- Identify the property area with the highest average total income
select property_area,
avg(applicantincome +coapplicantincome) as avg_income from l_approved 
group by property_area order by avg_income desc limit 1;

-- List all applicants whose income is above the average income of their education category
select * from l_approved
where ApplicantIncome > (select avg(ApplicantIncome + CoapplicantIncome) as total_income
from l_approved) order by education;

-- Rank applicants based on total income (highest income rank =1)
select Loan_ID,
		   ApplicantIncome+CoapplicantIncome
as total_income,
           rank () over (order by 
(ApplicantIncome + CoapplicantIncome) desc ) as Rank_number
from l_approved;

-- Show average loan amount per property area using a window function 
select distinct
    property_area,
    avg(LoanAmount) over(partition by property_area) as
    avg_loan_amount
    from l_approved;
-- Calculate approval rate by education using window function
select 
    education,
    round(
    (sum(case when loan_status="Y" then 1 else 0 end)
    over (partition by education)*100.0)/
    count(*) over(partition by education),
   2) as approval_rate 
   from l_approved 
   group by education, loan_status;
-- Compare approval rate by credit history and education level to find which combination performs best
select
     Credit_History,
     education,
     round(
       (sum(case when loan_status="Y" then 1 else 0 end)*
       100.0)/count(*),
        2) as approval_rate 
        from l_approved 
        group by Credit_History,Education
        order by approval_rate desc;

