import torch
import torchvision.transforms as T
from fastai.vision import *

class Prediction:
    def __init__(self):
        defaults.device = torch.device('cpu')
        # use "model/" for aws instance
        self.learn = load_learner(".")
        #self.classes = ['BLB', 'Brown Spot', 'Brown Spot Crop', 'False Smut', 'Healthy', 'Healthy Rice', 'Leaf Blast', 'Sheath Blight', 'ZnDf']
        self.classes = self.learn.data.classes
    
    def predict(self, pil_image, crop):
        img = Image(T.ToTensor()(pil_image))
        pred_class, pred_idx, outputs = self.learn.predict(img)
        return str(self.model_output(outputs, 0.5))
    
    def model_output(self, outputs, bound):
        labelled_preds = [i for i,p in enumerate(outputs) if p > bound]
        if not labelled_preds:
            return "This is not rice"
        greatest = int(max(labelled_preds))
        if outputs[greatest] < bound :
            return 'Image is unclear. Please try again'
        else:
            if self.classes[greatest] == 'Brown Spot Crop': 
                return 'Brown Spot'
            elif self.classes[greatest] == 'Healthy Rice':
                return 'Healthy'
            elif self.classes[greatest] == 'Natural Brown':
                return 'This is not rice'
            elif self.classes[greatest] == 'BrownGreen':
                return 'This is not rice'
            return self.classes[greatest]