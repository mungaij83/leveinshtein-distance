from __future__ import print_function

"""
	Python: >=2.7 and >=3.3
	Author: John Mungai
	Date: 30-05-2017
	Reference: https://people.cs.pitt.edu/~kirk/cs1501/Pruhs/Spring2006/assignments/editdistance/Levenshtein%20Distance.htm

	This algorithm can be used to determine the strength of a password as 
	implemented in the attached SQL document.
"""

def minimum(x,y,z):
	"""
	Determine the minum of three values
		min=x
		if(y<mi):
			mi=y
		if(z<mi):
			mi=z
		return mi
	"""
	return min(min(x,y),z)
def leveinshtein_distance(source,target):
	"""
	Implement leveintein distance algorithm as described in the reference
	"""
	#Step 1
	s_len=len(source)
	t_len=len(target)
	cost=0
	if(s_len==0):
		return t_len
	if(t_len==0):
		return s_len
	print("Dimensions:\n\tN:%d\n\tM:%d"%(s_len,t_len))
	#Step 2
	matrix=[[0 for _ in range(0,t_len+1)] for _ in range(0, s_len+1)]
	#Initialize first row 0..s_len
	for idx in range(0,s_len+1):
		matrix[idx][0]=idx
	#Initialize the first column 0..t_len
	for idx in range(0, t_len+1):
		matrix[0][idx]=idx
	print("===Original===")
	print_matrix(matrix,source,target)
	#Step 3
	for i in range(1,s_len+1):
		ch=source[i-1]
		#print(ch)
		#Step 4
		for j in range(1,t_len+1):
			#print(">%s"%target[j-1])
			#Step 5
			if ch==target[j-1]:
				cost=0
			else:
				cost=1
			#Step 6
			
			#print("(i,j)=>(%d,%d)"%(i,j))
			#print(matrix[i][j])
			matrix[i][j]=minimum(
				matrix[i-1][j]+1,
				matrix[i][j-1]+1,
				matrix[i-1][j-1]+cost
			)
	print("===Final Matrix===")
	print_matrix(matrix,source,target)
	return matrix[s_len-1][t_len-1]
def print_matrix(matrix,source,target):
	"""
	Print source matrix for visual representation
	"""
	print(u"\t (s)\u2192 \t",end='')
	for c in target:
		print("%2s\t"%c,end='')
	print()
	for x in range(0,len(matrix)):
		if(x==0):
			print(u"(t)\u2193 \t",end='')
		else:
			print("%2s\t"%source[x-1],end='')
		for y in range(0,len(matrix[0])):
			#print("%2d (%d,%d)\t"%(matrix[x][y],x,y),end='')
			print("%2d \t"%(matrix[x][y]),end='')
		print("")
def main():
	source="GUMBO"
	target="GAMBOL"
	distance=leveinshtein_distance(source,target)
	print("Distance:%d"%distance)
if(__name__=='__main__'):
	main()