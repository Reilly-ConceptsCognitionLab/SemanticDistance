#' viz_monologue
#'
#' @name viz_monologue
#' @param dat a dataframe with semantic distance values in columns (CosDist_) labeled by 'row_id_postsplit'
#' @param interpolate T/F linear interpolation across missing observations of 'row_id_postsplit' (default is T)
#' @param roll_avg window for computing a rolling average for smoothing the data, default is 0 (no smoothing)
#' @param annotate T/F option for annotating large semantic distance jumps z>2.5 with a red vertical line
#' @param facet T/F facets the data by distance measure (CosDist_Glo vs. CosDist_SD15)
#' @return a dataframe
#' @importFrom dplyr group_by
#' @importFrom dplyr select
#' @importFrom dplyr ungroup
#' @importFrom dplyr filter
#' @importFrom dplyr rename
#' @importFrom ggplot2 facet_wrap
#' @importFrom ggplot2 geom_vline
#' @importFrom ggplot2 aes
#' @importFrom ggplot2 geom_line
#' @importFrom ggplot2 scale_color_manual
#' @importFrom ggplot2 labs
#' @importFrom ggplot2 coord_cartesian
#' @importFrom ggplot2 ggplot
#' @importFrom ggplot2 theme_minimal
#' @importFrom MetBrewer met.brewer
#' @importFrom tidyr pivot_longer
#' @importFrom zoo na.approx
#' @importFrom zoo rollmean
#' @export viz_monologue

viz_monologue <- function(dat, interpolate=TRUE, roll_avg=0, facet=TRUE, annotate=TRUE) {
  # Load required packages
  if (!requireNamespace("MetBrewer", quietly = TRUE)) {
    stop("Package 'MetBrewer' needed for this function to work. Please install it.")
  }

  # Select and reshape data
  dat <- dat %>% dplyr::select(id_row_postsplit, contains("CosDist_")) %>%
    tidyr::pivot_longer(
      cols = contains("CosDist_"),
      names_to = "Distance_Type",
      values_to = "Cos_Dist",
      names_prefix = "CosDist_") %>%
    dplyr::rename(word_order = id_row_postsplit) %>%
    dplyr::mutate(Distance_Type = factor(Distance_Type))  # Convert to factor for color mapping

  # Get number of unique Distance_Types
  n_types <- length(unique(dat$Distance_Type))

  # Get Degas color palette
  degas_pal <- MetBrewer::met.brewer("Degas", n = n_types)

  # Conditional interpolation across missing values
  if(interpolate) {
    dat <- dat %>%
      dplyr::group_by(Distance_Type) %>% dplyr::mutate(Cos_Dist = zoo::na.approx(Cos_Dist, na.rm = FALSE)) %>%
      dplyr::ungroup()
  }

  # Add z-scores within each Distance_Type group
  dat <- dat %>% dplyr::group_by(Distance_Type) %>%
    dplyr::mutate(z_CosDist = scale(Cos_Dist)) %>%
    dplyr::ungroup()

  # Add rolling average if requested
  if(roll_avg > 0) {
    dat <- dat %>% dplyr::group_by(Distance_Type) %>%
      dplyr::mutate(Cos_Dist = zoo::rollmean(Cos_Dist, k = roll_avg, fill = NA, align = "center"),
        z_CosDist = zoo::rollmean(z_CosDist, k = roll_avg, fill = NA, align = "center")) %>%
      dplyr::ungroup()
  }

  # Create the plot using the new column names and Degas palette
  p <- ggplot2::ggplot(dat, ggplot2::aes(x = word_order, y = Cos_Dist, color = Distance_Type)) +
    ggplot2::geom_line() +
    ggplot2::scale_color_manual(values = degas_pal) +  # Apply Degas palette
    ggplot2::coord_cartesian(ylim = c(0, 2)) +
    ggplot2::theme_minimal() +
    ggplot2::theme(legend.position = "none")  # This removes the legend

  # Add vertical red lines for significant z-scores if annotate=TRUE
  if(annotate) {
    # Get points where z_CosDist > 2.5
    sig_points <- dat %>% dplyr::filter(z_CosDist > 2.5)

    if(nrow(sig_points) > 0) {
      p <- p + ggplot2::geom_vline(data = sig_points,
                                   aes(xintercept = word_order),
                                   color = "red", linetype = "dashed", alpha = 0.5
      )
    }

    # Add labels
    p <- p + ggplot2::labs(title = "Cosine Distance Trajectories",
                           x = "Word Order", y = "Cosine Distance", color = "Distance Type"
    )
  }

  # Add faceting
  if(facet) {
    p <- p + ggplot2::facet_wrap(~Distance_Type, ncol=1)
  }

  return(p)
}
