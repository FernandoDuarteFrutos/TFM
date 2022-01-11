library(readr)
library(reshape2) #Para el uso de dcast()
library(ggplot2)
library(pheatmap)
library(DESeq2)
library(stringr) # Para usar scale_fill_discrete()
library(RColorBrewer)
library(gridExtra)
resistomas <- as.data.frame(read_delim("C:/Users/dfern/TFM/archivos_preprocesados/resistomas",
                         "\t", escape_double = FALSE, trim_ws = TRUE))
resistomas$`Drug Class` <- sub(";.*", "", resistomas$`Drug Class`)
resistomas$`Drug Class` <- gsub(" antibiotic","",resistomas$`Drug Class`)
resistomas$`AMR Gene Family` <- sub(";.*", "", resistomas$`AMR Gene Family`)
metadata <- as.data.frame(read_csv("C:/Users/dfern/TFM/R - copia/SraRunTable.txt"))
metadata$feature[metadata$feature=="Day 28"] <- "Día 28"
metadata$feature[metadata$feature=="Day 21"] <- "Día 21"
metadata$feature[metadata$feature=="Day 4"] <- "Día 4"
metadata$feature[metadata$feature=="Day 0"] <- "Día 0"
metadata$feature <- factor(metadata$feature, levels = c("Día 0", "Día 4", "Día 21", "Día 28"))
#Filtrar
library(dplyr)
df1 %>%
        resistomas(subj) %>%
        filter(!any(fixations==0))

# Crear tabla de abundancias
tabla_ARGs <- as.data.frame(dcast(resistomas, `AMR Gene Family`~Sample, value.var = "Relative abundance",sum)) # Se suman aquellos genes que se repiten en cada muestra
# Se quiere eliminar el título "sample" de la tabla
row.names(tabla_ARGs) <- tabla_ARGs$`AMR Gene Family`
mapa_calor <- tabla_ARGs[,-1]
row.names(metadata) <- metadata$Run
pheat_row_ano <- resistomas[,c(14,15)]
#Para la anotación no se necesitan valores que estén duplicados
unique(pheat_row_ano$`AMR Gene Family`)
pheat_row_ano <- pheat_row_ano[!duplicated(pheat_row_ano[,"AMR Gene Family"]),]
row.names(pheat_row_ano) <- pheat_row_ano$`AMR Gene Family`
pheat_row_ano <- pheat_row_ano[,-1, drop = FALSE]
names(pheat_row_ano)[1] <- "Clase"
pheat_col_ano <- metadata[,-1, drop =FALSE]
names(pheat_col_ano)[15] <- "Grupo"
pheatmap(scale(as.matrix(mapa_calor)), 
         annotation_col = pheat_col_ano[,15, drop = FALSE], 
         annotation_row = pheat_row_ano, cellwidth = 30, 
         cellheight = 10, cluster_cols = TRUE, 
         cluster_rows = TRUE)


# Abundance chart
barras_abundancia <- as.data.frame(dcast(resistomas, Sample~`Drug Class`, value.var = "Relative abundance",sum))
barras_abundancia <- melt(barras_abundancia, id.vars = "Sample", variable.name = "Drug Class")
names(metadata)[1] <- "Sample"
barras_abundancia <- merge(barras_abundancia, metadata[,c(1,16)], by="Sample")
mean.df <- as.data.frame(aggregate(value ~ `Drug Class` + feature, barras_abundancia, (function(x) c(mean = mean(x), sd = sd(x)))))
mean.df <- do.call(data.frame, mean.df)
names(mean.df)[3] <- "Mean"
names(mean.df)[4] <- "SD"
barras_abundancia_mean_sd <- merge(barras_abundancia, mean.df)
barras_abundancia_mean_sd <- barras_abundancia_mean_sd[,-c(2,3,4)]

cols <- colorRampPalette(brewer.pal(12, "Paired"))
myPal <- cols(length(unique(barras_abundancia_mean_sd$Drug.Class)))

plot1 <- ggplot(barras_abundancia_mean_sd, aes(x = feature, y = Mean, fill = Drug.Class)) + 
         labs(tag = "A") +
         ylab("Proporción de abundancia") + xlab("") +
         geom_bar(stat = "identity", position= "fill") + 
         guides(fill=guide_legend(title="Clase")) +
         scale_fill_manual(values = myPal) +
         theme(legend.title = element_text(face='bold'), axis.title = element_text(face='bold'),
               plot.margin = unit(c(1,3.5,1,1), "cm"))
plot2 <- ggplot(barras_abundancia_mean_sd, aes(x = feature, y = Mean, fill = Drug.Class)) +
         labs(tag = "B") +
         ylab("Abundancia relativa") + xlab("") +
         geom_bar(stat = "identity", width = 0.5) + 
         guides(fill=guide_legend(title="Clase")) +
         scale_fill_manual(values = myPal) +
         theme(legend.title = element_text(face='bold'), axis.title = element_text(face='bold'),
               plot.margin = unit(c(1,1,1,0), "cm"))

grid.arrange(plot1, plot2, ncol = 1, nrow = 2)



#Estadística
#Preparamos los datos con los counts deseq2
deseq_table <- as.data.frame(dcast(resistomas, `ARO Name`~Sample, value.var = "Counts",sum)) # Se suman aquellos genes que se repiten en cada muestra
head(deseq_table)
colnames(deseq_table)
dds <- DESeqDataSetFromMatrix(countData=deseq_table, 
                              colData=metadata[,c(1,16)], 
                              design=~feature, tidy = TRUE)
dds
keep <- rowSums(counts(dds)) >= 10
dds <- dds[keep,]
dds
dds<-estimateSizeFactors(dds) #Evitar mensaje "every gene contains at least one zero, cannot compute log geometric means"
dds <- DESeq(dds)
#Tidy true para quitar cabecera
res <- results(dds, contrast = c("feature", "Día 28", "Día 0"))
#Null hypothesis that there is no effect of the treatment on the gene
#and that the observed difference between treatment and control was merely caused by experimental
#variability
sum(res$padj < 0.1, na.rm=TRUE)
summary(res)
res_clean <- results(dds, contrast = c("feature", "Día 28", "Día 0"), tidy = TRUE)
length(res_clean$row)
head(res_clean)
#Vemos que genes están sobrerrepresentado e infrarepresentados
resSig <- res_clean[ which(res_clean$padj < 0.1 ), ]
head(resSig[order(resSig$log2FoldChange), ], 20)
tail(resSig[order(resSig$log2FoldChange), ], 10)

vsdata <- varianceStabilizingTransformation(dds, blind=FALSE)
plotPCA(vsdata, intgroup="feature") + labs(colour="Grupo") + theme(legend.title = element_text(face='bold'), axis.title = element_text(face='bold'))



