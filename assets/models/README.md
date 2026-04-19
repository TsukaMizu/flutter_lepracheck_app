# Model Assets

This directory is where the TFLite model binary is stored.

## Adding `model.tflite`

The model file is **not** committed to this repository because of its binary size (~3.11 MB).
Copy it here from the `lepracheck_cms` repository before building the app:

```bash
cp /path/to/lepracheck_cms/model.tflite assets/models/model.tflite
```

## Model Specifications

| Property      | Value                        |
|---------------|------------------------------|
| Input shape   | `[1, 64, 64, 3]`             |
| Input dtype   | `float32`, RGB normalised 0–1|
| Output shape  | `[1, 1]`                     |
| Output dtype  | `float32`, probability 0–1   |

## Classification Threshold

| Condition             | Label              |
|-----------------------|--------------------|
| output ≥ 0.5          | `tidak_indikasi`   |
| output  < 0.5         | `indikasi`         |
