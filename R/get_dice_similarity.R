#' Get Dice similarity coefficient scores
#' @description Get the Dice similiarity coefficient
#' scores for one or more nodes in a graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param nodes an optional vector of node IDs to
#' consider for Dice similarity scores. If notsupplied,
#' then similarity scores will be provided for every
#' pair of nodes in the graph.
#' @param direction using \code{all} (the default), the
#' function will ignore edge direction when
#' determining scores for neighboring nodes. With
#' \code{out} and \code{in}, edge direction for
#' neighboring nodes will be considered.
#' @param round_to the maximum number of decimal places
#' to retain for the Dice similarity coefficient
#' scores. The default value is \code{3}.
#' @return a matrix with Dice similiarity values
#' for each pair of nodes considered.
#' @examples
#' # Create a random graph
#' graph <-
#'   create_random_graph(
#'     10, 22, set_seed = 1)
#'
#' # Get the Dice similarity values for
#' # nodes `5`, `6`, and `7`
#' get_dice_similarity(graph, 5:7)
#' #>       5     6     7
#' #> 5 1.000 0.444 0.667
#' #> 6 0.444 1.000 0.444
#' #> 7 0.667 0.444 1.000
#' @importFrom igraph similarity V
#' @export get_dice_similarity

get_dice_similarity <- function(graph,
                                nodes = NULL,
                                direction = "all",
                                round_to = 3) {

  # Convert the graph to an igraph object
  ig_graph <- to_igraph(graph)

  if (is.null(nodes)) {
    ig_nodes <- V(ig_graph)
  }

  if (!is.null(nodes)) {

    # Stop function if nodes provided not in
    # the graph
    if (!all(as.character(nodes) %in%
             get_node_ids(graph))) {
      stop("One or more nodes provided not in graph.")
    }

    # Get an igraph representation of node ID values
    ig_nodes <- V(ig_graph)[nodes]
  }

  # Get the Dice similarity scores
  if (direction == "all") {
    d_sim_values <-
      as.matrix(
        igraph::similarity(
          ig_graph,
          vids = ig_nodes,
          mode = "all",
          method = "dice"))
  }

  if (direction == "out") {
    d_sim_values <-
      as.matrix(
        igraph::similarity(
          ig_graph,
          vids = ig_nodes,
          mode = "out",
          method = "dice"))
  }

  if (direction == "in") {
    d_sim_values <-
      as.matrix(
        igraph::similarity(
          ig_graph,
          vids = ig_nodes,
          mode = "in",
          method = "dice"))
  }

  if (is.null(nodes)) {
    row.names(d_sim_values) <- graph$nodes_df$nodes
    colnames(d_sim_values) <- graph$nodes_df$nodes
  }

  if (!is.null(nodes)) {
    row.names(d_sim_values) <- graph$nodes_df$nodes[nodes]
    colnames(d_sim_values) <- graph$nodes_df$nodes[nodes]
  }

  # Round all values in matrix to set SD
  d_sim_values <- round(d_sim_values, round_to)

  return(d_sim_values)
}
