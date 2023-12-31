library(optparse)

# CLI parsing
option_list <- list(
  make_option(c("-d", "--data"),
              type = "character",
              default = NULL,
              help = "state dataset file name",
              metavar = "character"),
  make_option(c("-o", "--out"),
              type = "character",
              default = "out.tab",
              help = "output file name [default = %default]",
              metavar = "character")
)

opt <- parse_args(OptionParser(option_list = option_list))

if (is.null(opt$data)){
  print_help(opt_parser)
  stop("At least one argument must be supplied (input file).n", call. = FALSE)
}

# Load data
df <- read.table(opt$data, header = FALSE, sep = "\t")
df <- df[, -c(1, 2, 3)]
colnames(df) <- c("locus_tag", "value")
# Force dots generated by bedtools to NAs and convert those to 0
df$value <- as.numeric(as.character(df$value))
df$value[is.na(df$value)] <- 0
#Export data
write.table(df, opt$out, quote = FALSE, row.names = FALSE, col.names = TRUE, sep = "\t")