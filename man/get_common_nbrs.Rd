% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_common_nbrs.R
\name{get_common_nbrs}
\alias{get_common_nbrs}
\title{Get all common neighbors between two or more nodes}
\usage{
get_common_nbrs(graph, nodes)
}
\arguments{
\item{graph}{a graph object of class
\code{dgr_graph} that is created using
\code{create_graph}.}

\item{nodes}{a vector of node ID values of length
at least 2.}
}
\value{
a vector of node ID values.
}
\description{
With two or more nodes, get the set of
common neighboring nodes.
}
\examples{
# Create a random, directed graph with 18 nodes
# and 22 edges
random_graph <-
  create_random_graph(
    n = 18,
    m = 22,
    directed = TRUE,
    fully_connected = TRUE,
    set_seed = 20)

# Find all common neighbor nodes for nodes
# `5` and `7` (there are no common neighbors)
random_graph \%>\% get_common_nbrs(c(5, 7))
#> [1] NA

# Find all neighbor nodes for nodes `9`
# and  `17`
random_graph \%>\% get_common_nbrs(c(9, 17))
#> [1] 1
}

