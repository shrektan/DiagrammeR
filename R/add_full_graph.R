#' Add a fully connected graph
#' @description With a graph object of class
#' \code{dgr_graph}, add a fully connected graph either
#' with or without loops. If the graph object set as
#' directed, the added graph will have edges to and from
#' each pair of nodes. In the undirected case, a single
#' edge will link each pair of nodes.
#' @param graph a graph object of class
#' \code{dgr_graph} that is created using
#' \code{create_graph}.
#' @param n the number of nodes comprising the fully
#' connected graph.
#' @param type an optional string that describes the
#' entity type for the nodes to be added.
#' @param label either a vector object of length
#' \code{n} that provides optional labels for the new
#' nodes, or, a boolean value where setting to
#' \code{TRUE} ascribes node IDs to the label and
#' \code{FALSE} or \code{NULL} yields a blank label.
#' @param rel an optional string for providing a
#' relationship label to all new edges created in the
#' connected graph.
#' @param edge_wt_matrix an optional matrix of \code{n}
#' by \code{n} dimensions containing values to apply
#' as edge weights. If the matrix has row names or
#' column names and \code{label = TRUE}, those row or
#' column names will be used as node label values.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a new graph object and add a directed and
#' # fully connected graph with 3 nodes and edges to
#' # and from all pairs of nodes; with the option
#' # `keep_loops = TRUE` nodes will also have edges
#' # from and to themselves
#' graph <-
#'   create_graph() %>%
#'   add_full_graph(
#'     n = 3, keep_loops = TRUE)
#'
#' # Get node information from this graph
#' node_info(graph)
#' #>   id type label deg indeg outdeg loops
#' #> 1  1          1   6     3      3     1
#' #> 2  2          2   6     3      3     1
#' #> 3  3          3   6     3      3     1
#'
#' # Using `keep_loops = FALSE` (the default)
#' # will remove the loops
#' create_graph() %>%
#'   add_full_graph(3) %>%
#'   node_info
#' #>   id type label deg indeg outdeg loops
#' #> 1  1          1   4     2      2     0
#' #> 2  2          2   4     2      2     0
#' #> 3  3          3   4     2      2     0
#'
#' # Values can be set for the node `label`,
#' # node `type`, and edge `rel`
#' graph <-
#'   create_graph() %>%
#'   add_full_graph(
#'     n = 3,
#'     type = "connected",
#'     label = c("1st", "2nd", "3rd"),
#'     rel = "connected_to")
#'
#' # Show the graph's node data frame (ndf)
#' graph %>% get_node_df
#' #>   id      type label
#' #> 1  1 connected   1st
#' #> 2  2 connected   2nd
#' #> 3  3 connected   3rd
#'
#' # Show the graph's edge data frame (edf)
#' graph %>% get_edge_df
#' #>   from to          rel
#' #> 1    1  2 connected_to
#' #> 2    1  3 connected_to
#' #> 3    2  1 connected_to
#' #> 4    2  3 connected_to
#' #> 5    3  1 connected_to
#' #> 6    3  2 connected_to
#'
#' # Create a fully-connected and directed
#' # graph with 3 nodes, and, where a matrix
#' # provides edge weights; first, create the
#' # matrix (with row names to be used as
#' # node labels)
#' set.seed(23)
#'
#' edge_wt_matrix <-
#'   rnorm(100, 5, 2) %>%
#'   sample(9, FALSE) %>%
#'   round(2) %>%
#'   matrix(
#'     nc = 3, nr = 3,
#'     dimnames = list(c("a", "b", "c")))
#'
#' # Create the fully-connected graph (without
#' # loops however)
#' graph <-
#'   create_graph() %>%
#'   add_full_graph(
#'     n = 3,
#'     type = "weighted",
#'     label = TRUE,
#'     rel = "related_to",
#'     edge_wt_matrix = edge_wt_matrix,
#'     keep_loops = FALSE)
#'
#' # Show the graph's node data frame (ndf)
#' graph %>% get_node_df
#' #>   id     type label
#' #> 1  1 weighted     a
#' #> 2  2 weighted     b
#' #> 3  3 weighted     c
#'
#' # Show the graph's edge data frame (edf)
#' graph %>% get_edge_df
#' #>   from to        rel weight
#' #> 1    1  2 related_to    3.3
#' #> 2    1  3 related_to   5.02
#' #> 3    2  1 related_to   4.13
#' #> 4    2  3 related_to   6.49
#' #> 5    3  1 related_to   6.03
#' #> 6    3  2 related_to   5.55
#'
#' # An undirected graph can also use a
#' # matrix with edge weights, but only
#' # the lower triangle of that matrix
#' # will be used
#' create_graph(directed = FALSE) %>%
#'   add_full_graph(
#'     n = 3,
#'     type = "weighted",
#'     label = TRUE,
#'     rel = "related_to",
#'     edge_wt_matrix = edge_wt_matrix,
#'     keep_loops = FALSE) %>%
#'   get_edge_df
#' #>   from to        rel weight
#' #> 1    1  2 related_to    3.3
#' #> 2    1  3 related_to   5.02
#' #> 3    2  3 related_to   6.49
#' @export add_full_graph

add_full_graph <- function(graph,
                           n,
                           type = NULL,
                           label = TRUE,
                           rel = NULL,
                           edge_wt_matrix = NULL,
                           keep_loops = FALSE) {

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Create initial adjacency matrix based
  adj_matrix <- matrix(1, nc = n, nr = n)

  # Remove loops by making the diagonal of the
  # adjacency matrix all 0
  if (keep_loops == FALSE) {
    adj_matrix <-
      adj_matrix -
      diag(1, nrow = nrow(adj_matrix), ncol = ncol(adj_matrix))
  }

  if (is_graph_directed(graph)) {

    # Create a new directed graph based on the
    # adjacency matrix `adj_matrix`
    new_graph <-
      from_adj_matrix(adj_matrix, mode = "directed")

    # If a matrix of edge weights provided, apply those
    # to each of the edges in a row-major fashion
    if (!is.null(edge_wt_matrix)) {

      new_graph <-
        set_edge_attrs(
          new_graph,
          edge_attr = "weight",
          values = as.numeric(edge_wt_matrix)[
            which(as.numeric(adj_matrix) == 1)])
    }
  }

  if (is_graph_directed(graph) == FALSE) {

    new_graph <-
      from_adj_matrix(adj_matrix,
                      mode = "undirected")

    # If a matrix of edge weights provided, apply those
    # from the bottom triangle to each of the edges in a
    # row-major fashion
    if (!is.null(edge_wt_matrix)) {

      new_graph <-
        set_edge_attrs(
          new_graph,
          edge_attr = "weight",
          values = edge_wt_matrix[
            lower.tri(
              edge_wt_matrix,
              diag = ifelse(keep_loops == FALSE,
                            FALSE, TRUE))])
    }
  }

  # Add label values to nodes
  if (length(label) == 1) {
    if (label == TRUE) {
      new_graph$nodes_df[, 3] <- new_graph$nodes_df[, 1]
    }
  }

  if (length(label) == 1) {
    if (label == FALSE) {
      new_graph$nodes_df[, 3] <- new_graph$nodes_df[, 1]
    }
  }

  if (length(label) > 1) {
    if (length(label) == n) {
      new_graph$nodes_df[, 3] <- label
    }
  }

  if (length(label) == 1) {
    if (label == TRUE) {
      if (!is.null(edge_wt_matrix)) {

        if (!is.null(colnames(edge_wt_matrix))) {
          ewm_names <- colnames(edge_wt_matrix)
        }
        if (!is.null(rownames(edge_wt_matrix))) {
          ewm_names <- rownames(edge_wt_matrix)
        }

        if (length(ewm_names) == n) {
          new_graph$nodes_df[, 3] <- ewm_names
        }
      }
    }
  }

  # Add `type` values to all new nodes
  if (!is.null(type) &
      length(type) == 1) {
    new_graph$nodes_df[, 2] <- type
  }

  # Add `rel` values to all new edges
  if (!is.null(rel) &
      length(rel) == 1) {
    new_graph$edges_df[, 3] <- rel
  }

  # If the input graph is not empty, combine graphs
  # using the `combine_graphs()` function
  if (!is_graph_empty(graph)) {

    graph <- combine_graphs(graph, new_graph)

    # Update the `last_node` counter
    graph$last_node <- nodes_created + n

    return(graph)
  } else {
    return(new_graph)
  }
}
