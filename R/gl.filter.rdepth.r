#' Filter loci based on counts of sequence tags scored at a locus (read depth)
#'
#' SNP datasets generated by DArT report AvgCountRef and AvgCountSnp as counts of sequence tags for the reference and alternate alleles respectively.
#' These can be used to backcalculate Read Depth. Fragment presence/absence datasets as provided by DArT (SilicoDArT) provide Average Read Depth and 
#' Standard Deviation of Read Depth as stanard columns in their report.
#' 
#' Filtering on Read Depth using the companion script gl.filter.rdepth can be on the basis of loci with exceptionally low counts, 
#' or loci with exceptionally high counts.
#' 
#' @param x -- name of the genlight object containing the SNP or tag presence/absence data [required]
#' @param lower -- lower threshold value below which loci will be removed [default 5]
#' @param upper -- upper threshold value above which loci will be removed [default 50]
#' @param verbose -- verbosity: 0, silent or fatal errors; 1, begin and end; 2, progress log ; 3, progress and results summary; 5, full report [default 2, unless specified using gl.set.verbosity]
#' @return     Returns a genlight object retaining loci with a Read Depth in the range specified by the lower and upper threshold.
#' @export
#' @author Arthur Georges (Post to \url{https://groups.google.com/d/forum/dartr})
#' @examples
#' # SNP data
#'   gl.report.rdepth(testset.gl)
#'   result <- gl.filter.rdepth(testset.gl, lower=8, upper=50, verbose=3)
#' # Tag P/A data
#'   result <- gl.filter.rdepth(testset.gs, lower=8, upper=50)

gl.filter.rdepth <- function(x, lower=5, upper=50, verbose=NULL) {

# TRAP COMMAND, SET VERSION
  
  funname <- match.call()[[1]]
  build <- "Jacob"
  
# SET VERBOSITY
  
  if (is.null(verbose)){ 
    if(!is.null(x@other$verbose)){ 
      verbose <- x@other$verbose
    } else { 
      verbose <- 2
    }
  } 
  
  if (verbose < 0 | verbose > 5){
    cat(paste("  Warning: Parameter 'verbose' must be an integer between 0 [silent] and 5 [full report], set to 2\n"))
    verbose <- 2
  }
  
# FLAG SCRIPT START
  
  if (verbose >= 1){
    if(verbose==5){
      cat("Starting",funname,"[ Build =",build,"]\n")
    } else {
      cat("Starting",funname,"\n")
    }
  }
  
# STANDARD ERROR CHECKING
  
  if(class(x)!="genlight") {
    stop("Fatal Error: genlight object required!\n")
  }
  
  if (all(x@ploidy == 1)){
    cat("  Processing Presence/Absence (SilicoDArT) data\n")
  } else if (all(x@ploidy == 2)){
    if (verbose >= 2){cat("  Processing a SNP dataset\n")}
  } else {
    stop("Fatal Error: Ploidy must be universally 1 (fragment P/A data) or 2 (SNP data)!")
  }
  
# FUNCTION SPECIFIC ERROR CHECKING
    
# DO THE JOB
  
  n0 <- nLoc(x)
  #if (verbose > 2) {cat("Initial no. of loci =", n0, "\n")}
  
  if (all(x@ploidy == 1)){
    rdepth <- x@other$loc.metrics$AvgReadDepth
  } else if (all(x@ploidy == 2)){
    rdepth <- x@other$loc.metrics$rdepth
  } 

  # Remove SNP loci with rdepth < threshold
  
  if (verbose >= 2){cat("  Removing loci with rdepth <=",lower,"and >=",upper,"\n")}
  
  if (all(x@ploidy == 1)){
    index <- (x@other$loc.metrics["AvgReadDepth"]>=lower & x@other$loc.metrics["AvgReadDepth"]<= upper)
  } else if (all(x@ploidy == 2)){
    index <- (x@other$loc.metrics["rdepth"]>=lower & x@other$loc.metrics["rdepth"]<= upper)
  } 
  x2 <- x[, index]
  # Remove the corresponding records from the loci metadata
  x2@other$loc.metrics <- x@other$loc.metrics[index,]
  #if (verbose > 2) {cat ("  No. of loci deleted =", (n0-nLoc(x2)),"\n")}
    
  # REPORT A SUMMARY
  if (verbose > 2) {
    cat("\n  Summary of filtered dataset\n")
    cat("  Initial no. of loci =", n0, "\n")
    #cat(paste("  read depth >=",lower,"and read depth <=",upper,"\n"))
    cat ("  No. of loci deleted =", (n0-nLoc(x2)),"\n")
    cat(paste("  No. of loci retained:",nLoc(x2),"\n"))
    cat(paste("  No. of individuals:", nInd(x2),"\n"))
    cat(paste("  No. of populations: ", length(levels(factor(pop(x2)))),"\n\n"))
  }  
  
# ADD TO HISTORY
    nh <- length(x2@other$history)
    x2@other$history[[nh + 1]] <- match.call()  
    
# FLAG SCRIPT END

  if (verbose > 0) {
    cat("Completed:",funname,"\n")
  }

  return(x2)
  
}
