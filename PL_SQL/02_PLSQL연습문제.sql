
-- 1. 구구단 중 3단을 출력하는 익명 블록을 만들어 보자. (출력문 9개를 복사해서 쓰세요)
BEGIN
    DBMS_OUTPUT.put_line('3 x 1 = ' || 3*1);
    DBMS_OUTPUT.put_line('3 x 2 = ' || 3*2);
    DBMS_OUTPUT.put_line('3 x 3 = ' || 3*3);
    DBMS_OUTPUT.put_line('3 x 4 = ' || 3*4);
    DBMS_OUTPUT.put_line('3 x 5 = ' || 3*5);
    DBMS_OUTPUT.put_line('3 x 6 = ' || 3*6);
    DBMS_OUTPUT.put_line('3 x 7 = ' || 3*7);
    DBMS_OUTPUT.put_line('3 x 8 = ' || 3*8);
    DBMS_OUTPUT.put_line('3 x 9 = ' || 3*9);
END;


-- 2. employees 테이블에서 201번 사원의 이름과 이메일 주소를 출력하는 익명 블록을 만들어 보자. (변수에 담아서 출력하세요.)
DECLARE
    emp_name employees.first_name%TYPE;
    emp_email employees.email%TYPE;
BEGIN
    SELECT
        first_name || ' ' || last_name,
        email
    INTO emp_name, emp_email
    FROM employees
    WHERE employee_id = 201;
    
    DBMS_OUTPUT.put_line('201번 사원의 정보');
    DBMS_OUTPUT.put_line('이름 : ' || emp_name);
    DBMS_OUTPUT.put_line('이메일 : ' || emp_email);
END;


-- 3. employees 테이블에서 사원번호가 제일 큰 사원을 찾아낸 뒤 (MAX 함수 사용) 해당 번호 + 1번으로 아래의 사원을 emps 테이블에 employee_id, last_name, email, hire_date, job_id를 신규 삽입하는 익명 블록을 만드세요.
--    SELECT절 이후에 INSERT문 사용이 가능합니다.
/*
    <사원명> : Steven
    <이메일> : stevenjobs
    <입사일자> : 오늘 날짜
    <JOB_ID> : CEO
*/
DECLARE
    max_num employees.employee_id%TYPE;
BEGIN
    SELECT
        MAX(employee_id) + 1
    INTO max_num
    FROM employees;
    
    INSERT INTO emps
        (employee_id, last_name, email, hire_date, job_id)
    VALUES(max_num, 'Steven', 'stevenjobs', sysdate, 'CEO');
END;