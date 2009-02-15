.ppnCount <- function(m) {
    ## scale subsequent columns to be proportions of 
    ## first column
    m[,-1] <- m[,-1] / m[,1]
    m
}
.laneLbl <- function(lane) sub("s_(.*)_.*", "\\1", lane)
.plotReadQuality <- function(df) {
    df$lane <- .laneLbl(df$lane)
    xyplot(density~quality|lane, df,
           type="l",
           xlab="Average (calibrated) base quality",
           ylab="Proportion of reads",
           aspect=2)
}
.plotReadOccurrences <- function(df, ...) {
    df$lane <- .laneLbl(df$lane)
    df <- with(df, {
        nOccur <- tapply(nOccurrences, lane, c)
        cumulative <- tapply(nOccurrences*nReads, lane, function(elt) {
            cs <- cumsum(elt)
            (cs-cs[1] + 1) / diff(range(cs))
        })
        lane <- tapply(lane, lane, c)
        data.frame(nOccurrences=unlist(nOccur),
                   cumulative=unlist(cumulative),
                   lane=unlist(lane))
    })
    xyplot(cumulative~log10(nOccurrences)|factor(lane), df,
           xlab=expression(paste(
               "Number of occurrences of each read (",
               log[10], ")", sep="")),
           ylab="Cumulative proportion of reads",
           aspect=2, type="l", ...)
}
.freqSequences <- function(qa, read, n=20)
{
    cnt <- qa[["readCounts"]]
    df <- qa[["frequentSequences"]]
    df1 <- df[df$type==read,]
    df1[["ppn"]] <- df1[["count"]] / cnt[df1[["lane"]], read]
    head(df1[order(df1$count, decreasing=TRUE),
             c("sequence", "count", "lane")], n)
}
.plotAlignQuality <- function(df) {
    df$lane <- .laneLbl(df$lane)
    xyplot(count~score|lane, df,
           type="l",
           prepanel=function(x, y, ...) {
               list(ylim=c(0, 1))
           },
           panel=function(x, y, ...) {
               panel.xyplot(x, y/max(y), ...)
           },
           xlab="Alignment quality score",
           ylab="Number of alignments, relative to lane maximum",
           aspect=2)
}

.plotTileLocalCoords <- function(tile, nrow) {
    row <- 1 + (tile - 1) %% nrow
    col <- 1 + floor((tile -1) / nrow)
    row[col%%2==0] <- nrow + 1 - row[col%%2==0]
    list(row=as.integer(row), col=as.factor(col))
}

.atQuantile <- function(x, breaks)
{
    at <- unique(quantile(x, breaks))
    if (length(at)==1)
        at <- at * c(.9, 1.1)
    at
}

.colorkeyNames <- function(at, fmt) {
    paste(names(at), " (", sprintf(fmt, at), ")", sep="")
}

.plotTileCounts <- 
    function(df, nrow=if (max(df$tile)==100) 50 else 100)
{
    df <- df[!is.na(df$count),]
    xy <- .plotTileLocalCoords(df$tile, nrow)
    df[,names(xy)] <- xy
    at <- .atQuantile(df$count, seq(0, 1, .1))
    df$lane <- .laneLbl(df$lane)
    levelplot(cut(count, at)~col*row|lane, df,
              main="Read count (percentile rank)",
              xlab="Tile x-coordinate",
              ylab="Tile y-coordinate",
              cuts=length(at)-2,
              colorkey=list(
                labels=.colorkeyNames(at, "%d")),
              aspect=2)
}
.plotTileQualityScore <- 
    function(df, nrow=if (max(df$tile)==100) 50 else 100)
{
    df <- df[!is.na(df$score),]
    xy <- .plotTileLocalCoords(df$tile, nrow)
    df[,names(xy)] <- xy
    at <- .atQuantile(df$score, seq(0, 1, .1))
    df$lane <- .laneLbl(df$lane)
    levelplot(cut(score, at)~col*row|lane, df,
              main="Read quality (percentile rank)",
              xlab="Tile x-coordinate",
              ylab="Tile y-coordinate",
              cuts=length(at)-2,
              colorkey=list(
                labels=.colorkeyNames(at, "%.2f")),
              aspect=2)
}
.plotCycleBaseCall <- function(df) {
    col <- rep(c("red", "blue"), 2)
    lty <- rep(1:2, each=2)
    df <- df[df$Base != "N",]
    df$lane <- .laneLbl(df$lane)
    xyplot(log10(Count)~as.integer(Cycle)|lane, 
           group=factor(Base), 
           df[with(df, order(lane, Base, Cycle)),], 
           type="l", col=col, lty=lty,
           key=list(space="top", 
             lines=list(col=col, lty=lty),
             text=list(lab=as.character(unique(df$Base))),
             columns=length(unique(df$Base))),
           xlab="Cycle", 
           aspect=2)
}
.plotCycleQuality <- function(df) 
{
    qnum <- as(SFastqQuality(as.character(df$Quality)), "numeric")
    df$qtot <- qnum * df$Count

    aveScore <- with(df,
                     tapply(qtot, list(lane, Cycle), sum) /
                     tapply(Count, list(lane, Cycle), sum))
    score <- data.frame(AverageScore=as.vector(aveScore),
                        Cycle=as.vector(col(aveScore)),
                        Lane=.laneLbl(rownames(aveScore)))
    xyplot(AverageScore~Cycle | Lane, score,
           ylab="Average score",
           aspect=2)
}