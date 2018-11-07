import cv2
import numpy as np
import matplotlib.pyplot as plt

import time
import random
import pdb
# pdb.set_trace()

# def findMatches(feats1,feats2):
# 	pts2 = np.array([feat.pt for feat in feats2]).astype(int)
# 	match = np.zeros(len(feats1))
# 	for i,feat in enumerate(feats1):
# 		dists = np.array(feat.pt) - pts2
# 		match[i] = np.argmin(np.linalg.norm(dists, axis=1))
# 	# nearest = pts2[match]
# 	return match.astype(int)

scale = 4

webcam = cv2.VideoCapture(0)
webcamWindowName = "type ' ' to snap a picture"
cv2.namedWindow(webcamWindowName)
cv2.moveWindow(webcamWindowName, 20, 20)

stationaryPoint = np.array([1280/2, 720/2])

th = 11
FASTobj = cv2.FastFeatureDetector_create()
FASTobj.setThreshold(10)
sift = cv2.ORB_create()

ret, img = webcam.read();
newsize = (int(img.shape[1]/scale),int(img.shape[0]/scale))
img = cv2.resize(img,newsize)
feats = FASTobj.detect(img , None)
feats, desc = sift.compute(img, feats)
LPFavgVec = np.array([0,0])

matcher = cv2.BFMatcher()

def scaleUpFeats(feats,scale=4):
	for feat in feats:
		feat.pt = (feat.pt[0]*scale, feat.pt[1]*scale)
def fixTuple(tup):
	return tuple([int(i) for i in tup])
def mapFromTo(from1,from2,to1,to2,x):
	return (x-from1)/(from2-from1) * (to2-to1) + to1

def mouseClick(event,x,y,flags,param):
	global stationaryPoint
	if event == cv2.EVENT_LBUTTONUP:
		stationaryPoint = np.array([x,y])

cv2.setMouseCallback(webcamWindowName, mouseClick)

while (cv2.waitKey(1) != ord(' ')):
	prevImg = img
	prevFeats = feats
	prevDesc = desc

	ret, bigimg = webcam.read()
	# bigimg = cv2.fastNlMeansDenoisingColored(bigimg, None, 10,10,3,3)

	bigimg = cv2.flip(bigimg,flipCode=1)
	img = cv2.resize(bigimg,newsize)
	feats = FASTobj.detect(img , None)
	feats, desc = sift.compute(img, feats)
	try:
		scaleUpFeats(feats, scale=4)
	except:
		print("scale error")

	if (len(feats)>0 and len(prevFeats)>0):
		matches = matcher.knnMatch(prevDesc, desc, k=2)
		try:
			good = []
			for m,n in matches:
				if m.distance < .75*n.distance and m.distance<20:
					good.append(m)
			# matches = findMatches(prevFeats, feats)

			# imFeat = cv2.drawMatches(prevImg, prevFeats, img, feats, good, img)
			# imFeat = cv2.drawMatches(prevImg, prevFeats, img, feats, good, img, flags=0)

			# pdb.pm()
			# pdb.set_trace()

			dirVects = []
			keyToDraw = []
			for match in good:
				pt1 = np.array([int(x) for x in prevFeats[match.queryIdx].pt])
				pt2 = np.array([int(x) for x in feats[match.trainIdx].pt])
				dirVec = np.array([pt2[0]-pt1[0],pt2[1]-pt1[1]])
				if np.linalg.norm(dirVec)>-1:
					dirVects.append(dirVec)
					keyToDraw.append(pt2)

			print(len(good),len(dirVects))

			if len(dirVects)>1:
				avgVec = np.mean(np.array(dirVects),axis=0)
			elif len(dirVects)==1:
				avgVec = np.array(dirVects[0])
			else:
				avgVec = np.array([0,0])

			# smooth motion of avgVec
			alpha = mapFromTo(0,1,.05,.75,1-np.exp(-len(dirVects)/50))
			if len(dirVects)==0:
				alpha = .5
			LPFavgVec = (1-alpha)*LPFavgVec + alpha*avgVec

			stationaryPoint = stationaryPoint + avgVec

			assert(len(avgVec)==2)
			startPt = np.array([1280/2,720/2])
			endPt = startPt+np.fix(LPFavgVec*10)

			imFeat = bigimg
			for vec in dirVects: # shoot i screwed this up
				# imFeat = cv2.arrowedLine(imFeat, pt1, pt2, (0,0,255))
				pass
			for pt in keyToDraw:
				imFeat = cv2.circle(imFeat, fixTuple(pt),3,(255,100,100),thickness=-1)
			# imFeat = cv2.drawKeypoints(imFeat, prevFeats, None, color=(100,0,0))
			# imFeat = cv2.drawKeypoints(imFeat, feats, None, color=(255,0,0))
			imFeat = cv2.arrowedLine(imFeat,fixTuple(startPt),fixTuple(endPt),(0,0,255))
			if len(dirVects)>1:
				imFeat = cv2.circle(imFeat, fixTuple(stationaryPoint), 15, (0,255,0),thickness=-1)
			else:
				imFeat = cv2.circle(imFeat, fixTuple(stationaryPoint), 15, (0,0,255),thickness=-1)
			cv2.imshow(webcamWindowName , imFeat)

			imVects = np.ones((500,500))*255
			imVects = cv2.line(imVects, (0,250), (500,250), (0,0,0))
			imVects = cv2.line(imVects, (250,0), (250,500), (0,0,0))
			for vec in dirVects:
				imVects = cv2.circle(imVects, fixTuple(4*(vec+np.array([random.random(),random.random()])*1.5-.75)+[250,250]), 1, (0,0,0), -1)
			cv2.imshow("vects", imVects)
		except ValueError:
			print('value error')
			pass
		except AssertionError:
			print('assertion error')
			pass

# print(feats)

# plt.plot()
# plt.subplot(211)
# plt.imshow(img)
# plt.subplot(212)
# plt.imshow(imFeat)
# plt.show()

# cv2.imshow(webcamWindowName, imFeat)

# cv2.waitKey(0)

cv2.destroyAllWindows()