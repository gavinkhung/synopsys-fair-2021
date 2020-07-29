import cv2
import numpy as np
import matplotlib.pyplot as plt

from ciede2000 import CIEDE2000

# masks the image
# look at https://realpython.com/python-opencv-color-spaces/ for more about image segmentation
def maskedImage(filename):
    # load image
    image = cv2.imread(filename)
    image = cv2.cvtColor(image, cv2.COLOR_BGR2RGB)
    plt.imshow(image)
    plt.show()
    hsv_image = cv2.cvtColor(image, cv2.COLOR_RGB2HSV)

    # masking range in hsv
    lower_bound = (35, 60, 35)
    upper_bound = (100, 255, 255)

    # create the mask
    lower_square = np.full((10, 10, 3), lower_bound, dtype=np.uint8) / 255.0
    upper_square = np.full((10, 10, 3), upper_bound, dtype=np.uint8) / 255.0
    mask = cv2.inRange(hsv_image, lower_bound, upper_bound)

    # apply mask
    result = cv2.bitwise_and(image, image, mask=mask)

    return result

# given the filename of an image, this method returns the flattened lab values
def convertToLAB(filename):
    img = cv2.imread(filename)
    img = cv2.cvtColor(img, cv2.COLOR_BGR2RGB)
    img = np.float32(img)
    img *= 1./255
    Lab = cv2.cvtColor(img, cv2.COLOR_RGB2Lab)
    L, a, b = cv2.split(Lab)
    return (L.flatten(), a.flatten(), b.flatten())

# given the filename of an image, this method returns the flattened lab values
def convertToLABAndMask(filename):
    img = maskedImage(filename)
    
    # dislay the masked image
    plt.imshow(img)
    plt.show()
    img = np.float32(img)

    # convert masked image to lab and flatten image
    img *= 1./255
    Lab = cv2.cvtColor(img, cv2.COLOR_RGB2Lab)
    L, a, b = cv2.split(Lab)
    return (L.flatten(), a.flatten(), b.flatten())

# iterates through the image and quotient of the sum of the differents and the length
def total_difference(L1, a1, b1, L2, a2, b2):
    length = min(L1.shape[0], L2.shape[0])
    trueLength = 0
    diff = 0
    for i in range(length):
        # do not count black pixels 
        if L1[i] != 0.0 and a1[i]!=0.0 and b1[i]!=0.0:
            diff += CIEDE2000((L1[i], a1[i], b1[i]), (L2[i], a2[i], b2[i]))
            trueLength += 1
    return diff/trueLength


if __name__ == "__main__":

    # REPLACE THE NAME OF THE IMAGE
    filename = 'leafblast.png'


    LCC2 = 'LCC2.jpeg'
    LCC3 = 'LCC3.jpeg'
    LCC4 = 'LCC4.jpeg'
    LCC5 = 'LCC5.jpeg'

    L, a, b = convertToLABAndMask(filename)

    L_LCC2, a_LCC2, b_LCC2 = convertToLAB(LCC2)
    L_LCC3, a_LCC3, b_LCC3 = convertToLAB(LCC3)
    L_LCC4, a_LCC4, b_LCC4 = convertToLAB(LCC4)
    L_LCC5, a_LCC5, b_LCC5 = convertToLAB(LCC5)

    print()
    
    print('LCC2', total_difference(L, a, b, L_LCC2, a_LCC2, b_LCC2))
    print('LCC3', total_difference(L, a, b, L_LCC3, a_LCC3, b_LCC3))
    print('LCC4', total_difference(L, a, b, L_LCC4, a_LCC4, b_LCC4))
    print('LCC5', total_difference(L, a, b, L_LCC5, a_LCC5, b_LCC5))

    print()