create database Recruitment_Analytics_DB;
use Recruitment_Analytics_DB;

CREATE TABLE clients (
    client_id INT AUTO_INCREMENT PRIMARY KEY,
    client_name VARCHAR(100) NOT NULL,
    industry VARCHAR(50),
    account_manager VARCHAR(100),
    city VARCHAR(50),
    state VARCHAR(50),
    country VARCHAR(50),
    contract_type VARCHAR(30),
    created_date DATE,
    status VARCHAR(20)
);

CREATE TABLE recruiters (
    recruiter_id INT AUTO_INCREMENT PRIMARY KEY,
    recruiter_name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    team VARCHAR(50),
    manager VARCHAR(100),
    experience_years DECIMAL(3,1),
    joining_date DATE,
    status VARCHAR(20)
);

CREATE TABLE candidate_sources (
    source_id INT AUTO_INCREMENT PRIMARY KEY,
    source_name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE candidates (
    candidate_id INT AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    city VARCHAR(50),
    state VARCHAR(50),
    experience_years DECIMAL(3,1),
    current_company VARCHAR(100),
    current_salary DECIMAL(10,2),
    expected_salary DECIMAL(10,2),
    visa_status VARCHAR(30),
    source_id INT,
    skills VARCHAR(255),
    created_date DATE,

    CONSTRAINT fk_candidate_source
        FOREIGN KEY (source_id)
        REFERENCES candidate_sources(source_id)
);

 CREATE TABLE requirements (
    req_id INT AUTO_INCREMENT PRIMARY KEY,
    client_id INT NOT NULL,
    job_title VARCHAR(100),
    job_category VARCHAR(50),
    employment_type VARCHAR(30),
    location VARCHAR(100),
    priority VARCHAR(20),
    openings INT,
    bill_rate DECIMAL(10,2),
    pay_rate DECIMAL(10,2),
    open_date DATE,
    target_close_date DATE,
    status VARCHAR(30),
    recruiter_owner INT,

    CONSTRAINT fk_req_client
        FOREIGN KEY (client_id)
        REFERENCES clients(client_id),

    CONSTRAINT fk_req_recruiter
        FOREIGN KEY (recruiter_owner)
        REFERENCES recruiters(recruiter_id)
);

CREATE TABLE submissions (
    submission_id INT AUTO_INCREMENT PRIMARY KEY,
    candidate_id INT NOT NULL,
    req_id INT NOT NULL,
    recruiter_id INT NOT NULL,
    submission_date DATE,
    submission_status VARCHAR(30),
    feedback VARCHAR(255),

    CONSTRAINT fk_submission_candidate
        FOREIGN KEY (candidate_id)
        REFERENCES candidates(candidate_id),

    CONSTRAINT fk_submission_req
        FOREIGN KEY (req_id)
        REFERENCES requirements(req_id),

    CONSTRAINT fk_submission_recruiter
        FOREIGN KEY (recruiter_id)
        REFERENCES recruiters(recruiter_id)
);

CREATE TABLE interviews (
    interview_id INT AUTO_INCREMENT PRIMARY KEY,
    submission_id INT NOT NULL,
    round_number INT,
    interview_type VARCHAR(30),
    interview_date DATE,
    interviewer VARCHAR(100),
    result VARCHAR(30),
    remarks VARCHAR(255),

    CONSTRAINT fk_interview_submission
        FOREIGN KEY (submission_id)
        REFERENCES submissions(submission_id)
);

CREATE TABLE offers (
    offer_id INT AUTO_INCREMENT PRIMARY KEY,
    interview_id INT NOT NULL,
    offer_date DATE,
    offered_salary DECIMAL(10,2),
    joining_date DATE,
    offer_status VARCHAR(30),

    CONSTRAINT fk_offer_interview
        FOREIGN KEY (interview_id)
        REFERENCES interviews(interview_id)
);

CREATE TABLE placements (
    placement_id INT AUTO_INCREMENT PRIMARY KEY,
    offer_id INT NOT NULL,
    start_date DATE,
    end_date DATE,
    revenue DECIMAL(12,2),
    placement_status VARCHAR(30),

    CONSTRAINT fk_placement_offer
        FOREIGN KEY (offer_id)
        REFERENCES offers(offer_id)
);

CREATE TABLE recruiter_activity (
    activity_id INT AUTO_INCREMENT PRIMARY KEY,
    recruiter_id INT NOT NULL,
    activity_date DATE,
    calls_made INT DEFAULT 0,
    emails_sent INT DEFAULT 0,
    submissions INT DEFAULT 0,
    interviews_scheduled INT DEFAULT 0,
    placements INT DEFAULT 0,

    CONSTRAINT fk_activity_recruiter
        FOREIGN KEY (recruiter_id)
        REFERENCES recruiters(recruiter_id)
);

-- 1. Total Candidates
SELECT COUNT(*) AS total_candidates
FROM candidates;

-- 2. 2. Total Recruiters
SELECT COUNT(*) AS total_recruiters
FROM recruiters;

-- 3. Total Open Requirements
SELECT COUNT(*) AS open_requirements
FROM requirements
WHERE status = 'Open';

-- 4. Candidates by Visa Status
SELECT visa_status, COUNT(*) AS candidate_count
FROM candidates
GROUP BY visa_status;

-- 5. Candidate Source Performance
SELECT cs.source_name, COUNT(c.candidate_id) AS candidates
FROM candidates as c
JOIN candidate_sources as cs
ON c.source_id = cs.source_id
GROUP BY cs.source_name
ORDER BY candidates DESC;

-- 6. Submissions by Recruiter
SELECT r.recruiter_name, COUNT(s.submission_id) AS submissions
FROM recruiters as r
JOIN submissions as s
ON r.recruiter_id = s.recruiter_id
GROUP BY r.recruiter_name
ORDER BY submissions DESC;

-- 7. Top Clients by Requirements
SELECT c.client_name, COUNT(r.req_id) AS requirements
FROM clients as c
JOIN requirements as r
ON c.client_id = r.client_id
GROUP BY c.client_name
ORDER BY requirements DESC
LIMIT 10;

-- 8. Average Experience of Candidates
SELECT ROUND(AVG(experience_years),2) AS avg_experience
FROM candidates;

-- 9. Submission Status Distribution
SELECT submission_status, COUNT(*) AS total
FROM submissions
GROUP BY submission_status;

-- 10. Interviews Scheduled Per Month
SELECT YEAR(interview_date) AS yr, MONTH(interview_date) AS mn, COUNT(*) AS interviews
FROM interviews
GROUP BY yr,mn
ORDER BY yr,mn;

-- 11. Hiring Funnel
SELECT
(SELECT COUNT(*) FROM candidates) AS candidates,
(SELECT COUNT(*) FROM submissions) AS submissions,
(SELECT COUNT(*) FROM interviews) AS interviews,
(SELECT COUNT(*) FROM offers) AS offers,
(SELECT COUNT(*) FROM placements) AS placements;

-- 12. Submission → Interview Conversion
SELECT 
ROUND(
(COUNT(DISTINCT i.submission_id) * 100.0) /
COUNT(DISTINCT s.submission_id),2) AS conversion_rate
FROM submissions s
LEFT JOIN interviews i
ON s.submission_id = i.submission_id;

-- 13. Interview → Offer Conversion
SELECT
ROUND(
(COUNT(DISTINCT o.offer_id) * 100.0) /
COUNT(DISTINCT i.interview_id),2) AS conversion_rate
FROM interviews i
LEFT JOIN offers o
ON i.interview_id = o.interview_id;

-- 14. Offer → Placement Conversion
SELECT
ROUND(
(COUNT(DISTINCT p.placement_id) * 100.0) /
COUNT(DISTINCT o.offer_id),2) AS conversion_rate
FROM offers o
LEFT JOIN placements p
ON o.offer_id = p.offer_id;

-- 15. Top Recruiters by Placements
SELECT r.recruiter_name,COUNT(DISTINCT p.placement_id)AS placements
FROM recruiters r
JOIN submissions s
ON r.recruiter_id=s.recruiter_id
JOIN interviews i
ON s.submission_id=i.submission_id
JOIN offers o
ON i.interview_id=o.interview_id
JOIN placements p
ON o.offer_id=p.offer_id
GROUP BY r.recruiter_name
ORDER BY placements DESC;

-- 16. Recruiter Success Rate
SELECT r.recruiter_name, COUNT(DISTINCT p.placement_id) AS placements,
COUNT(DISTINCT s.submission_id) AS submissions,

ROUND(
COUNT(DISTINCT p.placement_id)*100.0/
COUNT(DISTINCT s.submission_id),2
) AS success_rate
FROM recruiters r
LEFT JOIN submissions s
ON r.recruiter_id=s.recruiter_id

LEFT JOIN interviews i
ON s.submission_id=i.submission_id

LEFT JOIN offers o
ON i.interview_id=o.interview_id

LEFT JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY r.recruiter_name
ORDER BY success_rate DESC;

-- 17. Revenue by Client
SELECT c.client_name,
       SUM(p.revenue) AS revenue
FROM clients c
JOIN requirements r
ON c.client_id=r.client_id

JOIN submissions s
ON r.req_id=s.req_id

JOIN interviews i
ON s.submission_id=i.submission_id

JOIN offers o
ON i.interview_id=o.interview_id

JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY c.client_name
ORDER BY revenue DESC;

-- 18. Client Fill Rate
SELECT
c.client_name,

SUM(r.openings) AS openings,

COUNT(DISTINCT p.placement_id)
AS placements,

ROUND(
COUNT(DISTINCT p.placement_id)*100.0/
SUM(r.openings),2
) AS fill_rate
FROM clients c

JOIN requirements r
ON c.client_id=r.client_id

LEFT JOIN submissions s
ON r.req_id=s.req_id

LEFT JOIN interviews i
ON s.submission_id=i.submission_id

LEFT JOIN offers o
ON i.interview_id=o.interview_id

LEFT JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY c.client_name;

-- 19. Rank Recruiters by Placements
SELECT
recruiter_name,
placements,

RANK() OVER(
ORDER BY placements DESC
) AS recruiter_rank

FROM
(
SELECT r.recruiter_name,
COUNT(DISTINCT p.placement_id)
AS placements

FROM recruiters r
JOIN submissions s
ON r.recruiter_id=s.recruiter_id

JOIN interviews i
ON s.submission_id=i.submission_id

JOIN offers o
ON i.interview_id=o.interview_id

JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY r.recruiter_name
) t;

-- 20. Running Revenue
SELECT
start_date,
revenue,

SUM(revenue) OVER(
ORDER BY start_date
) AS running_revenue

FROM placements;

-- 21. Top Candidate Sources
SELECT
source_name,
placements,

DENSE_RANK() OVER(
ORDER BY placements DESC
) rank_no

FROM
(
SELECT
cs.source_name,
COUNT(p.placement_id)
AS placements

FROM candidate_sources cs

JOIN candidates c
ON cs.source_id=c.source_id

JOIN submissions s
ON c.candidate_id=s.candidate_id

JOIN interviews i
ON s.submission_id=i.submission_id

JOIN offers o
ON i.interview_id=o.interview_id

JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY cs.source_name
) x;

-- 22. Monthly Revenue Trend
SELECT
YEAR(start_date) year_,
MONTH(start_date) month_,
SUM(revenue) revenue
FROM placements
GROUP BY year_,month_
ORDER BY year_,month_;

-- 23. Best Recruiter for Each Month
WITH recruiter_monthly AS
(
SELECT
YEAR(s.submission_date) yr,
MONTH(s.submission_date) mn,
r.recruiter_name,

COUNT(DISTINCT p.placement_id)
placements

FROM recruiters r

JOIN submissions s
ON r.recruiter_id=s.recruiter_id

LEFT JOIN interviews i
ON s.submission_id=i.submission_id

LEFT JOIN offers o
ON i.interview_id=o.interview_id

LEFT JOIN placements p
ON o.offer_id=p.offer_id

GROUP BY yr,mn,r.recruiter_name
)

SELECT *
FROM
(
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY yr,mn
ORDER BY placements DESC
) rn

FROM recruiter_monthly
) x

WHERE rn=1;













