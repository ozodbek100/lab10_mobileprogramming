# Lab 10: Teachable Machine Image Classifier

Pair: <Name 1>, <Name 2>
Date: 16 Nov 2026

## Part 1: Model
### Class list
1. Phone  2. Laptop  3. Coffee Mug  4. Pen  5. Water Bottle  6. Nothing (background)

### Questions
- What does the model say for an object in no class? How does the background class change that?
- Floating point vs Quantized (size, input type, what Dart must do):

## Part 2: Setup
- `assets/model/` vs `assets/`:
- Why `image` and `http` run in plain Dart tests but `tflite_flutter` and `image_picker` cannot:

## Part 3: Classifier
- How the classifier is shared (constructor injection / provider):
- What happens with /255 instead of /127.5 - 1, and why nothing crashes:
- Where the number of classes is written, and what to edit for a 7th class:

## Part 4: Screens
- Design credit: name, author, link, licence
- Two things changed or left out from the Figma design, and why:
- Model screen reads labels from the classifier or the file? Why:

## Part 5: Sources
- Two training-data reasons why camera and downloaded pictures score differently:
- classify time on my phone (Stopwatch) and what the user sees meanwhile:

### Evaluation table
| # | Source | Expected | Predicted | % | Correct? |
|---|--------|----------|-----------|---|----------|

Overall accuracy: correct / attempts =
Weakest class:

## Checkpoint questions
1. Trace one photo from shutter to percentage:
2. Three pubspec.yaml lines that would break the app, and the errors:
3. Why pre-processing must match training (two things):
4. 97 % shoe = mug, is that a bug? What a percentage means / does not mean:
5. What stays on the device and what leaves it, vs a cloud API: