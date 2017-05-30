# leveinshtein-distance
Simple implementation of leveinshtein distance algorithm in python and oracle password security

# Oracle DB
To create secure password function
1. Change the parameters to fit your requirements.
2. Login to your SYS account e.g.
	```shell
	$sqlplus /  as sysdba
	```
3. Import the SQL file into your account
	```shell
	>@pstrensth.sql
	```
4. Create a user account to test the requirements.

# Python script
To run the script, user:
```shell
$python leveinshtein.py
```
or you can copy the functions to your code and use it as fit by calling the function:
```python
	distance=leveinshtein_distance(source,target)
	print("Distance:%d"%distance)
	#Do something useful here
```
