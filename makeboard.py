import sys
import os
import random

if(len(sys.argv)!=2):
	print('Give me a board file!')
	exit(1)

file = open(sys.argv[1],'w+')

w = 100
h = 40
seed = 2

x = 1
while(x<w):
	file.write('#')
	x += 1
file.write('#\n')

y = 2
while(y<h):
	x=2
	file.write('#')
	while(x<w):
		#flip a coin
		fill = random.randint(1,seed+1)
		if(fill == 1):
			file.write(' ')
		else:
			if(random.randint(1,10)==1):
				file.write('^')
			else:
				file.write('*')
		x += 1
	file.write('#\n')
	y += 1

x = 1
while(x<w):
	file.write('#')
	x += 1
file.write('#\n')

file.close()

print('Board written to {}'.format(sys.argv[1]))
print('Height: {}\nWidth: {}\nRand Seed: {}'.format(h,w,seed))
os.system('cat '+sys.argv[1])