% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/colorize_node_attrs.R
\name{colorize_node_attrs}
\alias{colorize_node_attrs}
\title{Apply colors based on node attribute values}
\usage{
colorize_node_attrs(graph, node_attr_from, node_attr_to, cut_points = NULL,
  alpha = NULL, default_color = "#D9D9D9")
}
\arguments{
\item{graph}{a graph object of class}

\item{node_attr_from}{the name of the node attribute
column from which color values will be based.}

\item{node_attr_to}{the name of the new node
attribute to which the color values will be applied.}

\item{cut_points}{an optional vector of numerical
breaks for bucketizing continuous numerical values
available in a node attribute column.}

\item{alpha}{an optional alpha transparency value to
apply to the generated colors. Should be in
the range of \code{0} (completely transparent) to
\code{100} (completely opaque).}

\item{default_color}{a hexadecimal color value to
use for instances when the values do not fall into
the bucket ranges specified in the \code{cut_points}
vector.}
}
\value{
a graph object of class
\code{dgr_graph}.
}
\description{
Within a graph's internal node data
frame (ndf), use a categorical node attribute to
generate a new node attribute with color values.
}
\examples{
# Create a random graph of 50 nodes and 85 edges
graph <-
  create_random_graph(
    50, 85, set_seed = 1)

# Find group membership values for all nodes
# in the graph through the Walktrap community
# finding algorithm and join those group values
# to the graph's internal node data frame (ndf)
# with the `join_node_attrs()` function
graph <-
  graph \%>\%
  join_node_attrs(get_cmty_walktrap(.))

# Inspect the number of distinct communities
get_node_attrs(graph, "walktrap_group") \%>\%
  unique \%>\%
  sort
#> [1] 1 2 3 4 5 6 7 8 9

# Visually distinguish the nodes in the different
# communities by applying colors using the
# `colorize_node_attrs()` function; specifically,
# set different `fillcolor` values with an alpha
# value of 90 and apply opaque colors to the node
# border (with the `color` node attribute)
graph <-
  graph \%>\%
  colorize_node_attrs(
    "walktrap_group", "fillcolor", alpha = 90) \%>\%
  colorize_node_attrs(
    "walktrap_group", "color") \%>\%
  set_node_attrs("fontcolor", "white") \%>\%
  set_global_graph_attrs(
    "graph", "layout", "circo")

# Create a random graph of 10 nodes and 22 edges
graph <-
  create_random_graph(
    10, 22, set_seed = 1)

# The `create_random_graph()` function automatically
# provides a node attribute `value` which has values
# in the range of 0 to 10.
get_node_df(graph)
#>    id type label value
#> 1   1          1     3
#> 2   2          2     4
#> 3   3          3     6
#> 4   4          4   9.5
#> 5   5          5   2.5
#> 6   6          6     9
#> 7   7          7   9.5
#> 8   8          8     7
#> 9   9          9   6.5
#> 10 10         10     1

# We can bucketize values in `value` using
# `cut_points` and assign colors to each of the
# bucketed ranges (for values not part of any
# bucket, a gray color is assigned by default)
graph <-
  graph \%>\%
  colorize_node_attrs(
    "value", "fillcolor",
    cut_points = c(1, 3, 5, 7, 9))

# Now there will be a `fillcolor` node attribute
# with distinct colors (the `#D9D9D9` color is
# the default `gray85` color)
get_node_df(graph)
#>    id type label value fillcolor
#> 1   1          1     3   #31688E
#> 2   2          2     4   #31688E
#> 3   3          3     6   #35B779
#> 4   4          4   9.5   #D9D9D9
#> 5   5          5   2.5   #440154
#> 6   6          6     9   #D9D9D9
#> 7   7          7   9.5   #D9D9D9
#> 8   8          8     7   #FDE725
#> 9   9          9   6.5   #35B779
#> 10 10         10     1   #440154
}

