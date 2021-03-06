low.spell.lengths <- function(flow.ts, quant = 0.1, threshold = NULL, ind.days = 5, ignore.zeros = F, ctf.threshold = 0.1, inter.spell = FALSE) {

    record.year <- strftime(flow.ts[["Date"]], format = "%Y")
    flow.ts <- data.frame(flow.ts, year = record.year)
    #make missing Q values 0 so that the correct start and end dates are returned.
   flow.ts[is.na(flow.ts[["Q"]]), "Q"] <- 0
    n.years <- nlevels(as.factor(record.year))


    if (!is.null(threshold)) {


        flow.threshold <- threshold
        # names(flow.threshold)<-NULL #normallyhide

    } else {


        if (ignore.zeros == T) {

            flow.threshold <- quantile(flow.ts[which(flow.ts[, "Q"] > ctf.threshold), "Q"], quant, na.rm = T)
            names(flow.threshold) <- NULL
        } else {
            flow.threshold <- quantile(flow.ts[, "Q"], quant, na.rm = T)
            names(flow.threshold) <- NULL
        }

    }





    low.flows <- ifelse(flow.ts[, "Q"] < flow.threshold, 1, 0)

    if (ind.days > 0) {

        low.flow.runs <- rle(low.flows)
        too.short <- which(low.flow.runs$lengths < ind.days & low.flow.runs$values == 0)
        spell.factor <- rep(seq_along(low.flow.runs$lengths), times = low.flow.runs$lengths)
        add.to.spell <- which(spell.factor %in% too.short)
        low.flows[add.to.spell] <- 1
    }


    low.flow.runs <- rle(low.flows)
    # low.flow.runs<-low.flow.runs[which(low.flow.runs$values==1)]

    good.low.flow.runs <- which(!is.na(low.flow.runs$values))
    flow.runs.values <- low.flow.runs$values[good.low.flow.runs]
    flow.runs.lengths <- low.flow.runs$lengths[good.low.flow.runs]
    spell.starts <- c(1, cumsum(head(flow.runs.lengths, -1)) + 1)
    spell.lengths <- data.frame(flow.runs.values, start.date = flow.ts[spell.starts, "Date"], spell.length = flow.runs.lengths)

    if (inter.spell == TRUE) {

        spell.lengths <- subset(spell.lengths, flow.runs.values == 0, select = names(spell.lengths) %in% c("start.date", "spell.length"))


    } else {
        spell.lengths <- subset(spell.lengths, flow.runs.values == 1, select = names(spell.lengths) %in% c("start.date", "spell.length"))

    }
    if (nrow(spell.lengths) == 0) {
        spell.lengths <- data.frame(start.date = NA, spell.length = NA)

    }

    return(spell.lengths)
}
