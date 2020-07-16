import cv2
import numpy as np

from ciede2000 import CIEDE2000

# image
image = cv2.imread("blb.png")
image = np.float32(image)
image *= 1./255
Lab = cv2.cvtColor(image, cv2.COLOR_BGR2Lab)
L, a, b = cv2.split(Lab)

L = L.flatten()
a = a.flatten()
b = b.flatten()

length = L.shape[0]

# color
colorL = np.full((length), 10)
colorA = np.full((length), 10)
colorB = np.full((length), 10)

print(colorL.shape)
print(L.shape)

diff = 0
for i in range(length):
    # diff += CIEDE2000((L[i], a[i], b[i]), (colorL[i], colorA[i], colorB[i]))
    diff += CIEDE2000((L[i], a[i], b[i]), (L[i], a[i], b[i]))
    print(f'{i}/{length}')

print('diff', diff)