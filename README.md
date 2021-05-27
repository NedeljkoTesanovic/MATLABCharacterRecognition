# MATLABCharacterRecognition
A MATLAB Guide application for Optical Character Recognition using Euclidean distance metric no neural networks.
Allows users to load an image, crop it, remove noise via median and wiener filters,
improve sharpness and contrast, binarize it, add gaussian or impulse noise, and set up the OCR and ROI detection parameters.
All the steps leading to the resulting recognized text are visible in an easy to use iterative slideshow within the GUI itself.

Additional information and analysis in "Non-Neural OCR.pdf"

Tweaked for single-row licence plates and white characters.

TEMPLATES:
Templates should ideally be 20 pixels wide, 40 pixels high and binarized. They should be .png and named XY where
the X is the symbol on the template and Y the number of the template for that symbol. (A1.png, A2.png, A3.png, B1.png, 51.png etc)

Templates will be loaded only during the first read of an application run in order to save performance, so adding new templates should be done whilst the app is shutdown.
