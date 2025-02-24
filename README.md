# Gene Feature Plot App

**An interactive Shiny app for visualizing gene expression from Seurat RDS objects.**  
Select genes, dimensionality reductions, and assays to generate customizable feature and dot plots for single-cell data analysis.

## Features

- Upload Seurat `.RDS` objects (up to 1GB).
- Select and visualize specific genes using feature and dot plots.
- Dynamically choose reductions (e.g., PCA, UMAP, t-SNE) and assays (e.g., RNA, ADT, ATAC) directly from the loaded object.
- Download high-resolution plots in TIFF format.
- Robust error handling for invalid gene names, missing reductions, and file issues.

## Requirements

- **R version** ≥ 4.0
- **R packages**:
  - `shiny`
  - `Seurat`
  - `cowplot`
  - `ggplot2`

Install required packages with:

```r
install.packages(c("shiny", "cowplot", "ggplot2"))
if (!requireNamespace("Seurat", quietly = TRUE)) {
  install.packages("Seurat")
}
```

## Usage

1. Clone the repository

```bash
git clone https://github.com/yourusername/gene-feature-plot-app.git
cd gene-feature-plot-app
```

2. Run the app in R

```r
library(shiny)
runApp()
```

3. Using the app: 
- Upload a Seurat .RDS object
- Select your desired reduction and assay
- Enter the gene name to visualize
- View and download the generated plots

## Contributing
Contributions are welcome! 

## License
This project is provided **as is**.  
Feel free to use and modify this code for **personal** or **educational** purposes.  
For **commercial use** or redistribution, please contact the author.
