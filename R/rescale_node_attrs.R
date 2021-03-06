#' Rescale numeric node attribute values
#' @description From a graph object of class
#' \code{dgr_graph}, take a set of numeric values for a
#' node attribute, rescale to a new numeric or color
#' range, then write to the same node attribute or to
#' a new node attribute column.
#' @param graph a graph object of class
#' \code{dgr_graph} that is created using
#' \code{create_graph}.
#' @param node_attr_from the node attribute containing
#' numeric data that is to be rescaled to new numeric
#' or color values.
#' @param to_lower_bound the lower bound value for the
#' set of rescaled values. This can be a numeric value
#' or an X11 color name.
#' @param to_upper_bound the upper bound value for the
#' set of rescaled values. This can be a numeric value
#' or an X11 color name.
#' @param node_attr_to an optional name of a new node
#' attribute to which the recoded values will be
#' applied. This will retain the original node
#' attribute and its values.
#' @param from_lower_bound an optional, manually set
#' lower bound value for the rescaled values. If not
#' set, the minimum value from the set will be used.
#' @param from_upper_bound an optional, manually set
#' upper bound value for the rescaled values. If not
#' set, the minimum value from the set will be used.
#' @return a graph object of class \code{dgr_graph}.
#' @import scales
#' @importFrom grDevices colors
#' @examples
#' # Create a random graph
#' graph <-
#'   create_random_graph(
#'     5, 10, set_seed = 3,
#'     directed = TRUE)
#'
#' # Get the graph's internal ndf to show which
#' # node attributes are available
#' get_node_df(graph)
#' #>   id type label value
#' #> 1  1          1     2
#' #> 2  2          2   8.5
#' #> 3  3          3     4
#' #> 4  4          4   3.5
#' #> 5  5          5   6.5
#'
#' # Rescale the `value` node attribute, so that
#' # its values are rescaled between 0 and 1
#' graph <-
#'   graph %>%
#'   rescale_node_attrs("value")
#'
#' # Get the graph's internal ndf to show that the
#' # node attribute values had been rescaled
#' get_node_df(graph)
#' #>   id type label value
#' #> 1  1          1 0.000
#' #> 2  2          2 1.000
#' #> 3  3          3 0.308
#' #> 4  4          4 0.231
#' #> 5  5          5 0.692
#'
#' # Scale the values in the `value` node attribute
#' # to different shades of gray for the `fillcolor`
#' # and `fontcolor` node attributes
#' graph <-
#'   graph %>%
#'   rescale_node_attrs(
#'     "value", "gray80", "gray20", "fillcolor") %>%
#'   rescale_node_attrs(
#'     "value", "gray5", "gray95", "fontcolor")
#'
#' # Get the graph's internal ndf once more to show
#' # that scaled grayscale colors are now available in
#' # the `fillcolor` and `fontcolor` node attributes
#' get_node_df(graph)
#' #>   id type label value fillcolor fontcolor
#' #> 1  1          1 0.000   #CCCCCC   #0D0D0D
#' #> 2  2          2 1.000   #333333   #F2F2F2
#' #> 3  3          3 0.308   #999999   #4B4B4B
#' #> 4  4          4 0.231   #A6A6A6   #3B3B3B
#' #> 5  5          5 0.692   #5E5E5E   #A4A4A4
#' @export rescale_node_attrs

rescale_node_attrs <- function(graph,
                               node_attr_from,
                               to_lower_bound = 0,
                               to_upper_bound = 1,
                               node_attr_to = NULL,
                               from_lower_bound = NULL,
                               from_upper_bound = NULL) {

  # Get the number of nodes ever created for
  # this graph
  nodes_created <- graph$last_node

  # Extract the graph's ndf
  nodes <- get_node_df(graph)

  # Get column names from the graph's ndf
  column_names_graph <- colnames(nodes)

  # Stop function if `node_attr_from` is not one
  # of the graph's node attributes
  if (!any(column_names_graph %in% node_attr_from)) {
    stop("The node attribute to rescale is not in the ndf.")
  }

  # Get the column number for the node attr to rescale
  col_num_rescale <-
    which(colnames(nodes) %in% node_attr_from)

  # Extract the vector to rescale from the `nodes` df
  vector_to_rescale <- as.numeric(nodes[, col_num_rescale])

  if ((!is.null(from_lower_bound) &
       is.null(from_upper_bound)) |
      (is.null(from_lower_bound) &
       !is.null(from_upper_bound)) |
      (is.null(from_lower_bound) &
       is.null(from_upper_bound))) {

    from <- range(vector_to_rescale,
                  na.rm = TRUE, finite = TRUE)
  } else {
    from <- c(from_lower_bound, from_upper_bound)
  }

  # Get vector of rescaled, numeric node
  # attribute values
  if (is.numeric(to_lower_bound) &
      is.numeric(to_upper_bound)) {

    nodes_attr_vector_rescaled <-
      round(
        rescale(
          x = vector_to_rescale,
          to = c(to_lower_bound,
                 to_upper_bound),
          from = from),
        3)
  }

  # Get vector of rescaled, node attribute color values
  if ((to_lower_bound %in% colors()) &
      (to_upper_bound %in% colors())) {

    nodes_attr_vector_rescaled <-
      cscale(
        x = vector_to_rescale,
        palette = seq_gradient_pal(to_lower_bound,
                                   to_upper_bound))
  }

  # If a new node attribute name was not provided,
  # overwrite the source node attribute with the
  # rescaled values
  if (is.null(node_attr_to)) {
    node_attr_to <- node_attr_from
  }

  # Set the node attribute values for nodes specified
  # in selection
  graph <-
    set_node_attrs(
      x = graph,
      node_attr = node_attr_to,
      values = nodes_attr_vector_rescaled)

  # Update the `last_node` counter
  graph$last_node <- nodes_created

  return(graph)
}
