
-- 테이블 생성과 제약조건
-- 테이블 열레벨 제약조건 (PRIMARY KEY, UNIQUE, NOT NULL, FOREIGN KEY, CHECK)
-- PRIMARY KEY: 테이블의 고유 식별 컬럼입니다. (주요 키)
-- UNIQUE: 유일한 값을 갖게 하는 컬럼 (중복값 방지)
-- NOT NULL: null을 허용하지 않음.
-- FOREIGN KEY: 참조하는 테이블의 PRIMARY KEY를 저장하는 컬럼
-- CHECK: 정의된 형식만 저장되도록 허용.

DROP TABLE dept2;

-- 컬럼 레벨 제약 조건 (컬럼 선언마다 제약조건 지정)
CREATE TABLE dept2(
    dept_no NUMBER(2) CONSTRAINT dept2_deptno_pk PRIMARY KEY,
    dept_name VARCHAR2(14) NOT NULL CONSTRAINT dept2_deptname_uk UNIQUE,
    loca NUMBER(4) CONSTRAINT dept2_loca_locid_fk REFERENCES locations(location_id),
    dept_bonus NUMBER(10) CONSTRAINT dept2_bonus_ck CHECK(dept_bonus > 0),
    dept_gender VARCHAR2(1) CONSTRAINT dept2_gender_ck CHECK(dept_gender IN('M', 'F'))
);

-- 테이블 레벨 제약 조건(모든 열 선언 후 제약조건을 취하는 방식)
CREATE TABLE dept2(
    dept_no NUMBER(2),
    dept_name VARCHAR2(14) NOT NULL,
    loca NUMBER(4),
    dept_bonus NUMBER(10),
    dept_gender VARCHAR2(1),
    
    CONSTRAINT dept2_deptno_pk PRIMARY KEY(dept_no),
    CONSTRAINT dept2_deptname_uk UNIQUE(dept_name),
    CONSTRAINT dept2_loca_locid_fk FOREIGN KEY(loca) REFERENCES locations(location_id),
    CONSTRAINT dept2_bonus_ck CHECK(dept_bonus > 0),
    CONSTRAINT dept2_gender_ck CHECK(dept_gender IN('M', 'F'))
);

-- 외래 키(foreign key)가 부모 테이블(참조 테이블)에 없다면 INSERT가 불가능
INSERT INTO dept2
VALUES(10, 'GG', 4000, 100000, 'M'); -- 에러

-- 주요 키(primary key)는 고유한 식별자여야 합니다.
INSERT INTO dept2
VALUES(20, 'HH', 1900, 100000, 'M');

UPDATE dept2
SET loca = 4000
WHERE dept_no = 10; -- 실패(외래키 제약조건 위반)

UPDATE dept2
SET loca = 4000
WHERE loca = 1800; -- 실패(외래키 제약조건 위반)

-- 제약 조건 변경
-- 제약 조건은 추가, 삭제는 가능하지만 변경은 안됩니다.
-- 변경하려면 삭제하고 새로운 내용으로 추가하셔야 합니다.
DROP TABLE dept2;

CREATE TABLE dept2(
    dept_no NUMBER(2),
    dept_name VARCHAR2(14) NOT NULL,
    loca NUMBER(4),
    dept_bonus NUMBER(10),
    dept_gender VARCHAR2(1)
);

-- pk 추가
ALTER TABLE dept2 ADD CONSTRAINT dept_no_pk PRIMARY KEY(dept_no);
-- fk 추가
ALTER TABLE dept2 ADD CONSTRAINT dept2_loca_locid_fk
FOREIGN KEY(loca) REFERENCES locations(location_id);
-- check 추가
ALTER TABLE dept2 ADD CONSTRAINT dept2_gender_ck CHECK(dept_gender IN('M', 'F'));
-- unique 추가
ALTER TABLE dept2 ADD CONSTRAINT dept2_deptname_uk UNIQUE(dept_name);
-- NOT NULL은 열 수정형태로 변경합니다.
ALTER TABLE dept2 MODIFY dept_bonus NUMBER(10) NOT NULL;

-- 제약 조건 삭제 (제약 조건 이름으로)
ALTER TABLE dept2 DROP CONSTRAINT dept_no_pk;

-- 제약 조건 확인
SELECT * FROM user_constraints
WHERE table_name = 'DEPT2';

--------------------------------------------------------------------------------

-- 문제 1. 다음과 같은 테이블을 생성하고 데이터를 insert하세요. (커밋)
-- 조건) M_NAME은 가변문자형, 널값을 허용하지 않음
-- 조건) M_NUM은 숫자형, 이름(mem_memnum_pk) primary key
-- 조건) REG_DATE는 날짜형, 널값을 허용하지 않음, 이름:(mem_regdate_uk) UNIQUE키
-- 조건) GENDER 가변문자형
-- 조건) LOCA 숫자형, 이름:(mem_loca_loc_locid_fk) foreign key - 참조 locations 테이블 (location_id)

CREATE TABLE members(
    m_name VARCHAR2(3) NOT NULL,
    m_num NUMBER(1),
    reg_date DATE NOT NULL,
    gender VARCHAR2(1),
    loca NUMBER(4),
    
    CONSTRAINT mem_memnum_pk PRIMARY KEY(m_num),
    CONSTRAINT mem_regdate_uk UNIQUE(reg_date),
    CONSTRAINT mem_loca_loc_locid_fk FOREIGN KEY(loca) REFERENCES locations(location_id)
);

INSERT INTO members VALUES('AAA', 1, '2018-07-01', 'M', 1800);
INSERT INTO members VALUES('BBB', 2, '2018-07-02', 'F', 1900);
INSERT INTO members VALUES('CCC', 3, '2018-07-03', 'M', 2000);
INSERT INTO members VALUES('DDD', 4, sysdate, 'M', 2000);

SELECT * FROM members;


-- 문제 2.
-- members 테이블과 locations 테이블을 inner join하고 m_name, m_num, street_address, location_id 컬럼만 조회.
-- m_num 기준으로 오름차순 조회
SELECT
    m.m_name, m.m_num,
    loc.street_address, loc.location_id
FROM members m JOIN locations loc
ON m.loca = loc.location_id
ORDER BY m.m_num;