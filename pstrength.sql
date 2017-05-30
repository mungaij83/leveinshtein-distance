Rem  Function: "is481_password" - Verifies the complexity 
Rem            of a password created by user.
Rem 
Rem  chars   -  All characters (i.e. string length)
Rem  letter  -  Alphabetic characters A-Z and a-z
Rem  upper   -  Uppercase letters A-Z
Rem  lower   -  Lowercase letters a-z
Rem  digit   -  Numeric characters 0-9
Rem  special -  All characters not in A-Z, a-z, 0-9 except DOUBLE QUOTE
Rem             which is a password delimiter
--https://docs.oracle.com/cd/B28359_01/network.111/b28531/authentication.htm#DBSEG97906
--CHECK password

CREATE OR REPLACE FUNCTION check_password_complexity(password varchar2,chars integer :=6, letter integer := 4, upper integer := 2, lower integer := 1, digit integer := 2,special integer := 1)
RETURN boolean IS
   digits_array varchar2(10) := '0123456789';
   alphabet_array varchar2(26) := 'abcdefghijklmnopqrstuvwxyz';
   count_letter integer := 0;
   count_upper integer := 0;
   count_lower integer := 0;
   count_digit integer := 0;
   count_special integer := 0;
   delimiter boolean := FALSE;
   len INTEGER := NVL(length(password), 0);
   i integer ;
   ch CHAR(1);
BEGIN
   --Check password does not exced manimum database password length
   IF len > 256 THEN
      raise_application_error(-20020, 'Password length more than 256');
   END IF;

   --Group password characterd as letters, digits, special characters, lower case characters, or upercase characters
   -- Also checks for password delimiter " 
   FOR i in 1..len LOOP
      ch := substr(password, i, 1); --Pick one character
      IF ch = '"' THEN
         delimiter := TRUE;
      ELSIF instr(digits_array, ch) > 0 THEN
         count_digit := count_digit + 1;
      ELSIF instr(alphabet_array, NLS_LOWER(ch)) > 0 THEN
         count_letter := count_letter + 1;
         IF ch = NLS_LOWER(ch) THEN
            count_lower := count_lower + 1;
         ELSE
            count_upper := count_upper + 1;
         END IF;
      ELSE
         count_special := count_special + 1;
      END IF;
   END LOOP;
  --Check if password delimiter is in password
   IF delimiter = TRUE THEN
      raise_application_error(-20012, 'password must NOT contain a ' || 'double-quote character, which is ' || 'reserved as a password delimiter');
   END IF;
   -- Count of characters 
   IF chars IS NOT NULL AND len < chars THEN
      raise_application_error(-20001, 'Password length less than ' || chars);
   END IF;
   --Check count of characters
   IF letter IS NOT NULL AND count_letter < letter THEN
      raise_application_error(-20022, 'Password must contain at least ' || letter || ' letter(s)');
   END IF;
   --Check count of upper characters
   IF upper IS NOT NULL AND count_upper < upper THEN
      raise_application_error(-20023, 'Password must contain at least ' || upper || ' uppercase character(s)');
   END IF;
   --Check count of lower case characters
   IF lower IS NOT NULL AND count_lower < lower THEN
      raise_application_error(-20024, 'Password must contain at least ' || lower || ' lowercase character(s)');
   END IF;
   --Check count of digits
   IF digit IS NOT NULL AND count_digit < digit THEN
      raise_application_error(-20025, 'Password must contain at least ' || digit || ' digit(s)');
   END IF;
   --Count of special characters
   IF special IS NOT NULL AND count_special < special THEN
      raise_application_error(-20026, 'Password must contain at least ' || special || ' special character(s)');
   END IF;
  --Return TRUE if all the rules passed
   RETURN(TRUE);
END;
/

Rem  Function: "string_distance" - Calculates the Levenshtein distance 
Rem            between two strings 's' and 't'.
Rem Reference https://people.cs.pitt.edu/~kirk/cs1501/Pruhs/Spring2006/assignments/editdistance/Levenshtein%20Distance.htm

CREATE OR REPLACE FUNCTION leveinstein_distance(source_s varchar2,target_s varchar2)
RETURN integer IS
   s_len    INTEGER := NVL (length(source_s), 0);
   t_len    INTEGER := NVL (length(target_s), 0);
   TYPE arr_type is TABLE OF NUMBER INDEX BY BINARY_INTEGER;
   d_col    arr_type ;
   dist     INTEGER := 0;
BEGIN
  --Base cases
   IF s_len = 0 THEN
      dist := t_len;
   ELSIF t_len = 0 THEN
      dist := s_len;
   ELSE
      
      FOR j IN 1 .. (t_len+1) * (s_len+1) - 1 LOOP
          d_col(j) := 0 ;
      END LOOP;
      --Create 0..m matrix
      FOR i IN 0 .. s_len LOOP
          d_col(i) := i;
      END LOOP;
      
      --Create 0..n matrix
      FOR j IN 1 .. t_len LOOP
          d_col(j * (s_len + 1)) := j;
      END LOOP;
      
      FOR i IN 1.. s_len LOOP
        FOR j IN 1 .. t_len LOOP
          IF substr(source_s, i, 1) = substr(target_s, j, 1)
          THEN
             d_col(j * (s_len + 1) + i) := d_col((j-1) * (s_len+1) + i-1) ;
          ELSE
             d_col(j * (s_len + 1) + i) := LEAST (
                       d_col( j * (s_len+1) + (i-1)) + 1,      -- Deletion
                       d_col((j-1) * (s_len+1) + i) + 1,       -- Insertion
                       d_col((j-1) * (s_len+1) + i-1) + 1 ) ;  -- Substitution
          END IF ;
        END LOOP;
      END LOOP;
      dist :=  d_col(t_len * (s_len+1) + s_len);
   END IF;

   RETURN (dist);
END;
/


CREATE OR REPLACE FUNCTION is481_password(username varchar2,password varchar2,old_password varchar2)
  RETURN boolean IS differ integer;
BEGIN 
   -- Check if the password is same as the username
   IF NLS_LOWER(password) = NLS_LOWER(username) THEN
     raise_application_error(-20001, 'Password same as or similar to user');
   END IF;

   -- Check if the password contains at least four characters, including
   -- one letter, one digit and one punctuation mark.
   IF NOT CHECK_PASSWORD_COMPLEXITY(password, chars => 6, letter => 1, digit => 1, special => 1) THEN
      RETURN(FALSE);
   END IF;

   -- Check if the password is too simple. A dictionary of words may be
   -- maintained and a check may be made so as not to allow the words
   -- that are too simple for the password.
   --You can also use the leveintein distance algorithm to check for similarity with these
   --entries
   IF NLS_LOWER(password) IN ('welcome', 'database', 'account', 'user', 
                              'password', 'oracle', 'computer', 'abcd','abcd123') THEN
      raise_application_error(-20002, 'Password too simple');
   END IF;

   -- Check if the password differs from the previous password by at least
   -- 3 letters
   IF old_password IS NOT NULL THEN
     differ := leveinstein_distance(old_password, password);
     IF differ < 3 THEN
         raise_application_error(-20004, 'Password should differ by at' || 'least 3 characters');
     END IF;
   END IF;

   RETURN(TRUE);
END;
/

GRANT EXECUTE ON is481_password TO PUBLIC;

Rem Alter the default password and create a user profile to utilize the above functions
Rem   uses the is481_password and set password limmit specification

ALTER PROFILE DEFAULT LIMIT
PASSWORD_LIFE_TIME 60
PASSWORD_GRACE_TIME 1
PASSWORD_REUSE_TIME 30
PASSWORD_REUSE_MAX  UNLIMITED
FAILED_LOGIN_ATTEMPTS 3
PASSWORD_LOCK_TIME 13
PASSWORD_VERIFY_FUNCTION is481_password;

