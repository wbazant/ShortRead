\name{alphabetByCycle}

\alias{alphabetByCycle}
\alias{alphabetByCycle,BStringSet-method}

\title{Summarize nucleotide, amino acid, or quality scores by cycle}

\description{

  \code{alphabetByCycle} summarizes nucleotides, amino acid, or qualities
  by cycle, e.g., returning the number of occurrences of each nucleotide
  \code{A, T, G, C} across all reads from 36 cycles of a Solexa lane.

}
\usage{

alphabetByCycle(stringSet, alphabet, ...)

}

\arguments{

  \item{stringSet}{A R object representing the collection of reads,
    amino acid sequences, or quality scores, to be summarized.}

  \item{alphabet}{The alphabet (character vector of length 1 strings)
    from which the sequences in \code{stringSet} are composed. Methods
    often define an appropriate alphabet, so that the user does not have
    to provide one.}

  \item{...}{Additional arguments, perhaps used by methods defined on
    this generic.}

}

\details{

  The default method requires that \code{stringSet} extends the
  \code{\link[Biostrings:XStringSet-class]{XStringSet}} class of
  \pkg{Biostrings}.

  The following method is defined, in addition to methods described in
  class-specific documentation:
  \describe{

    \item{alphabetByCycle}{\code{signature(stringSet = "BStringSet")}:
      this method uses an alphabet spanning all ASCII characters, codes
      \code{1:255}. }

  }
}

\value{

  A matrix with number of rows equal to the length of \code{alphabet}
  and columns equal to the maximum width of reads or quality scores in
  the string set. Entries in the matrix are the number of times, over
  all reads of the set, that the corresponding letter of the alphabet
  (row) appeared at the specified cycle (column).

}

\seealso{

  The IUPAC alphabet in Biostrings.

  \url{http://www.bioperl.org/wiki/FASTQ_sequence_format} for the
  BioPerl definition of fastq.

  Solexa documentation `Data analysis - documentation : Pipeline output
  and visualisation'.

}

\author{Martin Morgan}

\examples{
showMethods("alphabetByCycle")

sp <- SolexaPath(system.file('extdata', package='ShortRead'))
rfq <- readFastq(analysisPath(sp), pattern="s_1_sequence.txt")
alphabetByCycle(sread(rfq))

abcq <- alphabetByCycle(quality(rfq))
dim(abcq)
## 'high' scores, first and last cycles
abcq[64:94,c(1:5, 32:36)]
}
\keyword{manip}
