#' Apply colors based on node attribute values
#' @description Within a graph's internal node data
#' frame (ndf), use a categorical node attribute to
#' generate a new node attribute with color values.
#' @param graph a graph object of class
#' @param node_attr_from the name of the node attribute
#' column from which color values will be based.
#' @param node_attr_to the name of the new node
#' attribute to which the color values will be applied.
#' @param cut_points an optional vector of numerical
#' breaks for bucketizing continuous numerical values
#' available in a node attribute column.
#' @param alpha an optional alpha transparency value to
#' apply to the generated colors. Should be in
#' the range of \code{0} (completely transparent) to
#' \code{100} (completely opaque).
#' @param default_color a hexadecimal color value to
#' use for instances when the values do not fall into
#' the bucket ranges specified in the \code{cut_points}
#' vector.
#' @return a graph object of class
#' \code{dgr_graph}.
#' @examples
#' # Create a random graph of 50 nodes and 85 edges
#' graph <-
#'   create_random_graph(
#'     50, 85, set_seed = 1)
#'
#' # Find group membership values for all nodes
#' # in the graph through the Walktrap community
#' # finding algorithm and join those group values
#' # to the graph's internal node data frame (ndf)
#' # with the `join_node_attrs()` function
#' graph <-
#'   graph %>%
#'   join_node_attrs(get_cmty_walktrap(.))
#'
#' # Inspect the number of distinct communities
#' get_node_attrs(graph, "walktrap_group") %>%
#'   unique %>%
#'   sort
#' #> [1] 1 2 3 4 5 6 7 8 9
#'
#' # Visually distinguish the nodes in the different
#' # communities by applying colors using the
#' # `colorize_node_attrs()` function; specifically,
#' # set different `fillcolor` values with an alpha
#' # value of 90 and apply opaque colors to the node
#' # border (with the `color` node attribute)
#' graph <-
#'   graph %>%
#'   colorize_node_attrs(
#'     "walktrap_group", "fillcolor", alpha = 90) %>%
#'   colorize_node_attrs(
#'     "walktrap_group", "color") %>%
#'   set_node_attrs("fontcolor", "white") %>%
#'   set_global_graph_attrs(
#'     "graph", "layout", "circo")
#'
#' # Create a random graph of 10 nodes and 22 edges
#' graph <-
#'   create_random_graph(
#'     10, 22, set_seed = 1)
#'
#' # The `create_random_graph()` function automatically
#' # provides a node attribute `value` which has values
#' # in the range of 0 to 10.
#' get_node_df(graph)
#' #>    id type label value
#' #> 1   1          1     3
#' #> 2   2          2     4
#' #> 3   3          3     6
#' #> 4   4          4   9.5
#' #> 5   5          5   2.5
#' #> 6   6          6     9
#' #> 7   7          7   9.5
#' #> 8   8          8     7
#' #> 9   9          9   6.5
#' #> 10 10         10     1
#'
#' # We can bucketize values in `value` using
#' # `cut_points` and assign colors to each of the
#' # bucketed ranges (for values not part of any
#' # bucket, a gray color is assigned by default)
#' graph <-
#'   graph %>%
#'   colorize_node_attrs(
#'     "value", "fillcolor",
#'     cut_points = c(1, 3, 5, 7, 9))
#'
#' # Now there will be a `fillcolor` node attribute
#' # with distinct colors (the `#D9D9D9` color is
#' # the default `gray85` color)
#' get_node_df(graph)
#' #>    id type label value fillcolor
#' #> 1   1          1     3   #31688E
#' #> 2   2          2     4   #31688E
#' #> 3   3          3     6   #35B779
#' #> 4   4          4   9.5   #D9D9D9
#' #> 5   5          5   2.5   #440154
#' #> 6   6          6     9   #D9D9D9
#' #> 7   7          7   9.5   #D9D9D9
#' #> 8   8          8     7   #FDE725
#' #> 9   9          9   6.5   #35B779
#' #> 10 10         10     1   #440154
#' @import viridis
#' @export colorize_node_attrs

colorize_node_attrs <- function(graph,
                                node_attr_from,
                                node_attr_to,
                                cut_points = NULL,
                                alpha = NULL,
                                default_color = "#D9D9D9") {

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Extract ndf from graph
  nodes_df <- graph$nodes_df

  # Get the column number in the ndf from which to
  # recode values
  col_to_recode_no <-
    which(colnames(nodes_df) %in% node_attr_from)

  # Get the number of recoded values
  if (is.null(cut_points)) {
    num_recodings <-
      nrow(unique(nodes_df[col_to_recode_no]))
  } else if (!is.null(cut_points)) {
    num_recodings <- length(cut_points) - 1
  }

  # Create a data frame which initial values
  new_node_attr_col <-
    data.frame(
      node_attr_to = rep(default_color, nrow(nodes_df)),
      stringsAsFactors = FALSE)

  # Get the column number for the new node attribute
  to_node_attr_colnum <- ncol(nodes_df) + 1

  # Bind the current ndf with the new column
  nodes_df <- cbind(nodes_df, new_node_attr_col)

  # Rename the new column with the target node attr name
  colnames(nodes_df)[to_node_attr_colnum] <-
    node_attr_to

  # Get a data frame of recodings
  if (is.null(cut_points)) {
    viridis_df <-
      data.frame(
        to_recode = names(table(nodes_df[, col_to_recode_no])),
        colors = gsub("..$", "", viridis(num_recodings)),
        stringsAsFactors = FALSE)

    # Recode rows in the new node attribute
    for (i in seq_along(names(table(nodes_df[, col_to_recode_no])))) {

      recode_rows <-
        which(nodes_df[, col_to_recode_no] %in%
                viridis_df[i, 1])

      if (is.null(alpha)) {
        nodes_df[recode_rows, to_node_attr_colnum] <-
          gsub("..$", "", viridis(num_recodings)[i])
      } else if (!is.null(alpha)) {
        if (alpha < 100) {
          nodes_df[recode_rows, to_node_attr_colnum] <-
            gsub("..$", alpha, viridis(num_recodings)[i])
        } else if (alpha == 100) {
          nodes_df[recode_rows, to_node_attr_colnum] <-
            gsub("..$", "", viridis(num_recodings)[i])
        }
      }
    }
  }

  # Recode according to provided cut points
  if (!is.null(cut_points)) {
    for (i in 1:(length(cut_points) - 1)) {
      recode_rows <-
        which(
          as.numeric(nodes_df[,col_to_recode_no]) >=
            cut_points[i] &
            as.numeric(nodes_df[,col_to_recode_no]) <
            cut_points[i + 1])

      nodes_df[recode_rows, to_node_attr_colnum] <-
        gsub("..$", "", viridis(num_recodings)[i])
    }

    if (!is.null(alpha)) {
      if (alpha < 100) {
        nodes_df[, to_node_attr_colnum] <-
          gsub("..$", alpha,nodes_df[, to_node_attr_colnum])
      } else if (alpha == 100) {
        nodes_df[, to_node_attr_colnum] <-
          gsub("..$", "", nodes_df[, to_node_attr_colnum])
      }
    }
  }

  # Create the graph
  graph <-
    create_graph(
      nodes_df = nodes_df,
      edges_df = graph$edges_df,
      directed = graph$directed,
      graph_attrs = graph$graph_attrs,
      node_attrs = graph$node_attrs,
      edge_attrs = graph$edge_attrs,
      graph_name = graph$graph_name,
      graph_tz = graph$graph_tz,
      graph_time = graph$graph_time)

  # Update the `last_node` counter
  graph$last_node <- nodes_created

  return(graph)
}
