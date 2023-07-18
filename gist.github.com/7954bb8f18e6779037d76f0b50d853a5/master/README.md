

```r
library(rbokeh)
library(shiny)
library(dplyr)
library(igraph)
library(threejs)
library(magrittr)
library(htmlwidgets)
library(htmltools)
library(readxl)

read_excel_allsheets <- function(filename) {
   sheets <- readxl::excel_sheets(filename)
x <- lapply(sheets[c(1:2)], function(X) readxl::read_excel(filename, sheet = X, skip=1, guess_max=5))
names(x) <- sheets[c(1:2)]
x
}

data <- read_excel_allsheets("~/Downloads/query1.xlsx")

graph <- data$Edges %>%
select(`Vertex 1`, `Vertex 2`) %>%
graph_from_data_frame(vertices = data$Vertices)

V(graph)$Size <-((V(graph)$Size - min(V(graph)$Size, na.rm = T)) / (max(V(graph)$Size, na.rm = T) - min(V(graph)$Size, na.rm=T)))
V(graph)$Size <-  round(V(graph)$Size + .2, 3)
V(graph)$color <- "#318CE7"
graphy_3d <- graphjs(graph,layout = layout_with_fr(graph, dim=3), vertex.size = V(graph)$Size, vertex.label = paste0("<b>", V(graph)$Name, "<b>"), vertex.color = V(graph)$color,edge.color="orange", bg = "#FFFFFF", font.main = "38px Sans-Serif")

print(graphy_3d)
```