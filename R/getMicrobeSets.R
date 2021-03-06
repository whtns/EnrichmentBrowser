getMicrobeSets <- function(db = c("bugsigdb",
                                  "manalyst",
                                  "micropattern",
                                  "mdirectory"),
                           tax.id.type = c("ncbi", "metaphlan"))
{
    db <- match.arg(db)
    if(db == "bugsigdb") .getBugSigDB(tax.id.type)
}

.getBugSigDB <- function(id.type = c("ncbi", "metaphlan"))
{
    id.type <- match.arg(id.type)
    id.col <- ifelse(id.type == "ncbi",
                     "NCBI.Taxonomy.IDs",
                     "MetaPhlAn.taxon.names")
     
    s2pmid <- .study2pmid()
    einfo <- .getExpInfo()   

    sigs <- read.csv("https://bugsigdb.org/Special:Ask/-5B-5BCategory:Signatures-5D-5D/-3FOriginal-20page-20name%3DSignature-20page-20name/-3FRelated-20experiment%3DExperiment/-3FRelated-20study%3DStudy/-3FSource-20data%3DSource/-3FCurated-20date/-3FCurator/-3FRevision-20editor/-3FDescription/-3FAbundance-20in-20Group-201/-3FNCBI-20export%3DMetaPhlAn-20taxon-20names/-3FNCBI-20export-20ids%3DNCBI-20Taxonomy-20IDs/mainlabel%3D-2D/limit%3D5000/offset%3D0/format%3Dcsv/searchlabel%3DDownload-20all-20Signatures-20(CSV)/filename%3Dsignatures.csv")

    eid <- sub("^Experiment ", "", sigs[["Experiment"]])
    sid <- sub("^Study ", "", sigs[["Study"]])
    id <- paste(sid, eid, sep = "/")

    sgid <- sub("^Signature ", "", sigs[["Signature.page.name"]])
    up.down <- ifelse(sigs[["Abundance.in.Group.1"]] == "increased", "UP", "DOWN")
    titles <- paste(unname(einfo[id]), up.down, sep = "_")
    id <- paste(id, sgid, sep = "/")
    id <- paste("bsdb", id, sep = ":")
    sigs <- sigs[[id.col]]
    sigs <- strsplit(sigs, ",")
    names(sigs) <- paste(id, titles, sep = "_")
    sigs
}

.getExpInfo <- function()
{
    exps <- read.csv("https://bugsigdb.org/w/index.php?title=Special:Ask&x=-5B-5BCategory%3AExperiments-5D-5D%2F-3FOriginal-20page-20name%3DExperiment-20page-20name%2F-3FRelated-20study%3DStudy%2F-3FLocation-20of-20subjects%2F-3FHost-20species%2F-3FBody-20site%2F-3FCondition%2F-3FGroup-200-20name%2F-3FGroup-201-20name%2F-3FGroup-201-20definition%2F-3FGroup-200-20sample-20size%2F-3FGroup-201-20sample-20size%2F-3FAntibiotics-20exclusion%2F-3FSequencing-20type%2F-3F16s-20variable-20region%2F-3FSequencing-20platform%2F-3FStatistical-20test%2F-3FSignificance-20threshold%2F-3FMHT-20correction%2F-3FLDA-20Score-20above%2F-3FMatched-20on%2F-3FConfounders-20controlled-20for%2F-3FPielou%2F-3FShannon%2F-3FChao1%2F-3FSimpson%2F-3FInverse-20Simpson%2F-3FRichness&mainlabel=-&limit=5000&order=asc&sort=Page%20sort%20number&offset=0&format=csv&searchlabel=Download%20all%20Experiments%20%28CSV%29&filename=experiments.csv")
    
    is.study <- grepl("^Study [0-9]+$", exps[["Study"]])
    is.exp <- grepl("^Experiment [0-9]+$", exps[["Experiment.page.name"]])
    exps <- exps[is.study & is.exp,]    

    eid <- sub("^Experiment ", "", exps[["Experiment.page.name"]])
    sid <- sub("^Study ", "", exps[["Study"]])
    id <- paste(sid, eid, sep = "/")
    
    rel.cols <- c("Condition",
                  "Group.1.name",
                  "Group.0.name")        
    exps <- exps[,rel.cols]
    .conc <- function(x) paste(x[1], paste(x[2:3], collapse = "_vs_"), sep = ":")
    exp.str <- apply(exps, 1, .conc)
    exp.str <- gsub(" ", "-", exp.str)
    names(exp.str) <- id
    exp.str
}

.study2pmid <- function()
{
    studs <- read.csv("https://bugsigdb.org/Special:Ask/-5B-5BCategory:Studies-5D-5D/-3FStudy-20design/-3FPMID/-3FDOI/-3FURL/-3FAuthors/-3FTitle/-3FJournal/-3FYear/-3FAbstract/mainlabel%3DStudy-20page-20name/limit%3D5000/order%3Dasc/sort%3DPage-20sort-20number/offset%3D0/format%3Dcsv/searchlabel%3DDownload-20all-20Studies-20(CSV)/filename%3Dstudies.csv")

    s2pmid <- studs[["PMID"]]
    names(s2pmid) <- studs[["Study.page.name"]]
    s2pmid
}
 

