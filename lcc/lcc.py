import cv2
import numpy as np

from ciede2000 import CIEDE2000


# given the filename of an image, this method returns the flattened lab values
def convertToLAB(filename):
    img = cv2.imread(filename)
    img = np.float32(img)
    img *= 1./255
    Lab = cv2.cvtColor(img, cv2.COLOR_BGR2Lab)
    L, a, b = cv2.split(Lab)
    return (L.flatten(), a.flatten(), b.flatten())

# iterates through the image and quotient of the sum of the differents and the length
def total_difference(L1, a1, b1, L2, a2, b2):
    length = min(L1.shape[0], L2.shape[0])
    diff = 0
    for i in range(length):
        diff += CIEDE2000((L1[i], a1[i], b1[i]), (L2[i], a2[i], b2[i]))
        # print(f'{i}/{length}')
    return diff/length

# finds the difference between the medians of two images
def median_difference(L1, a1, b1, L2, a2, b2):
    length = min(L1.shape[0], L2.shape[0])
    # sort
    index = (length-1)/2


# REPLACE THE NAME OF THE IMAGE
filename = 'blb.png'

LCC2 = 'LCC2.jpeg'
LCC3 = 'LCC3.jpeg'
LCC4 = 'LCC4.jpeg'
LCC5 = 'LCC5.jpeg'

L, a, b = convertToLAB(filename)

L_LCC2, a_LCC2, b_LCC2 = convertToLAB(LCC2)
L_LCC3, a_LCC3, b_LCC3 = convertToLAB(LCC3)
L_LCC4, a_LCC4, b_LCC4 = convertToLAB(LCC4)
L_LCC5, a_LCC5, b_LCC5 = convertToLAB(LCC5)

print('LCC2', total_difference(L, a, b, L_LCC2, a_LCC2, b_LCC2))
print('LCC3', total_difference(L, a, b, L_LCC3, a_LCC3, b_LCC3))
print('LCC4', total_difference(L, a, b, L_LCC4, a_LCC4, b_LCC4))
print('LCC5', total_difference(L, a, b, L_LCC5, a_LCC5, b_LCC5))

