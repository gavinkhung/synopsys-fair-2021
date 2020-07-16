"""
import fastai
from fastai.vision import *


path = Path('data/ricedisease')
classes = ['BLB','BrSpt','FlsSmt','Healthy','LfBst','SthBlt','ZnDf']

for c in classes:
    print(c)
    verify_images(path / c, delete=True, max_size=400)

np.random.seed(42)
src = (ImageList.from_folder(path).split_by_rand_pct(0.2).label_from_folder())

data=(src.transform(tfms=get_transforms(), size = 332).databunch(num_workers=4, bs = 64).normalize(imagenet_stats))


learn = cnn_learner(data, models.resnet50, metrics=error_rate)
learn.fit_one_cycle(4)
learn.save('stage-1')
"""