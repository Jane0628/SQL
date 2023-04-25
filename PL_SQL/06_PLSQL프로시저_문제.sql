
/*
    1.
    프로시저명 guguProc
    구구단을 전달받아 해당 단수를 출력하는 procedure를 생성하세요.
*/
CREATE OR REPLACE PROCEDURE guguProc
    (p_num IN NUMBER)
IS
BEGIN
    DBMS_OUTPUT.put_line('*** 구구단 ' || p_num || '단 ***');
    FOR i IN 1..9
    LOOP
        DBMS_OUTPUT.put_line(p_num || ' x ' || i || ' = ' || p_num*i);
    END LOOP;
END;

EXEC guguProc(7);

--------------------------------------------------------------------------------

CREATE PROCEDURE guguproc
    (p_dan IN NUMBER)
IS
BEGIN
    DBMS_OUTPUT.put_line(p_dan || '단');
    FOR i IN 1..9
    LOOP
        DBMS_OUTPUT.put_lind(p_dan || ' x ' || i || ' = ' || p_dan*i);
    END LOOP;
END;

/*
    2.
    부서 번호, 부서명, 작업 flag(I : insert, U : update, D : delete)을 매개 변수로 받아
    depts 테이블에 각각 INSERT, UPDATE, DELETE하는 depts_proc란 이름의 프로시저를 만들어보자.
    그리고 정상 종료라면 commit, 예외라면 롤백 처리하도록 처리하세요.
*/
CREATE OR REPLACE PROCEDURE depts_proc
    (p_dept_num IN depts.department_id%TYPE,
     p_dept_name IN depts.department_name%TYPE,
     p_flag IN VARCHAR2)
IS
BEGIN
    IF p_flag = 'I' THEN
        INSERT INTO depts
            (department_id, department_name)
        VALUES(p_dept_num, p_dept_name);
    ELSIF p_flag = 'U' THEN
        UPDATE depts
        SET department_name = p_dept_name
        WHERE department_id = p_dept_num;
    ELSE
        DELETE FROM depts
        WHERE department_id = p_dept_num;
    END IF;
    
    COMMIT;
END;


BEGIN
    depts_proc(300, INITCAP('administration'), UPPER('D'));
EXCEPTION 
    WHEN OTHERS THEN
        DBMS_OUTPUT.put_line('오류가 발생하였습니다.');
        ROLLBACK;
END;


SELECT * FROM depts;

--------------------------------------------------------------------------------

ALTER TABLE depts ADD CONSTRAINT depts_pk PRIMARY KEY(department_id);

CREATE OR REPLACE PROCEDURE depts_proc
    (p_department_id IN depts.department_id%TYPE,
     p_department_name IN depts.department_name%TYPE,
     p_flag IN VARCHAR2)
IS
    v_cnt NUMBER := 0;
BEGIN
    SELECT COUNT(*) 
    INTO v_cnt
    FROM depts
    WHERE department_id = p_department_id;

    IF p_flag = 'I' THEN
        INSERT INTO depts
        (department_id, department_name)
        VALUES(p_department_id, p_department_name);
    ELSIF p_flag = 'U' THEN
        UPDATE depts
        SET department_name = p_department_name
        WHERE department_id = p_department_id;
    ELSIF p_flag = 'D' THEN
        IF v_cnt = 0 THEN
            DBMS_OUTPUT.put_line('삭제하고자 하는 부서가 존재하지 않습니다.');
            RETURN;
        END IF;
        DELETE FROM depts
        WHERE department_id = p_department_id;
    ELSE
        DBMS_OUTPUT.put_line('해당 flag에 대한 동작이 준비되지 않았습니다.');
    END IF;
    COMMIT;

EXCEPTION WHEN OTHERS THEN
    DBMS_OUTPUT.put_line('예외가 발생했습니다.');
    DBMS_OUTPUT.put_line('ERROR MSG : ' || SQLERRM);
    ROLLBACK;
END;

EXEC depts_proc(100, '오락부', 'D');

SELECT * FROM depts;


/*
    3.
    employee_id를 입력받아 employees에 존재하면, 근속년수를 out하는 프로시저를 작성하세요. (익명블록에서 프로시저를 실행)
    없다면 exception처리하세요
*/
CREATE OR REPLACE PROCEDURE emps_proc
    (p_emp_id IN emps.employee_id%TYPE,
     p_work_day OUT NUMBER)
IS
    v_work_day NUMBER := 0;
BEGIN
    SELECT
        TRUNC((sysdate - hire_date)/365)
    INTO v_work_day
    FROM employees
    WHERE employee_id = p_emp_id;
    
    p_work_day := v_work_day;
END;


DECLARE
    work_day NUMBER;
BEGIN
    emps_proc(10, work_day);
END;

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE emp_hire_proc
    (p_employee_id IN employees.employee_id%TYPE,
     p_year OUT NUMBER)
IS
    v_hire_date employees.hire_date%TYPE;
BEGIN
    SELECT
        hire_date
    INTO v_hire_date
    FROM employees
    WHERE employee_id = p_employee_id;
    
    p_year := TRUNC((sysdate - v_hire_date)/365);

EXCEPTION WHEN OTHERS THEN
    dbms_output.put_line(p_employee_id || '은(는) 없는 데이터입니다.');
END;

DECLARE
    v_year NUMBER;
BEGIN
    emp_hire_proc(135, v_year);
    dbms_output.put_line(v_year);
END;


/*
프로시저명 - new_emp_proc
employees 테이블의 복사 테이블 emps를 생성합니다.
employee_id, last_name, email, hire_date, job_id를 입력받아
존재하면 이름, 이메일, 입사일, 직업을 update, 
없다면 insert하는 merge문을 작성하세요

머지를 할 타겟 테이블 -> emps
병합시킬 데이터 -> 프로시저로 전달받은 employee_id를 dual에 select 때려서 비교.
프로시저가 전달받아야 할 값 : 사번, last_name, email, hire_date, job_id
*/
CREATE OR REPLACE PROCEDURE new_emp_proc
    (p_employee_id IN employees.employee_id%TYPE,
     p_last_name IN employees.last_name%TYPE,
     p_email IN employees.email%TYPE,
     p_hire_date IN employees.hire_date%TYPE,
     p_job_id IN employees.job_id%TYPE)
IS
BEGIN
    MERGE INTO emps a
        USING (SELECT * FROM dual)
        ON (a.employee_id = p_employee_id)
    WHEN MATCHED THEN
        UPDATE SET
            a.last_name = p_last_name,
            a.email = p_email,
            a.hire_date = p_hire_date,
            a.job_id = p_job_id
    WHEN NOT MATCHED THEN
        INSERT (employee_id, last_name, email, hire_date, job_id)
        VALUES (p_employee_id, p_last_name, p_email, p_hire_date, p_job_id);
END;

BEGIN
    new_emp_proc(148, 'Jane', 'I love Gogi', sysdate, 'Programmer');
END;

--------------------------------------------------------------------------------

CREATE OR REPLACE PROCEDURE new_emp_proc
    (p_employee_id IN employees.employee_id%TYPE,
     p_last_name IN employees.last_name%TYPE,
     p_email IN employees.email%TYPE,
     p_hire_date IN employees.hire_date%TYPE,
     p_job_id IN employees.job_id%TYPE)
IS
BEGIN
    MERGE INTO emps a
        USING (SELECT p_employee_id AS employee_id FROM dual) b
        ON (a.employee_id = b.employee_id)
    WHEN MATCHED THEN
        UPDATE SET
            a.last_name = p_last_name,
            a.email = p_email,
            a.hire_date = p_hire_date,
            a.job_id = p_job_id
    WHEN NOT MATCHED THEN
        INSERT (a.employee_id, a.last_name, a.email, a.hire_date, a.job_id)
        VALUES (p_employee_id, p_last_name, p_email, p_hire_date, p_job_id);
END;

EXEC new_emp_proc(100, 'park', 'park4321', '2023-04-24', 'test2');