import cv2
import numpy as np

from ciede2000 import CIEDE2000

# REPLACE THE NAME OF THE FILES
filename1 = 'blb1.png'
filename2 = 'blb1.png'

# image1
image1 = cv2.imread(filename1)
image1 = np.float32(image1)
image1 *= 1./255
Lab = cv2.cvtColor(image1, cv2.COLOR_BGR2Lab)
L1, a1, b1 = cv2.split(Lab)

L1 = L1.flatten()
a1 = a1.flatten()
b1 = b1.flatten()

# image2
image2 = cv2.imread(filename2)
image2 = np.float32(image2)
image2 *= 1./255
Lab = cv2.cvtColor(image2, cv2.COLOR_BGR2Lab)
L2, a2, b2 = cv2.split(Lab)

L2 = L2.flatten()
a2 = a2.flatten()
b2 = b2.flatten()

length = L1.shape[0]

diff = 0
for i in range(length):
    diff += CIEDE2000((L1[i], a1[i], b1[i]), (L2[i], a2[i], b2[i]))
    print(f'{i}/{length}')

print('diff', diff)