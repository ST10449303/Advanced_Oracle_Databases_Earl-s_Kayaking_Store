--Question 2
--Create Tables 

CREATE TABLE KAYAKS (
    kayak_id NUMBER PRIMARY KEY,
    kayak_type VARCHAR2(50),
    kayak_model VARCHAR2(50),
    manufacturer VARCHAR2(50)
);

CREATE TABLE CUSTOMER (
    cust_id VARCHAR2(10) PRIMARY KEY,
    cust_fname VARCHAR2(50),
    cust_sname VARCHAR2(50),
    cust_address VARCHAR2(100),
    cust_contact VARCHAR2(15)
);

CREATE TABLE UPGRADES (
    upgrade_id NUMBER PRIMARY KEY,
    upgrade_work VARCHAR2(100),
    upgrade_date DATE,
    upgrade_hrs NUMBER
);

CREATE TABLE KAYAK_UPGRADES (
    kayak_upgrade_num NUMBER PRIMARY KEY,
    kayak_upgrade_date DATE,
    kayak_upgrade_amt NUMBER,
    kayak_id NUMBER,
    cust_id VARCHAR2(10),
    upgrade_id NUMBER,
    CONSTRAINT fk_kayak FOREIGN KEY (kayak_id) REFERENCES KAYAKS(kayak_id),
    CONSTRAINT fk_customer FOREIGN KEY (cust_id) REFERENCES CUSTOMER(cust_id),
    CONSTRAINT fk_upgrade FOREIGN KEY (upgrade_id) REFERENCES UPGRADES(upgrade_id)
);

--Question 3
-- Create Users (Common Users in Oracle XE)
CREATE USER C##TSHEPO IDENTIFIED BY tmphoabc2023;
CREATE USER C##MYA IDENTIFIED BY mrobertabc2023;

-- Grant basic login privileges
GRANT CONNECT TO C##TSHEPO;
GRANT CONNECT TO C##MYA;

-- Grant required permissions
GRANT SELECT ANY TABLE TO C##TSHEPO;
GRANT INSERT ANY TABLE TO C##MYA;

--Question 3
/*
Separation of Duties (SoD) is important in a database environment to ensure that no single user has full control over all operations.

In this scenario:
- Tshepo is granted SELECT ANY TABLE, meaning he can only view data but cannot modify it.
- Mya is granted INSERT ANY TABLE, meaning she can add new data but cannot view or manipulate existing records broadly.

This separation improves security, reduces the risk of fraud or accidental data corruption, and ensures accountability, as each user has a specific and limited role within the system.
*/

--Question 4

SELECT 
    ku.kayak_id,
    ku.cust_id,
    u.upgrade_hrs,
    ku.kayak_upgrade_amt,
    (u.upgrade_hrs * ku.kayak_upgrade_amt) AS total_sales
FROM KAYAK_UPGRADES ku
JOIN UPGRADES u ON ku.upgrade_id = u.upgrade_id;

--QUESTION 5

SELECT 
    c.cust_fname || ' ' || c.cust_sname AS full_name,
    k.kayak_type,
    u.upgrade_hrs,
    u.upgrade_work,
    ku.kayak_upgrade_amt
FROM KAYAK_UPGRADES ku
JOIN CUSTOMER c ON ku.cust_id = c.cust_id
JOIN KAYAKS k ON ku.kayak_id = k.kayak_id
JOIN UPGRADES u ON ku.upgrade_id = u.upgrade_id;

--QUESTION 6

SET SERVEROUTPUT ON;

DECLARE
    -- Declare explicit cursor
    CURSOR c_upgrades IS
        SELECT ku.cust_id, u.upgrade_work, ku.kayak_upgrade_amt
        FROM KAYAK_UPGRADES ku
        JOIN UPGRADES u ON ku.upgrade_id = u.upgrade_id
        WHERE ku.kayak_upgrade_amt > 50
        ORDER BY ku.cust_id;

    -- Declare variables
    v_cust_id KAYAK_UPGRADES.cust_id%TYPE;
    v_work UPGRADES.upgrade_work%TYPE;
    v_amount KAYAK_UPGRADES.kayak_upgrade_amt%TYPE;

BEGIN
    -- Open cursor
    OPEN c_upgrades;

    LOOP
        -- Fetch data into variables
        FETCH c_upgrades INTO v_cust_id, v_work, v_amount;
        EXIT WHEN c_upgrades%NOTFOUND;

        -- Display output
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('CUSTOMER ID: ' || v_cust_id || ',');
        DBMS_OUTPUT.PUT_LINE('UPGRADE WORK: ' || v_work);
        DBMS_OUTPUT.PUT_LINE('UPGRADE AMOUNT: R ' || v_amount);
    END LOOP;

    -- Close cursor
    CLOSE c_upgrades;

END;
/

--QUESTION 7

SET SERVEROUTPUT ON;

DECLARE
    -- Explicit cursor
    CURSOR c_data IS
        SELECT 
            c.cust_fname || ' ' || c.cust_sname AS name,
            k.kayak_type,
            u.upgrade_work,
            TO_CHAR(ku.kayak_upgrade_date, 'DD-MON-YY') AS upgrade_date,
            ku.kayak_upgrade_amt,
            ku.cust_id
        FROM KAYAK_UPGRADES ku
        JOIN CUSTOMER c ON ku.cust_id = c.cust_id
        JOIN KAYAKS k ON ku.kayak_id = k.kayak_id
        JOIN UPGRADES u ON ku.upgrade_id = u.upgrade_id
        ORDER BY ku.cust_id DESC;

    -- Variables
    v_name CUSTOMER.cust_fname%TYPE;
    v_type KAYAKS.kayak_type%TYPE;
    v_work UPGRADES.upgrade_work%TYPE;
    v_date VARCHAR2(20);
    v_amount KAYAK_UPGRADES.kayak_upgrade_amt%TYPE;
    v_cust_id KAYAK_UPGRADES.cust_id%TYPE;
    v_discount NUMBER;

BEGIN
    -- Open cursor
    OPEN c_data;

    LOOP
        -- Fetch data
        FETCH c_data INTO v_name, v_type, v_work, v_date, v_amount, v_cust_id;
        EXIT WHEN c_data%NOTFOUND;

        -- Apply discount only for C121
        IF v_cust_id = 'C121' THEN
            v_discount := v_amount * 0.10;
        ELSE
            v_discount := 0;
        END IF;

        -- Display output
        DBMS_OUTPUT.PUT_LINE('--------------------------------------------------');
        DBMS_OUTPUT.PUT_LINE('CUSTOMER: ' || v_name);
        DBMS_OUTPUT.PUT_LINE('KAYAK TYPE: ' || v_type);
        DBMS_OUTPUT.PUT_LINE('UPGRADE WORK: ' || v_work);
        DBMS_OUTPUT.PUT_LINE('UPGRADE DATE: ' || v_date);
        DBMS_OUTPUT.PUT_LINE('UPGRADE AMT: R ' || v_amount);
        DBMS_OUTPUT.PUT_LINE('DISCOUNT AMT: R ' || v_discount);

    END LOOP;

    -- Close cursor
    CLOSE c_data;

END;
/

--QUESTION 8

CREATE VIEW vwCustUpgrades AS
SELECT 
    c.cust_fname || ', ' || c.cust_sname AS customer,
    k.kayak_type,
    u.upgrade_work,
    c.cust_contact
FROM KAYAK_UPGRADES ku
JOIN CUSTOMER c ON ku.cust_id = c.cust_id
JOIN KAYAKS k ON ku.kayak_id = k.kayak_id
JOIN UPGRADES u ON ku.upgrade_id = u.upgrade_id
WHERE c.cust_address LIKE '%Summer%';

SELECT * FROM vwCustUpgrades;
