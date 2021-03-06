% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/import_graph.R
\name{import_graph}
\alias{import_graph}
\title{Import a graph from various graph formats}
\usage{
import_graph(graph_file, file_type = NULL, graph_name = NULL,
  graph_time = NULL, graph_tz = NULL)
}
\arguments{
\item{graph_file}{a connection to a graph file.}

\item{file_type}{the type of file to be imported.
Options are: \code{graphml} (GraphML), \code{gml}
(GML), \code{sif} (SIF), \code{edges} (a .edges
file), and \code{mtx} (MatrixMarket format). If not
supplied, the function will infer the type by its
file extension.}

\item{graph_name}{an optional string for labeling
the graph object.}

\item{graph_time}{a date or date-time string
(required for insertion of graph into a graph series
of the type \code{temporal}).}

\item{graph_tz}{an optional value for the time zone
(\code{tz})
corresponding to the date or date-time string
supplied as a value to \code{graph_time}. If no time
zone is provided then it will be set to \code{GMT}.}
}
\value{
a graph object of class \code{dgr_graph}.
}
\description{
Import a variety of graphs from
different graph formats and create a graph object.
}
\examples{
\dontrun{
# Import a GraphML graph file
graphml_graph <-
  import_graph(
    system.file("examples/power_grid.graphml",
                package = "DiagrammeR"))

# Get a count of the graph's nodes
graphml_graph \%>\% node_count
#> [1] 4941

# Get a count of the graph's edges
graphml_graph \%>\% edge_count
#> [1] 6594

# Import an SIF graph file
sif_graph <-
  import_graph(
    system.file("examples/Human_Interactome.sif",
                package = "DiagrammeR"))

# Get a count of the graph's nodes
sif_graph \%>\% node_count
#> [1] 8347

# Get a count of the graph's edges
sif_graph \%>\% edge_count
#> [1] 61263

# Import a GML graph file
gml_graph <-
  import_graph(
    system.file("examples/karate.gml",
                package = "DiagrammeR"))

# Get a count of the graph's nodes
gml_graph \%>\% node_count
#> [1] 34

# Get a count of the graph's edges
gml_graph \%>\% edge_count
#> [1] 78
}
}

