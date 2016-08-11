#' Convert a igraph graph to a DiagrammeR one
#' @description Convert an igraph graph to a DiagrammeR
#' graph object.
#' @param graph a igraph graph object.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a DiagrammeR graph object
#' dgr_graph_orig <-
#'   create_random_graph(
#'     36, 50, set_seed = 1,
#'     directed = TRUE)
#'
#' # Convert the DiagrammeR graph to an
#' # igraph object
#' ig_graph <- to_igraph(dgr_graph_orig)
#'
#' # Convert the igraph graph back to a
#' # DiagrammeR graph
#' dgr_graph_new <- from_igraph(ig_graph)
#' @importFrom igraph list.vertex.attributes list.edge.attributes get.vertex.attribute get.edge.attribute is_directed ends E
#' @export from_igraph

from_igraph <- function(igraph) {

  # Get vectors of all node and edge attributes
  node_attrs <- igraph::list.vertex.attributes(igraph)
  edge_attrs <- igraph::list.edge.attributes(igraph)

  # Generate a single-column ndf with node ID values
  nodes_df <-
    data.frame(
      nodes = igraph::get.vertex.attribute(igraph, "name"),
      stringsAsFactors = FALSE)

  # If the `type` attr exists, add that to the ndf
  if ("type" %in% node_attrs) {
    nodes_df <-
      cbind(
        nodes_df,
        data.frame(
          type = igraph::get.vertex.attribute(igraph, "type"),
          stringsAsFactors = FALSE))
  } else {
    nodes_df <-
      cbind(
        nodes_df,
        data.frame(
          type = rep("", nrow(nodes_df)),
          stringsAsFactors = FALSE))
  }

  # If the `label` attr exists, add that to the ndf
  if ("label" %in% node_attrs) {
    nodes_df <-
      cbind(
        nodes_df,
        data.frame(
          label = igraph::get.vertex.attribute(igraph, "label"),
          stringsAsFactors = FALSE))
  } else {
    nodes_df <-
      cbind(
        nodes_df,
        data.frame(
          label = rep("", nrow(nodes_df)),
          stringsAsFactors = FALSE))
  }

  # Determine if there are any extra node attrs
  extra_node_attrs <-
    setdiff(node_attrs, c("name", "type", "label"))

  # If there are extra node attrs, add to the ndf
  if (length(extra_node_attrs) > 0) {

    for (i in seq_along(extra_node_attrs)) {

      df_col <-
        data.frame(
          igraph::get.vertex.attribute(igraph, extra_node_attrs[i]),
          stringsAsFactors = FALSE)

      colnames(df_col) <- extra_node_attrs[i]

      nodes_df <-
        cbind(nodes_df, df_col)
    }
  }

  # Generate a 2 column edf with `to` and `from` values
  edges_df <-
    as.data.frame(igraph::ends(igraph, igraph::E(igraph)),
                  stringsAsFactors = FALSE)

  colnames(edges_df) <- c("from", "to")

  # If the `rel` attr exists, add that to the edf
  if ("rel" %in% edge_attrs) {
    edges_df <-
      cbind(
        edges_df,
        data.frame(
          rel = igraph::get.edge.attribute(igraph, "rel"),
          stringsAsFactors = FALSE))
  } else {
    edges_df <-
      cbind(
        edges_df,
        data.frame(
          rel = rep("", nrow(edges_df)),
          stringsAsFactors = FALSE))
  }

  # Determine if there are any extra edge attrs
  extra_edge_attrs <-
    setdiff(edge_attrs, "rel")

  # If there are extra edge attrs, add to the edf
  if (length(extra_edge_attrs) > 0) {

    for (i in seq_along(extra_edge_attrs)) {

      df_col <-
        data.frame(
          igraph::get.edge.attribute(igraph, extra_edge_attrs[i]),
          stringsAsFactors = FALSE)

      colnames(df_col) <- extra_edge_attrs[i]

      edges_df <-
        cbind(edges_df, df_col)
    }
  }

  # Create a DiagrammeR graph object
  dgr_graph <-
    create_graph(
      nodes_df = nodes_df,
      edges_df = edges_df,
      directed = igraph::is_directed(igraph))

  return(dgr_graph)
}